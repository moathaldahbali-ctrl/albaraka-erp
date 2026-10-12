import 'dart:io';
void main() {
  final f = File(r'D:\albaraka\albaraka_pos\lib\db\local_db.dart');
  var c = f.readAsStringSync();
  const anchor = '  Future<List<Map<String, dynamic>>> searchProductsFast(';
  const helper = '''  List<String> _arabicVariants(String word, {int max = 12}) {
    final r = <String>{word};
    final sub = <String, List<String>>{
      '\u0627': ['\u0627','\u0623','\u0625'],
      '\u0623': ['\u0627','\u0623','\u0625'],
      '\u0625': ['\u0627','\u0623','\u0625'],
      '\u064A': ['\u064A','\u0649'],
      '\u0649': ['\u064A','\u0649'],
      '\u0647': ['\u0647','\u0629'],
      '\u0629': ['\u0647','\u0629'],
    };
    void exp(String s, int p) {
      if (r.length >= max || p >= s.length) return;
      final ch = s[p];
      final vs = sub[ch];
      if (vs != null) {
        for (final v in vs) {
          if (v != ch) {
            final n = s.substring(0,p)+v+s.substring(p+1);
            if (r.add(n)) exp(n, p+1);
          }
        }
      }
      exp(s, p+1);
    }
    exp(word, 0);
    return r.take(max).toList();
  }

''';
  if (!c.contains('_arabicVariants')) {
    c = c.replaceFirst(anchor, helper + anchor);
  }
  final oldB = "        orParts.add('(name LIKE ? OR sku LIKE ?)');\n        final q = '%' + w + '%';\n        categoryArgs.add(q);\n        categoryArgs.add(q);";
  final newB = "        final variants = _arabicVariants(w);\n        final vp = <String>[];\n        for (final v in variants) {\n          vp.add('(name LIKE ? OR sku LIKE ?)');\n          final q = '%' + v + '%';\n          categoryArgs.add(q);\n          categoryArgs.add(q);\n        }\n        orParts.add('(' + vp.join(' OR ') + ')');";
  if (c.contains(oldB)) {
    c = c.replaceAll(oldB, newB);
  }
  f.writeAsStringSync(c);
  print('OK. Length: \${c.length}');
}