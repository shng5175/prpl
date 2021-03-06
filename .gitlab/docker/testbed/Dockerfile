FROM debian:buster-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
	curl \
	etherwake \
	git-core \
	iputils-ping \
	iproute2 \
	locales \
	nmap \
	openssh-client \
	python3 \
	python3-pip \
	python3-setuptools \
	sudo \
	xz-utils && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8

ENV LABGRID_COMMIT=ffa994eca22b
RUN git clone --branch wip/testbed https://gitlab.com/prpl-foundation/prplOS/labgrid
WORKDIR labgrid
RUN git reset --hard $LABGRID_COMMIT

RUN \
	pip3 install -U pip && \
	pip3 install -r requirements.txt && \
	python3 setup.py install && \
	rm -fr /labgrid

RUN pip3 install \
	cdrouter \
	cram \
	humanize \
	jira \
	'marshmallow<3.0.0' \
	pyjwt

ENV TMATE_VERSION=2.4.0
ENV TMATE_SHA256SUM=6e503a1a3b0f9117bce6ff7cc30cf61bdc79e9b32d074cf96deb0264e067a60d
ENV TMATE_DL_URL=https://github.com/tmate-io/tmate/releases/download

RUN \
	curl --location --silent \
	"$TMATE_DL_URL/$TMATE_VERSION/tmate-${TMATE_VERSION}-static-linux-amd64.tar.xz" > tmate.tar.xz && \
	sha256sum tmate.tar.xz | grep -q "$TMATE_SHA256SUM" && \
	tar xf tmate.tar.xz --strip-components=1 -C /usr/local/bin && \
	rm tmate.tar.xz

RUN \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    useradd -c "OpenWrt Testbed" -m -d /home/testbed -G sudo -s /bin/bash testbed

USER testbed
ENV HOME /home/testbed
WORKDIR /home/testbed/

VOLUME [ "/home/testbed" ]
