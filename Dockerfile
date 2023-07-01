# Use an official Ubuntu image as the base
FROM ubuntu:latest

# Install necessary dependencies for C++ development
RUN apt-get update && \                                 
    apt-get install -y build-essential gdb cmake \
    binutils-multiarch-dev libcapstone-dev\
    python3 python3-pip \
    less file gawk     

# Instapp python libraries
RUN pip3 install pyelftools click==8.1.3 gdown==4.6.4

WORKDIR /nucleus

# Comment the following line to work in development mode
COPY . .
RUN make

# Set the default command to run when the container starts
CMD ["/bin/bash"]
