from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
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
            return FarmerQuery.objects.all()
        if user.role == 'agri_officer':
            return FarmerQuery.objects.filter(assigned_to__user=user)
        elif user.role == 'citizen':
            return FarmerQuery.objects.filter(farmer=user)
        return FarmerQuery.objects.all()
    
    def perform_create(self, serializer):
        serializer.save(farmer=self.request.user)
    
    @action(detail=True, methods=['post'])
    def respond(self, request, pk=None):
        """Add advisory to query"""
        query = self.get_object()
        officer = AgriOfficer.objects.get(user=request.user)
        
        advisory_serializer = AgriAdvisorySerializer(data=request.data)
        if advisory_serializer.is_valid():
            advisory_serializer.save(query=query, officer=officer)
            
            # Update query status
            query.status = 'answered'
            query.save()
            
            return Response(advisory_serializer.data, status=status.HTTP_201_CREATED)
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
        officer = AgriOfficer.objects.get(user=self.request.user)
        serializer.save(officer=officer)
