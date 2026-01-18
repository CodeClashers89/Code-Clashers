import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dpi_platform.settings')
django.setup()

from accounts.models import CustomUser

try:
    user = CustomUser.objects.get(username='neel123')
    print(f"Current token: {user.profile.face_token}")
    user.profile.face_token = None
    user.profile.save()
    print("Successfully cleared invalid face_token for user 'neel123'.")
except CustomUser.DoesNotExist:
    print("User 'neel123' not found.")
except Exception as e:
    print(f"Error: {e}")
