FROM google/dart

WORKDIR /app

ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline

FROM certbot/certbot

EXPOSE 8000/tcp
EXPOSE 3306/tcp
EXPOSE 3306/tcp

CMD []
ENTRYPOINT ["/usr/bin/dart", "bin/main.dart"]