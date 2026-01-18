from django.core.mail import send_mail
from django.conf import settings
from .models import OTP
import random
from datetime import timedelta
from django.utils import timezone

def generate_otp(user, purpose):
    """Generate a 6-digit OTP and save it to the database"""
    otp_code = f"{random.randint(100000, 999999)}"
    expires_at = timezone.now() + timedelta(minutes=10)
    
    # Deactivate old OTPs for this purpose
    OTP.objects.filter(user=user, purpose=purpose, is_verified=False).delete()
    
    otp = OTP.objects.create(
        user=user,
        otp_code=otp_code,
        purpose=purpose,
        expires_at=expires_at
    )
    return otp_code

def send_otp_email(user, otp_code, purpose):
    """Send OTP email based on purpose"""
    subject = ""
    message = ""
    
    if purpose == 'registration':
        subject = "DPI Platform - Verify Your Registration"
        message = f"Hello {user.first_name},\n\nYour OTP for registration is: {otp_code}\nThis code will expire in 10 minutes."
    elif purpose == 'password_reset':
        subject = "DPI Platform - Password Reset Request"
        message = f"Hello {user.username},\n\nYour OTP for password reset is: {otp_code}\nThis code will expire in 10 minutes."
    
    try:
        send_mail(
            subject,
            message,
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=False,
        )
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False

def send_admin_notification_email(user):
    """Notify user that their request reached admin"""
    subject = "DPI Platform - Account Request Received"
    message = f"Hello {user.first_name},\n\nYour request for the role of {user.get_role_display()} has been received and is currently under review by our administration. We will notify you once it's processed."
    
    try:
        send_mail(
            subject,
            message,
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=False,
        )
        return True
    except Exception as e:
        print(f"Error sending admin notification: {e}")
        return False

def send_approval_status_email(user, status, notes=""):
    """Notify user of approval/rejection status"""
    if status == 'approved':
        subject = "DPI Platform - Account Approved"
        message = f"Congratulations {user.first_name}!\n\nYour account has been approved. You can now log in to the portal."
    else:
        subject = "DPI Platform - Account Request Update"
        message = f"Hello {user.first_name},\n\nYour account request has been reviewed. Status: REJECTED.\nNotes: {notes}"
    
    try:
        send_mail(
            subject,
            message,
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=False,
        )
        return True
    except Exception as e:
        print(f"Error sending status email: {e}")
        return False
