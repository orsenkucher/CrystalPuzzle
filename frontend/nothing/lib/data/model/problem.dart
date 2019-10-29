import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Problem extends Equatable {
  final String question;
  final String explanation;
  final List<String> answers;

  const Problem({
    @required this.question,
    @required this.explanation,
    @required this.answers,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      question: json['question'],
      explanation: json['explanation'],
      answers: List<String>.from(json['answer']),
    );
  }

  @override
  List<Object> get props => [question, explanation, answers];
}