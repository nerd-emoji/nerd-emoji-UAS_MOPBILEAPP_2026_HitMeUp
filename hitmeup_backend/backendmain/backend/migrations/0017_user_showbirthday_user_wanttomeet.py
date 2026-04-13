from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("backend", "0016_remove_aichat_unique_aichat_main_user_solo_and_more"),
    ]

    operations = [
        migrations.AddField(
            model_name="user",
            name="showbirthday",
            field=models.BooleanField(default=True),
        ),
        migrations.AddField(
            model_name="user",
            name="wanttomeet",
            field=models.CharField(
                choices=[("man", "Man"), ("woman", "Woman"), ("anyone", "Anyone")],
                default="anyone",
                max_length=10,
            ),
        ),
    ]
