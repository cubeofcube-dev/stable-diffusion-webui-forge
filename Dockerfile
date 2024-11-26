FROM python:3.10-slim 

WORKDIR /app
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=on

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get install git -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements_versions.txt requirements_versions.txt
RUN pip install torch==2.3.1 torchvision==0.18.1 --extra-index-url https://download.pytorch.org/whl/cu121 \
    && pip install -r requirements_versions.txt
COPY . .
RUN python3 prepare_environment.py --skip-torch-cuda-test \
    && find . -name requirements.txt -exec pip install -r {} \; \
    && pip uninstall -y opencv-python \
    && pip install opencv-python-headless>=4.8.0 \
    && pip install bitsandbytes==0.43.3

ENTRYPOINT [ "/app/entrypoint.sh", "--skip-prepare-environment" ]
