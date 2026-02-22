# Tasks API ViewSets - Task management for farmers
from rest_framework import viewsets, filters
from rest_framework.pagination import PageNumberPagination
from .models import FarmerTask, TaskReminder, TaskLog
from .serializers import FarmerTaskSerializer, TaskReminderSerializer, TaskLogSerializer

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

# Task Reminder ViewSet - Notifications for tasks
class TaskReminderViewSet(viewsets.ModelViewSet):
    queryset = TaskReminder.objects.all()  # All reminders
    serializer_class = TaskReminderSerializer  # Convert to JSON
    pagination_class = StandardPagination  # Paginate
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]  # Filter
    search_fields = ['task__task_name']  # Search by task name
    ordering = ['reminder_date']  # By date

# Task Log ViewSet - Task history and activity tracking
class TaskLogViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = TaskLog.objects.all()  # All task logs (read-only)
    serializer_class = TaskLogSerializer  # Convert to JSON
    pagination_class = StandardPagination  # Paginate
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]  # Filter
    search_fields = ['task__task_name']  # Search by task name
    ordering = ['-timestamp']  # Newest logs first
