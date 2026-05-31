from django.contrib import admin
from django.urls import include, path

from config.views import health

urlpatterns = [
    path('', health),
    path('admin/', admin.site.urls),
    path('', include('apps.users.urls')),
]
