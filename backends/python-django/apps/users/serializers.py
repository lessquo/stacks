from rest_framework import serializers

from apps.users.models import User


class UserSerializer(serializers.ModelSerializer):
    createdAt = serializers.DateTimeField(source='created_at', read_only=True)
    updatedAt = serializers.DateTimeField(source='updated_at', read_only=True)

    class Meta:
        model = User
        fields = ['id', 'email', 'createdAt', 'updatedAt']
