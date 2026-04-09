from rest_framework import serializers
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
)


class userSerializer(serializers.ModelSerializer):
	class Meta:
		model = user
		fields = [
			"id",
			"name",
			"email",
			"password",
			"gender",
			"birthday",
			"location",
			"intrest1",
			"intrest2",
			"intrest3",
			"intrest4",
			"friends",
			"communities",
			"diamonds",
			"level",
			"profilepicture",
		]


class communitySerializer(serializers.ModelSerializer):
	def validate(self, attrs):
		max_participants = attrs.get(
			"maxParticipants",
			self.instance.maxParticipants if self.instance else 0,
		)
		total_participants = attrs.get(
			"totalParticipants",
			self.instance.totalParticipants if self.instance else 0,
		)

		if total_participants > max_participants:
			raise serializers.ValidationError(
				{"totalParticipants": "totalParticipants cannot be greater than maxParticipants."}
			)

		return attrs

	class Meta:
		model = community
		fields = [
			"id",
			"name",
			"description",
			"maxParticipants",
			"totalParticipants",
			"communityPicture",
			"created_at",
			"members",
		]


class directChatSerializer(serializers.ModelSerializer):
	lastMessage = serializers.SerializerMethodField(read_only=True)

	def get_lastMessage(self, obj):
		latest_message = obj.messages.order_by("-created_at").first()
		if latest_message is None:
			return ""
		if latest_message.text:
			return latest_message.text
		if latest_message.image:
			return "Image"
		if latest_message.video:
			return "Video"
		if latest_message.voiceRecording:
			return "Voice message"
		if latest_message.hasPoll:
			return "Poll"
		return ""

	def validate(self, attrs):
		user1_id = attrs.get("user1", self.instance.user1 if self.instance else None)
		user2_id = attrs.get("user2", self.instance.user2 if self.instance else None)

		user1_id = user1_id.id if hasattr(user1_id, "id") else user1_id
		user2_id = user2_id.id if hasattr(user2_id, "id") else user2_id

		if user1_id and user2_id and user1_id == user2_id:
			raise serializers.ValidationError("A user cannot create a direct chat with themselves.")

		if user1_id and user2_id:
			are_friends = user.objects.filter(id=user1_id, friends__id=user2_id).exists()
			if not are_friends:
				raise serializers.ValidationError("Direct chat is allowed only between friends.")

		return attrs

	def create(self, validated_data):
		user1_obj = validated_data["user1"]
		user2_obj = validated_data["user2"]
		if user1_obj.id > user2_obj.id:
			user1_obj, user2_obj = user2_obj, user1_obj
		chat, _ = directchat.objects.get_or_create(user1=user1_obj, user2=user2_obj)
		return chat

	class Meta:
		model = directchat
		fields = ["id", "user1", "user2", "created_at", "updated_at", "lastMessage"]


class aiChatSerializer(serializers.ModelSerializer):
	lastMessage = serializers.SerializerMethodField(read_only=True)

	def get_lastMessage(self, obj):
		latest_message = obj.messages.order_by("-created_at").first()
		if latest_message is None:
			return ""
		if latest_message.text:
			return latest_message.text
		if latest_message.image:
			return "Image"
		if latest_message.video:
			return "Video"
		if latest_message.voiceRecording:
			return "Voice message"
		return ""

	def validate(self, attrs):
		main_user_obj = attrs.get("main_user", self.instance.main_user if self.instance else None)
		context_user_obj = attrs.get("context_user", self.instance.context_user if self.instance else None)
		context_community_obj = attrs.get("context_community", self.instance.context_community if self.instance else None)

		if context_user_obj and context_community_obj:
			raise serializers.ValidationError("AI chat can have either a user context or a community context, not both.")

		if main_user_obj and context_user_obj and main_user_obj.id == context_user_obj.id:
			raise serializers.ValidationError("Main user and context user must be different users.")

		if main_user_obj and context_user_obj:
			are_friends = user.objects.filter(id=main_user_obj.id, friends__id=context_user_obj.id).exists()
			if not are_friends:
				raise serializers.ValidationError("User-context AI chat is allowed only between friends.")

		if main_user_obj and context_community_obj:
			if not context_community_obj.members.filter(id=main_user_obj.id).exists():
				raise serializers.ValidationError("Main user must be a member of the community context.")

		return attrs

	def create(self, validated_data):
		main_user_obj = validated_data["main_user"]
		context_user_obj = validated_data.get("context_user")
		context_community_obj = validated_data.get("context_community")

		if context_user_obj is not None:
			chat, _ = aichat.objects.get_or_create(main_user=main_user_obj, context_user=context_user_obj)
			return chat

		if context_community_obj is not None:
			chat, _ = aichat.objects.get_or_create(main_user=main_user_obj, context_community=context_community_obj)
			return chat

		chat, _ = aichat.objects.get_or_create(
			main_user=main_user_obj,
			context_user=None,
			context_community=None,
		)
		return chat

	class Meta:
		model = aichat
		fields = [
			"id",
			"main_user",
			"context_user",
			"context_community",
			"created_at",
			"updated_at",
			"lastMessage",
		]


