from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.conf import settings
from django.db.models import Q
from django.utils import timezone
from datetime import timedelta
import json
import re
import secrets
from urllib import error as urllib_error
from urllib import request as urllib_request

try:
	from google.auth.transport import requests as google_requests
	from google.oauth2 import id_token as google_id_token
	GOOGLE_AUTH_AVAILABLE = True
except Exception:
	GOOGLE_AUTH_AVAILABLE = False
from .models import (
	aichat,
	aichatmessage,
	community,
	communitymessage,
	communitymessagepoll,
	communitymessagepolloption,
	communitymessagepollvote,
	directchat,
	directmessage,
	directmessagepoll,
	directmessagepolloption,
	directmessagepollvote,
	friendrequest,
	user,
	oauthverificationcode,
)
from .serializers import (
	aiChatMessageSerializer,
	aiChatSerializer,
	communitySerializer,
	communityMessagePollOptionSerializer,
	communityMessagePollSerializer,
	communityMessagePollVoteSerializer,
	communityMessageSerializer,
	directChatSerializer,
	directMessageSerializer,
	directMessagePollOptionSerializer,
	directMessagePollSerializer,
	directMessagePollVoteSerializer,
	friendRequestSerializer,
	userSerializer,
)

# Create your views here.


GEMINI_API_KEY = "AIzaSyDJwEcS7UP0FusxUJWnfHQDEJoq7EYwktg"
GEMINI_MODEL = "gemini-2.5-flash"
GEMINI_GENERATE_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"
AI_CHAT_HISTORY_LIMIT = 24
COMMUNITY_CHAT_HISTORY_LIMIT = 30
MAX_ALL_USERS_FOR_CONTEXT = 40
MAX_ALL_COMMUNITIES_FOR_CONTEXT = 40
MAX_TEXT_CHARS_FOR_CONTEXT = 280


def _safe_file_url(file_field):
	if not file_field:
		return None
	try:
		return file_field.url
	except Exception:
		return str(file_field)


def _clip_text(text_value, max_length=MAX_TEXT_CHARS_FOR_CONTEXT):
	text = str(text_value or "").strip()
	if len(text) <= max_length:
		return text
	return f"{text[:max_length]}..."


def _serialize_user_for_ai(user_obj, compact=False):
	if user_obj is None:
		return None

	interests = [
		interest for interest in [user_obj.intrest1, user_obj.intrest2, user_obj.intrest3, user_obj.intrest4] if interest
	]

	if compact:
		return {
			"id": user_obj.id,
			"name": user_obj.name,
			"location": user_obj.location,
			"level": user_obj.level,
			"interests": interests,
		}

	return {
		"id": user_obj.id,
		"name": user_obj.name,
		"email": user_obj.email,
		"gender": user_obj.gender,
		"birthday": user_obj.birthday.isoformat() if user_obj.birthday else None,
		"location": user_obj.location,
		"intrest1": user_obj.intrest1,
		"intrest2": user_obj.intrest2,
		"intrest3": user_obj.intrest3,
		"intrest4": user_obj.intrest4,
		"diamonds": user_obj.diamonds,
		"level": user_obj.level,
	}


def _serialize_community_for_ai(community_obj, include_members=False, include_history=False, compact=False):
	if community_obj is None:
		return None

	if compact:
		return {
			"id": community_obj.id,
			"name": community_obj.name,
			"description": _clip_text(community_obj.description, 140),
			"maxParticipants": community_obj.maxParticipants,
			"totalParticipants": community_obj.totalParticipants,
		}

	data = {
		"id": community_obj.id,
		"name": community_obj.name,
		"description": _clip_text(community_obj.description, 240),
		"maxParticipants": community_obj.maxParticipants,
		"totalParticipants": community_obj.totalParticipants,
		"created_at": community_obj.created_at.isoformat() if community_obj.created_at else None,
	}

	if include_members:
		data["members"] = [
			_serialize_user_for_ai(member, compact=True)
			for member in community_obj.members.all().order_by("id")
		]

	if include_history:
		recent_messages = list(
			community_obj.messages.select_related("sender").order_by("-created_at")[:COMMUNITY_CHAT_HISTORY_LIMIT]
		)
		data["recent_messages"] = [
			_serialize_community_message_for_ai(message_obj)
			for message_obj in recent_messages[::-1]
		]

	return data


