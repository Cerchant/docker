FROM ubuntu:latest as assemble

RUN apt-get update &&  \
    apt-get install -y \
      libfontconfig1 \
      libxtst6 \
      rubygems \
      wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN gem install yaml-cv
RUN wget https://github.com/mikefarah/yq/releases/download/v4.29.2/yq_linux_amd64 -O /usr/bin/yq \
    && chmod +x /usr/bin/yq

RUN wget -O- https://github.com/go-task/task/releases/download/v3.17.0/task_linux_amd64.tar.gz \
    | tar xz -C /usr/bin

WORKDIR /opt/app

COPY src/ src/
COPY scripts/ scripts/
COPY Taskfile.yaml Taskfile.yaml
COPY .env .env

ENTRYPOINT ["/usr/bin/task"]

FROM assemble as assembler
RUN task build

FROM busybox as release
WORKDIR /opt/app
COPY --from=build /opt/app/build/cv.html cv.html
VOLUME /opt/app
