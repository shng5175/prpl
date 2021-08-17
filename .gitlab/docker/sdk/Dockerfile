ARG DESIGNATED_BRANCH=prplwrt-19.07
FROM registry.gitlab.com/prpl-foundation/prplos/prplos/$DESIGNATED_BRANCH/builder:latest

COPY --chown=builder:builder . /home/builder/

WORKDIR /home/builder
RUN mkdir .ssh && ssh-keyscan gitlab.com > .ssh/known_hosts
RUN sed -i 's;\(http[s]\?\)://\(.*@\);\1://;g' feeds.conf.default