def _serialize_ai_chat_message_for_ai(message_obj):
	if message_obj is None:
		return None

	return {
		"id": message_obj.id,
		"sender_id": message_obj.sender_id,
		"sender_name": message_obj.sender.name if message_obj.sender else "AI",
		"isFromAI": message_obj.isFromAI,
		"text": message_obj.text,
		"image": _safe_file_url(message_obj.image),
		"video": _safe_file_url(message_obj.video),
		"voiceRecording": _safe_file_url(message_obj.voiceRecording),
		"created_at": message_obj.created_at.isoformat() if message_obj.created_at else None,
	}


def _serialize_community_message_for_ai(message_obj):
	if message_obj is None:
		return None

	return {
		"id": message_obj.id,
		"sender_id": message_obj.sender_id,
		"sender_name": message_obj.sender.name if message_obj.sender else None,
		"text": _clip_text(message_obj.text),
		"has_image": bool(message_obj.image),
		"has_video": bool(message_obj.video),
		"has_voice": bool(message_obj.voiceRecording),
		"hasPoll": message_obj.hasPoll,
		"created_at": message_obj.created_at.isoformat() if message_obj.created_at else None,
	}


def _latest_user_prompt_text(chat_obj):
	latest_user_message = chat_obj.messages.filter(isFromAI=False).order_by("-created_at").first()
	if latest_user_message is None or not latest_user_message.text:
		return ""
	return latest_user_message.text.strip().lower()


def _contains_any_keyword(text_value, keywords):
	if not text_value:
		return False
	return any(keyword in text_value for keyword in keywords)


def _build_context_loading_plan(chat_obj):
	chat_mode = (
		"solo"
		if not chat_obj.context_user_id and not chat_obj.context_community_id
		else "direct_context"
		if chat_obj.context_user_id
		else "community_context"
	)

	latest_prompt = _latest_user_prompt_text(chat_obj)

	user_keywords = [
		"user",
		"friend",
		"friends",
		"profile",
		"email",
		"birthday",
		"location",
		"level",
		"diamonds",
	]
	community_keywords = [
		"community",
		"communities",
		"participant",
		"participants",
		"member",
		"members",
	]
	history_keywords = [
		"history",
		"chat history",
		"messages",
		"what happened",
		"previous",
		"earlier",
	]

	needs_user_directory = _contains_any_keyword(latest_prompt, user_keywords)
	needs_community_focus = _contains_any_keyword(latest_prompt, community_keywords)
	needs_history = _contains_any_keyword(latest_prompt, history_keywords)

	return {
		"chat_mode": chat_mode,
		"include_all_users": needs_user_directory,
		"include_all_communities": needs_community_focus or chat_mode == "community_context",
		"include_context_community_members": chat_mode == "community_context" and (needs_community_focus or needs_user_directory),
		"include_context_community_history": chat_mode == "community_context" and needs_history,
	}


