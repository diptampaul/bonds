from django.urls import path
from . import views


urlpatterns = [
    path('',views.DashboardView.as_view(), name='dashboard'),
    path('get-usernames',views.GetUserNames.as_view(), name='getusernames'),
    path('sign-in/',views.SignIn.as_view(), name='signin'),
    path('sign-up/',views.SignUp.as_view(), name='signup'),
]