class aiChatMessageSerializer(serializers.ModelSerializer):
	senderName = serializers.CharField(source="sender.name", read_only=True)
	senderProfile = serializers.ImageField(source="sender.profilepicture", read_only=True)

	def validate(self, attrs):
		chat_obj = attrs.get("chat", self.instance.chat if self.instance else None)
		sender_obj = attrs.get("sender", self.instance.sender if self.instance else None)
		is_from_ai = attrs.get("isFromAI", self.instance.isFromAI if self.instance else False)

		if chat_obj and sender_obj and sender_obj.id != chat_obj.main_user_id:
			raise serializers.ValidationError("Sender must be the main user for user-originated AI chat messages.")

		if sender_obj and is_from_ai:
			raise serializers.ValidationError("AI messages must not include a user sender.")

		if not sender_obj and not is_from_ai:
			raise serializers.ValidationError("Message must be sent by the main user or marked as AI-generated.")

		text_value = attrs.get("text", self.instance.text if self.instance else "")
		image_value = attrs.get("image", self.instance.image if self.instance else None)
		video_value = attrs.get("video", self.instance.video if self.instance else None)
		voice_value = attrs.get("voiceRecording", self.instance.voiceRecording if self.instance else None)

		has_content = bool(text_value and str(text_value).strip()) or bool(image_value) or bool(video_value) or bool(voice_value)
		if not has_content:
			raise serializers.ValidationError("Message must include text, image, video, or voiceRecording.")

		return attrs

	class Meta:
		model = aichatmessage
		fields = [
			"id",
			"chat",
			"sender",
			"senderName",
			"senderProfile",
			"isFromAI",
			"text",
			"image",
			"video",
			"voiceRecording",
			"created_at",
		]
		read_only_fields = ["created_at"]


class directMessageSerializer(serializers.ModelSerializer):
	pollQuestion = serializers.CharField(write_only=True, required=False, allow_blank=False)
	pollOptions = serializers.ListField(
		child=serializers.CharField(allow_blank=False),
		write_only=True,
		required=False,
	)
	poll = serializers.SerializerMethodField(read_only=True)

	def get_poll(self, obj):
		if not hasattr(obj, "poll"):
			return None
		return directMessagePollSerializer(obj.poll).data

	def validate(self, attrs):
		poll_question = attrs.get("pollQuestion")
		poll_options = attrs.get("pollOptions")

		if poll_question and (not poll_options or len(poll_options) < 2):
			raise serializers.ValidationError("A poll must include at least 2 options.")
		if poll_options and not poll_question:
			raise serializers.ValidationError("pollQuestion is required when pollOptions are provided.")

		chat_obj = attrs.get("chat", self.instance.chat if self.instance else None)
		sender_obj = attrs.get("sender", self.instance.sender if self.instance else None)

		if chat_obj and sender_obj:
			if sender_obj.id not in (chat_obj.user1_id, chat_obj.user2_id):
				raise serializers.ValidationError("Sender must be one of the chat participants.")

		text_value = attrs.get("text", self.instance.text if self.instance else "")
		image_value = attrs.get("image", self.instance.image if self.instance else None)
		video_value = attrs.get("video", self.instance.video if self.instance else None)
		voice_value = attrs.get("voiceRecording", self.instance.voiceRecording if self.instance else None)
		has_poll = bool(poll_question and poll_options)

		has_content = bool(text_value and str(text_value).strip()) or bool(image_value) or bool(video_value) or bool(voice_value) or has_poll
		if not has_content:
			raise serializers.ValidationError("Message must include text, image, video, voiceRecording, or a poll.")

		return attrs

	def create(self, validated_data):
		poll_question = validated_data.pop("pollQuestion", None)
		poll_options = validated_data.pop("pollOptions", [])

		if poll_question and poll_options:
			validated_data["hasPoll"] = True

		message = super().create(validated_data)

		if poll_question and poll_options:
			poll = directmessagepoll.objects.create(message=message, question=poll_question)
			for option_name in poll_options:
				directmessagepolloption.objects.create(poll=poll, optionName=option_name)

		return message

	class Meta:
		model = directmessage
		fields = [
			"id",
			"chat",
			"sender",
			"text",
			"image",
			"video",
			"voiceRecording",
			"hasPoll",
			"pollQuestion",
			"pollOptions",
			"poll",
			"created_at",
		]
		read_only_fields = ["created_at", "hasPoll"]


