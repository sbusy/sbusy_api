// @dart=2.9
import 'dart:io';
import 'package:mime/mime.dart' as Mime;

/// Class of static page method.
/// Calls when server starts.
///
/// **Method should return `String`**
///
/// Example 1:
///
///     @StaticPage("/path")
///     String my_page(){
///       return "<h1>Hello world</h1>";
///     }
///
/// Example 2:
///
///     @StaticPage("/index.html")
///     String index() => File("html/index.html").readAsStringSync();
///
class StaticPage {
  final String path;
  const StaticPage(this.path);
}

/// Class of dynamic page method.
/// Calls when user send request.
///
/// Example:
///
///     int cnt = 0;
///     @DynamicPage("/counter")
///     void counter(HttpRequest request){
///       request.response
///         ..write("<h1> Called ${this.cnt}</h1>")
///         ..close();
///     }
class DynamicPage {
  final String path;
  const DynamicPage(this.path);
}

/// Class of json function method.
/// Response mimetype `text/json`.
///
/// Example:
///
///     int cnt = 0;
///     @ApiFunction("/counter")
///     void counter(HttpRequest request){
///       request.response
///         ..write(jsonEncode({"called":cnt}))
///         ..close();
///     }
class ApiFunction {
  final String path;
  const ApiFunction(this.path);
}

/// Class of web application.
///
/// Example:
///
///     @WebApp(80, debug: false, compression: true) // Don't use debug mode in production
///     class MyApp{
///         ...
///     }
class WebApp {
  final int port;
  final bool debug, compression;
  const WebApp(this.port, {this.debug = false, this.compression = false});
}

/// Class of directory, where server will watch files, images, etc.
///
/// Example files:
///
///     ./
///       bin/
///         main.dart // WebApp there
///       files/
///         index.html
///
/// Example:
///
///     @FileProvider("/files")
///     @WebApp(80, debug: false, compression: true) // Don't use debug mode in production AGAIN!!!
///     class MyApp{
///         ...
///     }
///
class FileProvider {
  final String path;
  final bool cached;
  bool handle_request(HttpRequest request) {
    File file = File(this.path + request.uri.path);
    if (file.existsSync()) {
      String type = Mime.lookupMimeType(this.path + request.uri.path);
      //if (type == null) {
      //  request.response.headers.contentType = ContentType.text;
      //} else {
      type += "; charset=utf-8";
      request.response.headers.contentType = ContentType.parse(type);
      //}
      try {
        file.openRead().pipe(request.response);
      } catch (e) {
        print(e);
      }
      return true;
    } else {
      return false;
    }
  }

  const FileProvider(this.path, {this.cached = false});
}

/// Class of file, wich will be loaded from file
///
/// File can be placed in all directiories, not only in "File provider"
///
/// Example:
///
///     @Load("/src/footer.html")
///     String footer;
/// Cancelled !!! :`(
// class Load {
//   final String path;
//   const Load(this.path);
// }
