# Dockerfile for building hcvl AppImage

# Docker image based on official appimage-builder image
FROM appimagecrafters/appimage-builder:latest

# Specify UID of user to build and save AppImage to volume mount
# Example: $ docker build -t hcvl-builder:latest --build-arg BUILD_UID=$(id -u) .
ARG BUILD_UID=1000
USER $BUILD_UID

# Expects volume mount of data at /data
WORKDIR /data
ENTRYPOINT ["appimage-builder"]
