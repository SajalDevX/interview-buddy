import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/enums.dart';
import '../../../domain/entities/interview_session.dart';
import '../../../domain/entities/parsed_resume.dart';
import '../../../domain/usecases/interview/start_interview_usecase.dart';
import '../../../domain/usecases/interview/submit_answer_usecase.dart';
import '../../../domain/usecases/interview/get_feedback_usecase.dart';
import '../../../domain/usecases/progress/update_progress_usecase.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../data/datasources/remote/groq_api_service.dart';
import '../../../data/datasources/remote/gemini_api_service.dart';

part 'interview_event.dart';
part 'interview_state.dart';

class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  final StartInterviewUseCase startInterviewUseCase;
  final SubmitAnswerUseCase submitAnswerUseCase;
  final GetFeedbackUseCase getFeedbackUseCase;
  final UpdateProgressUseCase updateProgressUseCase;
  final GroqApiService groqApiService;
  final GeminiApiService geminiApiService;
  final SettingsRepository settingsRepository;

  InterviewSession? _currentSession;
  List<InterviewQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  ParsedResume? _resume;
  AIProvider _currentProvider = AIProvider.gemini;

  InterviewBloc({
    required this.startInterviewUseCase,
    required this.submitAnswerUseCase,
    required this.getFeedbackUseCase,
    required this.updateProgressUseCase,
    required this.groqApiService,
    required this.geminiApiService,
    required this.settingsRepository,
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
      // Load settings to get AI provider
      developer.log('InterviewBloc: Loading settings...', name: 'InterviewBloc');
      final settingsResult = await settingsRepository.getSettings();

      settingsResult.fold(
        (failure) {
          developer.log('InterviewBloc: Failed to load settings: ${failure.message}', name: 'InterviewBloc');
        },
        (settings) {
          _currentProvider = settings.aiProvider;
          developer.log('InterviewBloc: AI Provider: ${_currentProvider.displayName}', name: 'InterviewBloc');
        },
      );

      // Load appropriate API key based on provider
      String? apiKey;
      if (_currentProvider == AIProvider.gemini) {
        developer.log('InterviewBloc: Loading Gemini API key...', name: 'InterviewBloc');
        final geminiKeyResult = await settingsRepository.getGeminiApiKey();
        geminiKeyResult.fold(
          (failure) => developer.log('InterviewBloc: Failed to load Gemini API key: ${failure.message}', name: 'InterviewBloc'),
          (key) => apiKey = key,
        );

        if (apiKey == null || apiKey!.isEmpty) {
          emit(const InterviewError('Gemini API key not configured. Please add your Gemini API key in Settings.'));
          return;
        }

        geminiApiService.setApiKey(apiKey!);
        developer.log('InterviewBloc: Gemini API key set (${apiKey!.length} chars)', name: 'InterviewBloc');
      } else {
        developer.log('InterviewBloc: Loading Groq API key...', name: 'InterviewBloc');
        final groqKeyResult = await settingsRepository.getApiKey();
        groqKeyResult.fold(
          (failure) => developer.log('InterviewBloc: Failed to load Groq API key: ${failure.message}', name: 'InterviewBloc'),
          (key) => apiKey = key,
        );

        if (apiKey == null || apiKey!.isEmpty) {
          emit(const InterviewError('Groq API key not configured. Please add your Groq API key in Settings.'));
          return;
        }

        groqApiService.setApiKey(apiKey!);
        developer.log('InterviewBloc: Groq API key set (${apiKey!.length} chars)', name: 'InterviewBloc');
      }

      // Generate questions using selected AI provider
      developer.log('InterviewBloc: Generating interview questions with ${_currentProvider.displayName}...', name: 'InterviewBloc');
      developer.log('InterviewBloc: Target role: ${event.targetRole ?? "Software Engineer"}', name: 'InterviewBloc');
      developer.log('InterviewBloc: Interview type: ${event.interviewType}', name: 'InterviewBloc');
      developer.log('InterviewBloc: Category: ${event.questionCategory ?? QuestionCategory.behavioral}', name: 'InterviewBloc');
      developer.log('InterviewBloc: Question count: ${event.interviewType.questionCount}', name: 'InterviewBloc');

      List<String> questionTexts;
      if (_currentProvider == AIProvider.gemini) {
        questionTexts = await geminiApiService.generateInterviewQuestions(
          targetRole: event.targetRole ?? 'Software Engineer',
          interviewType: event.interviewType,
          category: event.questionCategory ?? QuestionCategory.behavioral,
          resume: _resume,
          count: event.interviewType.questionCount,
        );
      } else {
        questionTexts = await groqApiService.generateInterviewQuestions(
          targetRole: event.targetRole ?? 'Software Engineer',
          interviewType: event.interviewType,
          category: event.questionCategory ?? QuestionCategory.behavioral,
          resume: _resume,
          count: event.interviewType.questionCount,
        );
      }

      developer.log('InterviewBloc: Generated ${questionTexts.length} questions', name: 'InterviewBloc');

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
        developer.log('InterviewBloc: Interview started successfully', name: 'InterviewBloc');
        emit(InterviewInProgress(
          session: _currentSession!,
          currentQuestion: _questions[0],
          currentQuestionIndex: 0,
          totalQuestions: _questions.length,
        ));
      } else {
        developer.log('InterviewBloc: No questions generated', name: 'InterviewBloc');
        emit(const InterviewError('Failed to generate questions. The AI returned no questions.'));
      }
    } catch (e, stackTrace) {
      developer.log(
        'InterviewBloc: Error starting interview',
        name: 'InterviewBloc',
        error: e,
        stackTrace: stackTrace,
      );
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

        // Evaluate the answer using selected provider
        developer.log('InterviewBloc: Evaluating answer with ${_currentProvider.displayName}', name: 'InterviewBloc');

        late final dynamic evaluation;
        if (_currentProvider == AIProvider.gemini) {
          evaluation = await geminiApiService.evaluateAnswer(
            question: currentState.currentQuestion.question,
            answer: mockTranscript,
            category: currentState.currentQuestion.category,
            targetRole: _currentSession?.targetRole ?? 'Software Engineer',
          );
        } else {
          evaluation = await groqApiService.evaluateAnswer(
            question: currentState.currentQuestion.question,
            answer: mockTranscript,
            category: currentState.currentQuestion.category,
            targetRole: _currentSession?.targetRole ?? 'Software Engineer',
          );
        }

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
        // Evaluate the answer using selected provider
        developer.log('InterviewBloc: Evaluating answer with ${_currentProvider.displayName}', name: 'InterviewBloc');

        late final dynamic evaluation;
        if (_currentProvider == AIProvider.gemini) {
          final geminiEval = await geminiApiService.evaluateAnswer(
            question: event.question,
            answer: event.transcript,
            category: event.category,
            targetRole: _currentSession!.targetRole,
          );
          evaluation = geminiEval;
        } else {
          evaluation = await groqApiService.evaluateAnswer(
            question: event.question,
            answer: event.transcript,
            category: event.category,
            targetRole: _currentSession!.targetRole,
          );
        }

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
      // TTS requires Groq API (PlayAI model)
      final groqKeyResult = await settingsRepository.getApiKey();
      String? groqKey;
      groqKeyResult.fold(
        (_) => groqKey = null,
        (key) => groqKey = key,
      );

      if (groqKey == null || groqKey!.isEmpty) {
        developer.log('InterviewBloc: TTS skipped - Groq API key not configured', name: 'InterviewBloc');
        return;
      }

      groqApiService.setApiKey(groqKey!);
      await groqApiService.textToSpeech(
        text: event.text,
        voice: event.voice,
      );
    } catch (e) {
      developer.log('InterviewBloc: TTS error: $e', name: 'InterviewBloc');
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
        // Transcription requires Groq API (Whisper model)
        final groqKeyResult = await settingsRepository.getApiKey();
        String? groqKey;
        groqKeyResult.fold(
          (_) => groqKey = null,
          (key) => groqKey = key,
        );

        if (groqKey == null || groqKey!.isEmpty) {
          emit(currentState.copyWith(isProcessing: false));
          emit(const InterviewError('Transcription requires Groq API key. Please configure it in Settings.'));
          return;
        }

        groqApiService.setApiKey(groqKey!);
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
