import 'dart:io';

void main() {
  final src = Directory(r'D:\albaraka\albaraka_pos\build\windows\x64\runner\Release');
  if (!src.existsSync()) {
    print('ERROR: Release folder not found.');
    return;
  }

  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  final staging = Directory(r'D:\albaraka\_v7_staging\albaraka_pos');
  final zipPath = r'D:\albaraka\albaraka_pos_v7_' + ts + '.zip';

  if (staging.parent.existsSync()) {
    staging.parent.deleteSync(recursive: true);
  }
  staging.createSync(recursive: true);

  print('Copying files...');
  int count = 0;
  for (final f in src.listSync(recursive: true)) {
    if (f is File) {
      final rel = f.path.substring(src.path.length + 1);
      final dst = File(staging.path + Platform.pathSeparator + rel);
      dst.parent.createSync(recursive: true);
      dst.writeAsBytesSync(f.readAsBytesSync());
      count++;
    }
  }
  print('Copied $count files.');

  final exe = File(staging.path + r'\albaraka_pos.exe');
  final env = File(staging.path + r'\data\flutter_assets\.env');
  print('exe exists: ' + exe.existsSync().toString() +
      ' (' + (exe.existsSync() ? exe.lengthSync().toString() : '0') + ' bytes)');
  print('.env exists: ' + env.existsSync().toString() +
      ' (' + (env.existsSync() ? env.lengthSync().toString() : '0') + ' bytes)');

  print('Zipping...');
  final zipResult = Process.runSync('powershell', [
    '-NoProfile',
    '-Command',
    'Compress-Archive -Path "' + staging.path + '" -DestinationPath "' + zipPath + '" -Force'
  ]);
  if (zipResult.exitCode != 0) {
    print('ZIP ERROR: ' + zipResult.stderr.toString());
    return;
  }

  final zipFile = File(zipPath);
  final sizeMB = (zipFile.lengthSync() / 1024 / 1024).toStringAsFixed(2);
  print('DONE. ZIP: ' + zipPath + ' (' + sizeMB + ' MB)');

  staging.parent.deleteSync(recursive: true);
  print('Staging cleaned.');
}
