import 'dart:convert';
import 'dart:io';

import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';

///Icon metadata definition
class IconMetadata {
  final String name;
  final String label;
  final String unicode;
  final List<String> searchTerms;
  final List<String> free;

  IconMetadata(this.name, this.label, this.unicode, this.searchTerms, this.free);
}

///Icon category definition
class IconCategory {
  final String name;
  final String label;
  final List<String> icons;

  IconCategory(this.name, this.label, this.icons);
}

/// replace names that cannot be properties
const Map<String, String> nameAdjustments = {
  "500px": "fiveHundredPx",
  "1": "one",
  "2": "two",
  "3": "three",
  "4": "four",
  "5": "five",
  "6": "six",
  "7": "seven",
  "8": "eight",
  "9": "nine",
  "0": "zero",
  "42-group": "fortyTwoGroup"
};

void main() async {
  File iconsJson = File('assets/icons.json');
  File categoriesYaml = File('assets/categories.yml');
  final metadata = readMetadata(iconsJson);
  final categories = readCategories(categoriesYaml);

  writeCodeToFile(
    () => generateSearchTermMap(metadata),
    '../lib/src/font_awesome_search.dart',
  );

  writeCodeToFile(
    () => generateIconNameMap(metadata),
    '../lib/src/font_awesome_named.dart',
  );

  writeCodeToFile(
    () => generateCategories(metadata, categories),
    '../lib/src/font_awesome_categories.dart',
  );
}

/// Writes lines of code created by a [generator] to [filePath] and formats it
void writeCodeToFile(List<String> Function() generator, String filePath) {
  List<String> generated = generator();
  File(filePath).writeAsStringSync(generated.join('\n'));
  final result = Process.runSync('dart', ['format', filePath]);
  stdout.write(result.stdout);
  stderr.write((result.stderr));
}

/// Creates an inverted index from the search terms to the icons
List<String> generateSearchTermMap(List<IconMetadata> icons) {
  List<String> output = [
    "import 'package:flutter/widgets.dart';",
    "import 'package:font_awesome_flutter/font_awesome_flutter.dart';",
    '',
    '// THIS FILE IS AUTOMATICALLY GENERATED!',
    '/// Search term mapping to font awesome icons',
    'const Map<String, List<IconData>> searchTermMappings = {',
  ];

  final map = <String, Set<String>>{};
  for (var icon in icons) {
    String iconName;
    for (var style in icon.free) {
      iconName = normalizeIconName(icon.name, style, icon.free.length);
      for (var element in icon.searchTerms) {
        final cleanTerm = element.replaceAll(RegExp(r'[^\w\s]+'), '').toLowerCase();
        if (map.containsKey(cleanTerm)) {
          map[cleanTerm]!.add(iconName);
        } else {
          map.putIfAbsent(cleanTerm, () => {iconName});
        }
      }
    }
  }

  for (var element in map.entries) {
    output.add("'${element.key}': ${element.value.map((e) => 'FontAwesomeIcons.$e').toList().toString()},");
  }

  output.add('};');

  return output;
}

/// Creates a one to one map between the icon name and the respective IconData
List<String> generateIconNameMap(List<IconMetadata> icons) {
  List<String> output = [
    "import 'package:flutter/widgets.dart';",
    "import 'package:font_awesome_flutter/font_awesome_flutter.dart';",
    '',
    '// THIS FILE IS AUTOMATICALLY GENERATED!',
    '/// Name to IconData mapping',
    'const Map<String, IconData> faNamedMappings = {',
  ];

  String iconName;
  for (var icon in icons) {
    for (var style in icon.free) {
      iconName = normalizeIconName(icon.name, style, icon.free.length);
      output.add("'$iconName': FontAwesomeIcons.$iconName,");
    }
  }

  output.add('};');

  return output;
}

/// Creates constant categories list
List<String> generateCategories(List<IconMetadata> icons, List<IconCategory> categories) {
  List<String> output = [
    "import 'package:flutter/widgets.dart';",
    "import 'package:font_awesome_flutter/font_awesome_flutter.dart';",
    '',
    '// THIS FILE IS AUTOMATICALLY GENERATED!',
    "class IconCategory {"
        "final String name;"
        "final String label;"
        "final List<IconData> icons;"
        "IconCategory(this.name, this.label, this.icons);}"
        '/// Name to IconData mapping',
    'class FaIconCategory {',
  ];

  for (var category in categories) {
    output.add(
        "static IconCategory ${category.name.camelCase} = IconCategory('${category.name}', '${category.label}', ${category.icons.toList().map((e) => 'FontAwesomeIcons.${normalizeIconName(e, 'solid', 1)}').toList()});");
  }

  output.add("static List<IconCategory> get categories => ${categories.map((e) => e.name.camelCase).toList()};");
  output.add('}');

  return output;
}

/// Returns a normalized version of [iconName] which can be used as const name
String normalizeIconName(String iconName, String style, int styleCompetitors) {
  iconName = nameAdjustments[iconName] ?? iconName;

  if (styleCompetitors > 1 && style != "regular") {
    iconName = "${style}_$iconName";
  }

  return iconName.camelCase;
}

/// Read icon metadata with search terms
List<IconMetadata> readMetadata(File iconsJson) {
  final List<IconMetadata> metadata = <IconMetadata>[];
  Map<String, dynamic> rawMetadata;
  try {
    final content = iconsJson.readAsStringSync();
    rawMetadata = json.decode(content);
  } catch (_) {
    print('Error: Invalid icons.json. Make sure you have the right file.');
    exit(1);
  }

  Map<String, dynamic> icon;
  for (var iconName in rawMetadata.keys) {
    icon = rawMetadata[iconName];

    List<String> freeStyles = (icon['free'] as List).cast<String>();

    metadata.add(IconMetadata(
        iconName,
        icon['label'],
        icon['unicode'],
        (icon['search']['terms'] as List).map((e) => e.toString()).toList()
          ..add(icon['label'].toString().toLowerCase()),
        freeStyles));
  }

  return metadata;
}

///Read categories file from yaml
List<IconCategory> readCategories(File yaml) {
  final List<IconCategory> categories = <IconCategory>[];
  Map data = {};
  try {
    final content = yaml.readAsStringSync();
    data = loadYaml(content);
  } catch (_) {
    print('Error: Invalid categories.yml. Make sure you have the right file.');
    exit(1);
  }

  Map element;
  for (var category in data.keys) {
    element = data[category];
    categories.add(IconCategory(category, element['label'], (element['icons'] as List).cast<String>()));
  }

  return categories;
}