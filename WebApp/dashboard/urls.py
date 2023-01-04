from django.urls import path
from . import views


urlpatterns = [
    path('',views.DashboardView.as_view(), name='dashboard'),
    path('get-usernames/',views.GetUserNames.as_view(), name='getusernames'),
    path('sign-in/',views.SignIn.as_view(), name='signin'),
    path('sign-up/',views.SignUp.as_view(), name='signup'),
    path('email-verify/',views.EmailVerify.as_view(), name='email-verify'),
    path('reset-password/',views.ResetPassword.as_view(), name='reset-password'),
    path('add-login-pin/',views.AddLoginPin.as_view(), name='add-login-pin'),
    path('get-details/',views.GetUserDetails.as_view(), name='get-details'),
]