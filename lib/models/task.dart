class Task {
  String text;
  bool isDone;

  Task({required this.text, this.isDone = false});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(text: json['text'], isDone: json['isDone']);
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'isDone': isDone};
  }
}