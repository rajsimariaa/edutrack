class Flashcard {
  final String id;
  final String front;
  final String back;
  final String? subjectName;
  final String? chapterName;
  bool isKnown;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.subjectName,
    this.chapterName,
    this.isKnown = false,
  });
}
