import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    this.child,
    this.baseColors = const [
      Color(0xFF000104),
      Color(0xFF03060C),
      Color(0xFF060B16),
    ],
    this.blobColors = const [
      Color(0xFF0A4F4F),
      Color(0xFF2E1B52),
      Color(0xFF551D3C),
      Color(0xFF14325C),
    ],
    this.lineColors = const [
      Color(0xFF8FEAFF),
      Color(0xFFC9AEFF),
      Color(0xFFFFB8D6),
      Color(0xFFFFD98A),
      Color(0xFF9DFFC4),
    ],
    this.blobCount = 5,
    this.blobOpacity = 0.3,
    this.blur = 70,
    this.speed = 1,
    this.lineOpacity = 0.10,
    this.touchLines = true,
  });

  final Widget? child;
  final List<Color> baseColors;
  final List<Color> blobColors;
  final List<Color> lineColors;
  final int blobCount;
  final double blobOpacity;
  final double blur;
  final int speed;
  final double lineOpacity;
  final bool touchLines;

  @override
  State<AnimatedBackground> createState() =>
      _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Stopwatch _clock = Stopwatch()..start();
  final math.Random _rnd = math.Random();

  late List<_Blob> _blobs;

  final List<_Line> _lines = [];
  final Map<int, Offset> _lastSpawn = {};

  int _colorIndex = 0;

  static const int _maxLines = 60;
  static const int _lifeMs = 1300;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )
      ..addListener(_prune)
      ..repeat();

    _generate();
  }

  @override
  void didUpdateWidget(covariant AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.blobCount != widget.blobCount ||
        oldWidget.blobColors != widget.blobColors) {
      _generate();
    }
  }

  void _generate() {
    final rnd = math.Random(7);

    _blobs = List.generate(widget.blobCount, (i) {
      return _Blob(
        color: widget.blobColors[i % widget.blobColors.length],
        centerX: 0.15 + rnd.nextDouble() * 0.7,
        centerY: 0.15 + rnd.nextDouble() * 0.7,
        radiusX: 0.10 + rnd.nextDouble() * 0.20,
        radiusY: 0.10 + rnd.nextDouble() * 0.20,
        size: 0.25 + rnd.nextDouble() * 0.25,
        phase: rnd.nextDouble() * math.pi * 2,
        cycles: 1 + rnd.nextInt(3),
      );
    });
  }

  void _prune() {
    final now = _clock.elapsedMilliseconds;
    _lines.removeWhere((line) => now - line.birthMs > _lifeMs);
  }

  Color _nextColor() {
    final color =
    widget.lineColors[_colorIndex % widget.lineColors.length];
    _colorIndex++;
    return color;
  }

  void _addLine(
      Offset origin,
      Offset direction, {
        double extraSpeed = 0,
      }) {
    if (_lines.length >= _maxLines) {
      _lines.removeAt(0);
    }

    _lines.add(
      _Line(
        origin: origin,
        dir: direction,
        speed: 160 + extraSpeed + _rnd.nextDouble() * 90,
        length: 65 + _rnd.nextDouble() * 45,
        width: 1.0,
        birthMs: _clock.elapsedMilliseconds,
        color: _nextColor(),
      ),
    );
  }

  bool get _reduceMotion =>
      MediaQuery.of(context).disableAnimations;

  // One line when the user taps.
  void _onDown(PointerDownEvent event) {
    if (!widget.touchLines || _reduceMotion) return;

    _lastSpawn[event.pointer] = event.localPosition;

    final angle = _rnd.nextDouble() * math.pi * 2;

    _addLine(
      event.localPosition,
      Offset(math.cos(angle), math.sin(angle)),
    );
  }

  // One line along the direction of finger movement.
  void _onMove(PointerMoveEvent event) {
    if (!widget.touchLines || _reduceMotion) return;

    final last = _lastSpawn[event.pointer] ?? event.localPosition;
    final delta = event.localPosition - last;
    final distance = delta.distance;

    if (distance < 14) return;

    final direction = delta / distance;

    _addLine(
      event.localPosition,
      direction,
      extraSpeed: distance * 6,
    );

    _lastSpawn[event.pointer] = event.localPosition;
  }

  void _onUp(PointerEvent event) {
    _lastSpawn.remove(event.pointer);
  }

  @override
  void dispose() {
    _controller.dispose();
    _clock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion && _controller.isAnimating) {
      _controller.stop();
    } else if (!reduceMotion && !_controller.isAnimating) {
      _controller.repeat();
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      onPointerCancel: _onUp,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _BackgroundPainter(
                    t: _controller.value,
                    speed: widget.speed.clamp(1, 8),
                    baseColors: widget.baseColors,
                    blobs: _blobs,
                    blobOpacity: widget.blobOpacity,
                    blur: widget.blur,
                    lines: _lines,
                    lineOpacity: widget.lineOpacity,
                    nowMs: _clock.elapsedMilliseconds,
                    lifeMs: _lifeMs,
                  ),
                );
              },
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _Blob {
  _Blob({
    required this.color,
    required this.centerX,
    required this.centerY,
    required this.radiusX,
    required this.radiusY,
    required this.size,
    required this.phase,
    required this.cycles,
  });

  final Color color;
  final double centerX;
  final double centerY;
  final double radiusX;
  final double radiusY;
  final double size;
  final double phase;
  final int cycles;
}

