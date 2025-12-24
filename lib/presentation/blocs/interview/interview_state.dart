part of 'interview_bloc.dart';

abstract class InterviewState extends Equatable {
  const InterviewState();

  @override
  List<Object?> get props => [];
}

class InterviewInitial extends InterviewState {}

class InterviewLoading extends InterviewState {}

/// Main state during an active interview session
class InterviewInProgress extends InterviewState {
  final InterviewSession session;
  final InterviewQuestion currentQuestion;
  final int currentQuestionIndex;
  final int totalQuestions;
  final bool isRecording;
  final bool isProcessing;
  final String currentTranscript;
  final String aiResponse;
  final Map<String, dynamic>? currentFeedback;

  const InterviewInProgress({
    required this.session,
    required this.currentQuestion,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    this.isRecording = false,
    this.isProcessing = false,
    this.currentTranscript = '',
    this.aiResponse = '',
    this.currentFeedback,
  });

  InterviewInProgress copyWith({
    InterviewSession? session,
    InterviewQuestion? currentQuestion,
    int? currentQuestionIndex,
    int? totalQuestions,
    bool? isRecording,
    bool? isProcessing,
    String? currentTranscript,
    String? aiResponse,
    Map<String, dynamic>? currentFeedback,
  }) {
    return InterviewInProgress(
      session: session ?? this.session,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      currentTranscript: currentTranscript ?? this.currentTranscript,
      aiResponse: aiResponse ?? this.aiResponse,
      currentFeedback: currentFeedback ?? this.currentFeedback,
    );
  }

  @override
  List<Object?> get props => [
        session,
        currentQuestion,
        currentQuestionIndex,
        totalQuestions,
        isRecording,
        isProcessing,
        currentTranscript,
        aiResponse,
        currentFeedback,
      ];
}

class InterviewQuestion {
  final String question;
  final QuestionCategory category;
  final int index;

  const InterviewQuestion({
    required this.question,
    required this.category,
    required this.index,
  });
}

class InterviewCompleted extends InterviewState {
  final InterviewSession session;

  const InterviewCompleted({required this.session});

  @override
  List<Object?> get props => [session];
}

class InterviewError extends InterviewState {
  final String message;

  const InterviewError(this.message);

  @override
  List<Object?> get props => [message];
}
