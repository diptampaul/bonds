from django.http.response import HttpResponse, JsonResponse
from django.utils import timezone
from django.core.exceptions import BadRequest
from django.views.decorators.csrf import csrf_exempt
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.parsers import FileUploadParser
from dashboard.models import Profile, UserLogin
import os
import logging
import json
logger = logging.getLogger('django')

# Create your views here.
class HomeView(APIView):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    def get(self, request):
        return HttpResponse("Welcome !! Diptam Bonds")

    def post(self, request):
        received_json_data=json.loads(request.body)
        login_token = received_json_data['login_token']
        logger.info(f"Home page request => Login Token: {login_token}")

        try:
            login_obj = UserLogin.objects.get(login_token=login_token)
            profile_obj = Profile.objects.get(user_id=login_obj.user_id.user_id)
            print(profile_obj.login_pin)
            if profile_obj.login_pin == None or profile_obj.login_pin == "" or len(str(profile_obj.login_pin)) < 6:
                return JsonResponse({'errorCode': 2,
                    'message': "Ask for login pin",}, status=202)
            else:
                return JsonResponse(
                    {
                        'errorCode': 0,
                        'message': "Success",
                        'loginpin': profile_obj.login_pin,
                        'isLogined': True,
                    }, status=202)
        except Exception as e:
            logger.info(f"Home page load Failed ; Reason - {e}")
            return JsonResponse({'errorCode': 1,
                    'message': str(e),}, status=202)


class MainView(APIView):
    def post(self, request):
        received_json_data=json.loads(request.body)
        login_token = received_json_data['login_token']
        login_pin = received_json_data['login_pin']
        logger.info(f"Login Pin Submitted: {login_token}")

        try:
            if str(login_pin).isdigit() and len(str(login_pin)) == 6:
                pass
            else:
                raise BadRequest("INVALID PIN FORMAT")
        except Exception as e:
            logger.info(f"Email Verification Failed ; Reason - {e}")
            return JsonResponse({'errorCode': 1,
                    'message': str(e),}, status=202)