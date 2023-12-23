FROM lwthiker/curl-impersonate:0.5-chrome-alpine AS builder

FROM python:3.12-alpine3.19

ENV PYTHONFAULTHANDLER=1 \
     PYTHONUNBUFFERED=1 \
     PYTHONDONTWRITEBYTECODE=1 \
     PIP_DISABLE_PIP_VERSION_CHECK=on\
     POETRY_VERSION=1.7.0

COPY --from=builder /usr/local /usr/local

RUN apk --no-cache add ffmpeg build-base nss ca-certificates

WORKDIR /app

COPY poetry.lock pyproject.toml ./
RUN pip install --upgrade pip && pip install poetry

RUN poetry config virtualenvs.create false \
  && poetry install --only main --no-interaction --no-ansi

# I don't like that I have to do this. Not one bit.
RUN ln -s /etc/ssl/certs/ca-certificates.crt /usr/local/lib/python3.12/site-packages/curl_cffi/cacert.pem

RUN apk del build-base

WORKDIR /app
COPY . .

ENTRYPOINT ["python", "bot/main.py"]