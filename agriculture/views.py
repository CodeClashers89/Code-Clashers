from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import AgriOfficer, CropCategory, FarmerQuery, AgriAdvisory, AgriUpdate
from .serializers import (
    AgriOfficerSerializer, CropCategorySerializer, FarmerQuerySerializer,
    AgriAdvisorySerializer, AgriUpdateSerializer
)

class CropCategoryViewSet(viewsets.ModelViewSet):
    """Crop category management"""
    queryset = CropCategory.objects.all()
    serializer_class = CropCategorySerializer
    permission_classes = [IsAuthenticated]

class FarmerQueryViewSet(viewsets.ModelViewSet):
    """Farmer query management"""
    queryset = FarmerQuery.objects.all()
    serializer_class = FarmerQuerySerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if not user.is_authenticated:
            return FarmerQuery.objects.none()
        if user.role == 'agri_officer':
            # Allow officers to see all queries to pick them up
            return FarmerQuery.objects.all().order_by('-created_at')
        elif user.role == 'citizen':
            return FarmerQuery.objects.filter(farmer=user).order_by('-created_at')
        return FarmerQuery.objects.all()
    
    def perform_create(self, serializer):
        serializer.save(farmer=self.request.user)
    
    @action(detail=True, methods=['post'])
    def respond(self, request, pk=None):
        """Add advisory to query"""
        query = self.get_object()
        officer, created = AgriOfficer.objects.get_or_create(
            user=request.user,
            defaults={
                'department': 'Agriculture',
                'specialization': 'General Officer',
                'employee_id': f"EMP-{request.user.username}",
                'district': 'Central District'
            }
        )
        
        print(f"[DEBUG] Respond Action - Query: {query.query_id}, Officer: {officer.user.username}")
        print(f"[DEBUG] Request Data: {request.data}")
        
        advisory_serializer = AgriAdvisorySerializer(data=request.data)
        if advisory_serializer.is_valid():
            try:
                advisory_serializer.save(query=query, officer=officer)
                
                # Update query status
                query.status = 'answered'
                query.save()
                
                return Response(advisory_serializer.data, status=status.HTTP_201_CREATED)
            except Exception as e:
                print(f"[DEBUG] Save Exception: {e}")
                return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        
        print(f"[DEBUG] Validation Errors: {advisory_serializer.errors}")
        return Response(advisory_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['post'])
    def validate_advisory(self, request, pk=None):
        """Validate an advisory (senior officer)"""
        query = self.get_object()
        advisory_id = request.data.get('advisory_id')
        
        try:
            advisory = AgriAdvisory.objects.get(id=advisory_id, query=query)
            advisory.is_validated = True
            advisory.validated_by = AgriOfficer.objects.get(user=request.user)
            advisory.save()
            return Response({'message': 'Advisory validated'})
        except AgriAdvisory.DoesNotExist:
            return Response({'error': 'Advisory not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_stats(request):
    """Get officer dashboard statistics"""
    if request.user.role != 'agri_officer':
        return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
    
    # Calculate stats
    pending_queries = FarmerQuery.objects.filter(status__in=['submitted', 'under_review']).count()
    try:
        officer, created = AgriOfficer.objects.get_or_create(
            user=request.user,
            defaults={
                'department': 'Agriculture',
                'specialization': 'General Officer',
                'employee_id': f"EMP-{request.user.username}",
                'district': 'Central District'
            }
        )
        advisories = AgriAdvisory.objects.filter(officer=officer).count()
        updates = AgriUpdate.objects.filter(officer=officer).count()
    except Exception as e:
        print(f"Stats Error: {e}")
        advisories = 0
        updates = 0
    
    return Response({
        'pending_queries': pending_queries,
        'advisories_given': advisories,
        'updates_posted': updates
    })

class AgriAdvisoryViewSet(viewsets.ReadOnlyModelViewSet):
    """View given advisories"""
    serializer_class = AgriAdvisorySerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.role == 'agri_officer':
            return AgriAdvisory.objects.filter(officer__user=user).select_related('query').order_by('-created_at')
        return AgriAdvisory.objects.none()

class AgriUpdateViewSet(viewsets.ModelViewSet):
    """Agricultural update management"""
    queryset = AgriUpdate.objects.all()
    serializer_class = AgriUpdateSerializer
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated()]
    
    def get_queryset(self):
        queryset = AgriUpdate.objects.all().order_by('-created_at')
        district = self.request.query_params.get('district')
        update_type = self.request.query_params.get('type')
        
        if district:
            queryset = queryset.filter(district=district)
        if update_type:
            queryset = queryset.filter(update_type=update_type)
        
        return queryset
    
    def perform_create(self, serializer):
        officer, created = AgriOfficer.objects.get_or_create(
            user=self.request.user,
            defaults={
                'department': 'Agriculture',
                'specialization': 'General Officer',
                'employee_id': f"EMP-{self.request.user.username}",
                'district': 'Central District'
            }
        )
        serializer.save(officer=officer)
