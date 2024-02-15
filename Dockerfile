FROM ubuntu:22.04 as builder

ARG YQ_VERSION=v4.29.2
ARG YQ_BINARY=yq_linux_amd64
ARG TASK_VERSION=v3.17.0
ARG TASK_BINARY=task_linux_amd64.tar.gz

RUN apt-get update &&  \
    apt-get install -y \
      libfontconfig1 \
      libxtst6 \
      rubygems \
      #wkhtmltopdf \
      wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN gem install yaml-cv
RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O /usr/bin/yq \
    && chmod +x /usr/bin/yq

RUN wget -O- https://github.com/go-task/task/releases/download/${TASK_VERSION}/${TASK_BINARY} \
    | tar xz -C /usr/bin

WORKDIR /opt/app

COPY src/ src/
COPY scripts/ scripts/
COPY Taskfile.yaml Taskfile.yaml
COPY .env .env

ENTRYPOINT ["/usr/bin/task"]

FROM builder as build
RUN task build

FROM busybox as release
WORKDIR /opt/app
COPY --from=build /opt/app/build/cv.html cv.html
VOLUME /opt/app