from django.http.response import HttpResponse
from django.utils import timezone
from django.core.exceptions import BadRequest
from django.views.decorators.csrf import csrf_exempt
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.parsers import FileUploadParser
import os
import logging
logger = logging.getLogger('django')

# Create your views here.
class DashboardView(APIView):
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    def get(self, request):
        return HttpResponse("Welcome !! Diptam Bonds")