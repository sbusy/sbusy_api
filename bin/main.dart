// @dart=2.9
import 'dart:io';

import 'package:sbusy_api/sbusy_api.dart';
import 'package:sbusy_api/src/route/annotations.dart';
import 'package:sbusy_api/src/route/router.dart';

@WebApp(80)
class SimpleApp {
  @ApiFunction("/index")
  void index(HttpRequest request) {
    request.response
      ..writeln('{"a":"b"}')
      ..close();
  }
}

void serve() async {
  var server = await HttpServer.bind(InternetAddress.anyIPv4, 80);
}

void serveSecure() async {
  SecurityContext context = new SecurityContext();
  var chain = Platform.script
      .resolve('/etc/letsencrypt/live/armacoty.tk/fullchain.pem')
      .toFilePath();
  var key = Platform.script
      .resolve('/etc/letsencrypt/live/armacoty.tk/privkey.pem')
      .toFilePath();

  context.useCertificateChain(chain);
  context.usePrivateKey(key);

  var server =
      await HttpServer.bindSecure(InternetAddress.anyIPv4, 443, context);
}

void main(List<String> args) {
  log("SBusy Api server starting ...");

  var app = UniServer(SimpleApp());
  app.serve();
}