def _build_ai_knowledge_base(chat_obj, loading_plan):
	main_user = chat_obj.main_user
	context_user = chat_obj.context_user if chat_obj.context_user_id else None
	context_community = chat_obj.context_community if chat_obj.context_community_id else None

	if loading_plan["include_all_users"]:
		all_users_query = user.objects.only(
			"id",
			"name",
			"location",
			"level",
			"intrest1",
			"intrest2",
			"intrest3",
			"intrest4",
		).order_by("id")[:MAX_ALL_USERS_FOR_CONTEXT]
		all_users = [_serialize_user_for_ai(user_obj, compact=True) for user_obj in all_users_query]
	else:
		all_users = {
			"included": False,
			"count": user.objects.count(),
			"reason": "Excluded for token efficiency. Include when user asks about people/friends/profile details.",
		}

	if loading_plan["include_all_communities"]:
		all_communities_query = community.objects.only(
			"id",
			"name",
			"description",
			"maxParticipants",
			"totalParticipants",
		).order_by("id")[:MAX_ALL_COMMUNITIES_FOR_CONTEXT]
		all_communities = [_serialize_community_for_ai(community_obj, compact=True) for community_obj in all_communities_query]
	else:
		all_communities = []

	main_user_data = _serialize_user_for_ai(main_user)
	if main_user is not None:
		main_user_data["friends"] = [
			_serialize_user_for_ai(friend_obj, compact=True)
			for friend_obj in main_user.friends.all().order_by("id")
		]
		main_user_data["communities"] = [
			_serialize_community_for_ai(community_obj, compact=True)
			for community_obj in main_user.communities.all().order_by("id")
		]

	context_user_data = _serialize_user_for_ai(context_user)
	context_community_data = _serialize_community_for_ai(
		context_community,
		include_members=loading_plan["include_context_community_members"],
		include_history=loading_plan["include_context_community_history"],
	)

	knowledge_base = {
		"chat": {
			"id": chat_obj.id,
			"main_user_id": chat_obj.main_user_id,
			"context_user_id": chat_obj.context_user_id,
			"context_community_id": chat_obj.context_community_id,
			"mode": loading_plan["chat_mode"],
		},
		"loaded_sections": {
			"all_users": loading_plan["include_all_users"],
			"all_communities": loading_plan["include_all_communities"],
			"context_community_members": loading_plan["include_context_community_members"],
			"context_community_history": loading_plan["include_context_community_history"],
		},
		"main_user": main_user_data,
		"context_user": context_user_data,
		"context_community": context_community_data,
		"all_users": all_users,
		"all_communities": all_communities,
	}

	return knowledge_base


def _summarize_ai_chat_context(chat_obj):
	if chat_obj.context_user_id:
		context_name = chat_obj.context_user.name if chat_obj.context_user else "the direct chat user"
		return f"Direct chat context with user: {context_name}."

	if chat_obj.context_community_id:
		context_name = chat_obj.context_community.name if chat_obj.context_community else "the community"
		return f"Community chat context: {context_name}."

	return "Personal AI chat context (no external user/community context)."


def _build_gemini_contents(chat_obj):
	loading_plan = _build_context_loading_plan(chat_obj)
	knowledge_base = _build_ai_knowledge_base(chat_obj, loading_plan)
	raw_message_history = list(chat_obj.messages.select_related("sender").order_by("-created_at")[:AI_CHAT_HISTORY_LIMIT])
	raw_message_history.reverse()

	main_user_name = chat_obj.main_user.name if chat_obj.main_user else "User"
	chat_mode = loading_plan["chat_mode"]

	if chat_mode == "community_context":
		focus_prompt = (
			"This chat is tied to a community. Prioritize that community, its members, and the community chat history. "
			"Use other communities only as secondary reference points."
		)
	elif chat_mode == "direct_context":
		focus_prompt = (
			"This chat is tied to a direct friend context. Prioritize the context user/friend when answering, "
			"but still use the full app data as needed."
		)
	else:
		focus_prompt = (
			"This is a solo AI chat. Use the full app data for reference, but do not invent private member or chat-history data for communities that is not provided."
		)

	system_prompt = (
		f"You are Chat.AI inside HitMeUp. Be concise, practical, and friendly. "
		"Do not prefix your responses with labels like [AI]:, AI:, or Assistant:. "
		f"The main user talking to you is {main_user_name}. "
		f"{_summarize_ai_chat_context(chat_obj)}"
	)

	knowledge_prompt = (
		"Use the following app data as the source of truth. "
		"Heavy sections are loaded only when needed based on the latest user request. "
		"Do not assume hidden data exists beyond what is shown. "
		f"{focus_prompt}\n\n"
		f"APP_DATA_JSON:\n{json.dumps(knowledge_base, ensure_ascii=False, default=str)}"
	)

	contents = [
		{
			"role": "user",
			"parts": [{"text": system_prompt}],
		},
		{
			"role": "user",
			"parts": [{"text": knowledge_prompt}],
		},
	]

	for message_obj in raw_message_history:
		parts = []
		sender_name = message_obj.sender.name if message_obj.sender else "AI"

		if message_obj.text and message_obj.text.strip():
			parts.append({"text": f"[{sender_name}]: {_clip_text(message_obj.text)}"})
		if message_obj.image:
			media_label = "sent an image" if not message_obj.isFromAI else "image reference"
			parts.append({"text": f"[{sender_name}]: {media_label}"})
		if message_obj.video:
			media_label = "sent a video" if not message_obj.isFromAI else "video reference"
			parts.append({"text": f"[{sender_name}]: {media_label}"})
		if message_obj.voiceRecording:
			media_label = "sent a voice recording" if not message_obj.isFromAI else "voice reference"
			parts.append({"text": f"[{sender_name}]: {media_label}"})

		if not parts:
			continue

		contents.append(
			{
				"role": "model" if message_obj.isFromAI else "user",
				"parts": parts,
			}
		)

	return contents


