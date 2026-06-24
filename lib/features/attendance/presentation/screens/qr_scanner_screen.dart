import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final String expectedQRToken; // Pre-existing token to validate against
  final bool isCheckOut;

  const QRScannerScreen({
    super.key,
    required this.expectedQRToken,
    this.isCheckOut = false,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleQRCode(String scannedData) async {
    if (_isProcessing) return;

    //debugPrint('QR Code Scanned: $scannedData\nExpected QR Code: ${widget.expectedQRToken}');

    setState(() => _isProcessing = true);

    // Validate the entire scanned string against our expected token
    // Our expected tokens now include the type suffix (e.g., "|checkin")
    if (scannedData.trim() != widget.expectedQRToken.trim()) {

      // Check if it's just the wrong type but valid token
      final parts = scannedData.split('|');
      final expectedParts = widget.expectedQRToken.split('|');

      if (parts.length >= 2 && expectedParts.length >= 2 && parts[0] == expectedParts[0]) {
        // Token matches, but type (checkin/checkout) is wrong
        Navigator.pop(context, {
          'verified': false,
          'wrongType': true,
          'scannedType': parts[1],
        });
        return;
      }

      // Invalid QR token - pop back to check-in screen and show wrong QR type screen
      Navigator.pop(context, {
        'verified': false,
        'wrongType': true,
      });
      return;
    }

    // QR code verified successfully
    Navigator.pop(context, {
      'verified': true,
      'wrongType': false,
      'scannedData': scannedData,
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Scan QR Code'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (_, TorchState torchState, __) {
                return Icon(
                  torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (_, CameraFacing cameraFacing, __) {
                return Icon(
                  cameraFacing == CameraFacing.front
                      ? Icons.camera_front
                      : Icons.camera_rear,
                );
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleQRCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          // Scanner overlay
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Instruction text
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Align QR code within the frame',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}