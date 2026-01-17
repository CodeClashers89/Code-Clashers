from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import CustomUser, UserProfile, ApprovalRequest, OTP
import random
from datetime import datetime, timedelta

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['avatar', 'bio', 'city', 'state', 'pincode']

class CustomUserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(read_only=True)
    
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'role', 
                  'phone_number', 'address', 'is_approved', 'created_at', 'profile']
        read_only_fields = ['id', 'created_at', 'is_approved']

class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)
    
    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'password', 'password_confirm', 'first_name', 
                  'last_name', 'role', 'phone_number', 'address']
    
    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError("Passwords do not match")
        return data
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
        
        # Auto-approve citizens, others need approval
        if validated_data['role'] == 'citizen':
            validated_data['is_approved'] = True
        
        user = CustomUser.objects.create_user(password=password, **validated_data)
        
        # Create user profile
        UserProfile.objects.create(user=user)
        
        # Create approval request for service providers
        if user.role in ['doctor', 'city_staff', 'agri_officer']:
            ApprovalRequest.objects.create(
                user=user,
                request_type=user.role
            )
        
        return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    
    def validate(self, data):
        user = authenticate(**data)
        if not user:
            raise serializers.ValidationError("Invalid credentials")
        if not user.is_approved:
            raise serializers.ValidationError("Your account is pending approval")
        return {'user': user}

class ApprovalRequestSerializer(serializers.ModelSerializer):
    user = CustomUserSerializer(read_only=True)
    
    class Meta:
        model = ApprovalRequest
        fields = '__all__'
