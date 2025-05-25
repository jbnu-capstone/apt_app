import 'package:flutter/material.dart';

import 'highlight.dart';
import 'mic_open_button.dart';

class ScoreViewer extends StatefulWidget {
  final String serverUrl;
  final Function(double x, double y)? onTap;

  const ScoreViewer({
    super.key,
    required this.serverUrl,
    this.onTap,
  });

  @override
  _ScoreViewerState createState() => _ScoreViewerState();
}

class _ScoreViewerState extends State<ScoreViewer> {
  Offset? _highlightPosition; // 단일 하이라이트 위치
  bool _isMicActive = false;

  void _setHighlight(double x, double y) {
    setState(() {
      _highlightPosition = Offset(x, y);
    });
    widget.onTap?.call(x, y);
  }

  void _clearHighlight() {
    setState(() {
      _highlightPosition = null;
    });
  }

  void _onMicToggle(bool isActive) {
    setState(() {
      _isMicActive = isActive;
    });
  }

  // 외부에서 하이라이트 위치를 설정할 수 있는 메서드
  void moveHighlight(double x, double y) {
    _setHighlight(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 상단 컨트롤 바
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    MicOpenButton(
                      serverUrl: widget.serverUrl,
                      onMicToggle: _onMicToggle,
                    ),
                    SizedBox(width: 16),
                    if (_isMicActive)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '녹음 중',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.clear_all),
                  onPressed: _clearHighlight,
                  tooltip: '하이라이트 지우기',
                ),
              ],
            ),
          ),
          // PDF 뷰어와 하이라이트 영역
          Expanded(
            child: GestureDetector(
              onTapDown: (TapDownDetails details) {
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final localPosition = renderBox.globalToLocal(details.globalPosition);
                _setHighlight(localPosition.dx, localPosition.dy - 60); // 상단 바 높이 보정
              },
              child: Stack(
                children: [
                  // PDF 뷰어
                  Positioned.fill(
                    child: PdfViewer(), // 기존에 구현된 PDF 뷰어
                  ),
                  // 단일 하이라이트
                  if (_highlightPosition != null)
                    Highlight(
                      x: _highlightPosition!.dx,
                      y: _highlightPosition!.dy,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 기존 PDF 뷰어 위젯 (placeholder)
class PdfViewer extends StatelessWidget {
  const PdfViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          'PDF 악보가 여기에 표시됩니다',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