def _strip_leading_ai_label(text_value):
	cleaned = (text_value or "").strip()
	pattern = re.compile(r"^(?:\[(?:ai|assistant|chat\.?ai)\]|(?:ai|assistant|chat\.?ai))\s*[:\-]\s*", re.IGNORECASE)

	# Some model outputs can repeat labels; remove all leading occurrences.
	while cleaned:
		updated = pattern.sub("", cleaned, count=1).strip()
		if updated == cleaned:
			break
		cleaned = updated

	return cleaned


def _extract_gemini_text(response_payload):
	candidates = response_payload.get("candidates") or []
	if not candidates:
		return ""

	content = candidates[0].get("content") or {}
	parts = content.get("parts") or []
	texts = [str(part.get("text", "")).strip() for part in parts if isinstance(part, dict)]
	combined = "\n".join([text for text in texts if text]).strip()
	return _strip_leading_ai_label(combined)


def _generate_gemini_reply(chat_obj):
	payload = {
		"contents": _build_gemini_contents(chat_obj),
		"generationConfig": {
			"temperature": 0.7,
			"maxOutputTokens": 512,
		},
	}

	request_obj = urllib_request.Request(
		f"{GEMINI_GENERATE_URL}?key={GEMINI_API_KEY}",
		data=json.dumps(payload).encode("utf-8"),
		headers={"Content-Type": "application/json"},
		method="POST",
	)

	try:
		with urllib_request.urlopen(request_obj, timeout=60) as raw_response:
			body = raw_response.read().decode("utf-8")
			parsed = json.loads(body)
	except urllib_error.HTTPError as exc:
		error_body = exc.read().decode("utf-8", errors="replace")
		raise RuntimeError(f"Gemini HTTP {exc.code}: {error_body}")
	except urllib_error.URLError as exc:
		raise RuntimeError(f"Gemini request failed: {exc.reason}")
	except Exception as exc:
		raise RuntimeError(f"Gemini request failed: {exc}")

	reply_text = _extract_gemini_text(parsed)
	if not reply_text:
		raise RuntimeError("Gemini returned an empty response.")

	return reply_text


