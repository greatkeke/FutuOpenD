# Use Ubuntu base image
FROM ubuntu:16.04

# Copy FutuOpenD files
COPY Futu_OpenD_9.2.5208_Ubuntu16.04/* /app

# Set working directory
WORKDIR /app

VOLUME /app/FutuOpenD/FutuOpenD.xml

# Run FutuOpenD
CMD ["/app/FutuOpenD"]
