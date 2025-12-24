part of 'interview_bloc.dart';

abstract class InterviewEvent extends Equatable {
  const InterviewEvent();

  @override
  List<Object?> get props => [];
}

class StartInterviewEvent extends InterviewEvent {
  final InterviewType interviewType;
  final QuestionCategory? questionCategory;
  final String? targetRole;
  final ParsedResume? resume;

  const StartInterviewEvent({
    required this.interviewType,
    this.questionCategory,
    this.targetRole,
    this.resume,
  });

  @override
  List<Object?> get props => [interviewType, questionCategory, targetRole, resume];
}

class StartRecordingEvent extends InterviewEvent {
  const StartRecordingEvent();
}

class StopRecordingEvent extends InterviewEvent {
  const StopRecordingEvent();
}

class SubmitAnswerEvent extends InterviewEvent {
  final String question;
  final QuestionCategory category;
  final String transcript;
  final String? audioPath;

  const SubmitAnswerEvent({
    required this.question,
    required this.category,
    required this.transcript,
    this.audioPath,
  });

  @override
  List<Object?> get props => [question, category, transcript, audioPath];
}

class NextQuestionEvent extends InterviewEvent {
  const NextQuestionEvent();
}

class CompleteInterviewEvent extends InterviewEvent {
  const CompleteInterviewEvent();
}

class TextToSpeechEvent extends InterviewEvent {
  final String text;
  final TTSVoice voice;

  const TextToSpeechEvent({
    required this.text,
    this.voice = TTSVoice.fritz,
  });

  @override
  List<Object?> get props => [text, voice];
}

class TranscribeAudioEvent extends InterviewEvent {
  final dynamic audioFile;

  const TranscribeAudioEvent({required this.audioFile});

  @override
  List<Object?> get props => [audioFile];
}
