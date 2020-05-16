FROM lefuturiste/karate
LABEL maintainer="spamfree@matthieubessat.fr"

ADD ./ /app
WORKDIR /app

RUN npm i

# Set the karate absolute path
ENV KARATE_PATH=/utils/karate.jar

CMD ["node", "start.js"]
