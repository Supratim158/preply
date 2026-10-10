import 'dart:ui';
import 'package:flutter/material.dart';

class DashboardStatsCards extends StatelessWidget {
  const DashboardStatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.12,
      children: const [
        _StatCard(
          title: 'Resume Score',
          value: '84',
          suffix: '/100',
          subtitle: 'Top 15% ATS Match',
          icon: Icons.description_outlined,
          subtitleIcon: Icons.trending_up_rounded,
          color: Color(0xFF34D399),
          progress: 0.84,
        ),
        _StatCard(
          title: 'Interview Score',
          value: '78%',
          suffix: 'avg',
          subtitle: '6 Interview Done',
          icon: Icons.workspace_premium_outlined,
          subtitleIcon: Icons.verified_outlined,
          color: Color(0xFF6095FF),
          progress: 0.78,
        ),
        _StatCard(
          title: 'Applications Tracked',
          value: '12',
          suffix: 'roles',
          subtitle: '3 Under Review',
          icon: Icons.work_outline_rounded,
          subtitleIcon: Icons.access_time_rounded,
          color: Color(0xFFFFB547),
          progress: 0.60,
        ),
        _StatCard(
          title: 'Interviews Scheduled',
          value: '4',
          suffix: 'upcoming',
          subtitle: 'Next in 2 days',
          icon: Icons.calendar_month_outlined,
          subtitleIcon: Icons.notifications_active_outlined,
          color: Color(0xFF34D399),
          progress: 0.40,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final String subtitle;
  final IconData icon;
  final IconData subtitleIcon;
  final Color color;
  final double progress;

  const _StatCard({
    required this.title,
    required this.value,
    required this.suffix,
    required this.subtitle,
    required this.icon,
    required this.subtitleIcon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card title and icon
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFADB5C8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    icon,
                    color: color,
                    size: 19,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Main value
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFFDCE5F7),
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      suffix,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF929DB1),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Progress indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF303849),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),

              const Spacer(),

              // Bottom information
              Row(
                children: [
                  Icon(
                    subtitleIcon,
                    color: color,
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}