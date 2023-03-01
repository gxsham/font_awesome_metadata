import 'package:flutter/material.dart';
import 'package:font_awesome_metadata/font_awesome_metadata.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Font awesome metadata example',
      home: FontAwesomeMetadataPage(),
    );
  }
}

class FontAwesomeMetadataPage extends StatefulWidget {
  const FontAwesomeMetadataPage({super.key});

  @override
  State<FontAwesomeMetadataPage> createState() => _FontAwesomeMetadataPageState();
}

class _FontAwesomeMetadataPageState extends State<FontAwesomeMetadataPage> {
  List<IconData> results = [];
  TextEditingController controller = TextEditingController();

  void directSearch(String searchTerm) {
    setState(() {
      results = searchTermMappings[searchTerm] ?? [];
    });
  }

  void multipleSearch(String searchTerm) {
    setState(() {
      results = searchTermMappings.entries // get the entries as iterable
          .where((e) => e.key.contains(searchTerm)) // search for all the entries where the key contains the search term
          .map((e) => e.value) // select only the entry value
          .expand((e) => e) // because the value is a list expand all the results to a single list
          .toSet() // make sure you don't have duplicates
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Font Awesome Metadata'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: controller,
            ),
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
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      tooltip: 'Direct search',
                      onPressed: () => directSearch(controller.text),
                      icon: FaIcon(
                        faNamedMappings['magnifyingGlass'],
                      )),
                  IconButton(
                      tooltip: 'Full search',
                      onPressed: () => multipleSearch(controller.text),
                      icon: FaIcon(faNamedMappings['expand']))
                ],
              ),
            ),
            Expanded(
                child: GridView.builder(
                    itemCount: results.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
                    itemBuilder: (context, index) => FaIcon(results[index])))
          ],
        ),
      ),
    );
  }
}
