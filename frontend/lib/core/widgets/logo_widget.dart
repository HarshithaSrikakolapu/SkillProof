import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool animate;

  const LogoWidget({
    super.key, 
    this.size = 100,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final logoContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Attempt to load asset, fallback to Icon
        Image(
          image: AssetImage('assets/images/logo.png'),
          width: 80,
          height: 80,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.verified_user, // Fallback Shield Icon
              size: 80, 
              color: Color(0xFF6C63FF)
            );
          },
        ),
      ],
    );

    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        curve: Curves.easeOutBack,
        duration: const Duration(seconds: 1),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: logoContent,
      );
    }
    
    return logoContent;
  }
}
