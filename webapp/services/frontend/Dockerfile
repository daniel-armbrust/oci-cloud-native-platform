FROM container-registry.oracle.com/os/oraclelinux:8-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
COPY ./app .

RUN microdnf update -y && \
    microdnf install -y python3.11 && \
    python -m ensurepip && \
    python -m pip install --no-cache-dir --upgrade pip setuptools && \
    pip install --no-cache-dir -r requirements.txt && \
    microdnf clean all && rm -rf /var/cache/yum

EXPOSE 8080

CMD ["python", "main.py"]
