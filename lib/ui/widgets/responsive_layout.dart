import 'package:flutter/material.dart';

/// Keeps desktop field groups side by side and gives phone fields full width.
class ResponsiveRow extends StatefulWidget {
  const ResponsiveRow({
    super.key,
    required this.children,
    this.breakpoint = 600,
    this.spacing = 16,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  final List<Widget> children;
  final double breakpoint;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  @override
  State<ResponsiveRow> createState() => _ResponsiveRowState();
}

class _ResponsiveRowState extends State<ResponsiveRow> {
  final _keys = <GlobalKey>[];

  @override
  Widget build(BuildContext context) {
    while (_keys.length < widget.children.length) {
      _keys.add(GlobalKey());
    }
    Widget retained(int index) {
      final child = widget.children[index];
      return KeyedSubtree(
        key: _keys[index],
        child: child is Flexible ? child.child : child,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        if (constraints.maxWidth >= widget.breakpoint * scale.clamp(1, 1.5)) {
          return Row(
            crossAxisAlignment: widget.crossAxisAlignment,
            mainAxisAlignment: widget.mainAxisAlignment,
            children: [
              for (var i = 0; i < widget.children.length; i++)
                if (widget.children[i] is Flexible)
                  Flexible(
                    flex: (widget.children[i] as Flexible).flex,
                    fit: (widget.children[i] as Flexible).fit,
                    child: retained(i),
                  )
                else
                  retained(i),
            ],
          );
        }
        final stacked = <Widget>[];
        for (var i = 0; i < widget.children.length; i++) {
          var child = widget.children[i];
          if (child is Spacer ||
              (child is SizedBox &&
                  child.width != null &&
                  child.child == null)) {
            continue;
          }
          if (child is Flexible) child = child.child;
          if (child is Container &&
              child.child == null &&
              child.decoration == null) {
            continue;
          }
          if (stacked.isNotEmpty) stacked.add(SizedBox(height: widget.spacing));
          stacked.add(retained(i));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: stacked,
        );
      },
    );
  }
}

/// Result cards grow with their labels instead of using a fixed grid height.
class ResponsiveResults extends StatelessWidget {
  const ResponsiveResults({
    super.key,
    required this.children,
    this.minWidth = 220,
  });

  final List<Widget> children;
  final double minWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final columns =
          ((constraints.maxWidth + 16) / (minWidth * scale.clamp(1, 1.5) + 16))
              .floor()
              .clamp(1, 3);
      final width = (constraints.maxWidth - 16 * (columns - 1)) / columns;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: children
            .map(
              (child) => SizedBox(
                width: width,
                child: child is SizedBox && child.child != null
                    ? child.child
                    : child,
              ),
            )
            .toList(),
      );
    },
  );
}

/// Makes wide calculator tables discoverable and scrollable by touch or mouse.
class ResponsiveTable extends StatefulWidget {
  const ResponsiveTable({super.key, required this.child});
  final Widget child;

  @override
  State<ResponsiveTable> createState() => _ResponsiveTableState();
}

class _ResponsiveTableState extends State<ResponsiveTable> {
  final _controller = ScrollController();
  bool _overflows = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) {
          final overflows = notification.metrics.maxScrollExtent > 0;
          if (overflows != _overflows) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && overflows != _overflows) {
                setState(() => _overflows = overflows);
              }
            });
          }
          return false;
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_overflows)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Scroll sideways to see all columns',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            Scrollbar(
              controller: _controller,
              thumbVisibility: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SingleChildScrollView(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      );
}
