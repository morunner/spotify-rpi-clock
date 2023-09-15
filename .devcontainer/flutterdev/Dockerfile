FROM ubuntu:22.04

###########################
# 1. Create non-root user #
###########################

ARG USERNAME=flut
ARG USER_UID=1000
ARG USER_GID=1000

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

##############################
# 2. Install necessary tools #
##############################

RUN sudo apt-get install -y \
    bash \
    curl \
    wget \
    file \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    clang \
    ninja-build \
    pkg-config \
    cmake \
    libgtk-3-dev

WORKDIR /home/$USERNAME/
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.5-stable.tar.xz
RUN tar xf flutter_linux_3.10.5-stable.tar.xz
RUN echo "export PATH='$PATH:/home/$USERNAME/flutter/bin'" >> /home/$USERNAME/.bashrc
RUN rm flutter_linux_3.10.5-stable.tar.xz