# Weather API ViewSets - Readonly access to weather data
from rest_framework import viewsets, filters
from rest_framework.pagination import PageNumberPagination
from .models import WeatherData, FarmersWeatherAlert, WeatherForecast
from .serializers import WeatherDataSerializer, FarmersWeatherAlertSerializer, WeatherForecastSerializer

class StandardPagination(PageNumberPagination):
    page_size = 20  # Show 20 results per page

# WeatherData ViewSet - Current weather information
class WeatherDataViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = WeatherData.objects.all()  # All current weather records
    serializer_class = WeatherDataSerializer  # Convert to JSON
    pagination_class = StandardPagination  # Paginate results
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]  # Search and sort
    search_fields = ['location']  # Search by location name
    ordering = ['-recorded_at']  # Newest first

    def get_queryset(self):
        queryset = WeatherData.objects.all().order_by('-recorded_at')
        location = self.request.query_params.get('location')
        if location:
            queryset = queryset.filter(location__icontains=location)
        return queryset

# Weather Alert ViewSet - Farmer weather alerts
class FarmersWeatherAlertViewSet(viewsets.ModelViewSet):
    queryset = FarmersWeatherAlert.objects.all()  # All alerts
    serializer_class = FarmersWeatherAlertSerializer  # Convert to JSON
    pagination_class = StandardPagination  # Paginate
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]  # Filter
    search_fields = ['farmer__first_name', 'alert_type']  # Search
    ordering = ['-issued_at']  # Newest first

    def get_queryset(self):
        queryset = FarmersWeatherAlert.objects.all().order_by('-issued_at')
        farmer_id = self.request.query_params.get('farmer')
        if farmer_id:
            queryset = queryset.filter(farmer_id=farmer_id)
        return queryset

# Forecast ViewSet - Weather predictions
class WeatherForecastViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = WeatherForecast.objects.all()  # All forecasts
    serializer_class = WeatherForecastSerializer  # Convert to JSON
    pagination_class = StandardPagination  # Paginate
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]  # Filter
    search_fields = ['location']  # Search by location
    ordering = ['forecast_date']  # By date (earliest first)

    def get_queryset(self):
        queryset = WeatherForecast.objects.all().order_by('forecast_date')
        location = self.request.query_params.get('location')
        if location:
            queryset = queryset.filter(location__icontains=location)
        return queryset
