# syntax=docker/dockerfile:1
ARG UBUNTU_VERSION=24.04
FROM public.ecr.aws/docker/library/ubuntu:${UBUNTU_VERSION} AS base

ARG USER_UID=1001
ARG USER_GID=1001
ARG USER_NAME=batch

ENV DEBIAN_FRONTEND noninteractive

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN \
      groupadd --gid "${USER_GID}" "${USER_NAME}" \
      && useradd --uid "${USER_UID}" --gid "${USER_GID}" --shell /bin/bash --create-home "${USER_NAME}"

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

USER "${USER_NAME}"

ENTRYPOINT ["/usr/bin/env", "bash", "-xc"]
CMD ["sleep", "5"]
