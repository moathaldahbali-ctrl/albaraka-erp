// ignore_for_file: avoid_print, avoid_relative_lib_imports
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/screens/settings/permissions_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbPath = r'D:\v94_test\albaraka_local.db';
  if (!File(dbPath).existsSync()) {
    print('Test DB not found: $dbPath');
    print('Run: dart run tool/test_v94_seed.dart first');
    return;
  }

  final db = await databaseFactory.openDatabase(dbPath);
  runApp(DemoApp(db: db));
}

class DemoApp extends StatelessWidget {
  final Database db;
  const DemoApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo — إدارة الصلاحيات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: PermissionsScreen(db: db),
    );
  }
}