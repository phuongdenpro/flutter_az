import 'package:flutter/material.dart';

void main() {
  runApp(const AnimatedDemoApp());
}

class AnimatedDemoApp extends StatelessWidget {
  const AnimatedDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, height: 1.4),
          bodyMedium: TextStyle(fontSize: 14, height: 1.4),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xLarge,
              vertical: AppSpacing.medium,
            ),
          ),
        ),
      ),
      home: const AnimatedDemoScreen(),
    );
  }
}

class AppColors {
  static const primary = Color(0xFF3B82F6);
  static const secondary = Color(0xFF22C55E);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF3F4F6);
  static const accent = Color(0xFFF97316);
  static const highlight = Color(0xFF6366F1);
  static const text = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
}

class AppSpacing {
  static const double xSmall = 6;
  static const double small = 10;
  static const double medium = 14;
  static const double large = 20;
  static const double xLarge = 24;
  static const double radius = 18;
}

class AnimatedDemoScreen extends StatefulWidget {
  const AnimatedDemoScreen({super.key});

  @override
  State<AnimatedDemoScreen> createState() => _AnimatedDemoScreenState();
}

class _AnimatedDemoScreenState extends State<AnimatedDemoScreen> {
  bool _isExpanded = false;
  bool _isVisible = true;

  static const _animationDuration = Duration(milliseconds: 600);
  static const _curve = Curves.easeInOut;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _toggleVisibility(bool value) {
    setState(() {
      _isVisible = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Implicit Animation Demo'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Mini Design System'),
              const SizedBox(height: AppSpacing.medium),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: const [
                  DesignTokenBadge(label: 'Primary', color: AppColors.primary),
                  DesignTokenBadge(
                    label: 'Secondary',
                    color: AppColors.secondary,
                  ),
                  DesignTokenBadge(
                    label: 'Surface',
                    color: AppColors.surface,
                    textColor: AppColors.text,
                  ),
                  DesignTokenBadge(label: 'Accent', color: AppColors.accent),
                  DesignTokenBadge(label: 'Text', color: AppColors.text),
                ],
              ),
              const SizedBox(height: AppSpacing.large),
              const SectionHeader(title: 'AnimatedContainer'),
              const SizedBox(height: AppSpacing.medium),
              AnimatedContainer(
                duration: _animationDuration,
                curve: _curve,
                width: _isExpanded ? 280 : 180,
                height: _isExpanded ? 180 : 120,
                padding: const EdgeInsets.all(AppSpacing.large),
                decoration: BoxDecoration(
                  color: _isExpanded
                      ? AppColors.secondary
                      : AppColors.highlight,
                  borderRadius: BorderRadius.circular(_isExpanded ? 32 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.96),
                      child: Icon(
                        Icons.auto_awesome,
                        color: _isExpanded
                            ? AppColors.secondary
                            : AppColors.highlight,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.large),
                    Expanded(
                      child: Text(
                        'Tap the button below to animate shape, color and size.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              ElevatedButton(
                onPressed: _toggleExpansion,
                child: Text(
                  _isExpanded ? 'Shrink container' : 'Expand container',
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              const SectionHeader(title: 'AnimatedOpacity'),
              const SizedBox(height: AppSpacing.medium),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Column(
                    children: [
                      AnimatedOpacity(
                        opacity: _isVisible ? 1 : 0.0,
                        duration: _animationDuration,
                        curve: _curve,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.large),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radius,
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.visibility, color: AppColors.primary),
                              SizedBox(width: AppSpacing.medium),
                              Expanded(
                                child: Text(
                                  'This area fades in and out smoothly using AnimatedOpacity.',
                                  style: TextStyle(color: AppColors.text),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      SwitchListTile(
                        value: _isVisible,
                        onChanged: _toggleVisibility,
                        title: const Text('Show animated content'),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              const SectionHeader(title: 'Hero Animation'),
              const SizedBox(height: AppSpacing.medium),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HeroDetailPage()),
                  );
                },
                child: Hero(
                  tag: 'demo-hero',
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: Row(
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.flight_takeoff,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.large),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Hero Animation card',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(height: AppSpacing.small),
                              Text(
                                'Tap this card to animate it to the new screen with a Hero transition.',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(color: AppColors.text),
    );
  }
}

class DesignTokenBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const DesignTokenBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}

class HeroDetailPage extends StatelessWidget {
  const HeroDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Detail'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'demo-hero',
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Row(
                    children: const [
                      Icon(Icons.flight_takeoff, size: 46, color: Colors.white),
                      SizedBox(width: AppSpacing.large),
                      Expanded(
                        child: Text(
                          'Hero animation makes shared elements transition between screens.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              const Text(
                'What you see here',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              const Text(
                'The same Hero tag is used between the source card and this destination card. Flutter automatically animates the shared widget across routes.',
                style: TextStyle(fontSize: 16, color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.large),
              const Text(
                'Try it again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to demo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
