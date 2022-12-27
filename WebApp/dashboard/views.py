from django.http.response import HttpResponse, JsonResponse
from django.contrib.auth.models import User, auth
from django.contrib.auth.decorators import login_required
from django.utils import timezone
from django.core.exceptions import BadRequest
from django.views.decorators.csrf import csrf_exempt
from rest_framework.views import APIView
from rest_framework.parsers import FileUploadParser
from .models import *
from .utils import random_char, reset_password_email
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
    def post(self, request):
        received_json_data=json.loads(request.body)
        email = received_json_data['email'].lower()
        password = received_json_data['password']
        logger.info(f"Login Request => email: {email}")
        user = auth.authenticate(username=email, password=password)
        user_obj = ProfileUserMap.objects.filter(user=user)
        if user is not None:
            if user_obj:
                customer_id = user_obj[0].customer_id    
                logger.info(f"Login Successfully")
                #Update login table
                user_login_obj = UserLogin.objects.get(user_id=customer_id)
                user_login_obj.last_login_time = user_login_obj.login_time
                user_login_obj.login_time = timezone.now()
                token_id = user_login_obj.login_token
                user_login_obj.save()
                return JsonResponse(
                    {
                        'errorCode': 0,
                        'message': "User is authenticated",
                        'isLogined': True,
                        'token': token_id,
                    }, status=202)
        
        logger.info(f"Login Failed")
        return JsonResponse(
            {
                'errorCode': 0,
                'message': "User is not authenticated",
                'isLogined': False,
            }, status=202)


class SignUp(APIView):
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
            user_id = profile_obj.user_id

            profile_user_map_obj = ProfileUserMap(user=user, customer_id=profile_obj)
            profile_user_map_obj.save()

            token_id  = f"{random_char(8)}{user_id}"
            user_login_obj = UserLogin(user_id=profile_obj, login_time=timezone.now(), login_token=token_id)
            user_login_obj.save()

            logger.info(f"Sign up and Login Successfully")

            return JsonResponse(
                    {
                        'errorCode': 0,
                        'message': "User is registered and logged in",
                        'isLogined': True,
                        'token': token_id,
                    }, status=202)

        except Exception as e:
            logger.info(f"Sign Up Failed {e}")
            return JsonResponse({'errorCode': 1,
                    'message': str(e),}, status=202)

class ResetPassword(APIView):
    def post(self, request):
        received_json_data=json.loads(request.body)
        email = received_json_data['email']
        dropdownvalue = received_json_data['dropdownvalue']
        new_password = received_json_data['new_password']
        logger.info(f"{dropdownvalue} Request => email: {email}")

        try:
            if dropdownvalue == "Reset Password":
                user_obj = User.objects.get(email=email)
                user_obj.set_password(new_password)
                user_obj.save()

                profile_obj = Profile.objects.get(email=email)
                profile_obj.password = new_password
                profile_obj.save()
            elif dropdownvalue == "Reset Pin":
                profile_obj = Profile.objects.get(email=email)
                profile_obj.login_pin = new_password
                profile_obj.save()
            else:
                raise BadRequest("Invalid dropdownvalue")

            return JsonResponse({'errorCode': 0,
                    'message': "Reset Successfully",}, status=202)

        except Exception as e:
            logger.info(f"Reset Password Failed ; Reason - {e}")
            return JsonResponse({'errorCode': 1,
                    'message': str(e),}, status=202)


class EmailVerify(APIView):
    def post(self, request):
        received_json_data=json.loads(request.body)
        email = received_json_data['email']
        authToken = received_json_data['authToken']
        logger.info(f"Email Verify Request => email: {email}")

        try:
            if User.objects.filter(email=email).exists():
                profile_obj = Profile.objects.get(email=email)
                first_name = profile_obj.first_name
                reset_password_email(email, first_name, authToken)
                return JsonResponse({'errorCode': 0,
                    'message': "Success",}, status=202)
            else:
                raise BadRequest("Email id is not in use")
        except Exception as e:
            logger.info(f"Reset Password Failed ; Reason - {e}")
            return JsonResponse({'errorCode': 0,
                    'message': str(e),}, status=202)