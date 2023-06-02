# Use an official Ubuntu image as the base
FROM ubuntu:latest

# Install necessary dependencies for C++ development
RUN apt-get update && \
    apt-get install -y build-essential gdb cmake 

# Install dependencies for the project
RUN apt-get install -y binutils-multiarch-dev libcapstone-dev

# Install VSCode server
RUN apt-get install -y curl
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Set the default command to run when the container starts
CMD ["/bin/bash"]
