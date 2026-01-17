from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, UserProfile, ApprovalRequest, OTP

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    list_display = ['username', 'email', 'role', 'is_approved', 'is_active', 'created_at']
    list_filter = ['role', 'is_approved', 'is_active']
    search_fields = ['username', 'email', 'phone_number']
    
    fieldsets = UserAdmin.fieldsets + (
        ('Additional Info', {'fields': ('role', 'phone_number', 'address', 'is_approved')}),
    )

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'city', 'state']
    search_fields = ['user__username', 'city', 'state']

@admin.register(ApprovalRequest)
class ApprovalRequestAdmin(admin.ModelAdmin):
    list_display = ['user', 'request_type', 'status', 'requested_at', 'reviewed_by']
    list_filter = ['status', 'request_type']
    search_fields = ['user__username']
    
@admin.register(OTP)
class OTPAdmin(admin.ModelAdmin):
    list_display = ['user', 'otp_code', 'purpose', 'is_verified', 'created_at']
    list_filter = ['purpose', 'is_verified']
