from django.conf import settings
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.html import strip_tags
import random, string

def random_char(y):
    return ''.join(random.choice(string.ascii_letters) for x in range(y))

#Sending Email Auth Key
def reset_password_email(email, first_name, token):
    subject = 'ATTENTION: FinnOne Account needs to be verified'

    ''' Normal Text Email
    message = "Hi {}, You are just two steps away to login again. Enter the OTP {} to verify your email. \n\n <b>OTP : {}".format(first_name, token, token)
    from_email = settings.EMAIL_HOST_USER
    recipient_list = [email]
    send_mail(subject, message, from_email, recipient_list, fail_silently=True)'''

    #Html Template Email
    context = {'email': email, 'first_name': first_name, 'token': token}
    html_message = render_to_string('email_templates/reset_password.html', {'context': context})
    plain_message = strip_tags(html_message)
    from_email = settings.EMAIL_HOST_USER
    recipient_list = [email]
    send_mail(subject, plain_message, from_email, recipient_list, html_message=html_message, fail_silently=False)