import 'package:dartz_exception_handling_01/english_word_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.put(EnglishWordsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dartz Exception Handling'),
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: c.words.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Text(c.words[index].id.toString()),
              title: Text(c.words[index].name),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => c.getOneWord(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
