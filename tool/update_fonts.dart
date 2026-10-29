import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:http/http.dart';

void main() async {
  final response = await Client().get(
    Uri(
      scheme: 'https',
      host: 'www.googleapis.com',
      pathSegments: ['webfonts', 'v1', 'webfonts'],
      queryParameters: {
        'key': Platform.environment['API_KEY'],
        'sort': 'popularity',
      },
    ),
  );
  final webfonts = jsonDecode(response.body);
  final items = ((webfonts as Map<String, dynamic>)['items'] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .indexed
      .map(
        (item) => (
          family: item.$2['family'] as String,
          variants: (item.$2['variants'] as List<dynamic>).cast<String>(),
          subsets: (item.$2['subsets'] as List<dynamic>)
              .cast<String>()
              .map(_toCamelCase)
              .toList(),
          version: item.$2['version'] as String,
          lastModified: item.$2['lastModified'] as String,
          files: (item.$2['files'] as Map<String, dynamic>)
              .cast<String, String>(),
          category: _toCamelCase(item.$2['category'] as String),
          menu: item.$2['menu'] as String,
          popularityRank: item.$1,
        ),
      )
      .toList();
  items.sort((a, b) => a.family.compareTo(b.family));
  final subsets = {for (final item in items) ...item.subsets}.toList();
  subsets.sort();
  final categories = {for (final item in items) item.category}.toList();
  categories.sort();
  final source =
      '''
      // Generated file. Do not edit.
      //
      // To regenerate, run: `dart run tool/update_fonts.dart`

      enum WebFontSubset {${subsets.join(',')}}

      enum WebFontCategory {${categories.join(',')}}
      ''';
  File('lib/src/webfont_enums.dart').writeAsStringSync(
    DartFormatter(languageVersion: DartFormatter.latestLanguageVersion)
        .format(source),
  );
  final fonts = [
    for (final item in items)
      {
        'family': item.family,
        'variants': item.variants,
        'subsets': item.subsets,
        'version': item.version,
        'lastModified': item.lastModified,
        'files': item.files,
        'category': item.category,
        'menu': item.menu,
        'popularityRank': item.popularityRank,
      },
  ];
  File('assets/webfont_list.json').writeAsStringSync(jsonEncode(fonts));
}

String _toCamelCase(String kebabCase) {
  return kebabCase.splitMapJoin(
    RegExp(r'-[a-z]'),
    onMatch: (match) => match[0]![1].toUpperCase(),
  );
}
