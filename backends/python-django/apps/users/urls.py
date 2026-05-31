from rest_framework.routers import SimpleRouter

from apps.users.views import UserViewSet

router = SimpleRouter(trailing_slash=False)
router.register('users', UserViewSet)

urlpatterns = router.urls
