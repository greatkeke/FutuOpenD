# Use Ubuntu base image
FROM ubuntu:16.04

# Set working directory
WORKDIR /app

# Copy FutuOpenD files
COPY Futu_OpenD_9.2.5208_Ubuntu16.04/ /app

VOLUME /app/config
EXPOSE 11111
EXPOSE 22222

# Run FutuOpenD
CMD ["/app/FutuOpenD", "-cfg_file=/app/config/FutuOpenD.xml"]
