from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ("backend", "0014_allow_duplicate_poll_option_names"),
    ]

    operations = [
        migrations.CreateModel(
            name="aichat",
            fields=[
                ("id", models.AutoField(primary_key=True, serialize=False)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "context_community",
                    models.ForeignKey(
                        blank=True,
                        null=True,
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="ai_chats_with_community_context",
                        to="backend.community",
                    ),
                ),
                (
                    "context_user",
                    models.ForeignKey(
                        blank=True,
                        null=True,
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="ai_chats_with_user_context",
                        to="backend.user",
                    ),
                ),
                (
                    "main_user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="ai_chats",
                        to="backend.user",
                    ),
                ),
            ],
            options={
                "constraints": [
                    models.CheckConstraint(
                        condition=~(
                            models.Q(("context_user__isnull", False), ("context_community__isnull", False))
                        ),
                        name="aichat_single_context_only",
                    ),
                    models.CheckConstraint(
                        condition=models.Q(("context_user__isnull", True))
                        | ~models.Q(("main_user", models.F("context_user"))),
                        name="aichat_distinct_main_and_context_user",
                    ),
                    models.UniqueConstraint(
                        condition=models.Q(("context_user__isnull", False)),
                        fields=("main_user", "context_user"),
                        name="unique_aichat_main_user_context_user",
                    ),
                    models.UniqueConstraint(
                        condition=models.Q(("context_community__isnull", False)),
                        fields=("main_user", "context_community"),
                        name="unique_aichat_main_user_context_community",
                    ),
                    models.UniqueConstraint(
                        condition=models.Q(("context_user__isnull", True), ("context_community__isnull", True)),
                        fields=("main_user",),
                        name="unique_aichat_main_user_solo",
                    ),
                ],
            },
        ),
        migrations.CreateModel(
            name="aichatmessage",
            fields=[
                ("id", models.AutoField(primary_key=True, serialize=False)),
                ("isFromAI", models.BooleanField(default=False)),
                ("text", models.TextField(blank=True)),
                ("image", models.ImageField(blank=True, null=True, upload_to="ai_chat/images/")),
                ("video", models.FileField(blank=True, null=True, upload_to="ai_chat/videos/")),
                (
                    "voiceRecording",
                    models.FileField(blank=True, null=True, upload_to="ai_chat/voice/"),
                ),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                (
                    "chat",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="messages",
                        to="backend.aichat",
                    ),
                ),
                (
                    "sender",
                    models.ForeignKey(
                        blank=True,
                        null=True,
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="sent_ai_messages",
                        to="backend.user",
                    ),
                ),
            ],
            options={
                "ordering": ["created_at"],
            },
        ),
    ]
