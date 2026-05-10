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
  final source = [
    '''
    // Generated file. Do not edit.
    //
    // Source: webfonts.json
    // To regenerate, run: `dart run tool/generate_metadatas.dart webfonts.json`

    enum WebFontSubset {${subsets.join(',')}}

    enum WebFontCategory {${categories.join(',')}}

    class WebFont {
      const WebFont({
        required this.family,
        required this.variants,
        required this.subsets,
        required this.version,
        required this.lastModified,
        required this.files,
        required this.category,
        required this.menu,
        required this.popularityRank,
      });

      final String family;
      final List<String> variants;
      final List<WebFontSubset> subsets;
      final String version;
      final String lastModified;
      final Map<String, String> files;
      final WebFontCategory category;
      final String menu;
      final int popularityRank;
    }

    ''',
    'const webfontList = [',
    for (final item in items) ...[
      'WebFont(',
      "  family: '${item.family}',",
      '  variants: [',
      for (final variant in item.variants) "'$variant',",
      '  ],',
      '  subsets: [',
      for (final subset in item.subsets) 'WebFontSubset.$subset,',
      '  ],',
      "  version: '${item.version}',",
      "  lastModified: '${item.lastModified}',",
      '  files: {',
      for (final entry in item.files.entries)
        "  '${entry.key}': '${entry.value}',",
      '  },',
      '  category: WebFontCategory.${item.category},',
      "  menu: '${item.menu}',",
      "  popularityRank: ${item.popularityRank},",
      '),',
    ],
    '];',
  ].join('\n');
  File("lib/webfont_list.dart").writeAsStringSync(
    DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(source),
  );
}

String _toCamelCase(String kebabCase) {
  return kebabCase.splitMapJoin(
    RegExp(r'-[a-z]'),
    onMatch: (match) => match[0]![1].toUpperCase(),
  );
}
