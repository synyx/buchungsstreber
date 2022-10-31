FROM ruby:2.5.8-alpine
LABEL maintainer="synyx"
LABEL org.opencontainers.image.source https://github.com/synyx/buchungsstreber

RUN apk update && \
    apk add --no-cache \
    bash \
    vim \
    gcc \
    ncurses-dev \
    libc-dev \
    make \
    && rm -rf /var/cache/apk/*

RUN gem source --add https://nexus.synyx.de/content/repositories/gems/ && \
    gem install buchungsstreber ncursesw filewatcher

RUN adduser -D bs

USER bs
WORKDIR /home/bs

CMD ["/bin/bash"]
