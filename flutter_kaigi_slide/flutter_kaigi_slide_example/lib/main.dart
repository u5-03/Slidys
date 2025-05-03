import 'package:flutter/material.dart';
import 'package:flutter_kaigi_slide/main.dart';
import 'package:flutter_kaigi_slide_example/screens/path_animation_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterKaigi Widget Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FlutterKaigi Widget Demo'),
    );
  }
}

enum SectionType {
  pageTypes,
  samples;
}

enum SampleTypes {
  pathAnimation,
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: CustomScrollView(
          slivers: SectionType.values.map((sectionType) {
            final items = switch (sectionType) {
              SectionType.pageTypes => PageType.values,
              SectionType.samples => SampleTypes.values,
            };
            return SliverList(
                delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  sectionType.name,
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              ...items.map((item) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        _onTapItem(sectionType, item.name);
                      },
                      child: ListTile(
                        title: Text(item.name,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                            )),
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.primary,
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                    )
                  ],
                );
              }),
            ]));
          }).toList(),
        ));
  }

  void _onTapItem(SectionType sectionType, String item) {
    switch (sectionType) {
      case SectionType.pageTypes:
        final pageType = PageType.values.firstWhere((e) => e.name == item);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Scaffold(
                    appBar: AppBar(
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      title: Text(pageType.name),
                    ),
                    extendBodyBehindAppBar: true,
                    body: pageType.widget,
                  )),
        );
      case SectionType.samples:
        final sampleType = SampleTypes.values.firstWhere((e) => e.name == item);
        switch (sampleType) {
          case SampleTypes.pathAnimation:
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PathAnimationListScreen()),
            );
        }
    }
  }
}
