FROM python:3.12

# 1) Avoid Python writing .pyc and enable unbuffered logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# 2) Install system deps (if you later need gcc for some libs, add build-essential)
#    Kept minimal for fast, reproducible builds
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
 && rm -rf /var/lib/apt/lists/*

# 3) Set working directory inside the container
WORKDIR /app

# 4) Copy only requirements first to leverage Docker layer caching
#    When requirements.txt hasn't changed, this layer is reused.
COPY requirements.txt /app/requirements.txt

# 5) Upgrade pip and install Python deps
RUN python -m pip install --upgrade pip \
 && pip install -r requirements.txt

# 6) Copy the rest of the project (code, configs, but NOT your dataset)
#    Your .dockerignore should exclude data and venv (see below)
COPY . /app

# 7) Default command: run your app's main script.
#    You can override this at `docker run` time if needed.
#    Example expects your entry point at src/app/main.py
CMD ["python", "src/app/main.py"]
