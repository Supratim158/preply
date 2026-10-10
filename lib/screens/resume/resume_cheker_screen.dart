import 'package:flutter/material.dart';
import 'package:preply/screens/resume/components/recent_resume_score.dart';
import 'components/rate_resume_card.dart';

class ResumeChekerScreen extends StatefulWidget {
  const ResumeChekerScreen({super.key});

  @override
  State<ResumeChekerScreen> createState() => _ResumeChekerScreenState();
}

class _ResumeChekerScreenState extends State<ResumeChekerScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
            left: 17.0,
            right: 17.0,
            bottom: 100.0,
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              const RateResumeCard(),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Score',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Updated 2hrs ago',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const RecentResumeScore(),
            ],
          ),
        ))
      ],
    );
  }
}
