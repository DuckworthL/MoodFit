import 'package:flutter/material.dart';

class SliderVerification extends StatefulWidget {
  final ValueChanged<bool> onVerified;
  const SliderVerification({Key? key, required this.onVerified})
      : super(key: key);

  @override
  State<SliderVerification> createState() => _SliderVerificationState();
}

class _SliderVerificationState extends State<SliderVerification> {
  double _sliderValue = 0.0;
  bool _isVerified = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Verify you're human",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          "Slide to complete verification",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              width: _sliderValue * (MediaQuery.of(context).size.width - 64),
              decoration: BoxDecoration(
                color:
                    _isVerified ? Colors.green : Colors.blue.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 48,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: _isVerified ? Colors.green : Colors.blue,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 22),
                overlayColor: Colors.blue.withOpacity(0.2),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
              ),
              child: Slider(
                value: _sliderValue,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                    _isVerified = value >= 0.99;
                  });
                  if (_isVerified) {
                    widget.onVerified(true);
                  }
                },
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  _isVerified ? "Verified! ✓" : "→ Slide to verify",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
