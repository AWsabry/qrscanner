import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Import the path_provider package
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QRCodeScannerApp(),
    );
  }
}

class QRCodeScannerApp extends StatefulWidget {
  const QRCodeScannerApp({
    Key? key,
  }) : super(key: key);

  @override
  _QRCodeScannerAppState createState() => _QRCodeScannerAppState();
}

class _QRCodeScannerAppState extends State<QRCodeScannerApp> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _qrController;
  String _scannedData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Column(
        children: [
          // Expanded(
          //   child: QRView(
          //     key: _qrKey,
          //     onQRViewCreated: _onQRViewCreated,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Scanned Data: $_scannedData'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _downloadScannedData();
            },
            child: const Text('Download as .txt'),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _qrController = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _scannedData = scanData.code ?? '';
      });
    });
  }

  Future<void> _downloadScannedData() async {
    try {
      if (await _requestPermission()) {
        String fileName = 'scanned_data.txt';
        String filePath = await _getFilePath(
            fileName); // Get the application's documents directory
        File file = File(filePath);

        await file.writeAsString(_scannedData);

        // You can implement further logic here, such as showing a success message.
        print('File downloaded successfully as $fileName');
      } else {
        print('Permission denied');
      }
    } catch (e) {
      // Handle exceptions.
      print('Error: $e');
    }
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    } else {
      var result = await Permission.storage.request();
      return result.isGranted;
    }
  }

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }
}
