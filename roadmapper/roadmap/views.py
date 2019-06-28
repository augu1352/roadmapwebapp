from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect, HttpRequest
from .forms import *
import psycopg2

# Create your views here.
def index(request):
    template = "index.html"
    context = {}
    response = render(request, template, context)

    return response


def createUser(request):
    if request.method == "POST":
        form = CreateUserForm(request.POST)

        if form.is_valid():
            username = form.cleaned_data["username"]
            email = form.cleaned_data["email"]
            password = form.cleaned_data["password"]

            conn = psycopg2.connect(dbname="roadmapDB", user="roadmapuser", password="roadmappassword", host="localhost")
            cur = conn.cursor()

            cur.callproc("fn_createuser", (username, email, password))

            conn.commit()
            cur.close()
            conn.close()

            return HttpResponseRedirect("/login/")
    form = CreateUserForm()
    template = "createUser.html"
    context = {"form": form}
    response = render(request, template, context)
    return response

def login(request):
    if request.method == "POST":
        form = LoginForm(request.POST)
        if form.is_valid():
            username = form.cleaned_data["username"]
            password = form.cleaned_data["password"]

            conn = psycopg2.connect(dbname="roadmapDB", user="roadmapuser", password="roadmappassword", host="localhost")
            cur = conn.cursor()

            cur.callproc("fn_checkpassword", (username, password))
            fetched = cur.fetchone()
            if "True" in str(fetched):
                response = HttpResponseRedirect("/roadmap/")
                cur.execute("BEGIN")
                cur.callproc("fn_createsessionid", [username])
                fetched = cur.fetchone()
                cur.execute("COMMIT")
                session_id = list(fetched)[0]

                response.set_cookie("session_id", session_id)
                conn.commit()
                cur.close()
                conn.close()
                return response
            else:
                message = "Wrong Password!"
                return render(request, "login.html", {"form": form, "message": message})



            return HttpResponseRedirect("/roadmap/")
    form = LoginForm()
    template = "login.html"
    context = {"form": form}
    response = render(request, template, context)
    return response


def roadmap(request):
    conn = psycopg2.connect(dbname="roadmapDB", user="roadmapuser", password="roadmappassword", host="localhost")
    cur = conn.cursor()

    if "session_id" in request.COOKIES:
        cur.callproc("fn_checksessionid", [request.COOKIES["session_id"]])
        fetched = cur.fetchone()
        if "True" in str(fetched):
            pass
        else:
            return HttpResponseRedirect("/")
    else:
        return HttpResponseRedirect("/")

    conn.commit()
    cur.close()
    conn.close()

    template = "roadmap.html"
    context = {}
    response = render(request, template, context)

    return response
