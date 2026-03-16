import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:job_finder/core/helper/typedef.dart';

// Gemini Pro 1.5

class GeminiService {
  final String _apiKey;

  // Dedicated models for different tasks
  late final GenerativeModel _jobPostModel;
  late final GenerativeModel _resumeAnalysisModel;
  late final GenerativeModel _jobMatchModel;
  late final GenerativeModel _interviewCoachModel;

  GeminiService(this._apiKey) {
    final config = GenerationConfig(responseMimeType: 'application/json');
    final safety = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
    ];

    // 1. Fast model for generating job posts
    _jobPostModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: config,
    );

    // 2. High-intelligence model for deep resume analysis
    _resumeAnalysisModel = GenerativeModel(
      model: 'gemini-2.5-pro',
      apiKey: _apiKey,
      generationConfig: config,
      safetySettings: safety,
    );

    // 3. Latest performance model for job matching
    _jobMatchModel = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
      generationConfig: config,
      safetySettings: safety,
    );

    // 4. Interview Coach Model (Flash for speed and higher quota)
    _interviewCoachModel = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
      generationConfig: config,
      safetySettings: safety,
    );
  }

  // Generates a structured job post content based on initial input.
  Future<DataMap?> generateContent({
    required String title,
    String? category,
    String? experienceLevel,
  }) async {
    try {
      final prompt =
          '''
      You are an expert HR recruiter. Generate a professional job post for the following:
      Job Title: $title
      Category: ${category ?? 'General'}
      Experience Level: ${experienceLevel ?? 'Any'}

      Please provide the response in a VALID JSON format with the following keys:
      - description: A compelling summary of the role (at least 60 words).
      - responsibilities: A list of 5 key responsibilities.
      - requirements: A list of 5 key requirements/qualifications.
      - skills: A comma-separated string of important technical and soft skills.

      Return ONLY the JSON object.
      ''';

      final content = [Content.text(prompt)];
      final response = await _jobPostModel.generateContent(content);

      final text = response.text;
      if (text == null) return null;

      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start != -1 && end != -1) {
        final jsonString = text.substring(start, end + 1);
        return jsonDecode(jsonString) as DataMap;
      }

      return null;
    } catch (e) {
      debugPrint('Gemini Job Post Error: $e');
      return null;
    }
  }

  // Analyzes a resume PDF and returns structured feedback.
  Future<DataMap?> analyzeResume({
    required Uint8List pdfBytes,
    String? targetJobTitle,
  }) async {
    try {
      final prompt =
          '''
      You are a Senior Technical Recruiter. 
      Analyze the attached Resume PDF. 
      ${targetJobTitle != null ? 'The candidate is targetting a "$targetJobTitle" role.' : ''}
      
      Compare their profile against current industry standards and provide:
      1. healthScore: An overall rating from 0 to 100.
      2. missingSkills: A list of 5 critical technical skills.
      3. strengthPoints: A list of 3 things they are currently doing well.
      4. improvementSuggestion: One specific advice.
      5. impactStatement: A motivational sentence.

      Return ONLY a VALID JSON format.
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('application/pdf', pdfBytes),
        ]),
      ];

      final response = await _resumeAnalysisModel.generateContent(content);
      final text = response.text;
      if (text == null) return null;

      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start != -1 && end != -1) {
        final jsonString = text.substring(start, end + 1);
        return jsonDecode(jsonString) as DataMap;
      }

      return null;
    } catch (e) {
      debugPrint('Gemini Resume Analysis Error: $e');
      return null;
    }
  }

  // Matches a job description with a candidate's resume.
  Future<DataMap> analyzeMatch({
    required String jobDescription,
    required Uint8List pdfBytes,
  }) async {
    try {
      final prompt =
          '''
      You are an AI Job Matching Assistant. 
      Analyze the provided Resume PDF and compare it with the Job Description below.
      
      JOB DESCRIPTION:
      $jobDescription
      
      Rules:
      1. Provide a matchScore (0-100).
      2. Provide a relevanceSummary (2 short sentences).
      3. Provide topGaps (List of 3 missing skills).
      4. Provide advice (1 actionable tip for this specific job).
      5. Return ONLY a valid JSON object.
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('application/pdf', pdfBytes),
        ]),
      ];

      final response = await _jobMatchModel.generateContent(content);
      final text = response.text;

      if (text == null || text.isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start != -1 && end != -1) {
        final jsonString = text.substring(start, end + 1);
        return jsonDecode(jsonString) as DataMap;
      }

      throw Exception(
        'Could not find a valid JSON object in Gemini response: $text',
      );
    } catch (e) {
      debugPrint('Gemini Match Analysis Error: $e');
      rethrow;
    }
  }

  // Generates interview questions based on job description and resume.
  Future<List<DataMap>> generateInterviewQuestions({
    required String jobTitle,
    required String jobDescription,
    Uint8List? pdfBytes,
  }) async {
    try {
      final prompt =
          '''
      You are 'Sam', a friendly but professional male Technical Interviewer. 
      Your priority is to look at the **JOB TITLE** first, then the Job Description.
      
      JOB TITLE: $jobTitle
      
      Seniority Target: Focus on **Junior to Mid-level** questions unless the job title explicitly states 'Senior' or 'Lead'. If the title is ambiguous, default to Mid-level technical difficulty.
      
      Generate 5 relevant interview questions.
      ${pdfBytes != null ? "Also consider the candidate's Resume PDF for more personalized questions." : "Focus on role requirements as no resume is provided."}
      
      Your personality:
      - Friendly but professional.
      - Pacing: Professional and clear.
      - Rule: Ask one question at a time.
      
      JOB DESCRIPTION:
      $jobDescription

      Please provide the questions in a VALID JSON ARRAY with each object containing:
      - question: The interview question text.
      - category: One of [Technical, Behavioral, Motivational].
      - hint: A small tip for the candidate on how to answer.

      Return ONLY the JSON array.
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          if (pdfBytes != null) DataPart('application/pdf', pdfBytes),
        ]),
      ];

      final response = await _interviewCoachModel.generateContent(content);
      final text = response.text;
      if (text == null) return [];

      final start = text.indexOf('[');
      final end = text.lastIndexOf(']');
      if (start != -1 && end != -1) {
        final jsonString = text.substring(start, end + 1);
        final List<dynamic> list = jsonDecode(jsonString);
        return list.map((e) => e as DataMap).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Gemini Interview Question Error: $e');
      return [];
    }
  }

  // Evaluates an interview response.
  Future<DataMap?> evaluateInterviewResponse({
    required String question,
    required String response,
    required String jobDescription,
  }) async {
    try {
      final prompt =
          '''
      You are 'Sam', the Interview Evaluator. 
      Evaluate the following candidate response to an interview question for a specific job.
      Be constructive, friendly, and professional in your feedback summary.

      JOB DESCRIPTION:
      $jobDescription

      QUESTION:
      $question

      CANDIDATE RESPONSE:
      $response

      Please provide feedback in a VALID JSON format with the following keys:
      - score: A score from 0 to 10.
      - strengths: What they mentioned well (1 sentence).
      - improvements: What they could add or improve (1 sentence).
      - modelAnswer: A short example of a perfect response (2 sentences).

      Return ONLY the JSON object.
      ''';

      final content = [Content.text(prompt)];
      final res = await _interviewCoachModel.generateContent(content);
      final text = res.text;
      if (text == null) return null;

      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start != -1 && end != -1) {
        final jsonString = text.substring(start, end + 1);
        return jsonDecode(jsonString) as DataMap;
      }

      return null;
    } catch (e) {
      debugPrint('Gemini Response Evaluation Error: $e');
      return null;
    }
  }
}
