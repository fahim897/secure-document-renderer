FROM mcr.microsoft.com/playwright/python:v1.45.0-jammy

# Install Bengali/Indic fonts, shaping libraries, and wget
USER root
RUN apt-get update && apt-get install -y \
    fonts-beng \
    fonts-beng-extra \
    fonts-indic \
    fonts-noto-core \
    fontconfig \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download Nikosh and Kalpurush directly into the system fonts directory
RUN mkdir -p /usr/share/fonts/truetype/custom \
    && wget -O /usr/share/fonts/truetype/custom/Nikosh.ttf "https://sonnetdp.github.io/nikosh/fonts/Nikosh.ttf" \
    && wget -O /usr/share/fonts/truetype/custom/Kalpurush.ttf "https://fonts.maateen.me/kalpurush/Kalpurush-v0.258.ttf" \
    && fc-cache -f -v

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
