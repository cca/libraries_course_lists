# https://hub.docker.com/_/python/tags?name=2.7.
FROM python:2.7.18
LABEL build_date="2024-10-03"
LABEL description="Update VAULT course lists"
LABEL maintainer="Eric Phetteplace <ephetteplace@cca.edu>"
LABEL name="courselists"
LABEL url="https://github.com/cca/course_lists"

RUN apt-get update && apt-get install -y \
    csvkit \
    fish \
    jq

# install nvm then node then equella-cli
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
# /bin/sh is dash on Debian, which doesn't support `source`
# . doesn't permanently modify PATH so we do it before `npm` cmds too
RUN . /root/.nvm/nvm.sh && nvm install stable
RUN . /root/.nvm/nvm.sh && npm install -g equella-cli

COPY . /app
WORKDIR /app

CMD ["sleep", "infinity"]
