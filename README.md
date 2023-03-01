
# font_awesome_metadata

The free [Font Awesome](https://fontawesome.com/icons) Icon pack based on the [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) package with additional mapped metadata allowing to search and filter the icons. Latest build is  based on Font Awesome version 6.3.0.

## Installation

In the `dependencies:` section of your `pubspec.yaml`, add the following line:

```yaml
dependencies:
  font_awesome_metadata: <latest_version>
```

## Usage

This package contains a search structure in the form of a map. This is an inverted map from the official Font Awesome data, where each search terms is mapped with a list of Icons.
This map called `searchTermMappings` can be used to execute direct or expanded searches. A direct search would return your results from an exact match: 

```dart
import 'package:font_awesome_metadata/font_awesome_metadata.dart';
...
List<IconData> results = searchTermMappings[searchTerm];
```

Or you can expand the query by looking for all the words containing your search term:

```dart
    List<IconData> results = searchTermMappings.entries // get the entries as iterable
          .where((e) => e.key.contains(searchTerm)) // search for all the entries where the key contains the search term
          .map((e) => e.value) // select only the entry value
          .expand((e) => e) // because the value is a list expand all the results to a single list
          .toSet() // make sure you don't have duplicates
          .toList();
```

The `faNamedMappings` map has a one to one relation from the Icon name to it's respective IconData, based on the [Font Awesome website](https://fontawesome.com/icons). The naming is changed to camelCase and icons starting with numbers have the numbers in a writtern form.

```dart
 FaIcon(faNamedMappings['magnifyingGlass'])
```

The `FaIconCategory` class is build based on the search categories from the [Font Awesome website](https://fontawesome.com/icons). Each category has a list of Icons and additional metadata which can be used for display. 

```dart
DropdownButton<IconCategory>(
        hint: const Text('Select category'),
        items: FaIconCategory.categories
        .map((e) => DropdownMenuItem<IconCategory>(
            value: e,
            child: Text(e.label),
            ))
        .toList(),
        onChanged: (value) {
            setState(() {
                results = value?.icons ?? [];
            });
        }),
```