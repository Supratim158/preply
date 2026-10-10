import 'dart:ui';
import 'package:flutter/material.dart';

class YourProgressCard extends StatelessWidget {
  final String resumeScore;
  final String interviewScore;
  final String skillsProgress;
  final int interviewsPracticed;

  final VoidCallback? onResumeTap;
  final VoidCallback? onInterviewTap;
  final VoidCallback? onSkillsTap;
  final VoidCallback? onPracticedTap;

  const YourProgressCard({
    super.key,
    this.resumeScore = '--',
    this.interviewScore = '--',
    this.skillsProgress = '--',
    this.interviewsPracticed = 0,
    this.onResumeTap,
    this.onInterviewTap,
    this.onSkillsTap,
    this.onPracticedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          padding: EdgeInsets.zero,

          // Taller cards prevent vertical overflow.
          childAspectRatio: 1.25,

          children: [
            _ProgressItem(
              icon: Icons.description_outlined,
              color: const Color(0xFF8265FF),
              title: 'Resume Score',
              value: '$resumeScore / 100',
              subtitle: 'Analyze your resume',
              onTap: onResumeTap,
            ),
            _ProgressItem(
              icon: Icons.mic_none_rounded,
              color: const Color(0xFFAD69FF),
              title: 'Interview Score',
              value: '$interviewScore / 100',
              subtitle: 'Practice a mock interview',
              onTap: onInterviewTap,
            ),
            _ProgressItem(
              icon: Icons.track_changes_rounded,
              color: const Color(0xFF00CFC1),
              title: 'Skills Progress',
              value: '$skillsProgress%',
              subtitle: 'Review skill gaps',
              onTap: onSkillsTap,
            ),
            _ProgressItem(
              icon: Icons.calendar_month_outlined,
              color: const Color(0xFFFFAA32),
              title: 'Interviews Practiced',
              value: '$interviewsPracticed',
              subtitle: 'Start practicing',
              onTap: onPracticedTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback? onTap;

  const _ProgressItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.035),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Icon
                  Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),

                  const SizedBox(height: 7),

                  // Title
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFB8B8C5),
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Score
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Subtitle
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFAAAAAF),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}