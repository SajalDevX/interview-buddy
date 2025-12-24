import '../../../domain/entities/enums.dart';
import '../../../domain/entities/parsed_resume.dart';

class AIPrompts {
  AIPrompts._();

  /// System prompt for AI Interviewer
  static String getInterviewerSystemPrompt({
    required String targetRole,
    required InterviewType interviewType,
    ParsedResume? resume,
  }) {
    final resumeContext = resume != null
        ? '''
The candidate has the following background:
- Name: ${resume.fullName ?? 'Not provided'}
- Years of Experience: ${resume.yearsOfExperience} years
- Skills: ${resume.skills.take(10).join(', ')}
- Recent Role: ${resume.workExperience.isNotEmpty ? resume.workExperience.first.role : 'Not provided'}
- Education: ${resume.education.isNotEmpty ? '${resume.education.first.degree} from ${resume.education.first.institution}' : 'Not provided'}
'''
        : '';

    return '''You are an expert AI interview coach conducting a ${interviewType.displayName} for a ${targetRole} position.

ROLE AND PERSONALITY:
- Act as a professional, experienced interviewer from a top-tier company
- Be encouraging but maintain professional standards
- Adapt your questioning style to the candidate's experience level
- Ask probing follow-up questions to understand depth of knowledge

$resumeContext

INTERVIEW GUIDELINES:
1. Ask clear, well-structured questions appropriate for the ${targetRole} role
2. For ${interviewType.displayName}, focus on ${_getInterviewFocus(interviewType)}
3. Questions should be challenging but fair
4. Avoid yes/no questions - encourage detailed responses
5. Reference specific technologies/skills relevant to ${targetRole} when appropriate

QUESTION STYLE:
- Use open-ended questions that reveal problem-solving ability
- Include scenario-based questions when appropriate
- For technical roles, balance conceptual and practical questions
- Ensure questions are relevant to current industry practices

Remember: Your goal is to help the candidate prepare effectively by simulating real interview conditions.''';
  }

  static String _getInterviewFocus(InterviewType type) {
    switch (type) {
      case InterviewType.quickPractice:
        return 'a single comprehensive question to warm up';
      case InterviewType.standard:
        return 'a balanced mix of behavioral and role-specific questions';
      case InterviewType.deepDive:
        return 'in-depth exploration with follow-up questions';
      case InterviewType.technical:
        return 'technical knowledge, problem-solving, and system design';
      case InterviewType.finalRound:
        return 'leadership, strategic thinking, and cultural fit';
    }
  }

  /// Prompt for generating interview questions
  static String getQuestionGenerationPrompt({
    required QuestionCategory category,
    required int count,
    required String targetRole,
  }) {
    return '''Generate exactly $count ${category.displayName} interview questions for a ${targetRole} position.

CATEGORY SPECIFICS:
${_getCategoryGuidelines(category)}

REQUIREMENTS:
- Each question should be on a new line
- Questions should be progressively challenging
- Include a mix of common and unique questions
- Questions should end with a question mark
- Do not number the questions

Generate $count questions now:''';
  }

