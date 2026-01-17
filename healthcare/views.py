from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from rest_framework import viewsets, status, permissions
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Doctor, Appointment, MedicalRecord, Prescription, FollowUp, DoctorUnavailability
from .serializers import (
    DoctorSerializer, AppointmentSerializer, MedicalRecordSerializer,
    PrescriptionSerializer, FollowUpSerializer, DoctorUnavailabilitySerializer
)

@login_required
def doctor_dashboard(request):
    """Doctor dashboard view"""
    if request.user.role != 'doctor':
        return render(request, 'error.html', {'message': 'Access denied. Doctor role required.'})
    return render(request, 'healthcare/doctor_dashboard.html')

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

from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from django.http import HttpResponse
from io import BytesIO

# ... existing imports ...

class MedicalRecordViewSet(viewsets.ModelViewSet):
    """Medical record management"""
    queryset = MedicalRecord.objects.all()
    serializer_class = MedicalRecordSerializer
    permission_classes = [IsAuthenticated]
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve', 'patient_history', 'prescription_pdf']:
            return [permissions.IsAuthenticated()]
        return [permissions.IsAuthenticated()]

    def perform_create(self, serializer):
        doctor = Doctor.objects.get(user=self.request.user)
        serializer.save(doctor=doctor)
    
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

    @action(detail=True, methods=['get'])
    def prescription_pdf(self, request, pk=None):
        """Generate PDF for prescription"""
        medical_record = self.get_object()
        doctor = medical_record.doctor
        patient = medical_record.patient
        prescriptions = medical_record.prescriptions.all()
        
        buffer = BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter)
        elements = []
        styles = getSampleStyleSheet()
        
        # Header
        elements.append(Paragraph(f"Dr. {doctor.user.get_full_name()}", styles['Heading1']))
        elements.append(Paragraph(f"{doctor.specialization}", styles['Normal']))
        elements.append(Paragraph(f"License: {doctor.license_number}", styles['Normal']))
        if doctor.hospital_affiliation:
            elements.append(Paragraph(f"{doctor.hospital_affiliation}", styles['Normal']))
        elements.append(Spacer(1, 20))
        
        # Patient Details
        elements.append(Paragraph(f"Patient: {patient.get_full_name()}", styles['Heading2']))
        elements.append(Paragraph(f"Date: {medical_record.created_at.date()}", styles['Normal']))
        elements.append(Paragraph(f"Diagnosis: {medical_record.diagnosis}", styles['Normal']))
        elements.append(Spacer(1, 20))
        
        # Prescriptions Table
        if prescriptions.exists():
            data = [['Medicine', 'Dosage', 'Frequency', 'Duration', 'Instructions']]
            for rx in prescriptions:
                data.append([
                    rx.medication_name, 
                    rx.dosage, 
                    rx.frequency, 
                    rx.duration,
                    rx.instructions
                ])
            
            table = Table(data, colWidths=[120, 80, 80, 80, 150])
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                ('GRID', (0, 0), (-1, -1), 1, colors.black),
            ]))
            elements.append(table)
        else:
            elements.append(Paragraph("No prescriptions.", styles['Normal']))
            
        elements.append(Spacer(1, 30))
        
        # Footer / Signature
        elements.append(Paragraph("Doctor's Signature:", styles['Normal']))
        elements.append(Spacer(1, 40))
        elements.append(Paragraph("_______________________", styles['Normal']))
        
        doc.build(elements)
        buffer.seek(0)
        return HttpResponse(buffer, content_type='application/pdf')

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

    def perform_create(self, serializer):
        doctor = Doctor.objects.get(user=self.request.user)
        serializer.save(doctor=doctor)
