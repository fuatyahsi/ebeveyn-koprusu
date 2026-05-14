import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Soyut köprü işareti — markanın hem app bar'da hem rapor başlığında
/// kullanılan küçük versiyonu.
class BridgeMark extends StatelessWidget {
  const BridgeMark({super.key, this.size = 22, this.color = AppColors.ink});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BridgeMarkPainter(color)),
    );
  }
}

class _BridgeMarkPainter extends CustomPainter {
  _BridgeMarkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * (1.6 / 24);

    final w = size.width;
    final h = size.height;
    final left = w * (4 / 24);
    final right = w * (20 / 24);
    final base = h * (18 / 24);
    final top = h * (9 / 24);

    // deck
    canvas.drawLine(Offset(left, base), Offset(right, base), stroke);
    // towers
    canvas.drawLine(Offset(left, base), Offset(left, top), stroke);
    canvas.drawLine(Offset(right, base), Offset(right, top), stroke);
    // arch (quadratic via cubic approx)
    final path = Path()
      ..moveTo(left, top)
      ..quadraticBezierTo(w * 0.5, h * (18 / 24), right, top);
    canvas.drawPath(path, stroke);

    // child orb
    final orb = Paint()..color = AppColors.ochre;
    canvas.drawCircle(Offset(w * 0.5, h * (13.7 / 24)), w * (1.6 / 24), orb);
  }

  @override
  bool shouldRepaint(covariant _BridgeMarkPainter old) => old.color != color;
}

/// Tam app icon (yuvarlatılmış kare). Onboarding ve abonelik ekranında
/// kullanılır; ayrıca [generateAppIconPng] export'u burayı baz alır.
class AppIconWidget extends StatelessWidget {
  const AppIconWidget({super.key, this.size = 180, this.radius});

  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? size * 0.225;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: const RadialGradient(
          radius: 1.0,
          center: Alignment(0, -1),
          colors: [Color(0xFF1B3A57), AppColors.ink, Color(0xFF081A2C)],
          stops: [0, 0.55, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF081A2C).withValues(alpha: 0.35),
            offset: Offset(0, size * 0.04),
            blurRadius: size * 0.12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: CustomPaint(painter: _AppIconPainter(), size: Size.square(size)),
      ),
    );
  }
}

class _AppIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final scale = w / 200;

    final cream = Paint()
      ..color = AppColors.paper
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.4 * scale;

    final sage = Paint()
      ..color = AppColors.sage.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4 * scale;

    final cable = Paint()
      ..color = AppColors.paper.withValues(alpha: 0.55)
      ..strokeWidth = 0.9 * scale;

    final horizon = Paint()
      ..color = AppColors.paper.withValues(alpha: 0.18)
      ..strokeWidth = 1 * scale;

    Offset p(double x, double y) => Offset(x * scale, y * scale);

    // horizon
    canvas.drawLine(p(22, 138), p(178, 138), horizon);

    // towers
    canvas.drawLine(p(48, 138), p(48, 64), cream);
    canvas.drawLine(p(152, 138), p(152, 64), cream);

    // main arch
    final arch = Path()
      ..moveTo(48 * scale, 64 * scale)
      ..quadraticBezierTo(100 * scale, 140 * scale, 152 * scale, 64 * scale);
    canvas.drawPath(arch, cream);

    // echo arch (sage)
    final echo = Path()
      ..moveTo(48 * scale, 64 * scale)
      ..quadraticBezierTo(100 * scale, 116 * scale, 152 * scale, 64 * scale);
    canvas.drawPath(echo, sage);

    // cables
    for (final t in const [0.18, 0.32, 0.46, 0.54, 0.68, 0.82]) {
      final x = 48 + (152 - 48) * t;
      final y = (1 - t) * (1 - t) * 64 + 2 * (1 - t) * t * 140 + t * t * 64;
      canvas.drawLine(p(x, y), p(x, 138), cable);
    }

    // deck plate
    final plate = Paint()..color = AppColors.paper;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(44 * scale, 136.5 * scale, 112 * scale, 3.2 * scale),
        Radius.circular(1.6 * scale),
      ),
      plate,
    );

    // child orb (ochre)
    canvas.drawCircle(
      p(100, 100),
      6.2 * scale,
      Paint()..color = AppColors.ochre,
    );
    canvas.drawCircle(
      p(100, 100),
      6.2 * scale,
      Paint()
        ..color = AppColors.paper.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6 * scale,
    );

    // parent dots
    canvas.drawCircle(p(48, 64), 3.4 * scale, Paint()..color = AppColors.paper);
    canvas.drawCircle(
      p(152, 64),
      3.4 * scale,
      Paint()..color = AppColors.paper,
    );

    // top sheen
    final sheenRect = Rect.fromLTWH(0, 0, w, w * 0.4);
    canvas.drawRect(
      sheenRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(sheenRect),
    );
  }

  @override
  bool shouldRepaint(covariant _AppIconPainter old) => false;
}