class userViewSet(viewsets.ModelViewSet):
	queryset = user.objects.all()
	serializer_class = userSerializer

	@action(detail=False, methods=["post"], url_path="login")
	def login(self, request):
		identifier = str(request.data.get("identifier", "")).strip()
		password = str(request.data.get("password", ""))

		if not identifier or not password:
			return Response(
				{"detail": "identifier and password are required."},
				status=status.HTTP_400_BAD_REQUEST,
			)

		matched_user = user.objects.filter(
			Q(email__iexact=identifier) | Q(name__iexact=identifier),
			password=password,
		).first()

		if matched_user is None:
			return Response(
				{"detail": "Invalid username/email or password."},
				status=status.HTTP_401_UNAUTHORIZED,
			)

		serializer = self.get_serializer(matched_user)
		return Response(serializer.data, status=status.HTTP_200_OK)

	@action(detail=True, methods=["patch"], url_path="edit-user")
	def edit_user(self, request, pk=None):
		user_obj = self.get_object()
		serializer = self.get_serializer(user_obj, data=request.data, partial=True)
		serializer.is_valid(raise_exception=True)
		serializer.save()
		return Response(serializer.data)

	@action(detail=True, methods=["delete"], url_path="delete-user")
	def delete_user(self, request, pk=None):
		user_obj = self.get_object()
		user_obj.delete()
		return Response(status=status.HTTP_204_NO_CONTENT)


def _generate_verification_code():
	return f"{secrets.randbelow(10000):04d}"


def _verify_google_token(id_token_value):
	if not GOOGLE_AUTH_AVAILABLE:
		raise RuntimeError("google-auth is not installed on the backend.")
	return google_id_token.verify_oauth2_token(id_token_value, google_requests.Request())


def _send_verification_email(recipient_email, code_value):
	from django.core.mail import send_mail

	try:
		send_mail(
			subject="Your HitMeUp verification code",
			message=f"Your verification code is {code_value}. It expires in 10 minutes.",
			from_email=settings.DEFAULT_FROM_EMAIL,
			recipient_list=[recipient_email],
			fail_silently=False,
		)
		return True, None
	except Exception as exc:
		return False, str(exc)


@api_view(["POST"])
def oauth_signin(request):
	provider = str(request.data.get("provider", "")).strip().lower()
	id_token_value = str(request.data.get("id_token", "")).strip()
	email = str(request.data.get("email", "")).strip().lower()

	if provider != "google":
		return Response({"detail": "Only Google sign-in is enabled right now."}, status=status.HTTP_400_BAD_REQUEST)

	if not id_token_value:
		return Response({"detail": "id_token is required."}, status=status.HTTP_400_BAD_REQUEST)

	try:
		id_info = _verify_google_token(id_token_value)
	except Exception as exc:
		return Response({"detail": f"Google token verification failed: {exc}"}, status=status.HTTP_400_BAD_REQUEST)

	verified_email = str(id_info.get("email", "")).strip().lower()
	provider_user_id = str(id_info.get("sub", "")).strip()

	if not verified_email:
		return Response({"detail": "Google account did not provide an email address."}, status=status.HTTP_400_BAD_REQUEST)

	if email and email != verified_email:
		return Response({"detail": "Email mismatch between Google token and request."}, status=status.HTTP_400_BAD_REQUEST)

	matched_user = user.objects.filter(email__iexact=verified_email).first()
	if matched_user is None:
		return Response(
			{
				"status": "signup_required",
				"email": verified_email,
				"name": str(id_info.get("name", "")).strip(),
				"identifier": provider_user_id,
				"detail": "No linked account found for this Google email.",
			},
			status=status.HTTP_200_OK,
		)

	serializer = userSerializer(matched_user)
	return Response(
		{
			"status": "linked",
			"user": serializer.data,
		},
		status=status.HTTP_200_OK,
	)


@api_view(["POST"])
def verify_oauth_code(request):
	email = str(request.data.get("email", "")).strip().lower()
	code_value = str(request.data.get("code", "")).strip()
	provider = str(request.data.get("provider", "google")).strip().lower()

	if not email or not code_value:
		return Response({"detail": "email and code are required."}, status=status.HTTP_400_BAD_REQUEST)

	verification = oauthverificationcode.objects.filter(email=email, provider=provider, code=code_value, is_used=False).first()
	if verification is None:
		return Response({"detail": "Invalid verification code."}, status=status.HTTP_400_BAD_REQUEST)

	if verification.has_expired():
		verification.delete()
		return Response({"detail": "Verification code expired."}, status=status.HTTP_400_BAD_REQUEST)

	verification.is_used = True
	verification.save(update_fields=["is_used"])

	matched_user = user.objects.filter(email__iexact=email).first()
	if matched_user is None:
		return Response(
			{
				"detail": "No existing user was found for this Google account. Create or link the account first.",
			},
			status=status.HTTP_404_NOT_FOUND,
		)

	serializer = userSerializer(matched_user)
	return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(["POST"])
