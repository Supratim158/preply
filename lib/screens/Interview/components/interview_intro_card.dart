
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:preply/widgets/animated_button.dart';

import 'interview_setup_sheet.dart';

class InterviewIntroCard extends StatelessWidget {

  const InterviewIntroCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF536DFE).withOpacity(0.22),
                const Color(0xFF8E5BFF).withOpacity(0.12),
                Colors.white.withOpacity(0.04),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and label
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6485FF)
                          .withOpacity(0.18),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.psychology_alt_rounded,
                      color: Color(0xFF9BB5FF),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI INTERVIEW COACH',
                          style: TextStyle(
                            color: Color(0xFF9BB5FF),
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Practice makes progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Ready for your next interview?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Practice with AI-powered mock interviews, '
                    'answer role-specific questions, and get '
                    'feedback to improve your performance.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.70),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 18),

              // Feature highlights
              const _FeatureRow(
                icon: Icons.check_circle_outline_rounded,
                text: 'Technical, HR and behavioral questions',
              ),
              const SizedBox(height: 10),
              const _FeatureRow(
                icon: Icons.analytics_outlined,
                text: 'AI feedback and answer evaluation',
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: AnimatedButton(
                  text: 'Start Mock Interview',
                  icon: Icons.mic_rounded,
                  onPressed: () async {
                    final result = await showInterviewSetupSheet(
                      context: context,
                      resumes: const [
                        InterviewResumeOption(
                          id: 'resume_1',
                          title: 'Software Developer Resume.pdf',
                          subtitle: 'Updated October 2026',
                        ),
                        InterviewResumeOption(
                          id: 'resume_2',
                          title: 'General Resume.pdf',
                          subtitle: 'General purpose resume',
                        ),
                      ],
                    );

                    if (result == null || !context.mounted) return;

                    final selectedRole = result.role;
                    final selectedResumeId = result.resume?.id;

                    debugPrint(
                      'Starting mock interview for role: $selectedRole with resume: $selectedResumeId',
                    );
                    // Send selectedRole and selectedResumeId to your
                    // interview setup API or next screen.
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF91ADFF),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
