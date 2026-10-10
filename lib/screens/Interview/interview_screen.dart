import 'package:flutter/material.dart';

import 'components/interview_intro_card.dart';
import 'components/recent_interview_card.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
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
          const InterviewIntroCard(),

          const SizedBox(height: 22),

          const Text(
            'Your Recent Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          RecentInterviewCard(
            score: '85/100',
            role: 'Software Engineer',
            interviewDate: 'Oct 09, 2026',
            duration: '25 minutes',
            performance:
            'Good technical knowledge and clear communication. '
                'Work on structuring behavioral answers.',
            onSeeDetails: () {
              // Navigate to your interview report screen.
            },
          ),
        ],
      ),
          )
          )
        ],
      )
    );
  }
}