class directMessagePollVoteSerializer(serializers.ModelSerializer):
	voterName = serializers.CharField(source="voter.name", read_only=True)
	voterProfile = serializers.ImageField(source="voter.profilepicture", read_only=True)

	class Meta:
		model = directmessagepollvote
		fields = ["id", "option", "voter", "voterName", "voterProfile", "created_at"]
		read_only_fields = ["created_at"]


class directMessagePollOptionSerializer(serializers.ModelSerializer):
	votes = directMessagePollVoteSerializer(many=True, read_only=True)

	class Meta:
		model = directmessagepolloption
		fields = ["id", "poll", "optionName", "voteCount", "votes"]
		read_only_fields = ["voteCount"]


class directMessagePollSerializer(serializers.ModelSerializer):
	options = directMessagePollOptionSerializer(many=True, read_only=True)

	class Meta:
		model = directmessagepoll
		fields = ["id", "message", "question", "created_at", "options"]
		read_only_fields = ["created_at"]


class communityMessagePollVoteSerializer(serializers.ModelSerializer):
	voterName = serializers.CharField(source="voter.name", read_only=True)
	voterProfile = serializers.ImageField(source="voter.profilepicture", read_only=True)

	class Meta:
		model = communitymessagepollvote
		fields = ["id", "option", "voter", "voterName", "voterProfile", "created_at"]
		read_only_fields = ["created_at"]


class communityMessagePollOptionSerializer(serializers.ModelSerializer):
	votes = communityMessagePollVoteSerializer(many=True, read_only=True)

	class Meta:
		model = communitymessagepolloption
		fields = ["id", "poll", "optionName", "voteCount", "votes"]
		read_only_fields = ["voteCount"]


class communityMessagePollSerializer(serializers.ModelSerializer):
	options = communityMessagePollOptionSerializer(many=True, read_only=True)

	class Meta:
		model = communitymessagepoll
		fields = ["id", "message", "question", "created_at", "options"]
		read_only_fields = ["created_at"]


class communityMessageSerializer(serializers.ModelSerializer):
	senderName = serializers.CharField(source="sender.name", read_only=True)
	senderProfile = serializers.ImageField(source="sender.profilepicture", read_only=True)
	pollQuestion = serializers.CharField(write_only=True, required=False, allow_blank=False)
	pollOptions = serializers.ListField(
		child=serializers.CharField(allow_blank=False),
		write_only=True,
		required=False,
	)
	poll = serializers.SerializerMethodField(read_only=True)

	def get_poll(self, obj):
		if not hasattr(obj, "poll"):
			return None
		return communityMessagePollSerializer(obj.poll).data

	def validate(self, attrs):
		poll_question = attrs.get("pollQuestion")
		poll_options = attrs.get("pollOptions")

		if poll_question and (not poll_options or len(poll_options) < 2):
			raise serializers.ValidationError("A poll must include at least 2 options.")
		if poll_options and not poll_question:
			raise serializers.ValidationError("pollQuestion is required when pollOptions are provided.")

		community_obj = attrs.get("community", self.instance.community if self.instance else None)
		sender_obj = attrs.get("sender", self.instance.sender if self.instance else None)

		if community_obj and sender_obj:
			if not community_obj.members.filter(id=sender_obj.id).exists():
				raise serializers.ValidationError("Sender must be a member of the community.")

		text_value = attrs.get("text", self.instance.text if self.instance else "")
		image_value = attrs.get("image", self.instance.image if self.instance else None)
		video_value = attrs.get("video", self.instance.video if self.instance else None)
		voice_value = attrs.get("voiceRecording", self.instance.voiceRecording if self.instance else None)
		has_poll = bool(poll_question and poll_options)

		has_content = bool(text_value and str(text_value).strip()) or bool(image_value) or bool(video_value) or bool(voice_value) or has_poll
		if not has_content:
			raise serializers.ValidationError("Message must include text, image, video, voiceRecording, or a poll.")

		return attrs

	def create(self, validated_data):
		poll_question = validated_data.pop("pollQuestion", None)
		poll_options = validated_data.pop("pollOptions", [])

		if poll_question and poll_options:
			validated_data["hasPoll"] = True

		message = super().create(validated_data)

		if poll_question and poll_options:
			poll = communitymessagepoll.objects.create(message=message, question=poll_question)
			for option_name in poll_options:
				communitymessagepolloption.objects.create(poll=poll, optionName=option_name)

		return message

	class Meta:
		model = communitymessage
		fields = [
			"id",
			"community",
			"sender",
			"senderName",
			"senderProfile",
			"text",
			"image",
			"video",
			"voiceRecording",
			"hasPoll",
			"pollQuestion",
			"pollOptions",
			"poll",
			"created_at",
		]
		read_only_fields = ["created_at", "hasPoll"]