class _Line {
  _Line({
    required this.origin,
    required this.dir,
    required this.speed,
    required this.length,
    required this.width,
    required this.birthMs,
    required this.color,
  });

  final Offset origin;
  final Offset dir;
  final double speed;
  final double length;
  final double width;
  final int birthMs;
  final Color color;
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter({
    required this.t,
    required this.speed,
    required this.baseColors,
    required this.blobs,
    required this.blobOpacity,
    required this.blur,
    required this.lines,
    required this.lineOpacity,
    required this.nowMs,
    required this.lifeMs,
  });

  final double t;
  final int speed;
  final List<Color> baseColors;
  final List<_Blob> blobs;
  final double blobOpacity;
  final double blur;
  final List<_Line> lines;
  final double lineOpacity;
  final int nowMs;
  final int lifeMs;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Dark gradient background.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: baseColors,
        ).createShader(rect),
    );

    final angle = t * math.pi * 2 * speed;
    final shortest = size.shortestSide;

    // 2. Slowly drifting colored blobs.
    for (final blob in blobs) {
      final a = angle * blob.cycles + blob.phase;

      final dx =
          (blob.centerX + math.cos(a) * blob.radiusX) * size.width;

      final dy =
          (blob.centerY + math.sin(a * 0.8) * blob.radiusY) *
              size.height;

      canvas.drawCircle(
        Offset(dx, dy),
        blob.size * shortest * 1.4,
        Paint()
          ..color = blob.color.withOpacity(blobOpacity)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            blur,
          ),
      );
    }

    // 3. Single subtle touch line with a soft glow.
    for (final line in lines) {
      final ageMs = nowMs - line.birthMs;

      if (ageMs < 0 || ageMs > lifeMs) continue;

      final life = ageMs / lifeMs;
      final head =
          line.origin + line.dir * (line.speed * ageMs / 1000.0);
      final tail = head - line.dir * line.length;

      // Smooth fade as the line disappears.
      final fade = (1 - life) * (1 - life);
      final peak = (lineOpacity * fade).clamp(0.0, 1.0);

      final lineRect = Rect.fromPoints(tail, head);

      // Soft outer glow.
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..color = line.color.withOpacity(peak * 0.35)
          ..strokeWidth = line.width * 5
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            6,
          ),
      );

      // Single thin line.
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..strokeWidth = line.width
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..blendMode = BlendMode.plus
          ..shader = LinearGradient(
            colors: [
              line.color.withOpacity(0),
              line.color.withOpacity(peak),
            ],
          ).createShader(lineRect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}