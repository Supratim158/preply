import 'dart:ui';
import 'package:flutter/material.dart';

class RecentResumeScore extends StatelessWidget {
  final int score;
  final List<ResumeDimension> dimensions;

  const RecentResumeScore({
    super.key,
    this.score = 84,
    this.dimensions = const [
      ResumeDimension(
        title: 'ATS Compatibility',
        score: 89,
        color: Color(0xFF34D399),
      ),
      ResumeDimension(
        title: 'Content Quality',
        score: 82,
        color: Color(0xFF3B82F6),
      ),
      ResumeDimension(
        title: 'Technical Skills',
        score: 91,
        color: Color(0xFF34D399),
      ),
      ResumeDimension(
        title: 'Experience Depth',
        score: 78,
        color: Color(0xFFFFB547),
      ),
      ResumeDimension(
        title: 'Projects Impact',
        score: 86,
        color: Color(0xFF34D399),
      ),
      ResumeDimension(
        title: 'Formatting & Layout',
        score: 83,
        color: Color(0xFF3B82F6),
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF10C995);
    const muted = Color(0xFF9BA8BD);

    final isStrong = score >= 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main score panel
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 18,
              sigmaY: 18,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF172033).withOpacity(0.85),
                    const Color(0xFF102C30).withOpacity(0.75),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: Column(
                children: [
                  // ATS optimized badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF172B4B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF31508B)
                            .withOpacity(0.65),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF8CB7FF),
                          size: 12,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'ATS OPTIMIZED',
                          style: TextStyle(
                            color: Color(0xFF9CC2FF),
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Circular score
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 94,
                          height: 94,
                          child: CircularProgressIndicator(
                            value: score.clamp(0, 100) / 100,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            backgroundColor:
                            const Color(0xFF293749),
                            valueColor:
                            const AlwaysStoppedAnimation<Color>(
                              green,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$score',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '/ 100',
                              style: TextStyle(
                                color: muted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Score status
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 7,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: green.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: green.withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          isStrong ? 'Good Resume' : 'Needs Improvement',
                          style: const TextStyle(
                            color: green,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Text(
                        'Top 16% in SWE Roles',
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Passes standard enterprise parsing models with '
                        'high keyword density for Full Stack & Mobile tiers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFBAC5D7),
                      fontSize: 10.5,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Breakdown heading
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Score Breakdown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${dimensions.length} Dimensions',
              style: const TextStyle(
                color: muted,
                fontSize: 10,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        // Six glassmorphic dimension cards
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dimensions.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 66,
          ),
          itemBuilder: (context, index) {
            return _DimensionCard(
              dimension: dimensions[index],
            );
          },
        ),
      ],
    );
  }
}

class ResumeDimension {
  final String title;
  final int score;
  final Color color;

  const ResumeDimension({
    required this.title,
    required this.score,
    required this.color,
  });
}

class _DimensionCard extends StatelessWidget {
  final ResumeDimension dimension;

  const _DimensionCard({
    required this.dimension,
  });

  @override
  Widget build(BuildContext context) {
    final score = dimension.score.clamp(0, 100);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dimension.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD6DFEF),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$score%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 4,
                  backgroundColor: const Color(0xFF293448),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    dimension.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}