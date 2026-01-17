from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from .models import Service, ServiceProvider, ServiceRequest, SystemMetrics
from .serializers import (
    ServiceSerializer, ServiceProviderSerializer, 
    ServiceRequestSerializer, SystemMetricsSerializer
)

class ServiceViewSet(viewsets.ModelViewSet):
    """Service registry management"""
    queryset = Service.objects.filter(is_active=True)
    serializer_class = ServiceSerializer
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [IsAuthenticated()]
    
    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

class ServiceRequestViewSet(viewsets.ModelViewSet):
    """Unified service request tracking"""
    queryset = ServiceRequest.objects.all()
    serializer_class = ServiceRequestSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.role == 'citizen':
            return ServiceRequest.objects.filter(citizen=user)
        elif user.role == 'admin':
            return ServiceRequest.objects.all()
        else:
            # Service providers see assigned requests
            return ServiceRequest.objects.filter(provider__user=user)
    
    def perform_create(self, serializer):
        serializer.save(citizen=self.request.user)

@api_view(['GET'])
@permission_classes([AllowAny])
def dashboard_stats(request):
    """Get dashboard statistics"""
    from django.db.models import Count
    from accounts.models import CustomUser
    from healthcare.models import Appointment
    from city_services.models import Complaint
    from agriculture.models import FarmerQuery
    
    stats = {
        'total_users': CustomUser.objects.count(),
        'total_services': Service.objects.filter(is_active=True).count(),
        'total_requests': ServiceRequest.objects.count(),
        'pending_approvals': 0,
        'healthcare': {
            'total_appointments': Appointment.objects.count(),
            'pending_appointments': Appointment.objects.filter(status='scheduled').count(),
        },
        'city_services': {
            'total_complaints': Complaint.objects.count(),
            'pending_complaints': Complaint.objects.filter(status='submitted').count(),
        },
        'agriculture': {
            'total_queries': FarmerQuery.objects.count(),
            'pending_queries': FarmerQuery.objects.filter(status='submitted').count(),
        }
    }
    
    if request.user.is_authenticated and hasattr(request.user, 'role') and request.user.role == 'admin':
        from accounts.models import ApprovalRequest
        stats['pending_approvals'] = ApprovalRequest.objects.filter(status='pending').count()
    
    return Response(stats)
