import 'package:demo4/app/craftedge_app.dart';
import 'package:demo4/core/config/app_environment.dart';
import 'package:demo4/core/di/service_locator.dart';
import 'package:demo4/core/services/firebase_service.dart';
import 'package:demo4/core/storage/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap({AppFlavor flavor = AppFlavor.dev}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = await AppEnvironment.load(flavor);
  await configureDependencies(environment);
  await sl<LocalStorageService>().init();
  await sl<FirebaseService>().init();

  runApp(const ProviderScope(child: CraftEdgeApp()));
}
