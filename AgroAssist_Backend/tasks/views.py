# Tasks API ViewSets - Task management for farmers
from rest_framework import viewsets, filters
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework.exceptions import PermissionDenied, ValidationError
from .models import FarmerTask, TaskReminder, TaskLog
from .serializers import FarmerTaskSerializer, TaskReminderSerializer, TaskLogSerializer
from AgroAssist_Backend.farmers.models import Farmer


def _linked_farmer_for_user(user):
    return Farmer.objects.filter(email__iexact=user.email).first()

class StandardPagination(PageNumberPagination):
    page_size = 20  # Show 20 results per page

# FarmerTask ViewSet - Task management for farmers
class FarmerTaskViewSet(viewsets.ModelViewSet):
    queryset = FarmerTask.objects.all()  # All farmer tasks
    serializer_class = FarmerTaskSerializer  # Convert to JSON
    pagination_class = StandardPagination  # Paginate results
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]  # Filter/sort
    search_fields = ['farmer__first_name', 'task_name']  # Search by farmer or task name
    ordering = ['due_date']  # Sort by due date (urgent first)
    
    # Require authentication (ADDED)
    permission_classes = [IsAuthenticated]
    
    def get_permissions(self):
        """Authenticated users can create; only admins can update/delete."""
        if self.action in ['update', 'partial_update', 'destroy']:
            return [IsAdminUser()]
        return super().get_permissions()
    
    def get_queryset(self):
        """Scope tasks: admins see all, farmers see only their assigned tasks."""
        user = self.request.user
        queryset = FarmerTask.objects.all()
        
        # Admins see all tasks
        if user.is_staff or user.is_superuser:
            return queryset
        
        # Farmers see only their assigned tasks
        farmer = _linked_farmer_for_user(user)
        if farmer:
            return queryset.filter(farmer=farmer)
        
        # Return empty if not admin and not linked farmer
        return queryset.none()

    def perform_create(self, serializer):
        user = self.request.user

        # Admins can create broadly; infer farmer from farmer_crop when omitted.
        if user.is_staff or user.is_superuser:
            farmer = serializer.validated_data.get('farmer')
            farmer_crop = serializer.validated_data.get('farmer_crop')

            if farmer is None and farmer_crop is not None:
                serializer.save(farmer=farmer_crop.farmer)
                return

            serializer.save()
            return

        # Farmers can create only for their own profile and own crop records.
        farmer = _linked_farmer_for_user(user)
        if not farmer:
            raise PermissionDenied('No farmer profile linked to this user.')

        farmer_crop = serializer.validated_data.get('farmer_crop')
        if not farmer_crop:
            raise ValidationError({'farmer_crop': ['This field is required.']})

        if farmer_crop.farmer_id != farmer.id:
            raise PermissionDenied('You can only create tasks for your own crops.')

        serializer.save(farmer=farmer)

# Task Reminder ViewSet - Notifications for tasks
class TaskReminderViewSet(viewsets.ModelViewSet):
    queryset = TaskReminder.objects.all()  # All reminders
    serializer_class = TaskReminderSerializer  # Convert to JSON
    pagination_class = StandardPagination  # Paginate
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]  # Filter
    search_fields = ['task__task_name']  # Search by task name
    ordering = ['reminder_date']  # By date
    permission_classes = [IsAuthenticated]

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAdminUser()]
        return super().get_permissions()

    def get_queryset(self):
        user = self.request.user
        queryset = TaskReminder.objects.select_related('task', 'task__farmer').all()

        if user.is_staff or user.is_superuser:
            return queryset

        farmer = _linked_farmer_for_user(user)
        if farmer:
            return queryset.filter(task__farmer=farmer)

        return queryset.none()

# Task Log ViewSet - Task history and activity tracking
class TaskLogViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = TaskLog.objects.all()  # All task logs (read-only)
    serializer_class = TaskLogSerializer  # Convert to JSON
    pagination_class = StandardPagination  # Paginate
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]  # Filter
    search_fields = ['task__task_name']  # Search by task name
    ordering = ['-timestamp']  # Newest logs first
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        queryset = TaskLog.objects.select_related('task', 'task__farmer').all()

        if user.is_staff or user.is_superuser:
            return queryset

        farmer = _linked_farmer_for_user(user)
        if farmer:
            return queryset.filter(task__farmer=farmer)

        return queryset.none()
