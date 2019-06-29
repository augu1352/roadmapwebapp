from django import forms


class CreateUserForm(forms.Form):
    username = forms.CharField(label="Username")
    email = forms.EmailField(label="Email Address")
    password = forms.CharField(widget=forms.PasswordInput())
    confirm_password = forms.CharField(widget=forms.PasswordInput())
    # termsAndConditions = forms.MultipleChoiceField(widget=forms.CheckboxInput(), choices=[("agree", "I agree to the terms and conditions")])



class LoginForm(forms.Form):
    username = forms.CharField(label="Username")
    password = forms.CharField(widget=forms.PasswordInput())
