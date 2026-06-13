FROM python:3.12-slim
WORKDIR /app

# SUMO's binaries (from the eclipse-sumo wheel) are dynamically linked against
# X11/GL/FOX libraries even for the headless `sumo` — without them it fails at
# runtime with "libX11.so.6: cannot open shared object file" and TraCI never
# connects. Install the shared libs the binary needs.
RUN apt-get update && apt-get install -y --no-install-recommends \
      libx11-6 libxext6 libxrender1 libxcb1 libxfixes3 libxcursor1 \
      libxrandr2 libxi6 libxft2 libxinerama1 \
      libgl1 libglu1-mesa libfontconfig1 libgomp1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY backend ./backend
COPY frontend ./frontend
COPY data ./data
EXPOSE 8000
# shell form so hosts that inject PORT (Render, HF Spaces, Railway) work;
# defaults to 8000 for local docker run
CMD uvicorn backend.app:app --host 0.0.0.0 --port ${PORT:-8000}
