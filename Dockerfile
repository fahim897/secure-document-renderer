FROM mcr.microsoft.com/playwright/python:v1.45.0-jammy

# Install Bengali/Indic fonts and shaping libraries to fix Bengali conjunct character breaking
USER root
RUN apt-get update && apt-get install -y \
    fonts-beng \
    fonts-beng-extra \
    fonts-indic \
    fonts-noto-core \
    fontconfig \
    && fc-cache -f -v \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
