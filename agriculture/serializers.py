from rest_framework import serializers
from .models import AgriOfficer, CropCategory, FarmerQuery, AgriAdvisory, AgriUpdate

class AgriOfficerSerializer(serializers.ModelSerializer):
    user_details = serializers.SerializerMethodField()
    
    class Meta:
        model = AgriOfficer
        fields = '__all__'
    
    def get_user_details(self, obj):
        return {
            'username': obj.user.username,
            'full_name': obj.user.get_full_name(),
            'email': obj.user.email
        }

class CropCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = CropCategory
        fields = '__all__'

class AgriAdvisorySerializer(serializers.ModelSerializer):
    officer_name = serializers.CharField(source='officer.user.get_full_name', read_only=True)
    
    class Meta:
        model = AgriAdvisory
        fields = '__all__'
        read_only_fields = ['created_at']

class FarmerQuerySerializer(serializers.ModelSerializer):
    advisories = AgriAdvisorySerializer(many=True, read_only=True)
    crop_name = serializers.CharField(source='crop_category.name', read_only=True)
    farmer_name = serializers.CharField(source='farmer.get_full_name', read_only=True)
    
    class Meta:
        model = FarmerQuery
        fields = '__all__'
        read_only_fields = ['query_id', 'created_at', 'updated_at']
    
    def create(self, validated_data):
        # Generate unique query ID
        import uuid
        validated_data['query_id'] = f"AGR-{uuid.uuid4().hex[:8].upper()}"
        return super().create(validated_data)

class AgriUpdateSerializer(serializers.ModelSerializer):
    officer_name = serializers.CharField(source='officer.user.get_full_name', read_only=True)
    crop_name = serializers.CharField(source='crop_category.name', read_only=True)
    
    class Meta:
        model = AgriUpdate
        fields = '__all__'
        read_only_fields = ['created_at']
