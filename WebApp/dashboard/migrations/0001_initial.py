# Generated by Django 4.1.4 on 2022-12-24 19:53

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import django.utils.timezone


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Profile',
            fields=[
                ('user_id', models.IntegerField(primary_key=True, serialize=False)),
                ('photo', models.FileField(null=True, upload_to='dashboard/user_photo')),
                ('email', models.CharField(max_length=50)),
                ('username', models.CharField(max_length=20)),
                ('first_name', models.CharField(max_length=30)),
                ('last_name', models.CharField(max_length=30)),
                ('password', models.CharField(max_length=50)),
                ('is_active', models.BooleanField()),
                ('is_verified', models.BooleanField()),
                ('created_timestamp', models.DateTimeField(auto_now_add=True)),
            ],
        ),
        migrations.CreateModel(
            name='UserLogin',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('login_time', models.DateTimeField(auto_now_add=True)),
                ('last_login_time', models.DateTimeField(null=True)),
                ('user_id', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='dashboard.profile')),
            ],
        ),
        migrations.CreateModel(
            name='UserKyc',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('document', models.FileField(null=True, upload_to='dashboard/user_document')),
                ('document_details', models.CharField(max_length=50)),
                ('user_id', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='dashboard.profile')),
            ],
        ),
        migrations.CreateModel(
            name='UserDetails',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('phone_no', models.IntegerField()),
                ('dateofbirth', models.DateTimeField(default=django.utils.timezone.now)),
                ('address1', models.CharField(max_length=50)),
                ('address2', models.CharField(max_length=50)),
                ('district', models.CharField(max_length=30)),
                ('state', models.CharField(max_length=20)),
                ('pincode', models.CharField(max_length=8)),
                ('user_id', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='dashboard.profile')),
            ],
        ),
        migrations.CreateModel(
            name='UserBankDetails',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('bank_name', models.CharField(max_length=50)),
                ('account_number', models.CharField(max_length=50)),
                ('account_holder_name', models.CharField(max_length=80)),
                ('IFSC_code', models.CharField(max_length=15)),
                ('account_type', models.CharField(max_length=10)),
                ('user_id', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='dashboard.profile')),
            ],
        ),
        migrations.CreateModel(
            name='ProfileUserMap',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('customer_id', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='dashboard.profile')),
                ('user', models.OneToOneField(default='NULL', on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
