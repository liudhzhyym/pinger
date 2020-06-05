import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pinger/model/ping_session.dart';
import 'package:pinger/resources.dart';
import 'package:pinger/utils/format_utils.dart';

class SessionPingGauge extends StatelessWidget {
  const SessionPingGauge({
    Key key,
    @required this.session,
    @required this.duration,
  }) : super(key: key);

  final PingSession session;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Positioned.fill(
        child: PingGaugeArc.forSession(session),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: _buildLabels(),
      ),
    ]);
  }

  Widget _buildLabels() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(height: 32.0),
        Text(
          _getDeltaLabel(session.values),
          style: TextStyle(fontSize: 24.0, color: R.colors.gray),
        ),
        Container(height: 8.0),
        Text(
          _getValueLabel(
              session.values.isNotEmpty ? session.values.last : null),
          style: TextStyle(fontSize: 36.0),
        ),
        Container(height: 16.0),
        Text(
          FormatUtils.getDurationLabel(duration),
          style: TextStyle(fontSize: 24.0, color: R.colors.secondary),
        ),
      ],
    );
  }

  String _getDeltaLabel(List<int> values) {
    if (values.length > 1 && values.last != null) {
      final previous = values.reversed
          .skip(1)
          .firstWhere((it) => it != null, orElse: () => null);
      if (previous != null) {
        final delta = (values.last - previous).round();
        return delta < 0 ? "$delta" : "+$delta";
      }
    }
    return "-";
  }

  String _getValueLabel(int value) => value != null ? "$value ms" : "-";
}

class PingGaugeArc extends StatefulWidget {
  final double value;
  final double progress;
  final bool isActive;
  final Duration duration;

  const PingGaugeArc({
    Key key,
    @required this.progress,
    @required this.value,
    @required this.isActive,
    @required this.duration,
  }) : super(key: key);

  factory PingGaugeArc.forSession(PingSession session) {
    final progress = !session.status.isQuickCheck
        ? session.values.length / session.settings.count
        : 0.0;
    final lastResult =
        session.values.lastWhere((it) => it != null, orElse: () => null);
    final value = lastResult != null
        ? session.stats.max == session.stats.min
            ? 0.5
            : (lastResult - session.stats.min) /
                (session.stats.max - session.stats.min)
        : null;
    return PingGaugeArc(
      progress: progress,
      value: value,
      isActive: session.status.isStarted,
      duration: Duration(milliseconds: 800),
    );
  }

  @override
  _PingGaugeArcState createState() => _PingGaugeArcState();
}

class _PingGaugeArcState extends State<PingGaugeArc>
    with SingleTickerProviderStateMixin {
  AnimationController _animator;
  Animation<double> _arcProgressAnim;
  Animation<double> _dotValueAnim;

  @override
  void initState() {
    super.initState();
    _animator = AnimationController(vsync: this, duration: widget.duration);
    _arcProgressAnim = AlwaysStoppedAnimation(widget.progress);
    _dotValueAnim = AlwaysStoppedAnimation(widget.value ?? 0.5);
  }

  @override
  void didUpdateWidget(PingGaugeArc old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress || old.value != widget.value) {
      _arcProgressAnim = Tween<double>(
        begin: _arcProgressAnim.value,
        end: widget.progress,
      ).chain(CurveTween(curve: Curves.easeInOut)).animate(_animator);
      _dotValueAnim = Tween<double>(
        begin: _dotValueAnim.value,
        end: widget.value ?? old.value ?? _dotValueAnim.value,
      ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_animator);
      _animator.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animator,
      builder: (_, __) => Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CustomPaint(
            painter: PingGaugeArcPainter(
              progress: 1.0,
              width: 4.0,
              color: R.colors.grayLight,
            ),
          ),
          CustomPaint(
            painter: PingGaugeArcPainter(
              progress: _arcProgressAnim.value,
              width: 4.0,
              color: R.colors.primaryLight,
            ),
          ),
          if (_dotValueAnim.value != null)
            PingGaugeDot(
              value: _dotValueAnim.value,
              isActive: widget.isActive,
              duration: widget.duration,
            ),
        ],
      ),
    );
  }
}

class PingGaugeDot extends StatefulWidget {
  final double value;
  final bool isActive;
  final Duration duration;

  const PingGaugeDot({
    Key key,
    @required this.value,
    @required this.isActive,
    @required this.duration,
  }) : super(key: key);

  @override
  _PingGaugeDotState createState() => _PingGaugeDotState();
}

class _PingGaugeDotState extends State<PingGaugeDot>
    with SingleTickerProviderStateMixin {
  Animation<Color> _dotColorAnim;
  AnimationController _animator;

  @override
  void initState() {
    super.initState();
    _animator = AnimationController(vsync: this, duration: widget.duration);
    _dotColorAnim = AlwaysStoppedAnimation(
        widget.isActive ? R.colors.secondary : R.colors.gray);
  }

  @override
  void didUpdateWidget(PingGaugeDot old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive) {
      _dotColorAnim = ColorTween(
        begin: _dotColorAnim.value,
        end: !widget.isActive || widget.value == null
            ? R.colors.gray
            : R.colors.secondary,
      ).animate(_animator);
      _animator.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotColorAnim,
      builder: (_, __) => CustomPaint(
        painter: PingGaugeDotPainter(
          value: widget.value,
          radius: 8.0,
          color: _dotColorAnim.value,
        ),
      ),
    );
  }
}

class PingGaugeArcPainter extends CustomPainter {
  PingGaugeArcPainter({
    @required this.progress,
    @required this.width,
    @required this.color,
  });

  final double progress;
  final double width;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.0, 0.0, size.width, 2 * size.height);
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(rect, pi, progress * pi, false, paint);
  }

  @override
  bool shouldRepaint(PingGaugeArcPainter old) =>
      old.progress != progress || old.width != width || old.color != color;
}

class PingGaugeDotPainter extends CustomPainter {
  PingGaugeDotPainter({
    @required this.value,
    @required this.radius,
    @required this.color,
  });

  final double value;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final offset = _calcDotPosition(size);
    final paint = Paint()..color = color;
    final shadowPaint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas
      ..drawCircle(offset, radius + 1.0, shadowPaint)
      ..drawCircle(offset, radius, paint);
  }

  Offset _calcDotPosition(Size size) {
    final bottomCenter = Offset(size.width / 2, size.height);
    final dx = -size.width / 2 * cos(pi * value);
    final dy = -size.height * sin(pi * value);
    return bottomCenter + Offset(dx, dy);
  }

  @override
  bool shouldRepaint(PingGaugeDotPainter old) =>
      old.value != value || old.radius != radius || old.color != color;
}