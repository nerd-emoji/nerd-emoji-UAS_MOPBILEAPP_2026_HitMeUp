from django.db import migrations, models


def migrate_anyone_to_everyone(apps, schema_editor):
    User = apps.get_model("backend", "user")
    User.objects.filter(wanttomeet="anyone").update(wanttomeet="everyone")


def migrate_everyone_to_anyone(apps, schema_editor):
    User = apps.get_model("backend", "user")
    User.objects.filter(wanttomeet="everyone").update(wanttomeet="anyone")


class Migration(migrations.Migration):

    dependencies = [
        ("backend", "0017_user_showbirthday_user_wanttomeet"),
    ]

    operations = [
        migrations.RunPython(migrate_anyone_to_everyone, migrate_everyone_to_anyone),
        migrations.AlterField(
            model_name="user",
            name="wanttomeet",
            field=models.CharField(
                choices=[("man", "Man"), ("woman", "Woman"), ("everyone", "Everyone")],
                default="everyone",
                max_length=10,
            ),
        ),
    ]
