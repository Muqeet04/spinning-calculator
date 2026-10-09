import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class PageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [SpinColors.lavenderBg, SpinColors.cardWhite],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Watermark
          const Positioned(
            right: -50,
            bottom: -50,
            child: Opacity(
              opacity: 0.03,
              child: Icon(
                Icons.settings,
                size: 300,
                color: SpinColors.navyDark,
              ),
            ),
          ),
          // Content
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [SpinColors.navyDark, SpinColors.navyLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          bottom: BorderSide(color: SpinColors.amber, width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (GoRouter.of(context).canPop())
                  InkWell(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back, color: SpinColors.navyDark, size: 16),
                          SizedBox(width: 8),
                          Text('Back to Home', style: TextStyle(color: SpinColors.navyDark, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  children: [
                    _buildActionButton('Save data', SpinColors.successGreen, Colors.white),
                    const SizedBox(width: 8),
                    _buildActionButton('Print', Colors.transparent, Colors.white, border: Colors.white),
                    const SizedBox(width: 8),
                    _buildActionButton('Save PDF', SpinColors.amber, SpinColors.navyDark),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 16,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color bgColor, Color textColor, {Color? border}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: border != null ? Border.all(color: border) : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
