ARG DOCKER_IMAGE=debian:bullseye-slim
FROM $DOCKER_IMAGE AS builder

WORKDIR /tmp


RUN apt-get update && apt-get -y install \
	gcc \
	g++ \
	git \
	build-essential \
	make \
	file \
	ca-certificates \
	--no-install-recommends &&\
	git clone --recurse-submodules https://github.com/rui314/chibicc.git && \
	apt-get -y autoremove --purge && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/chibicc
RUN make chibicc
RUN make stage2/chibicc
RUN make test-all


ARG DOCKER_IMAGE=debian:bullseye-slim
FROM $DOCKER_IMAGE AS runtime

LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

RUN apt-get update && apt-get -y install \
	make \
	g++ \
	ca-certificates \
	--no-install-recommends \
	&& apt-get -y autoremove --purge \
	&& rm -rf /var/lib/apt/lists/*
RUN ls -la
RUN find / -name "*stdarg.h"
ARG VERSION="1.0.0"
ENV VERSION=$VERSION

COPY --from=builder /tmp/chibicc /usr/local/chibicc
ENV PATH="/usr/local/chibicc/stage2/:${PATH}"

ENV CC=/usr/local/chibicc/stage2/chibicc

WORKDIR /usr/src/myapp

CMD ["chibicc", "-h"]

LABEL org.label-schema.schema-version="1.0" \
	  org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.name="bensuperpc/chibicc" \
	  org.label-schema.description="build chibicc compiler" \
	  org.label-schema.version=$VERSION \
	  org.label-schema.vendor="Bensuperpc" \
	  org.label-schema.url="http://bensuperpc.com/" \
	  org.label-schema.vcs-url="https://github.com/Bensuperpc/docker-chibicc" \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.docker.cmd="docker build -t bensuperpc/chibicc -f Dockerfile ."

