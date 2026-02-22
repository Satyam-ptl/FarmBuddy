from django.db import models

# Create your models here.
class Crop(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    optimal_temperature = models.FloatField()
    optimal_humidity = models.FloatField()
    optimal_soil_moisture = models.FloatField()

    def __str__(self):
        return self.name