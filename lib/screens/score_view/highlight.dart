import 'package:flutter/material.dart';

class Highlight extends StatefulWidget {
  final double x;
  final double y;
  final double size;
  final Color color;
  final Color borderColor;

  const Highlight({
    super.key,
    required this.x,
    required this.y,
    this.size = 20,
    this.color = const Color(0x80FFFF00), // 반투명 노란색
    this.borderColor = Colors.orange,
  });

  @override
  _HighlightState createState() => _HighlightState();
}

class _HighlightState extends State<Highlight> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.x - widget.size / 2, // 중심점 기준으로 위치 조정
      top: widget.y - widget.size / 2,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(color: widget.borderColor, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
