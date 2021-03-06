import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_server/sqflite.dart';
import 'package:sqflite_server/src/constant.dart';
// ignore: implementation_imports
import 'package:sqflite/src/mixin.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_web_socket/web_socket.dart';

class SqfliteServerDatabaseFactory extends SqfliteDatabaseFactoryBase {
  SqfliteServerDatabaseFactory(this.context);

  final SqfliteServerContext context;

  static Future<SqfliteServerDatabaseFactory> connect(String url,
      {WebSocketChannelClientFactory webSocketChannelClientFactory}) async {
    var sqfliteContext = await SqfliteServerContext.connect(url,
        webSocketChannelClientFactory: webSocketChannelClientFactory);
    if (sqfliteContext != null) {
      return SqfliteServerDatabaseFactory(sqfliteContext);
    }
    return null;
  }

  path.Context get pathContext => context.pathContext;

  Future close() async {
    await context.close();
  }

  @override
  Future<T> invokeMethod<T>(String method, [dynamic arguments]) =>
      context.invoke<T>(method, arguments);

  @override
  Future deleteDatabase(String path) async {
    return await context.sendRequest<String>(
        methodSqfliteDeleteDatabase, <String, dynamic>{keyPath: path});
  }

  // overrident to use the proper path context
  @override
  Future<String> fixPath(String path) async {
    if (path == null) {
      path = await getDatabasesPath();
    } else if (path == inMemoryDatabasePath) {
      // nothing
    } else {
      if (context.pathContext.isRelative(path)) {
        path = pathContext.join(await getDatabasesPath(), path);
      }
      path = pathContext.absolute(pathContext.normalize(path));
    }
    return path;
  }
}
