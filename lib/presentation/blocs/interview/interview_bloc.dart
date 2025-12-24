import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/enums.dart';
import '../../../domain/entities/interview_session.dart';
import '../../../domain/entities/parsed_resume.dart';
import '../../../domain/usecases/interview/start_interview_usecase.dart';
import '../../../domain/usecases/interview/submit_answer_usecase.dart';
import '../../../domain/usecases/interview/get_feedback_usecase.dart';
import '../../../domain/usecases/progress/update_progress_usecase.dart';
import '../../../data/datasources/remote/groq_api_service.dart';

part 'interview_event.dart';
part 'interview_state.dart';

class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  final StartInterviewUseCase startInterviewUseCase;
  final SubmitAnswerUseCase submitAnswerUseCase;
  final GetFeedbackUseCase getFeedbackUseCase;
  final UpdateProgressUseCase updateProgressUseCase;
  final GroqApiService groqApiService;

  InterviewSession? _currentSession;
  List<InterviewQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  ParsedResume? _resume;

  InterviewBloc({
    required this.startInterviewUseCase,
    required this.submitAnswerUseCase,
    required this.getFeedbackUseCase,
    required this.updateProgressUseCase,
    required this.groqApiService,
  }) : super(InterviewInitial()) {
    on<StartInterviewEvent>(_onStartInterview);
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<NextQuestionEvent>(_onNextQuestion);
    on<CompleteInterviewEvent>(_onCompleteInterview);
    on<TextToSpeechEvent>(_onTextToSpeech);
    on<TranscribeAudioEvent>(_onTranscribeAudio);
  }

  Future<void> _onStartInterview(
    StartInterviewEvent event,
    Emitter<InterviewState> emit,
  ) async {
    emit(InterviewLoading());

    _resume = event.resume;

    try {
      // Generate questions using Groq API
      final questionTexts = await groqApiService.generateInterviewQuestions(
        targetRole: event.targetRole ?? 'Software Engineer',
        interviewType: event.interviewType,
        category: event.questionCategory ?? QuestionCategory.behavioral,
        resume: _resume,
        count: event.interviewType.questionCount,
      );

      // Create interview questions with categories
      _questions = questionTexts.asMap().entries.map((entry) {
        return InterviewQuestion(
          question: entry.value,
          category: event.questionCategory ?? _getRandomCategory(entry.key),
          index: entry.key,
        );
      }).toList();

      _currentQuestionIndex = 0;

      // Create session
      _currentSession = InterviewSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        targetRole: event.targetRole ?? 'Software Engineer',
        type: event.interviewType,
        startedAt: DateTime.now(),
        responses: [],
      );

      if (_questions.isNotEmpty) {
        emit(InterviewInProgress(
          session: _currentSession!,
          currentQuestion: _questions[0],
          currentQuestionIndex: 0,
          totalQuestions: _questions.length,
        ));
      } else {
        emit(const InterviewError('Failed to generate questions'));
      }
    } catch (e) {
      emit(InterviewError('Failed to start interview: ${e.toString()}'));
    }
  }

  QuestionCategory _getRandomCategory(int index) {
    const categories = QuestionCategory.values;
    return categories[index % categories.length];
  }

  Future<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<InterviewState> emit,
  ) async {
    if (state is InterviewInProgress) {
      final currentState = state as InterviewInProgress;
      emit(currentState.copyWith(
        isRecording: true,
        currentTranscript: '',
        aiResponse: '',
        currentFeedback: null,
      ));
    }
  }

  Future<void> _onStopRecording(
    StopRecordingEvent event,
    Emitter<InterviewState> emit,
  ) async {
    if (state is InterviewInProgress) {
      final currentState = state as InterviewInProgress;
      emit(currentState.copyWith(
        isRecording: false,
        isProcessing: true,
      ));

      try {
        // For demo, simulate a transcript
        await Future.delayed(const Duration(seconds: 1));
        final mockTranscript = 'This is my answer to the question about ${currentState.currentQuestion.category.displayName}. I have experience in this area and can provide specific examples from my previous role...';

        emit(currentState.copyWith(
          isRecording: false,
          isProcessing: true,
          currentTranscript: mockTranscript,
        ));

        // Evaluate the answer
        final evaluation = await groqApiService.evaluateAnswer(
          question: currentState.currentQuestion.question,
          answer: mockTranscript,
          category: currentState.currentQuestion.category,
          targetRole: _currentSession?.targetRole ?? 'Software Engineer',
        );

        // Create feedback map from EvaluationResult
        final feedbackMap = {
          'overallScore': evaluation.overallScore / 10, // Normalize to 0-1
          'contentScore': evaluation.contentScore,
          'structureScore': evaluation.structureScore,
          'communicationScore': evaluation.communicationScore,
          'confidenceScore': evaluation.confidenceScore,
          'feedback': evaluation.feedback,
          'strengths': evaluation.strengths,
          'improvements': evaluation.improvements,
          'modelAnswer': evaluation.modelAnswer,
        };

        emit(currentState.copyWith(
          isRecording: false,
          isProcessing: false,
          currentTranscript: mockTranscript,
          aiResponse: evaluation.feedback,
          currentFeedback: feedbackMap,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isRecording: false,
          isProcessing: false,
        ));
        emit(InterviewError('Failed to process answer: ${e.toString()}'));
      }
    }
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<InterviewState> emit,
  ) async {
    if (_currentSession == null) {
      emit(const InterviewError('No active session'));
      return;
    }

    if (state is InterviewInProgress) {
      final currentState = state as InterviewInProgress;
      emit(currentState.copyWith(isProcessing: true));

      try {
        // Evaluate the answer
        final evaluation = await groqApiService.evaluateAnswer(
          question: event.question,
          answer: event.transcript,
          category: event.category,
          targetRole: _currentSession!.targetRole,
        );

        // Create response record
        final response = QuestionResponse(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          question: event.question,
          category: event.category,
          transcript: event.transcript,
          audioPath: event.audioPath,
          score: ResponseScore(
            content: evaluation.contentScore,
            structure: evaluation.structureScore,
            communication: evaluation.communicationScore,
            confidence: evaluation.confidenceScore,
            overall: evaluation.overallScore,
          ),
          feedback: evaluation.feedback,
          modelAnswer: evaluation.modelAnswer,
          answeredAt: DateTime.now(),
          responseDuration: const Duration(minutes: 2),
        );

        // Add to session responses
        final updatedResponses = [..._currentSession!.responses, response];
        _currentSession = _currentSession!.copyWith(responses: updatedResponses);

        final feedbackMap = {
          'overallScore': evaluation.overallScore / 10,
          'strengths': evaluation.strengths,
          'improvements': evaluation.improvements,
        };

        emit(currentState.copyWith(
          session: _currentSession,
          isProcessing: false,
          currentFeedback: feedbackMap,
        ));
      } catch (e) {
        emit(InterviewError('Failed to evaluate answer: ${e.toString()}'));
      }
    }
  }

  Future<void> _onNextQuestion(
    NextQuestionEvent event,
    Emitter<InterviewState> emit,
  ) async {
    _currentQuestionIndex++;

    if (_currentQuestionIndex < _questions.length && _currentSession != null) {
      emit(InterviewInProgress(
        session: _currentSession!,
        currentQuestion: _questions[_currentQuestionIndex],
        currentQuestionIndex: _currentQuestionIndex,
        totalQuestions: _questions.length,
      ));
    } else {
      add(const CompleteInterviewEvent());
    }
  }

  Future<void> _onCompleteInterview(
    CompleteInterviewEvent event,
    Emitter<InterviewState> emit,
  ) async {
    if (_currentSession == null) {
      emit(const InterviewError('No active session'));
      return;
    }

    emit(InterviewLoading());

    // Calculate average score
    double totalScore = 0;
    final categoryScores = <QuestionCategory, double>{};

    for (final response in _currentSession!.responses) {
      if (response.score != null) {
        totalScore += response.score!.overall;
        final existing = categoryScores[response.category] ?? 0;
        final count = _currentSession!.responses
            .where((r) => r.category == response.category)
            .length;
        categoryScores[response.category] =
            (existing * (count - 1) + response.score!.overall) / count;
      }
    }

    final averageScore = _currentSession!.responses.isNotEmpty
        ? totalScore / _currentSession!.responses.length
        : 0.0;

    // Update session with final score and end time
    _currentSession = _currentSession!.copyWith(
      completedAt: DateTime.now(),
      overallScore: ResponseScore(
        content: averageScore,
        structure: averageScore,
        communication: averageScore,
        confidence: averageScore,
        overall: averageScore,
      ),
    );

    // Update progress
    if (_currentSession!.responses.isNotEmpty) {
      await updateProgressUseCase(
        questionsAnswered: _currentSession!.responses.length,
        categoryScores: categoryScores,
        sessionScore: averageScore,
      );
    }

    emit(InterviewCompleted(session: _currentSession!));

    // Reset state
    _questions = [];
    _currentQuestionIndex = 0;
  }

  Future<void> _onTextToSpeech(
    TextToSpeechEvent event,
    Emitter<InterviewState> emit,
  ) async {
    try {
      await groqApiService.textToSpeech(
        text: event.text,
        voice: event.voice,
      );
    } catch (e) {
      // TTS errors are non-critical
    }
  }

  Future<void> _onTranscribeAudio(
    TranscribeAudioEvent event,
    Emitter<InterviewState> emit,
  ) async {
    if (state is InterviewInProgress) {
      final currentState = state as InterviewInProgress;
      emit(currentState.copyWith(isProcessing: true));

      try {
        final transcript = await groqApiService.transcribeAudio(event.audioFile);
        emit(currentState.copyWith(
          isProcessing: false,
          currentTranscript: transcript,
        ));
      } catch (e) {
        emit(currentState.copyWith(isProcessing: false));
        emit(InterviewError('Failed to transcribe audio: ${e.toString()}'));
      }
    }
  }
}
