"""
WSGI config for roadmapper project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/2.1/howto/deployment/wsgi/
"""

import os
import sys

sys.path.append("/home/augu1352/roadmapRepo/roadmapwebapp/roadmapper")
sys.path.append("/home/augu1352/roadmapRepo/roadmapwebapp/roadmapper/roadmapper")
sys.path.append("/usr/bin/python3.6/site-packages")
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'roadmapper.settings')

application = get_wsgi_application()
