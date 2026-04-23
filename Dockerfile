FROM python:3.11-slim

# WeasyPrint system dependencies (PDF export)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpango-1.0-0 \
    libpangoft2-1.0-0 \
    libpangocairo-1.0-0 \
    libcairo2 \
    libgdk-pixbuf2.0-0 \
    libffi8 \
    shared-mime-info \
    fonts-liberation \
    fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Sauvegarde des fichiers statiques pour initialisation au premier démarrage
RUN cp -r /app/static /app/static_default

# Répertoires de données (écrasés par le volume)
RUN mkdir -p /data/uploads /data/backups

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV DATA_DIR=/data
ENV PYTHONUNBUFFERED=1

EXPOSE 5050

ENTRYPOINT ["/docker-entrypoint.sh"]