def resend_oauth_code(request):
	email = str(request.data.get("email", "")).strip().lower()
	provider = str(request.data.get("provider", "google")).strip().lower()

	verification = oauthverificationcode.objects.filter(email=email, provider=provider).first()
	if verification is None:
		return Response({"detail": "No verification request found."}, status=status.HTTP_404_NOT_FOUND)

	code_value = _generate_verification_code()
	verification.code = code_value
	verification.expires_at = timezone.now() + timedelta(minutes=10)
	verification.is_used = False
	verification.save(update_fields=["code", "expires_at", "is_used"])

	email_sent, email_error = _send_verification_email(email, code_value)
	response_payload = {
		"message": "Verification code resent." if email_sent else "Verification code regenerated, but email delivery failed.",
	}
	if not email_sent:
		response_payload["email_error"] = email_error
		if settings.DEBUG:
			response_payload["debug_code"] = code_value

	return Response(response_payload, status=status.HTTP_200_OK)


class communityViewSet(viewsets.ModelViewSet):
	queryset = community.objects.all()
	serializer_class = communitySerializer

	@action(detail=True, methods=["post"], url_path="add-member")
	def add_member(self, request, pk=None):
		"""Add a user to a community"""
		try:
			community_obj = self.get_object()
			user_id = request.data.get("user_id")

			if not user_id:
				return Response(
					{"detail": "user_id is required."},
					status=status.HTTP_400_BAD_REQUEST,
				)

			user_obj = user.objects.filter(id=user_id).first()
			if not user_obj:
				return Response(
					{"detail": "User not found."},
					status=status.HTTP_404_NOT_FOUND,
				)

			# Check if user is already a member
			if community_obj.members.filter(id=user_id).exists():
				return Response(
					{"detail": "User is already a member of this community."},
					status=status.HTTP_200_OK,
				)

			# Add user to community
			community_obj.members.add(user_obj)
			
			# Update totalParticipants
			community_obj.totalParticipants = community_obj.members.count()
			community_obj.save(update_fields=['totalParticipants'])

			return Response(
				{"detail": "User added to community successfully.", "totalParticipants": community_obj.totalParticipants},
				status=status.HTTP_200_OK,
			)
		except Exception as e:
			return Response(
				{"detail": f"Error adding user to community: {str(e)}"},
				status=status.HTTP_400_BAD_REQUEST,
			)

	@action(detail=True, methods=["post"], url_path="remove-member")
	def remove_member(self, request, pk=None):
		"""Remove a user from a community"""
		try:
			community_obj = self.get_object()
			user_id = request.data.get("user_id")

			if not user_id:
				return Response(
					{"detail": "user_id is required."},
					status=status.HTTP_400_BAD_REQUEST,
				)

			user_obj = user.objects.filter(id=user_id).first()
			if not user_obj:
				return Response(
					{"detail": "User not found."},
					status=status.HTTP_404_NOT_FOUND,
				)

			# Check if user is a member
			if not community_obj.members.filter(id=user_id).exists():
				return Response(
					{"detail": "User is not a member of this community."},
					status=status.HTTP_200_OK,
				)

			# Remove user from community
			community_obj.members.remove(user_obj)
			
			# Update totalParticipants
			community_obj.totalParticipants = community_obj.members.count()
			community_obj.save(update_fields=['totalParticipants'])

			return Response(
				{"detail": "User removed from community successfully.", "totalParticipants": community_obj.totalParticipants},
				status=status.HTTP_200_OK,
			)
		except Exception as e:
			return Response(
				{"detail": f"Error removing user from community: {str(e)}"},
				status=status.HTTP_400_BAD_REQUEST,
			)


