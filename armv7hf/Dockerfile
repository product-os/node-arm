FROM resin/armv7hf-toolchain

# Install deps
RUN apt-get -q update \
		&& apt-get install -y python-pip gcc-multilib g++-multilib --no-install-recommends \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN pip install awscli

RUN git clone https://github.com/nodejs/node.git

COPY . /
