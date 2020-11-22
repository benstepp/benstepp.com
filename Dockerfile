FROM node:15
RUN apt-get update && \
    apt-get install -y \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*


RUN npm install -g npm
RUN mkdir /web
WORKDIR /web

COPY package.json yarn.lock ./
RUN yarn

CMD bash