class communityMessageViewSet(viewsets.ModelViewSet):
	queryset = communitymessage.objects.select_related("community", "sender").all()
	serializer_class = communityMessageSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		community_id = self.request.query_params.get("community")
		if community_id:
			queryset = queryset.filter(community_id=community_id)

		before_id = self.request.query_params.get("before_id")
		limit_value = self.request.query_params.get("limit")

		if before_id:
			queryset = queryset.filter(id__lt=before_id)

		if community_id and limit_value:
			try:
				limit_count = max(1, int(limit_value))
			except ValueError:
				limit_count = 20

			queryset = queryset.order_by("-created_at")[:limit_count]
			return list(queryset)[::-1]

		if community_id and not limit_value:
			queryset = queryset.order_by("created_at")
			return queryset

		return queryset.order_by("-created_at")


class directChatViewSet(viewsets.ModelViewSet):
	queryset = directchat.objects.select_related("user1", "user2").all()
	serializer_class = directChatSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		user_id = self.request.query_params.get("user")
		if user_id:
			current_user = user.objects.prefetch_related("friends").filter(id=user_id).first()
			if current_user is None:
				return queryset.none()

			directchat.ensure_for_user_friends(current_user)
			queryset = queryset.filter(user1_id=user_id) | queryset.filter(user2_id=user_id)
		return queryset.order_by("-updated_at")


class aiChatViewSet(viewsets.ModelViewSet):
	queryset = aichat.objects.select_related("main_user", "context_user", "context_community").all()
	serializer_class = aiChatSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		main_user_id = self.request.query_params.get("main_user")
		context_user_id = self.request.query_params.get("context_user")
		context_community_id = self.request.query_params.get("context_community")

		if main_user_id:
			queryset = queryset.filter(main_user_id=main_user_id)
		if context_user_id:
			queryset = queryset.filter(context_user_id=context_user_id)
		if context_community_id:
			queryset = queryset.filter(context_community_id=context_community_id)

		return queryset.order_by("-updated_at")


class directMessageViewSet(viewsets.ModelViewSet):
	queryset = directmessage.objects.select_related("chat", "sender").all()
	serializer_class = directMessageSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		chat_id = self.request.query_params.get("chat")
		if chat_id:
			queryset = queryset.filter(chat_id=chat_id)

		before_id = self.request.query_params.get("before_id")
		limit_value = self.request.query_params.get("limit")

		if before_id:
			queryset = queryset.filter(id__lt=before_id)

		if chat_id and limit_value:
			try:
				limit_count = max(1, int(limit_value))
			except ValueError:
				limit_count = 20

			queryset = queryset.order_by("-created_at")[:limit_count]
			return list(queryset)[::-1]

		if chat_id and not limit_value:
			queryset = queryset.order_by("created_at")
			return queryset
		return queryset


class aiChatMessageViewSet(viewsets.ModelViewSet):
	queryset = aichatmessage.objects.select_related("chat", "sender").all()
	serializer_class = aiChatMessageSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		chat_id = self.request.query_params.get("chat")
		if chat_id:
			queryset = queryset.filter(chat_id=chat_id)

		before_id = self.request.query_params.get("before_id")
		limit_value = self.request.query_params.get("limit")

		if before_id:
			queryset = queryset.filter(id__lt=before_id)

		if chat_id and limit_value:
			try:
				limit_count = max(1, int(limit_value))
			except ValueError:
				limit_count = 20

			queryset = queryset.order_by("-created_at")[:limit_count]
			return list(queryset)[::-1]

		if chat_id and not limit_value:
			queryset = queryset.order_by("created_at")
			return queryset

		return queryset

	@action(detail=False, methods=["post"], url_path="generate")
	def generate(self, request):
		chat_id = request.data.get("chat")
		if not chat_id:
			return Response({"detail": "chat is required."}, status=status.HTTP_400_BAD_REQUEST)

		chat_obj = aichat.objects.select_related("context_user", "context_community").filter(id=chat_id).first()
		if chat_obj is None:
			return Response({"detail": "AI chat not found."}, status=status.HTTP_404_NOT_FOUND)

		has_user_prompt = aichatmessage.objects.filter(chat=chat_obj, isFromAI=False).exists()
		if not has_user_prompt:
			return Response(
				{"detail": "At least one user message is required before generating an AI response."},
				status=status.HTTP_400_BAD_REQUEST,
			)

		try:
			reply_text = _generate_gemini_reply(chat_obj)
		except RuntimeError as exc:
			return Response({"detail": str(exc)}, status=status.HTTP_502_BAD_GATEWAY)

		ai_message = aichatmessage.objects.create(
			chat=chat_obj,
			sender=None,
			isFromAI=True,
			text=reply_text,
		)

		serializer = self.get_serializer(ai_message)
		return Response(serializer.data, status=status.HTTP_201_CREATED)


