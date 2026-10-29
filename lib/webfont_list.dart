import 'dart:convert';

import 'package:flutter/services.dart';

import 'src/webfont_enums.dart';

export 'src/webfont_enums.dart';

const webfontListAssetPath = 'packages/webfont_list/assets/webfont_list.json';

class const WebFont({
  required final String family,
  required final List<String> variants,
  required final List<WebFontSubset> subsets,
  required final String version,
  required final String lastModified,
  required final Map<String, String> files,
  required final WebFontCategory category,
  required final String menu,
  required final int popularityRank,
});

Future<List<WebFont>> loadWebfontList() async {
  final webfontList = jsonDecode(
    await rootBundle.loadString(webfontListAssetPath),
  );
  final webFontSubsetNameMap = WebFontSubset.values.asNameMap();
  final webFontCategoryNameMap = WebFontCategory.values.asNameMap();
  return [
    for (final font in webfontList as List<dynamic>)
      if (font case {
        'family': final String family,
        'variants': final List<dynamic> variants,
        'subsets': final List<dynamic> subsets,
        'version': final String version,
        'lastModified': final String lastModified,
        'files': final Map<String, dynamic> files,
        'category': final String category,
        'menu': final String menu,
        'popularityRank': final int popularityRank,
      })
        if (webFontCategoryNameMap[category] case final category?)
          WebFont(
            family: family,
            variants: [
              for (final variant in variants)
                if (variant is String) variant,
            ],
            subsets: [
              for (final subset in subsets) ?webFontSubsetNameMap[subset],
            ],
            version: version,
            lastModified: lastModified,
            files: {
              for (final MapEntry(:key, :value) in files.entries)
                if (value is String) key: value,
            },
            category: category,
            menu: menu,
            popularityRank: popularityRank,
          ),
  ];
}
