FROM google/dart

WORKDIR /app

RUN apt update
RUN apt install certbot

ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline

EXPOSE 80/tcp
EXPOSE 443/tcp

EXPOSE 3306/tcp
EXPOSE 3306/tcp

CMD []
ENTRYPOINT ["/usr/bin/dart", "bin/main.dart"]