class friendRequestViewSet(viewsets.ModelViewSet):
	queryset = friendrequest.objects.select_related("requester", "receiver").all()
	serializer_class = friendRequestSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		requester_id = self.request.query_params.get("requester")
		receiver_id = self.request.query_params.get("receiver")
		status_value = self.request.query_params.get("status")

		if requester_id:
			queryset = queryset.filter(requester_id=requester_id)
		if receiver_id:
			queryset = queryset.filter(receiver_id=receiver_id)
		if status_value:
			queryset = queryset.filter(status=status_value)

		return queryset.order_by("-created_at")


class directMessagePollViewSet(viewsets.ReadOnlyModelViewSet):
	queryset = directmessagepoll.objects.prefetch_related("options__votes__voter").all()
	serializer_class = directMessagePollSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		message_id = self.request.query_params.get("message")
		if message_id:
			queryset = queryset.filter(message_id=message_id)
		return queryset


class directMessagePollOptionViewSet(viewsets.ReadOnlyModelViewSet):
	queryset = directmessagepolloption.objects.prefetch_related("votes__voter").all()
	serializer_class = directMessagePollOptionSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		poll_id = self.request.query_params.get("poll")
		if poll_id:
			queryset = queryset.filter(poll_id=poll_id)
		return queryset


class directMessagePollVoteViewSet(viewsets.ModelViewSet):
	queryset = directmessagepollvote.objects.select_related("option", "voter", "option__poll").all()
	serializer_class = directMessagePollVoteSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		option_id = self.request.query_params.get("option")
		poll_id = self.request.query_params.get("poll")

		if option_id:
			queryset = queryset.filter(option_id=option_id)
		if poll_id:
			queryset = queryset.filter(option__poll_id=poll_id)

		return queryset.order_by("-created_at")


class communityMessagePollViewSet(viewsets.ReadOnlyModelViewSet):
	queryset = communitymessagepoll.objects.prefetch_related("options__votes__voter").all()
	serializer_class = communityMessagePollSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		message_id = self.request.query_params.get("message")
		if message_id:
			queryset = queryset.filter(message_id=message_id)
		return queryset


class communityMessagePollOptionViewSet(viewsets.ReadOnlyModelViewSet):
	queryset = communitymessagepolloption.objects.prefetch_related("votes__voter").all()
	serializer_class = communityMessagePollOptionSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		poll_id = self.request.query_params.get("poll")
		if poll_id:
			queryset = queryset.filter(poll_id=poll_id)
		return queryset


class communityMessagePollVoteViewSet(viewsets.ModelViewSet):
	queryset = communitymessagepollvote.objects.select_related("option", "voter", "option__poll").all()
	serializer_class = communityMessagePollVoteSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		option_id = self.request.query_params.get("option")
		poll_id = self.request.query_params.get("poll")

		if option_id:
			queryset = queryset.filter(option_id=option_id)
		if poll_id:
			queryset = queryset.filter(option__poll_id=poll_id)

		return queryset.order_by("-created_at")
