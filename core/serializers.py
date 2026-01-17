from rest_framework import serializers
from .models import Service, ServiceProvider, ServiceRequest, DataExchange, SystemMetrics

class ServiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Service
        fields = '__all__'
        read_only_fields = ['created_by', 'created_at', 'updated_at']

class ServiceProviderSerializer(serializers.ModelSerializer):
    user_details = serializers.SerializerMethodField()
    
    class Meta:
        model = ServiceProvider
        fields = '__all__'
    
    def get_user_details(self, obj):
        return {
            'username': obj.user.username,
            'full_name': obj.user.get_full_name(),
            'email': obj.user.email
        }

class ServiceRequestSerializer(serializers.ModelSerializer):
    service_name = serializers.CharField(source='service.name', read_only=True)
    citizen_name = serializers.CharField(source='citizen.get_full_name', read_only=True)
    
    class Meta:
        model = ServiceRequest
        fields = '__all__'
        read_only_fields = ['reference_id', 'created_at', 'updated_at']
    
    def create(self, validated_data):
        # Generate unique reference ID
        import uuid
        validated_data['reference_id'] = f"REQ-{uuid.uuid4().hex[:8].upper()}"
        return super().create(validated_data)

class DataExchangeSerializer(serializers.ModelSerializer):
    class Meta:
        model = DataExchange
        fields = '__all__'

class SystemMetricsSerializer(serializers.ModelSerializer):
    class Meta:
        model = SystemMetrics
        fields = '__all__'
