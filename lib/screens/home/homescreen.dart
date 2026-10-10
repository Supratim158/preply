import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:preply/screens/home/components/action_glass_card.dart';
import 'package:preply/screens/home/components/ai_career_insight.dart';

import 'components/upcoming_reminders_card.dart';
import 'components/your_progress_card.dart';

class Homescreen extends StatelessWidget {
  final ValueChanged<int> onNavigateTab;

  const Homescreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 10,
              left: 17,
              right: 17,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome heading
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Hello, Supratim',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 4),

                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Lottie.asset(
                        'assets/animations/waving hand.json',
                        repeat: true,
                        animate: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Subtitle
                const Text(
                  "Let's prepare you for your next opportunity.",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                // AI Career Insight
                const AICareerInsight(),

                const SizedBox(height: 15),

                // Progress cards
                YourProgressCard(
                  resumeScore: '--',
                  onResumeTap: () {
                    onNavigateTab(1);
                  },
                  interviewScore: '--',
                  onInterviewTap: () {
                    onNavigateTab(2);
                  },
                  skillsProgress: '--',
                  onSkillsTap: () {
                    onNavigateTab(1);
                  },
                  interviewsPracticed: 0,
                  onPracticedTap: () {
                    onNavigateTab(2);
                  },
                ),

                const SizedBox(height: 20),

                // Recent Score heading

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 17,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          "Upcoming Reminders",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        onNavigateTab(3);
                      },
                      child: const Text(
                        "View All Reminders",
                        style:
                            TextStyle(fontSize: 14, color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Upcoming reminder 1
                UpcomingReminders(
                  title: 'Check Application',
                  description: 'Google · Software Engineering Intern',
                  reminderTime: 'Today, 6:00 PM',
                  icon: Icons.event_note_rounded,
                  onTap: () {
                    onNavigateTab(3);
                  },
                ),

                const SizedBox(height: 12),

                // Upcoming reminder 2
                UpcomingReminders(
                  title: 'Check Application',
                  description: 'Google · Software Engineering Intern',
                  reminderTime: 'Today, 6:00 PM',
                  icon: Icons.event_note_rounded,
                  onTap: () {
                    onNavigateTab(3);
                  },
                ),

                const SizedBox(height: 15),

                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 15),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.30,
                  padding: EdgeInsets.zero,
                  children: [
                    ActionGlassCard(
                      icon: Icons.description_outlined,
                      title: 'Resume Checker',
                      onTap: () {
                        onNavigateTab(1);
                      },
                    ),
                    ActionGlassCard(
                      icon: Icons.voice_chat_outlined,
                      title: 'Mock Interview',
                      onTap: () {
                        onNavigateTab(2);
                      },
                    ),
                    ActionGlassCard(
                      icon: Icons.event_available_rounded,
                      title: 'Reminders',
                      onTap: () {
                        onNavigateTab(3);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
