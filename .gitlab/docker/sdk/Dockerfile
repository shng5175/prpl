FROM registry.gitlab.com/prpl-foundation/prplwrt/prplwrt/builder:latest

COPY --chown=builder:builder . /home/builder/

WORKDIR /home/builder
RUN mkdir .ssh && ssh-keyscan gitlab.com > .ssh/known_hosts
RUN \
	sed -i '/src-include defaults feeds.conf.default/d' feeds.conf.default && \
	sed -i 's;base git@gitlab.com:;base https://gitlab.com/;' feeds.conf.default
