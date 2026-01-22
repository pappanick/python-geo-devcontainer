FROM mcr.microsoft.com/devcontainers/python:3.12

# Install uv system-wide
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh

# Install GDAL and other geo dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgdal-dev \
    gdal-bin \
    libgeos-dev \
    libproj-dev \
    # SNAP dependencies
    default-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set GDAL environment variables
ENV GDAL_CONFIG=/usr/bin/gdal-config
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# Install ESA SNAP
ARG SNAP_VERSION=13.0.0
ARG SNAP_INSTALLER=esa-snap_sentinel_linux-${SNAP_VERSION}.sh

RUN curl -fsSL "https://download.esa.int/step/snap/13.0/installers/${SNAP_INSTALLER}" -o /tmp/${SNAP_INSTALLER} \
    && chmod +x /tmp/${SNAP_INSTALLER} \
    && /tmp/${SNAP_INSTALLER} -q -dir /opt/snap \
    && rm /tmp/${SNAP_INSTALLER}

# Add SNAP to PATH and set SNAP_HOME (required for esa-snappy)
ENV PATH="/opt/snap/bin:${PATH}"
ENV SNAP_HOME="/opt/snap"

# Install esa-snappy from PyPI (new method for SNAP 10+)
RUN pip install esa-snappy

# Update SNAP modules (optional - can be slow)
# RUN /opt/snap/bin/snap --nosplash --nogui --modules --update-all
