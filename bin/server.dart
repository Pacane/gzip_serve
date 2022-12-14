import 'dart:async' show runZonedGuarded;
import 'dart:io';

import 'package:path/path.dart' show join, dirname;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_gzip/shelf_gzip.dart';
import 'package:shelf_static/shelf_static.dart';

void main() {
  // Assumes the server lives in bin/ and that `pub build` ran
  final pathToBuild = join(
    dirname(Platform.script.toFilePath()),
    'web',
  );
  final staticHandler = createStaticHandler(
    pathToBuild,
    defaultDocument: 'index.html',
  );

  final portEnv = Platform.environment['PORT'];
  final port = portEnv == null ? 9999 : int.parse(portEnv);

  runZonedGuarded(() async {
    final handler = const shelf.Pipeline()
        .addMiddleware(gzipMiddleware)
        .addHandler(staticHandler);

    await shelf_io.serve(handler, '0.0.0.0', port);

    print("Serving $pathToBuild on port $port");
  }, (e, stackTrace) => print('Server error: $e $stackTrace'));
}
