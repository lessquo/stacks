from django.db import models


class User(models.Model):
    id = models.UUIDField(
        primary_key=True, db_default=models.Func(function='uuidv7'), editable=False
    )
    email = models.TextField(unique=True)
    created_at = models.DateTimeField(db_default=models.Func(function='now'))
    updated_at = models.DateTimeField(db_default=models.Func(function='now'))

    class Meta:
        db_table = 'users'
