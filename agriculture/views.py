from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import AgriOfficer, CropCategory, FarmerQuery, AgriAdvisory, AgriUpdate
from .serializers import (
    AgriOfficerSerializer, CropCategorySerializer, FarmerQuerySerializer,
    AgriAdvisorySerializer, AgriUpdateSerializer
)
from dpi_platform.forms import FarmerForm
from dpi_platform.utils import crop_model, yield_model, encoders
import numpy as np

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

@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def recommend_crop(request):
    """Recommend crop based on farmer input"""
    form = FarmerForm(request.data)
    if form.is_valid():
        data = form.cleaned_data

        try:
            # Transform inputs using loaded encoders
            # Note: The original code used encoders["location"].transform([data["location"]])[0]
            # We assume encoders is a dict of LabelEncoders or OneHotEncoders as per utils.py
            
            input_data = [
                encoders["location"].transform([data["location"]])[0],
                encoders["season"].transform([data["season"]])[0],
                encoders["soil_type"].transform([data["soil_type"]])[0],
                encoders["irrigation"].transform([data["irrigation"]])[0],
                encoders["rainfall"].transform([data["rainfall"]])[0],
                data["land_size"]
            ]

            X = np.array([input_data])

            crop = crop_model.predict(X)[0]
            # Check if yield_model predicts a scalar or array
            yield_pred = yield_model.predict(X)
            yield_level = yield_pred[0] if len(yield_pred.shape) > 0 else yield_pred

            # Advisory (rule-based)
            fertilizer_map = {
                "Rice": "Nitrogen-rich fertilizer & water retention needed",
                "Wheat": "Apply NPK fertilizer before tillering",
                "Cotton": "Potassium fertilizer & pest monitoring",
                "Maize": "Balanced NPK fertilizer",
                "Mustard": "Sulphur-rich fertilizer recommended"
            }

            advisory = fertilizer_map.get(crop, "General soil nutrient management")

            # Risk alert
            if data["rainfall"] == "Low":
                risk = "⚠️ Drought risk"
            elif data["rainfall"] == "High" and data["soil_type"] == "Clay":
                risk = "⚠️ Flood risk"
            else:
                risk = "No major risk detected"

            result = {
                "crop": crop,
                "yield_level": yield_level,
                "advisory": advisory,
                "risk": risk
            }
            return Response(result)

        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return Response(form.errors, status=status.HTTP_400_BAD_REQUEST)
