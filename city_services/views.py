from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action, api_view
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import CityStaff, ComplaintCategory, Complaint, ComplaintResponse
from .serializers import (
    CityStaffSerializer, ComplaintCategorySerializer,
    ComplaintSerializer, ComplaintResponseSerializer
)
from .ai_utils import analyze_complaint_priority
import logging

logger = logging.getLogger(__name__)

class ComplaintCategoryViewSet(viewsets.ModelViewSet):
    """Complaint category management"""
    queryset = ComplaintCategory.objects.all()
    serializer_class = ComplaintCategorySerializer
    permission_classes = [IsAuthenticated]

class ComplaintViewSet(viewsets.ModelViewSet):
    """Complaint management"""
    queryset = Complaint.objects.all()
    serializer_class = ComplaintSerializer
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated()]
    
    def get_queryset(self):
        user = self.request.user
        if not user.is_authenticated:
            return Complaint.objects.none()
            
        queryset = Complaint.objects.all().order_by('-created_at')
        
        if user.role == 'citizen':
            queryset = queryset.filter(citizen=user)
        
        # Category filtering
        category = self.request.query_params.get('category')
        if category:
            queryset = queryset.filter(category__name__iexact=category)
        
        # Priority filtering
        priority = self.request.query_params.get('priority')
        if priority:
            queryset = queryset.filter(priority__iexact=priority)
            
        return queryset
    
    def perform_create(self, serializer):
        """Create complaint and automatically assign AI-generated priority"""
        complaint = serializer.save(citizen=self.request.user)
        
        # Analyze and assign priority using AI
        try:
            category_name = complaint.category.name if complaint.category else ""
            ai_priority = analyze_complaint_priority(
                title=complaint.title,
                description=complaint.description,
                category=category_name
            )
            complaint.priority = ai_priority
            complaint.save(update_fields=['priority'])
            logger.info(f"Assigned AI priority '{ai_priority}' to complaint {complaint.complaint_id}")
        except Exception as e:
            logger.error(f"Failed to assign AI priority: {str(e)}")
            # Complaint is still created with default priority
    
    @action(detail=True, methods=['post'])
    def respond(self, request, pk=None):
        """Add response to complaint"""
        complaint = self.get_object()
        
        # Ensure staff profile exists
        staff, created = CityStaff.objects.get_or_create(
            user=request.user,
            defaults={
                'department': 'Operations',
                'designation': 'Field Officer',
                'employee_id': f"CITY-{request.user.username}",
                'jurisdiction': 'Central'
            }
        )
        
        response_serializer = ComplaintResponseSerializer(data=request.data)
        if response_serializer.is_valid():
            try:
                response_serializer.save(complaint=complaint, staff=staff)
                
                # Update complaint status
                complaint.status = 'in_progress'
                complaint.save()
                
                return Response(response_serializer.data, status=status.HTTP_201_CREATED)
            except Exception as e:
                return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(response_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['post'])
    def resolve(self, request, pk=None):
        """Mark complaint as resolved"""
        complaint = self.get_object()
        complaint.status = 'resolved'
        complaint.save()
        return Response({'message': 'Complaint resolved'})

@api_view(['GET'])
def dashboard_stats(request):
    """Get staff dashboard statistics"""
    if not request.user.is_authenticated or request.user.role != 'city_staff':
        return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
    
    staff, created = CityStaff.objects.get_or_create(
        user=request.user,
        defaults={
            'department': 'Operations',
            'designation': 'Field Officer',
            'employee_id': f"CITY-{request.user.username}",
            'jurisdiction': 'Central'
        }
    )
    
    stats = {
        'pending_complaints': Complaint.objects.filter(status='submitted').count(),
        'in_progress': Complaint.objects.filter(status='in_progress').count(),
        'resolved_this_month': Complaint.objects.filter(status='resolved').count(), # Simplified for now
    }
    
    return Response(stats)

class ComplaintResponseViewSet(viewsets.ModelViewSet):
    """Complaint response management"""
    queryset = ComplaintResponse.objects.all()
    serializer_class = ComplaintResponseSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_authenticated and user.role == 'city_staff':
            return ComplaintResponse.objects.filter(staff__user=user).order_by('-created_at')
        return ComplaintResponse.objects.none()
