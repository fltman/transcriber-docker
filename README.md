# Transcriber - Docker Installation

Run Transcriber with zero setup. No programming knowledge needed.

## Step 1: Install Docker Desktop

Download and install from https://www.docker.com/products/docker-desktop/

Works on Mac, Windows, and Linux. Just follow the installer.

## Step 2: Download

- **Mac**: Download [Transcriber.dmg](https://github.com/fltman/transcriber-docker/releases/latest/download/Transcriber.dmg), open it, and copy the **Transcriber** folder to your computer (e.g. Desktop or Documents).
- **Windows**: Click the green **Code** button above, choose **Download ZIP**, and unzip it.

## Step 3: Start Transcriber

Open the Transcriber folder and double-click:

- **Mac**: `start.command`
- **Windows**: `start.bat`

The first start downloads and builds everything needed (~7 GB) and may take 10-15 minutes. Your browser will open automatically when it's ready.

## Step 4: Configure

Go to http://localhost:8080, click the **settings icon** (top right), then the **Preferences** tab.

Enter your **Hugging Face token** (needed for speaker identification). Get a free one at https://huggingface.co/settings/tokens

## Stopping

Double-click `stop.command` (Mac) or `stop.bat` (Windows). Or just quit Docker Desktop.

## Updating

To get the latest version, double-click the stop script first, then run the start script again. Docker will detect and download the latest source code.

To force a full rebuild, open a terminal in this folder and run:
```
docker compose build --no-cache
docker compose up -d
```

## Troubleshooting

**"Docker is not running"** - Open Docker Desktop first, wait for it to start, then try again.

**Port conflict** - If something else uses port 8080, edit `docker-compose.yml` and change `8080:80` to another port like `9090:80`.

**Full reset** - Open a terminal in this folder and run: `docker compose down -v`
