FROM ubuntu:14.04

# Install deps
RUN apt-get -q update \
		&& apt-get install -y git lib32stdc++6 python build-essential lib32z1 wget ca-certificates --no-install-recommends

# Install S3 tool
RUN wget -O- -q http://s3tools.org/repo/deb-all/stable/s3tools.key | sudo apt-key add - \
		&& wget -O/etc/apt/sources.list.d/s3tools.list http://s3tools.org/repo/deb-all/stable/s3tools.list \
		&& apt-get -q update \
		&& apt-get install -y s3cmd \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

# Set ENV vars
ENV AR /tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin/arm-linux-gnueabihf-ar
ENV CC /tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin/arm-linux-gnueabihf-gcc
ENV CXX /tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin/arm-linux-gnueabihf-g++
ENV LINK /tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin/arm-linux-gnueabihf-g++


RUN git clone https://github.com/raspberrypi/tools.git --depth 1 \
		&& git clone https://github.com/joyent/node.git

COPY . /