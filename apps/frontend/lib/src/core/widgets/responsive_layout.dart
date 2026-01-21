import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final WidgetBuilder mobileBuilder;
  final WidgetBuilder desktopBuilder;
  final double mobileBreakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobileBuilder,
    required this.desktopBuilder,
    this.mobileBreakpoint = 768.0, // Matches .cursorrules specification
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > mobileBreakpoint) {
          return desktopBuilder(context);
        } else {
          return mobileBuilder(context);
        }
      },
    );
  }
}
