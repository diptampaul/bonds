from django.urls import path
from . import views


urlpatterns = [
    path('',views.HomeView.as_view(), name='home'),
    path('main/',views.MainView.as_view(), name='main'),
]