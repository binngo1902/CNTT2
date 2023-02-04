from django.db import models

# Create your models here.
class UploadImage(models.Model):
    image = models.ImageField(upload_to='images')  
    username = models.CharField(max_length=255)
    predictions = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)
    class Meta:
        ordering = ('-id',)