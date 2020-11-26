import 'dart:io';

import 'package:sbusy_api/sbusy_api.dart';

void serve() async {
  var server = await HttpServer.bind(InternetAddress.anyIPv4, 8000);
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
      await HttpServer.bindSecure(InternetAddress.anyIPv4, 4430, context);
}

void main(List<String> args) {
  log("SBusy Api server starting ...");
}