class friendRequestSerializer(serializers.ModelSerializer):
	def validate(self, attrs):
		requester_obj = attrs.get("requester", self.instance.requester if self.instance else None)
		receiver_obj = attrs.get("receiver", self.instance.receiver if self.instance else None)
		new_status = attrs.get("status", self.instance.status if self.instance else friendrequest.STATUS_PENDING)

		if requester_obj and receiver_obj:
			if requester_obj.id == receiver_obj.id:
				raise serializers.ValidationError("A user cannot send a friend request to themselves.")

			already_friends = user.objects.filter(id=requester_obj.id, friends__id=receiver_obj.id).exists()
			if already_friends:
				raise serializers.ValidationError("Users are already friends.")

			reverse_pending_exists = friendrequest.objects.filter(
				requester=receiver_obj,
				receiver=requester_obj,
				status=friendrequest.STATUS_PENDING,
			).exclude(id=self.instance.id if self.instance else None).exists()

			if reverse_pending_exists and new_status == friendrequest.STATUS_PENDING:
				raise serializers.ValidationError("A pending friend request already exists in the opposite direction.")

		if self.instance and self.instance.status != friendrequest.STATUS_PENDING and "status" in attrs:
			raise serializers.ValidationError("Only pending requests can be updated.")

		return attrs

	def update(self, instance, validated_data):
		new_status = validated_data.get("status", instance.status)
		instance = super().update(instance, validated_data)
		if new_status == friendrequest.STATUS_ACCEPTED:
			instance.requester.friends.add(instance.receiver)
			directchat.ensure_between_users(instance.requester, instance.receiver)
			# Keep level in sync even if signal handlers are bypassed or stale.
			instance.requester.sync_level_from_friends()
			instance.receiver.sync_level_from_friends()
			# Award 5 diamonds to both users
			instance.requester.diamonds = max(0, instance.requester.diamonds + 5)
			instance.requester.save(update_fields=["diamonds"])
			instance.receiver.diamonds = max(0, instance.receiver.diamonds + 5)
			instance.receiver.save(update_fields=["diamonds"])

		# Resolved friend requests are deleted to keep table size small.
		if new_status in {friendrequest.STATUS_ACCEPTED, friendrequest.STATUS_REJECTED}:
			instance.delete()

		return instance

	def create(self, validated_data):
		requester_obj = validated_data.get("requester")
		receiver_obj = validated_data.get("receiver")
		new_status = validated_data.get("status", friendrequest.STATUS_PENDING)

		if (
			requester_obj is not None
			and receiver_obj is not None
			and new_status == friendrequest.STATUS_PENDING
		):
			# Re-sending to the same user overrides the previous same-direction request.
			friendrequest.objects.filter(
				requester=requester_obj,
				receiver=receiver_obj,
			).delete()
			# Deduct 2 diamonds from requester
			requester_obj.diamonds = max(0, requester_obj.diamonds - 2)
			requester_obj.save(update_fields=["diamonds"])

		return super().create(validated_data)

	class Meta:
		model = friendrequest
		fields = ["id", "requester", "receiver", "status", "created_at", "updated_at"]
		read_only_fields = ["created_at", "updated_at"]
