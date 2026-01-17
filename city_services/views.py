from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import CityStaff, ComplaintCategory, Complaint, ComplaintResponse
from .serializers import (
    CityStaffSerializer, ComplaintCategorySerializer,
    ComplaintSerializer, ComplaintResponseSerializer
)

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
            return Complaint.objects.all()
        if user.role == 'city_staff':
            return Complaint.objects.filter(assigned_to__user=user)
        elif user.role == 'citizen':
            return Complaint.objects.filter(citizen=user)
        return Complaint.objects.all()
    
    def perform_create(self, serializer):
        serializer.save(citizen=self.request.user)
    
    @action(detail=True, methods=['post'])
    def respond(self, request, pk=None):
        """Add response to complaint"""
        complaint = self.get_object()
        staff = CityStaff.objects.get(user=request.user)
        
        response_serializer = ComplaintResponseSerializer(data=request.data)
        if response_serializer.is_valid():
            response_serializer.save(complaint=complaint, staff=staff)
            
            # Update complaint status
            complaint.status = 'in_progress'
            complaint.save()
            
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        return Response(response_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['post'])
    def resolve(self, request, pk=None):
        """Mark complaint as resolved"""
        complaint = self.get_object()
        complaint.status = 'resolved'
        complaint.save()
        return Response({'message': 'Complaint resolved'})

class ComplaintResponseViewSet(viewsets.ModelViewSet):
    """Complaint response management"""
    queryset = ComplaintResponse.objects.all()
    serializer_class = ComplaintResponseSerializer
    permission_classes = [IsAuthenticated]
