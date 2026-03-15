import 'dart:async' as async_timer;
import 'dart:math';
import 'package:flutter/material.dart';

class CenterTimer extends StatefulWidget {
  final VoidCallback onExit;
  final int initialSeconds;
  final Function(int)? onChanged;

  const CenterTimer({
    super.key,
    required this.onExit,
    this.initialSeconds = 3000,
    this.onChanged,
  });

  @override
  State<CenterTimer> createState() => _CenterTimerState();
}

class _CenterTimerState extends State<CenterTimer> {
  late int _secondsLeft;
  async_timer.Timer? _timer;
  bool _isRunning = false;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.initialSeconds;
  }

  void _startStopTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = async_timer.Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
          widget.onChanged?.call(_secondsLeft);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
        }
      });
    }
  }

  void _adjustTime(int seconds) {
    setState(() {
      _secondsLeft = max(0, _secondsLeft + seconds);
    });
    widget.onChanged?.call(_secondsLeft);
  }

  Future<void> _editTime() async {
    final controller = TextEditingController(text: (_secondsLeft ~/ 60).toString());
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Imposta Minuti'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(suffixText: 'minuti'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULLA')),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) {
                setState(() => _secondsLeft = val * 60);
                widget.onChanged?.call(_secondsLeft);
              }
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCollapsed) {
      return Container(
        color: Colors.black,
        height: 12,
        width: double.infinity,
        child: InkWell(
          onTap: () => setState(() => _isCollapsed = false),
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      );
    }

    int m = _secondsLeft ~/ 60;
    int s = _secondsLeft % 60;
    String timeStr = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Container(
      color: Colors.black,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.grey, size: 28),
            onPressed: widget.onExit,
            tooltip: 'Torna alla Home',
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.orange, size: 28),
                      onPressed: () => _adjustTime(-60),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.orange, size: 28),
                      onPressed: () => _adjustTime(60),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _editTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _isRunning ? Colors.greenAccent : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(
                        _isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: _isRunning ? Colors.greenAccent : Colors.orangeAccent,
                        size: 32,
                      ),
                      onPressed: _startStopTimer,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 28),
                      onPressed: () => setState(() => _isCollapsed = true),
                      tooltip: 'Riduci',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
