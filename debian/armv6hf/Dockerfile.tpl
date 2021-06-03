FROM balenalib/rpi-raspbian:#{SUITE}

RUN apt-get -q update \
		&& apt-get install -y git python3 python3-dev python3-pip python python-dev python-pip python-setuptools build-essential wget ca-certificates libssl-dev curl --no-install-recommends \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN pip install awscli

RUN git clone https://github.com/nodejs/node.git

COPY . /
