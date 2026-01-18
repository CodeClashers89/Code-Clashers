from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import CustomUser, UserProfile, ApprovalRequest, OTP
import random
from datetime import datetime, timedelta
from .utils import face_service

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['avatar', 'bio', 'city', 'state', 'pincode']

class CustomUserSerializer(serializers.ModelSerializer):
    profile = serializers.SerializerMethodField()
    
    def get_profile(self, obj):
        try:
            return UserProfileSerializer(obj.profile).data
        except UserProfile.DoesNotExist:
            return None
    
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'role', 
                  'phone_number', 'address', 'is_approved', 'created_at', 'profile']
        read_only_fields = ['id', 'created_at', 'is_approved']

from healthcare.models import Doctor

class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)
    face_image = serializers.ImageField(write_only=True, required=False)
    
    # Doctor specific fields
    specialization = serializers.CharField(write_only=True, required=False)
    consultation_fee = serializers.DecimalField(write_only=True, required=False, max_digits=10, decimal_places=2)
    
    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'password', 'password_confirm', 'first_name', 
                  'last_name', 'role', 'phone_number', 'address', 'face_image',
                  'specialization', 'consultation_fee']
    
    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError("Passwords do not match")
        
        if data.get('role') == 'doctor':
            if not data.get('specialization'):
                raise serializers.ValidationError({"specialization": "Specialization is required for doctors."})
            if not data.get('consultation_fee'):
                raise serializers.ValidationError({"consultation_fee": "Consultation fee is required for doctors."})
                
        return data
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
        
        # Extract extra fields
        face_image = validated_data.pop('face_image', None)
        specialization = validated_data.pop('specialization', 'General')
        consultation_fee = validated_data.pop('consultation_fee', 500.00)
        
        # Auto-approve citizens, others need approval
        if validated_data['role'] == 'citizen':
            validated_data['is_approved'] = True
        
        user = CustomUser.objects.create_user(password=password, **validated_data)
        
        # Create user profile
        profile = UserProfile.objects.create(user=user)
        
        # Handle face registration if image provided
        if face_image:
            face_image.seek(0)
            result = face_service.register_face(face_image, user.username)
            if 'face_token' in result:
                profile.face_token = result['face_token']
                face_image.seek(0)
                profile.avatar = face_image
                profile.save()
        
        # Create specific profiles based on role
        if user.role == 'doctor':
            # Create Doctor profile immediately
            # Generate a temporary license number
            import uuid
            temp_license = f"TMP-{uuid.uuid4().hex[:8].upper()}"
            
            Doctor.objects.create(
                user=user,
                specialization=specialization,
                consultation_fee=consultation_fee,
                qualification='Pending Verification', # Default
                license_number=temp_license,
                is_available=True
            )
            
            # Also create approval request
            ApprovalRequest.objects.create(user=user, request_type='doctor')
            
        elif user.role in ['city_staff', 'agri_officer']:
            ApprovalRequest.objects.create(
                user=user,
                request_type=user.role
            )
        
        return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    
    def validate(self, data):
        username = data.get('username')
        password = data.get('password')
        
        user = authenticate(username=username, password=password)
        
        # If username authentication fails, try email
        if not user and '@' in username:
            try:
                user_obj = CustomUser.objects.get(email=username)
                user = authenticate(username=user_obj.username, password=password)
            except CustomUser.DoesNotExist:
                pass
                
        if not user:
            raise serializers.ValidationError("Invalid credentials")
        if not user.is_approved:
            raise serializers.ValidationError("Your account is pending approval")
        return {'user': user}

class ApprovalRequestSerializer(serializers.ModelSerializer):
    user = CustomUserSerializer(read_only=True)
    reviewed_by_name = serializers.CharField(source='reviewed_by.get_full_name', read_only=True)
    
    class Meta:
        model = ApprovalRequest
        fields = '__all__'
        read_only_fields = ['reviewed_by', 'reviewed_at', 'status']
