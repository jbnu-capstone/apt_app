import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final _logger = Logger('MicOpenButton');

class MicOpenButton extends StatefulWidget {
  final String serverUrl;
  final Function(bool)? onMicToggle;

  const MicOpenButton({
    super.key,
    required this.serverUrl,
    this.onMicToggle,
  });

  @override
  MicOpenButtonState createState() => MicOpenButtonState();
}

class MicOpenButtonState extends State<MicOpenButton> {
  bool _isMicOpen = false;
  bool _isRecording = false;
  late AudioRecorder _audioRecorder; // Record() 대신 AudioRecorder() 사용
  io.Socket? _socket;
  Timer? _recordingTimer;
  StreamSubscription<RecordState>? _recordSub;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder(); // 올바른 클래스 사용
    _initializeSocket();
    _initRecorder();
  }

  void _initializeSocket() {
    _socket = io.io(widget.serverUrl, <String, dynamic>{
      'transports': [
        'websocket'
      ],
      'autoConnect': false,
    });
  }

  void _initRecorder() async {
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      setState(() {
        _isRecording = recordState == RecordState.record;
      });
    });
  }

  Future<void> _toggleMic() async {
    if (_isMicOpen) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        _socket?.connect();

        setState(() {
          _isMicOpen = true;
        });

        widget.onMicToggle?.call(true);

        // 0.5초마다 녹음 데이터 전송
        _recordingTimer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
          await _recordAndSend();
        });

        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/audio_recording.m4a';
        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 32000, // 16-bit mono at 22kHz = 352kbps, using 32kbps for AAC compression
            sampleRate: 22050, // 22kHz
            numChannels: 1, // mono
          ),
          path: path,
        );
      }
    } catch (e) {
      _logger.severe('녹음 시작 오류: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();

      if (_isRecording) {
        await _audioRecorder.stop();
      }

      _socket?.disconnect();

      setState(() {
        _isMicOpen = false;
        _isRecording = false;
      });

      widget.onMicToggle?.call(false);
    } catch (e) {
      _logger.severe('녹음 중지 오류: $e');
    }
  }

  Future<void> _recordAndSend() async {
    try {
      if (_socket?.connected == true && _isRecording) {
        // 실제 오디오 데이터를 소켓으로 전송
        _socket?.emit('audio_data', {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'data': 'audio_chunk_placeholder' // 실제 오디오 데이터로 교체
        });
      }
    } catch (e) {
      _logger.severe('오디오 전송 오류: $e');
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recordSub?.cancel();
    _audioRecorder.dispose();
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isMicOpen ? Colors.red.withAlpha(26) : null,
      ),
      child: IconButton(
        icon: Icon(
          _isMicOpen ? Icons.mic : Icons.mic_off,
          color: _isMicOpen ? Colors.red : Colors.grey,
          size: 28,
        ),
        onPressed: _toggleMic,
        tooltip: _isMicOpen ? '마이크 끄기' : '마이크 켜기',
      ),
    );
  }
}
