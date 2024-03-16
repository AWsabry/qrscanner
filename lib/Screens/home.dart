import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
  Barcode? result;
  QRViewController? controller;
  @override
  String? data;
  GlobalKey qrkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Column(
        children: [
          result.toString().isNotEmpty
              ? Expanded(
                  child: QRView(
                    key: qrkey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Scanned Data: ${data.toString().isNotEmpty ? 'Not Found yet' : data.toString()}',
            ),
            // child: Text(readCounter()
            //     // 'Scanned Data: ${result.toString().isNotEmpty ? 'Not Found yet' : result!.code.toString()}',
            //     ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await writeCounter("");
                setState(() {});
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

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    log(directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "Error reading counter: $e";
    }
  }

  Future<String> writeCounter(String counter) async {
    final file = await _localFile;
    log("data has been saved");
    log(counter);
    log("data has been saved to this path $_localPath");
    file.writeAsString(counter);
    data = await readCounter();
    setState(() {});
    return data!;

    // return file.writeAsString(counter);
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
        String filePath = await _getFilePath(fileName);
        File file = File(filePath);

        await file.writeAsString(result!.code.toString());

        print('File downloaded successfully as $fileName');
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

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
