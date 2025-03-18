# https://hub.docker.com/_/python/tags?name=2.7.
FROM python:2.7.18
LABEL description="Update VAULT course lists"
LABEL maintainer="Eric Phetteplace <ephetteplace@cca.edu>"
LABEL name="courselists"
LABEL url="https://github.com/cca/course_lists"

ENV TZ="America/Los_Angeles"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && apt-get install -y --no-install-recommends \
    csvkit \
    fish \
    jq \
    && rm -rf /var/lib/apt/lists/*

# install nvm then node then equella-cli
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
# /bin/sh is dash on Debian, which doesn't support `source`
# . doesn't permanently modify PATH so we do it before `npm` cmds too
# TODO nvm.sh only works in bash, not fish
RUN . /root/.nvm/nvm.sh && nvm install stable
RUN . /root/.nvm/nvm.sh && npm install -g equella-cli

COPY app /app
WORKDIR /app
ENV PATH="$PATH:/app"

CMD ["sleep", "infinity"]
