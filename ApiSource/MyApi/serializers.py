from rest_framework import serializers
from django.contrib.auth.models import User
from MyApi.models import UploadImage
# User Serializer
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username')
 

# Register Serializer
class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'password')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(validated_data['username'], validated_data['email'], validated_data['password'])

        return user

class UploadImageSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = UploadImage
        fields = ('id', 'username' ,'image')


class GetPredictSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(use_url=False)
    class Meta:
        model = UploadImage
        fields = ("image","predictions","created_at")