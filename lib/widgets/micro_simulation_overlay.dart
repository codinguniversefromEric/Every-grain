import 'package:flutter/material.dart';

class MicroSimulationOverlay extends StatefulWidget {
  final VoidCallback onCompleted;

  const MicroSimulationOverlay({
    super.key,
    required this.onCompleted,
  });

  @override
  State<MicroSimulationOverlay> createState() => _MicroSimulationOverlayState();
}

class _MicroSimulationOverlayState extends State<MicroSimulationOverlay> {
  final List<bool> _planted = List.generate(9, (_) => false);
  bool _isFadingOut = false;

  void _handleTap(int index) {
    if (_planted[index]) return;
    
    setState(() {
      _planted[index] = true;
    });
    
    // Play sound effect here if possible (can be tied to global ambient sound)
    
    if (_planted.every((element) => element)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isFadingOut = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFadingOut) {
      return AnimatedOpacity(
        opacity: 0.0,
        duration: const Duration(seconds: 2),
        onEnd: widget.onCompleted,
        child: _buildCompletionMessage(),
      );
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                "請在發光處插下秧苗\n(點擊光點)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 2,
                  height: 1.5,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        final isPlanted = _planted[index];
                        return GestureDetector(
                          onTap: () => _handleTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: isPlanted 
                                  ? Colors.green.withValues(alpha: 0.3) 
                                  : Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isPlanted ? Colors.green : Colors.white54,
                                width: 2,
                              ),
                              boxShadow: isPlanted 
                                  ? [] 
                                  : [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                            ),
                            child: isPlanted
                                ? const Icon(Icons.grass, color: Colors.green, size: 32)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionMessage() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: const Center(
        child: Text(
          "今日農事已畢\n田水正好\n去忙你的吧。",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 3,
            height: 2.0,
          ),
        ),
      ),
    );
  }
}
