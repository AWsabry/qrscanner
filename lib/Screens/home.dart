import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeScannerApp extends StatefulWidget {
  const QRCodeScannerApp({
    Key? key,
  }) : super(key: key);

  @override
  _QRCodeScannerAppState createState() => _QRCodeScannerAppState();
}

class _QRCodeScannerAppState extends State<QRCodeScannerApp> {
  @override
  void initState() {
    super.initState();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  Future<void> _downloadScannedData() async {
    try {
      if (await _requestPermission()) {
        String fileName = 'scanned_data.txt';
        String filePath = "/storage/emulated/0/Download/$fileName";
        File file = File(filePath);

        await file.writeAsString(result!.code.toString()).then((value) {
          log(value.path);
          log('File downloaded successfully as $fileName');
        });
      } else {
        print('Permission denied');
      }
    } catch (e) {
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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrkey = GlobalKey(debugLabel: 'QrScanner');
  @override
  Widget build(BuildContext context) {
    // log(result!.code.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrkey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Scanned Data: ${result == null ? 'Not Found yet' : result!.code.toString()}',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _downloadScannedData().then((value) {
                  // log(value.toString());
                  log(result!.code.toString());
                });
              } catch (E) {
                log(E.toString());
              }
            },
            child: const Text('Download as .txt'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                controller!.pauseCamera();
              });
            },
            child: const Text("Pause Camera"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                controller!.resumeCamera();
              });
            },
            child: const Text("Start Camera"),
          ),
        ],
      ),
    );
  }
}
