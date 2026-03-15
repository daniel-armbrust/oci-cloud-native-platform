FROM container-registry.oracle.com/os/oraclelinux:8-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY scripts/seed-pizzas.py .
COPY scripts/seed-users.py .
COPY assets ./assets
COPY data ./data

RUN microdnf update -y && \
    microdnf install -y python3.11 && \
    python -m ensurepip && \
    python -m pip install --no-cache-dir --upgrade pip setuptools && \
    pip install --no-cache-dir oci borneo bcrypt mysql-connector-python faker && \
    microdnf clean all && rm -rf /var/cache/yum

CMD python seed-pizzas.py && python seed-users.py