  static String _getCategoryGuidelines(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.behavioral:
        return '''- Use STAR method prompts (Situation, Task, Action, Result)
- Focus on: Leadership, Teamwork, Conflict Resolution, Problem-solving
- Ask about specific past experiences and what was learned
- Include questions about failures and how they were handled
- Examples: "Tell me about a time when...", "Describe a situation where..."''';

      case QuestionCategory.technical:
        return '''- Focus on role-specific technical knowledge
- Include coding concepts, system design, and problem-solving
- Ask about tools, frameworks, and best practices
- Include questions about debugging and optimization
- Balance theoretical knowledge with practical application''';

      case QuestionCategory.situational:
        return '''- Present hypothetical scenarios to assess judgment
- Focus on conflict resolution and priority handling
- Ask "What would you do if..." style questions
- Include ethical dilemmas relevant to the role
- Assess decision-making process and reasoning''';

      case QuestionCategory.caseStudy:
        return '''- Present business problems requiring analysis
- Focus on structured thinking and analytical skills
- Include market analysis and strategic thinking
- Ask about data-driven decision making
- Assess ability to break down complex problems''';

      case QuestionCategory.cultureFit:
        return '''- Assess values alignment and team dynamics
- Ask about work style preferences
- Include questions about motivation and career goals
- Assess self-awareness and authenticity
- Focus on collaboration and communication style''';
    }
  }

  /// System prompt for follow-up questions
  static const String followUpSystemPrompt = '''You are an expert interviewer conducting a follow-up during an interview session.

Your task is to generate a natural, probing follow-up question based on the candidate's previous answer.

GUIDELINES:
- The follow-up should dig deeper into the answer provided
- Ask for specific examples if the answer was vague
- Clarify any technical points that need more explanation
- Challenge assumptions respectfully
- Keep the conversation flowing naturally

Generate ONE clear, direct follow-up question.''';

  /// Prompt for generating follow-up questions
  static String getFollowUpPrompt({
    required String previousQuestion,
    required String previousAnswer,
    required QuestionCategory category,
    required String targetRole,
  }) {
    return '''Previous Question: $previousQuestion

Candidate's Answer: $previousAnswer

Based on this ${category.displayName} answer for a ${targetRole} position, generate a natural follow-up question that:
- Probes deeper into the response
- Seeks more specific details or examples
- Clarifies any vague points
- Tests the depth of their knowledge/experience

Generate one follow-up question:''';
  }

  /// System prompt for answer evaluation
  static const String evaluatorSystemPrompt = '''You are an expert interview coach evaluating candidate responses.

EVALUATION CRITERIA (Rate 1-10 for each):

1. CONTENT QUALITY (40% weight):
   - Relevance to the question
   - Accuracy of information
   - Depth and completeness
   - Use of specific examples
   - Demonstration of expertise

2. STRUCTURE (25% weight):
   - Logical organization
   - Use of frameworks (STAR, etc.)
   - Clear beginning, middle, end
   - Appropriate length

3. COMMUNICATION (20% weight):
   - Clarity of expression
   - Professional language
   - Conciseness
   - Appropriate detail level

4. CONFIDENCE INDICATORS (15% weight):
   - Assertive language
   - Absence of excessive hedging
   - Direct responses
   - Ownership of answers

RESPONSE FORMAT:
Respond in valid JSON format with these fields:
{
  "contentScore": <number 1-10>,
  "structureScore": <number 1-10>,
  "communicationScore": <number 1-10>,
  "confidenceScore": <number 1-10>,
  "feedback": "<2-3 sentence overall feedback>",
  "strengths": ["<strength 1>", "<strength 2>"],
  "improvements": ["<improvement 1>", "<improvement 2>"]
}

Be constructive but honest in your evaluation.''';

  /// Prompt for evaluating answers
  static String getEvaluationPrompt({
    required String question,
    required String answer,
    required QuestionCategory category,
    required String targetRole,
  }) {
    return '''INTERVIEW CONTEXT:
- Role: $targetRole
- Question Category: ${category.displayName}

QUESTION ASKED:
$question

CANDIDATE'S RESPONSE:
$answer

Evaluate this response according to the criteria and provide your assessment in the specified JSON format.''';
  }

  /// System prompt for generating model answers
  static const String modelAnswerSystemPrompt = '''You are an expert interview coach creating exemplary answers to help candidates learn.

Your model answers should:
1. Be structured using appropriate frameworks (STAR for behavioral, etc.)
2. Include specific, realistic examples
3. Demonstrate depth of knowledge and experience
4. Be the ideal length (not too short, not rambling)
5. Show confidence without arrogance
6. Be adaptable to different experience levels

Create answers that candidates can learn from and adapt to their own experiences.''';

  /// Prompt for generating model answers
  static String getModelAnswerPrompt({
    required String question,
    required QuestionCategory category,
    required String targetRole,
    ParsedResume? resume,
  }) {
    final experienceContext = resume != null
        ? 'The candidate has ${resume.yearsOfExperience} years of experience with skills in ${resume.skills.take(5).join(", ")}.'
        : 'Create a general model answer suitable for this role.';

    return '''Create a model answer for the following ${category.displayName} interview question for a ${targetRole} position.

$experienceContext

QUESTION:
$question

Create an exemplary answer that:
- Uses the ${_getFrameworkForCategory(category)} framework
- Is specific and demonstrates real expertise
- Is appropriately detailed (2-3 minutes when spoken)
- Could be adapted by the candidate to their own experience

MODEL ANSWER:''';
  }

  static String _getFrameworkForCategory(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.behavioral:
        return 'STAR (Situation, Task, Action, Result)';
      case QuestionCategory.technical:
        return 'structured problem-solving';
      case QuestionCategory.situational:
        return 'scenario analysis';
      case QuestionCategory.caseStudy:
        return 'framework-based analysis (e.g., MECE)';
      case QuestionCategory.cultureFit:
        return 'authentic self-reflection';
    }
  }

  /// System prompt for resume parsing
  static const String resumeParserSystemPrompt = '''You are an expert resume parser and career coach.

Your task is to extract structured information from resumes accurately.

EXTRACTION GUIDELINES:
1. Extract all relevant information even if formatting is inconsistent
2. Standardize date formats (use ISO format: YYYY-MM-DD)
3. Infer missing information when clearly implied
4. Identify key skills from job descriptions
5. Separate technical skills from soft skills
6. Recognize common job title variations

OUTPUT:
Return a valid JSON object with all extracted information.
Use null for missing fields, empty arrays for missing lists.
Be thorough but accurate - don't fabricate information.''';

  /// System prompt for conversational interview
  static String getConversationalInterviewPrompt({
    required String targetRole,
    required InterviewType interviewType,
    ParsedResume? resume,
    List<Map<String, String>>? conversationHistory,
  }) {
    final resumeContext = resume != null
        ? '''
CANDIDATE PROFILE:
- Name: ${resume.fullName ?? 'Candidate'}
- Experience: ${resume.yearsOfExperience} years
- Key Skills: ${resume.skills.take(8).join(', ')}
- Current/Last Role: ${resume.workExperience.isNotEmpty ? resume.workExperience.first.role : 'Not specified'}
'''
        : '';

    final historyContext = conversationHistory != null && conversationHistory.isNotEmpty
        ? 'Continue the interview naturally based on the conversation so far.'
        : 'Start the interview with a warm greeting and your first question.';

    return '''You are conducting a ${interviewType.displayName} for a ${targetRole} position.

$resumeContext

INTERVIEW STYLE:
- Be professional but personable
- Ask one question at a time
- Listen actively and acknowledge responses
- Provide brief encouragement when appropriate
- Transition naturally between topics

$historyContext

IMPORTANT:
- Generate only ONE response at a time
- If asking a question, wait for the answer
- After receiving an answer, either ask a follow-up or move to a new topic
- Keep the conversation flowing naturally''';
  }

  /// Prompt for interview summary
  static String getInterviewSummaryPrompt({
    required String targetRole,
    required List<Map<String, dynamic>> questionsAndAnswers,
  }) {
    final qaText = questionsAndAnswers.map((qa) {
      return '''Q: ${qa['question']}
A: ${qa['answer']}
Score: ${qa['score']}/10''';
    }).join('\n\n');

    return '''Provide a comprehensive summary of this ${targetRole} interview:

$qaText

Include:
1. Overall performance assessment
2. Key strengths demonstrated
3. Areas for improvement
4. Specific recommendations for practice
5. Readiness level for actual interviews (1-10)

Be constructive and actionable in your feedback.''';
  }

  /// Tips based on performance
  static String getImprovementTipsPrompt({
    required QuestionCategory weakCategory,
    required double score,
    required String targetRole,
  }) {
    return '''The candidate scored ${score.toStringAsFixed(1)}/10 in ${weakCategory.displayName} questions for a ${targetRole} position.

Provide 5 specific, actionable tips to improve their performance in this category.

Include:
- Specific techniques or frameworks to use
- Practice exercises they can do
- Common mistakes to avoid
- Resources for learning more
- Example phrases or structures to use

Be practical and encouraging.''';
  }
}
