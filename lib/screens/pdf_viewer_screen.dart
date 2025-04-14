import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // 로컬 저장소 경로 가져오기
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert'; // JSON 인코딩/디코딩
import 'package:pdfx/pdfx.dart'; // 페이지 렌더링용

class PdfViewerScreen extends StatefulWidget {
  final File pdfFile;

  const PdfViewerScreen({Key? key, required this.pdfFile}) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  final List<Offset> _points = []; // 드로잉 포인트 저장
  bool _isDrawing = false; // 드로잉 모드 활성화 여부
  bool _isErasing = false; // 지우개 모드 활성화 여부

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  void _clearDrawing() {
    setState(() {
      _points.clear(); // 드로잉 포인트 초기화
    });
  }

  void _eraseDrawing(Offset position) {
    setState(() {
      // 터치한 위치 근처의 포인트를 삭제
      _points.removeWhere((point) {
        return (point - position).distance < 20.0; // 20.0은 지우개 범위
      });
    });
  }

  Future<void> _saveDrawing() async {
    try {
      // 로컬 저장소 경로 가져오기
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/drawing.json';

      // 드로잉 데이터를 JSON으로 변환
      final drawingData =
          _points.map((point) => {'x': point.dx, 'y': point.dy}).toList();
      final jsonData = jsonEncode(drawingData);

      // 파일에 저장
      final file = File(filePath);
      await file.writeAsString(jsonData);

      // 저장 완료 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('드로잉이 저장되었습니다: $filePath')),
      );
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    // 뒤로가기 시 저장 여부를 묻는 다이얼로그 표시
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장하시겠습니까?'),
        content: const Text('현재 드로잉을 저장하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // 저장하지 않음
            child: const Text('아니요'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // 저장
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await _saveDrawing(); // 드로잉 저장
    }

    return true; // 화면 종료 허용
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // 뒤로가기 이벤트 처리
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PDF Viewer'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final canPop = await _onWillPop();
              if (canPop) {
                context.go('/'); // 홈 화면으로 이동
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(_isDrawing ? Icons.brush : Icons.brush_outlined),
              onPressed: () {
                setState(() {
                  _isDrawing = !_isDrawing; // 드로잉 모드 토글
                  _isErasing = false; // 지우개 모드 비활성화
                });
              },
            ),
            IconButton(
              icon: ImageIcon(
                AssetImage('assets/icons/eraser.png'),
                color: _isErasing ? Colors.blue : Colors.black, // 활성화 시 색상 변경
              ),
              onPressed: () {
                setState(() {
                  _isErasing = !_isErasing; // 지우개 모드 토글
                  _isDrawing = false; // 드로잉 모드 비활성화
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete), // 전체 삭제 버튼
              onPressed: _clearDrawing, // 드로잉 초기화
            ),
          ],
        ),
        body: Stack(
          children: [
            SfPdfViewer.file(
              widget.pdfFile,
              controller: _pdfViewerController,
            ),
            GestureDetector(
              onPanUpdate: (details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                Offset localPosition =
                    renderBox.globalToLocal(details.globalPosition);

                if (_isDrawing) {
                  setState(() {
                    _points.add(localPosition); // 드로잉 포인트 추가
                  });
                } else if (_isErasing) {
                  _eraseDrawing(localPosition); // 지우개로 포인트 삭제
                }
              },
              onPanEnd: (details) {
                if (_isDrawing) {
                  setState(() {
                    _points.add(Offset.zero); // 드로잉 종료 표시
                  });
                }
              },
              child: CustomPaint(
                painter: DrawingPainter(_points),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
