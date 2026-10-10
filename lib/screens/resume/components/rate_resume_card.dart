import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:preply/widgets/animated_button.dart';
import 'ats_setup.dart';

class RateResumeCard extends StatelessWidget {
  final VoidCallback? onTap;

  const RateResumeCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7EA7FF);
    const muted = Color(0xFF929DB1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rate My Resume',
                          style: TextStyle(
                            color: Color(0xFFDCE5F7),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Optimize your resume for any job role',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Dummy resume container
              const _InfoContainer(
                icon: Icons.description_outlined,
                title: 'Resume Analysis',
                subtitle: 'Check your resume against a job description',
                color: accent,
              ),

              const SizedBox(height: 12),

              // Dummy job role container
              const _InfoContainer(
                icon: Icons.work_outline_rounded,
                title: 'Job Role Matching',
                subtitle: 'Find skill gaps and missing keywords',
                color: Color(0xFF34D399),
              ),

              const SizedBox(height: 20),

              // Navigation button
              AnimatedButton(
                text: "Rate My Resume",
                onPressed: () async {
                  if (onTap != null) {
                    onTap!();
                  } else {
                    await showAtsResumeSheet(context: context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoContainer({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.09),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFDCE5F7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF929DB1),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_outline_rounded,
            color: color.withOpacity(0.8),
            size: 19,
          ),
        ],
      ),
    );
  }
}