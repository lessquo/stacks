from django.db import IntegrityError, transaction
from rest_framework import mixins, viewsets
from rest_framework.exceptions import APIException

from apps.users.models import User
from apps.users.serializers import UserSerializer


class Conflict(APIException):
    status_code = 409
    default_detail = 'Email already exists.'


class UserViewSet(mixins.CreateModelMixin,
                  mixins.RetrieveModelMixin,
                  viewsets.GenericViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def perform_create(self, serializer):
        try:
            with transaction.atomic():
                serializer.save()
        except IntegrityError as error:
            if getattr(error.__cause__, 'sqlstate', None) == '23505':
                raise Conflict()
            raise
