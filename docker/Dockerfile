# syntax=docker/dockerfile:1
ARG ubuntu_VERSION=3.12
FROM public.ecr.aws/docker/library/ubuntu:${UBUNTU_VERSION} AS base

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN \
      rm -f /etc/apt/apt.conf.d/docker-clean \
      && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
        > /etc/apt/apt.conf.d/keep-cache

RUN \
      --mount=type=cache,target=/var/cache/apt,sharing=locked \
      --mount=type=cache,target=/var/lib/apt,sharing=locked \
      apt-get -y update \
      && apt-get -y upgrade \
      && apt-get -y install --no-install-recommends --no-install-suggests \
        ca-certificates

HEALTHCHECK NONE

ENTRYPOINT ["/usr/bin/env", "bash", "-xc"]
CMD ["sleep", "5"]
