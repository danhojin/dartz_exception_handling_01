import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:english_words/english_words.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';

class MockWordHttpClient {
  static final _rng = Random();
  static var _id = 0;

  Future<String> getResponseBody() async {
    MockWordHttpClient._id++;
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    switch (MockWordHttpClient._rng.nextInt(10)) {
      case 0:
        throw const SocketException('No Internet');
      case 1:
        throw const HttpException('404');
      case 2:
        return 'abcd'; // Invalid json
      case 3:
        throw const FileSystemException(); // Missed exception
      default:
        final name = generateWordPairs().first;
        return '{"id": ${MockWordHttpClient._id}, "name": "$name"}';
    }
  }
}

class EnglishWordService {
  final mockWordHttpClient = MockWordHttpClient();
  Future<EnglishWord> getOnePost() async {
    try {
      final responseBody = await mockWordHttpClient.getResponseBody();
      return EnglishWord.fromJson(responseBody);
    } on SocketException catch (e) {
      throw Failure(e.toString());
    } on HttpException catch (e) {
      throw Failure(e.toString());
    } on FormatException catch (e) {
      throw Failure(e.toString());
    }
  }
}

class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() {
    return message;
  }
}

class EnglishWord {
  final int id;
  final String name;

  EnglishWord({required this.id, required this.name});

  EnglishWord.fromMap(Map<String, dynamic> map)
      : id = map['id'] as int,
        name = map['name'] as String;

  factory EnglishWord.fromJson(String source) {
    return EnglishWord.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'id: $id, name: $name';
  }
}

enum EnglishWordStates {
  waiting,
  hasData,
  hasError,
  done,
}

class EnglishWordsController extends GetxController {
  final wordService = EnglishWordService();
  RxList<EnglishWord> words = <EnglishWord>[].obs;
  // Rx<EnglishWordStates> state = EnglishWordStates.done.obs;

  void getOneWord() {
    // state = EnglishWordStates.waiting as Rx<EnglishWordStates>;
    Task<EnglishWord>(() => wordService.getOnePost())
        .attempt()
        .map(
          (either) => either.leftMap(
            (l) {
              try {
                return l as Failure;
              } catch (e) {
                return Failure('Unexpected exception found: $e');
              }
            },
          ),
        )
        .run() // task into a future
        .then(
      (w) {
        w.fold(
          (l) => Get.snackbar(
            'Service Error',
            l.message,
            snackPosition: SnackPosition.BOTTOM,
          ),
          (r) => words.add(r),
        );
      },
    );
  }
}
