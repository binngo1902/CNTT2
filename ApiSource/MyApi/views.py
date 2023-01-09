from rest_framework import generics, permissions
from rest_framework.response import Response
from knox.models import AuthToken
from .serializers import UserSerializer, RegisterSerializer, UploadImageSerializer , GetPredictSerializer
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser ,FormParser
from rest_framework import status

# Register API
class RegisterAPI(generics.GenericAPIView):
    serializer_class = RegisterSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response({
        "user": UserSerializer(user, context=self.get_serializer_context()).data,
        "token": AuthToken.objects.create(user)[1]
        })

from django.contrib.auth import login

from rest_framework import permissions
from rest_framework.authtoken.serializers import AuthTokenSerializer
from knox.views import LoginView as KnoxLoginView
from django.contrib.auth.models import User
class LoginAPI(KnoxLoginView):
    permission_classes = (permissions.AllowAny,)

    def post(self, request, format=None):
        serializer = AuthTokenSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        login(request, user)
        return super(LoginAPI, self).post(request, format=None)

class UserAPI(generics.ListCreateAPIView):
    # permission_classes = [permissions.IsAuthenticated, ]
    model = User
    serializer_class = UserSerializer

    def get_queryset(self):
        return User.objects.all()


class UploadImageAPI(APIView):
    permission_classes = [permissions.IsAuthenticated, ]
    parser_classes = [MultiPartParser, FormParser]

    def post(self,request,format=None):
        serializer = UploadImageSerializer(data = request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data,status= status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status= status.HTTP_400_BAD_REQUEST)

class GetPredict(generics.ListCreateAPIView):
    permission_classes = [permissions.IsAuthenticated, ]
    model = User
    serializer_class = GetPredictSerializer

    def get_queryset(self,request):
        print(request)
        return User.objects.filter(username="binngo1903").all()
