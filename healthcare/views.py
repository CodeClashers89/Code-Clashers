from rest_framework import viewsets, status, permissions
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Doctor, Appointment, MedicalRecord, Prescription, FollowUp, DoctorUnavailability
from .serializers import (
    DoctorSerializer, AppointmentSerializer, MedicalRecordSerializer,
    PrescriptionSerializer, FollowUpSerializer, DoctorUnavailabilitySerializer
)

class DoctorViewSet(viewsets.ModelViewSet):
    """Doctor management"""
    queryset = Doctor.objects.filter(user__is_approved=True)
    serializer_class = DoctorSerializer
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve', 'available']:
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated()]
    
    @action(detail=False, methods=['get'])
    def available(self, request):
        """Get available doctors"""
        doctors = Doctor.objects.filter(is_available=True, user__is_approved=True)
        serializer = self.get_serializer(doctors, many=True)
        return Response(serializer.data)

class AppointmentViewSet(viewsets.ModelViewSet):
    """Appointment management"""
    queryset = Appointment.objects.all()
    serializer_class = AppointmentSerializer
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated()]
    
    def get_queryset(self):
        user = self.request.user
        if not user.is_authenticated:
            return Appointment.objects.all()
        if user.role == 'doctor':
            return Appointment.objects.filter(doctor__user=user)
        elif user.role == 'citizen':
            return Appointment.objects.filter(patient=user)
        return Appointment.objects.all()
    
    def perform_create(self, serializer):
        serializer.save(patient=self.request.user)
    
    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        """Mark appointment as completed"""
        appointment = self.get_object()
        appointment.status = 'completed'
        appointment.save()
        return Response({'message': 'Appointment completed'})

class MedicalRecordViewSet(viewsets.ModelViewSet):
    """Medical record management"""
    queryset = MedicalRecord.objects.all()
    serializer_class = MedicalRecordSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.role == 'doctor':
            return MedicalRecord.objects.filter(doctor__user=user)
        elif user.role == 'citizen':
            return MedicalRecord.objects.filter(patient=user)
        return MedicalRecord.objects.all()
    
    @action(detail=False, methods=['get'])
    def patient_history(self, request):
        """Get patient medical history"""
        patient_id = request.query_params.get('patient_id')
        if patient_id:
            records = MedicalRecord.objects.filter(patient_id=patient_id).order_by('-created_at')
            serializer = self.get_serializer(records, many=True)
            return Response(serializer.data)
        return Response({'error': 'patient_id required'}, status=status.HTTP_400_BAD_REQUEST)

class PrescriptionViewSet(viewsets.ModelViewSet):
    """Prescription management"""
    queryset = Prescription.objects.all()
    serializer_class = PrescriptionSerializer
    permission_classes = [IsAuthenticated]

class DoctorUnavailabilityViewSet(viewsets.ModelViewSet):
    """Doctor unavailability management"""
    queryset = DoctorUnavailability.objects.all()
    serializer_class = DoctorUnavailabilitySerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        if self.request.user.role == 'doctor':
            return DoctorUnavailability.objects.filter(doctor__user=self.request.user)
        return DoctorUnavailability.objects.all()
