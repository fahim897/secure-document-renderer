FROM mcr.microsoft.com/playwright/python:v1.45.0-jammy

# Install Bengali/Indic fonts and shaping libraries
USER root
RUN apt-get update && apt-get install -y \
    fonts-beng \
    fonts-beng-extra \
    fonts-indic \
    fonts-noto-core \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# Copy our custom local fonts (Nikosh and Kalpurush) to the system font directory
COPY fonts/ /usr/share/fonts/truetype/

# Force update font cache to recognize Nikosh and Kalpurush natively
RUN fc-cache -f -v

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
