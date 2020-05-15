FROM lefuturiste/karate
LABEL maintainer="spamfree@matthieubessat.fr"

ADD ./ /app
WORKDIR /app

RUN npm i
RUN node install.js

CMD ["node", "start.js"]
