import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25), 
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), 
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15), 
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5), 
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
