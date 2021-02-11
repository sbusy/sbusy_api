// @dart=2.9
import 'dart:mirrors';
import 'dart:io';
import 'annotations.dart';

/// Server Class.
///
/// Example:
///
///     UniServer server = UniServer(MyApp());
///     server.serve();
///
class UniServer {
  ClassMirror _classMirror;
  ObjectMirror _objectMirror;
  dynamic _object;

  UniServer(dynamic this._object) {
    _classMirror = reflectClass(this._object.runtimeType);

    // Достаем метаинформацию из объекта
    bool have_UniWebsite = false;
    for (InstanceMirror i in _classMirror.metadata) {
      print(i.reflectee.runtimeType);
      if (i.reflectee.runtimeType == WebApp) {
        have_UniWebsite = true;
        this.port = i.reflectee.port;
        this.debug = i.reflectee.debug;
        this.compression = i.reflectee.compression;
      }
      if (i.reflectee.runtimeType == FileProvider) {
        this._file_providers.add(i.reflectee);
      }
    }
    if (!have_UniWebsite) {
      print("No metadata");
      exit(1);
    }
    // Web app functions and pages
    this._objectMirror = reflect(this._object);
    for (var i in _classMirror.instanceMembers.values) {
      if (i.metadata.length != 0 &&
          i.metadata.first.reflectee.runtimeType == StaticPage) {
        if (this.debug)
          print("static page: ${i.metadata.first.reflectee.path}");
        this._static[i.metadata.first.reflectee.path] =
            _objectMirror.invoke(i.simpleName, []).reflectee;
      }
    }
    for (var i in _classMirror.instanceMembers.values) {
      if (i.metadata.length != 0 &&
          i.metadata.first.reflectee.runtimeType == DynamicPage) {
        if (this.debug)
          print("dynamic page: ${i.metadata.first.reflectee.path}");
        this._dynamic[i.metadata.first.reflectee.path] = i.simpleName;
      }
    }
    for (var i in _classMirror.instanceMembers.values) {
      if (i.metadata.length != 0 &&
          i.metadata.first.reflectee.runtimeType == ApiFunction) {
        if (this.debug) print("api: ${i.metadata.first.reflectee.path}");
        this._api[i.metadata.first.reflectee.path] = i.simpleName;
      }
    }
    if (this.debug) {
      print(_static.toString());
    }
  }

  Map<String, Symbol> _dynamic = {};
  Map<String, Symbol> _api = {};
  Map<String, String> _static = {};
  int port;
  bool debug;
  bool compression;
  List<FileProvider> _file_providers = [];

  void serve() {
    HttpServer.bind(
            this.debug ? InternetAddress.loopbackIPv4 : InternetAddress.anyIPv4,
            this.port)
        .then((server) {
      server.autoCompress = this.compression;
      print("listening at ${server.address}:${server.port}");
      server.listen(this.handle_request);
    }, onError: (a) {
      print("UniServer: init error\ndata:\n$a");
    });
  }

  String getFileExtension(String s) =>
      s.contains(".") ? s.substring(s.lastIndexOf(".") + 1) : "";

  void handle_request_file(HttpRequest request) {
    bool found = false;
    for (FileProvider i in this._file_providers) {
      if (i.handle_request(request)) {
        found = true;
        break;
      }
    }
    if (!found) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.close();
    }
  }

  void handle_request(HttpRequest request) {
    if (this.debug)
      print(
          "${request.connectionInfo?.remoteAddress.address}:${request.connectionInfo?.remotePort} --> ${request.uri.path}");

    var path = request.uri.path;
    if (this._static.containsKey(path)) {
      if (this.debug) print("static >>> $path");
      request.response.headers.contentType = ContentType.html;
      request.response
        ..writeln(this._static[path])
        ..close();
    } else if (this._dynamic.containsKey(path)) {
      if (this.debug) print("dynamic >>> $path");
      request.response.headers.contentType = ContentType.html;
      var symbol = this._dynamic[path];
      if (symbol != null) this._objectMirror.invoke(symbol, [request]);
    } else if (this._api.containsKey(path)) {
      if (this.debug) print("api >>> $path");
      request.response.headers.contentType = ContentType.json;
      var symbol = this._api[path];
      if (symbol != null) this._objectMirror.invoke(symbol, [request]);
    } else {
      handle_request_file(request);
    }
  }
}
