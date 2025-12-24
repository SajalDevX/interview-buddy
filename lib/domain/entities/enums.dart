enum InterviewType {
  quickPractice,
  standard,
  deepDive,
  technical,
  finalRound;

  String get displayName {
    switch (this) {
      case InterviewType.quickPractice:
        return 'Quick Practice';
      case InterviewType.standard:
        return 'Standard Interview';
      case InterviewType.deepDive:
        return 'Deep Dive';
      case InterviewType.technical:
        return 'Technical Round';
      case InterviewType.finalRound:
        return 'Final Round';
    }
  }

  String get description {
    switch (this) {
      case InterviewType.quickPractice:
        return 'Single question with immediate feedback';
      case InterviewType.standard:
        return '5-7 questions simulating first-round';
      case InterviewType.deepDive:
        return '10+ questions with follow-ups';
      case InterviewType.technical:
        return 'Focused technical assessment';
      case InterviewType.finalRound:
        return 'Executive-style comprehensive interview';
    }
  }

  int get questionCount {
    switch (this) {
      case InterviewType.quickPractice:
        return 1;
      case InterviewType.standard:
        return 6;
      case InterviewType.deepDive:
        return 12;
      case InterviewType.technical:
        return 8;
      case InterviewType.finalRound:
        return 15;
    }
  }

  String get estimatedDuration {
    switch (this) {
      case InterviewType.quickPractice:
        return '2-5 min';
      case InterviewType.standard:
        return '15-20 min';
      case InterviewType.deepDive:
        return '30-45 min';
      case InterviewType.technical:
        return '25-35 min';
      case InterviewType.finalRound:
        return '45-60 min';
    }
  }
}

enum QuestionCategory {
  behavioral,
  technical,
  situational,
  caseStudy,
  cultureFit;

  String get displayName {
    switch (this) {
      case QuestionCategory.behavioral:
        return 'Behavioral';
      case QuestionCategory.technical:
        return 'Technical';
      case QuestionCategory.situational:
        return 'Situational';
      case QuestionCategory.caseStudy:
        return 'Case Study';
      case QuestionCategory.cultureFit:
        return 'Culture Fit';
    }
  }

  String get description {
    switch (this) {
      case QuestionCategory.behavioral:
        return 'STAR method questions, Leadership scenarios';
      case QuestionCategory.technical:
        return 'Coding concepts, System design, Problem-solving';
      case QuestionCategory.situational:
        return 'Conflict resolution, Priority handling';
      case QuestionCategory.caseStudy:
        return 'Business problems, Market analysis';
      case QuestionCategory.cultureFit:
        return 'Values alignment, Team dynamics';
    }
  }
}

enum SkillLevel {
  beginner,
  developing,
  intermediate,
  advanced,
  expert;

  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.developing:
        return 'Developing';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
    }
  }

  String get badge {
    switch (this) {
      case SkillLevel.beginner:
        return 'Seedling';
      case SkillLevel.developing:
        return 'Book';
      case SkillLevel.intermediate:
        return 'Star';
      case SkillLevel.advanced:
        return 'Trophy';
      case SkillLevel.expert:
        return 'Crown';
    }
  }

  static SkillLevel fromScore(double score) {
    if (score >= 9.0) return SkillLevel.expert;
    if (score >= 7.5) return SkillLevel.advanced;
    if (score >= 6.0) return SkillLevel.intermediate;
    if (score >= 4.0) return SkillLevel.developing;
    return SkillLevel.beginner;
  }
}

enum TTSVoice {
  fritz,
  celeste,
  atlas,
  gail,
  mikail;

  String get displayName {
    switch (this) {
      case TTSVoice.fritz:
        return 'Fritz';
      case TTSVoice.celeste:
        return 'Celeste';
      case TTSVoice.atlas:
        return 'Atlas';
      case TTSVoice.gail:
        return 'Gail';
      case TTSVoice.mikail:
        return 'Mikail';
    }
  }

  String get apiName {
    switch (this) {
      case TTSVoice.fritz:
        return 'Fritz-PlayAI';
      case TTSVoice.celeste:
        return 'Celeste-PlayAI';
      case TTSVoice.atlas:
        return 'Atlas-PlayAI';
      case TTSVoice.gail:
        return 'Gail-PlayAI';
      case TTSVoice.mikail:
        return 'Mikail-PlayAI';
    }
  }

  String get description {
    switch (this) {
      case TTSVoice.fritz:
        return 'Professional male, clear diction';
      case TTSVoice.celeste:
        return 'Warm female, encouraging tone';
      case TTSVoice.atlas:
        return 'Authoritative male, executive style';
      case TTSVoice.gail:
        return 'Friendly female, conversational';
      case TTSVoice.mikail:
        return 'Neutral male, technical precision';
    }
  }
}

enum AchievementType {
  firstSteps,
  streakMaster,
  perfect10,
  wellRounded,
  resumeReady,
  marathonRunner,
  quickLearner;

  String get title {
    switch (this) {
      case AchievementType.firstSteps:
        return 'First Steps';
      case AchievementType.streakMaster:
        return 'Streak Master';
      case AchievementType.perfect10:
        return 'Perfect 10';
      case AchievementType.wellRounded:
        return 'Well Rounded';
      case AchievementType.resumeReady:
        return 'Resume Ready';
      case AchievementType.marathonRunner:
        return 'Marathon Runner';
      case AchievementType.quickLearner:
        return 'Quick Learner';
    }
  }

  String get description {
    switch (this) {
      case AchievementType.firstSteps:
        return 'Complete your first interview session';
      case AchievementType.streakMaster:
        return 'Practice 7 days in a row';
      case AchievementType.perfect10:
        return 'Score 10/10 on any response';
      case AchievementType.wellRounded:
        return 'Practice all question categories';
      case AchievementType.resumeReady:
        return 'Upload and parse your resume';
      case AchievementType.marathonRunner:
        return 'Complete 100 questions';
      case AchievementType.quickLearner:
        return 'Improve score by 2+ points in a week';
    }
  }
}
