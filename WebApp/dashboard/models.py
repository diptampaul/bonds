from django.db import models

# Create your models here.
class Profile(models.Model):
    user_id = models.IntegerField(primary_key=True)
    photo = models.FileField(upload_to='dashboard/user_photo', null=True)
    email = models.CharField(max_length=50, null=False)
    username = models.CharField(max_length=20, null=False)
    first_name = models.CharField(max_length=30, null=False)
    last_name = models.CharField(max_length=30, null=False)
    password = models.CharField(max_length=50, null=False)
    is_active = models.BooleanField()
    is_verified = models.BooleanField()
    created_timestamp = models.DateTimeField(blank=False, auto_now_add=True)
    
    def __str__(self):
        return(str(self.username) + ' ' + str(self.email))
    
    
class UserKyc(models.Model):
    user_id = models.ForeignKey(Profile, to_field='user_id', on_delete=models.CASCADE)
    document = models.FileField(upload_to='dashboard/user_document', null=True)
    document_details= models.CharField(max_length=50)
    
    
class UserDetails(models.Model):
    user_id = models.ForeignKey(Profile, to_field='user_id', on_delete=models.CASCADE)
    phone_no = models.IntegerField()
    address1 = models.CharField(max_length=50)
    address2 = models.CharField(max_length=50)
    district = models.CharField(max_length=30)
    state = models.CharField(max_length=20)
    pincode = models.CharField(max_length=8)

    def __str__(self):
        return(str(self.user_id) + ' ' + str(self.phone_no) + ' ' + str(self.pincode))


class UserBankDetails(models.Model):
    user_id = models.ForeignKey(Profile, to_field='user_id', on_delete=models.CASCADE)
    bank_name = models.CharField(max_length=50)
    account_number = models.CharField(max_length=50)
    account_holder_name = models.CharField(max_length=80)
    IFSC_code = models.CharField(max_length=15)
    account_type = models.CharField(max_length=10)

    def __str__(self):
        return(str(self.user_id) + ' ' + str(self.bank_name) + ' ' + str(self.account_type))


class UserLogin(models.Model):
    user_id = models.ForeignKey(Profile, to_field='user_id', on_delete=models.CASCADE)
    login_time = models.DateTimeField(auto_now_add=True)
    last_login_time = models.DateTimeField(null=True)