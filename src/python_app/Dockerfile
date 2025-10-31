FROM python:3.12

# 1) Avoid Python writing .pyc and enable unbuffered logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# 2) Minimal system deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
 && rm -rf /var/lib/apt/lists/*

# 3) Workdir inside the container
WORKDIR /app

# 4) Copy requirements first for layer caching
COPY requirements.txt /app/requirements.txt

# 5) Install Python deps
RUN python -m pip install --upgrade pip \
 && pip install -r requirements.txt

# 6) Copy the rest of the repo (dataset should be .dockerignore’d)
COPY . /app

# 7) Default command: run your Python entry script under src/python_app
CMD ["python", "main.py"]
