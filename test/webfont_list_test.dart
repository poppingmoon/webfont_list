import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webfont_list/webfont_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads all fonts', () async {
    final webfontList = await loadWebfontList();
    final json = [
      for (final font in webfontList)
        {
          'family': font.family,
          'variants': font.variants,
          'subsets': font.subsets.map((subset) => subset.name).toList(),
          'version': font.version,
          'lastModified': font.lastModified,
          'files': font.files,
          'category': font.category.name,
          'menu': font.menu,
          'popularityRank': font.popularityRank,
        },
    ];
    final encoded = jsonEncode(json);
    final asset = await rootBundle.loadString(webfontListAssetPath);
    expect(encoded, asset);
  });
}
