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
    this.color = const Color(0x80FFFF00),
    this.borderColor = Colors.orange,
  });

  @override
  _HighlightState createState() => _HighlightState();
}

class _HighlightState extends State<Highlight> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;

  Offset _currentPosition = Offset.zero;
  final bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _currentPosition = Offset(widget.x, widget.y);
    _positionAnimation = Tween<Offset>(
      begin: _currentPosition,
      end: _currentPosition,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(Highlight oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 위치가 변경되면 현재 애니메이션 위치에서 새로운 목표로 이동
    if (oldWidget.x != widget.x || oldWidget.y != widget.y) {
      final newTarget = Offset(widget.x, widget.y);

      // 현재 애니메이션 진행 중인 위치를 가져옴
      final currentAnimatedPosition = _positionAnimation.value;

      // 새로운 애니메이션을 현재 위치에서 시작
      _positionAnimation = Tween<Offset>(
        begin: currentAnimatedPosition, // 현재 애니메이션 위치에서 시작
        end: newTarget,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _currentPosition = newTarget;

      // 애니메이션을 처음부터 다시 시작
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final position = _positionAnimation.value;
        return Positioned(
          left: position.dx - widget.size / 2,
          top: position.dy - widget.size / 2,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                border: Border.all(color: widget.borderColor, width: 2),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: widget.borderColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
