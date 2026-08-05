import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مسح الباركود', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 42, 150, 177),
          actions: [
            IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white),
              onPressed: () => _controller.toggleTorch(),
            ),
            IconButton(
              icon: const Icon(Icons.cameraswitch, color: Colors.white),
              onPressed: () => _controller.switchCamera(),
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_isScanned) return;
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
                    setState(() => _isScanned = true);
                    Navigator.pop(context, barcode.rawValue);
                    break;
                  }
                }
              },
            ),
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyan, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'وجه الكاميرا نحو باركود المنتج',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
