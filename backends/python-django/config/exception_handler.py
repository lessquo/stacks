from http import HTTPStatus

from rest_framework.views import exception_handler


def problem_detail_handler(exc, context):
    response = exception_handler(exc, context)
    if response is None:
        return response

    data = response.data
    if isinstance(data, dict) and set(data) == {'detail'}:
        detail = str(data['detail'])
    elif isinstance(data, dict):
        detail = '; '.join(
            f"{field}: {' '.join(str(m) for m in messages)}"
            if isinstance(messages, (list, tuple)) else f"{field}: {messages}"
            for field, messages in data.items()
        )
    else:
        detail = str(data)

    response.data = {
        'status': response.status_code,
        'title': HTTPStatus(response.status_code).phrase,
        'detail': detail,
    }
    response.content_type = 'application/problem+json'
    return response
