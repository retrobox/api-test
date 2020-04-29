FROM debian
LABEL maintainer="spamfree@matthieubessat.fr"

# need java jdk, jre to run .jar karate
# need Node.js
# run install.js

RUN apt-get update
RUN apt-get install -y default-jre
RUN apt-get install -y default-jdk

ADD ./ /app

RUN apt-get install -y curl nano build-essential
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
RUN sh nodesource_setup.sh
RUN apt-get install -y nodejs

WORKDIR /app
RUN npm i 
RUN node install.js

CMD ["node", "start.js"]
