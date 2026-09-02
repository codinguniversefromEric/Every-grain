import 'package:flutter/material.dart';

class JournalButton extends StatefulWidget {
  final bool hasUnread;
  final VoidCallback onTap;

  const JournalButton({
    super.key,
    required this.hasUnread,
    required this.onTap,
  });

  @override
  State<JournalButton> createState() => _JournalButtonState();
}

class _JournalButtonState extends State<JournalButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.hasUnread) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(JournalButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasUnread && !oldWidget.hasUnread) {
      _controller.repeat(reverse: true);
    } else if (!widget.hasUnread && oldWidget.hasUnread) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.hasUnread
                    ? Color.lerp(Colors.white30, const Color(0xFFD4AF37), _controller.value)!
                    : Colors.white30,
                width: widget.hasUnread ? 2.0 : 1.0,
              ),
              boxShadow: widget.hasUnread
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: _controller.value * 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              Icons.menu_book,
              color: widget.hasUnread ? Colors.white : Colors.white70,
              size: 28,
            ),
          );
        },
      ),
    );
  }
}
