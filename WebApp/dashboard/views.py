from django.http.response import HttpResponse, JsonResponse
from django.contrib.auth.models import User, auth
from django.contrib.auth.decorators import login_required
from django.utils import timezone
from django.core.exceptions import BadRequest
from django.views.decorators.csrf import csrf_exempt
from rest_framework.views import APIView
from rest_framework.parsers import FileUploadParser
from .models import *
import os
import logging
import json
logger = logging.getLogger('django')



# Create your views here.
class DashboardView(APIView):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    def get(self, request):
        if request.user.is_authenticated:
            logger.info("Home Screen")
            return HttpResponse("Welcome !! Diptam Bonds")
        else:
            return JsonResponse({
                'errorCode': 0,
                'message': "User is not authenticated",
                'isLogined': False,
            }, status=202)


class GetUserNames(APIView):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    def get(self, request):
        all_users = User.objects.all()
        usernames = []
        for user in all_users:
            usernames.append(user.username)
        return JsonResponse({
            'errorCode': 0,
           'message': "Success",
           'usernames': usernames,}, status=202)

class SignIn(APIView):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    def post(self, request):
        received_json_data=json.loads(request.body)
        email = received_json_data['email'].lower()
        password = received_json_data['password']
        logger.info(f"Login Request => email: {email}")
        user = auth.authenticate(email=email, password=password)
        user_obj = ProfileUserMap.objects.filter(user=user)
        if user is not None:
            if user_obj:
                customer_id = user_obj[0].customer_id    
                auth.login(request, user)
                logger.info(f"Login Successfully")
                #Update login table
                user_login_obj = UserLogin.objects.get(user_id=customer_id)
                user_login_obj.last_login_time = user_login_obj.login_time
                user_login_obj.login_time = timezone.now()
                user_login_obj.save()
                return JsonResponse(
                    {
                        'errorCode': 0,
                        'message': "User is authenticated",
                        'isLogined': True,
                    }, status=202)
        
        logger.info(f"Login Failed")
        return JsonResponse(
            {
                'errorCode': 0,
                'message': "User is not authenticated",
                'isLogined': False,
            }, status=202)


class SignUp(APIView):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    def post(self, request):
        received_json_data=json.loads(request.body)
        first_name = received_json_data['first_name']
        last_name = received_json_data['last_name']
        email = received_json_data['email'].lower()
        password = received_json_data['password']
        logger.info(f"Sign Up Request => email: {email} ; first_name: {first_name} ; last_name: {last_name}")

        try:
            if User.objects.filter(email=email).exists():
                raise BadRequest("Email id is already in use; Try Forget Password")
            #Create the user
            user = User.objects.create_user(username=email, password=password, email=email, first_name=first_name, last_name=last_name)
            user.save()

            profile_obj = Profile(email=email, first_name=first_name, last_name=last_name,password=password, is_active=True, is_verified=False)
            profile_obj.save()

            profile_user_map_obj = ProfileUserMap(user=user, customer_id=profile_obj)
            profile_user_map_obj.save()

            user_login_obj = UserLogin(user_id=profile_obj, login_time=timezone.now())
            user_login_obj.save()

            #login the user
            auth.login(request, user)
            logger.info(f"Sign up and Login Successfully")

            return JsonResponse(
                    {
                        'errorCode': 0,
                        'message': "User is registered and logged in",
                        'isLogined': True,
                    }, status=202)

        except Exception as e:
            logger.info(f"Sign Up Failed {e}")
            return JsonResponse({'errorCode': 1,
                    'message': str(e),}, status=202)