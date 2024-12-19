import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
      home: QRScannerPage(),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? scannedData;
  String? idNumber;
  bool isScanning = true;

  void resetScanner() {
    setState(() {
      scannedData = null;
      idNumber = null;
      isScanning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive font size and spacing
    double fontSize =
        screenWidth * 0.04; // Font size as a percentage of screen width
    double buttonPadding = screenWidth * 0.08; // Padding based on screen width
    double boxSize =
        screenWidth * 0.6; // Box size as a percentage of screen width

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: Colors.lime, // AppBar color
        elevation: 4,
      ),
      body: Column(
        children: [
          // Display the scanned data or a placeholder
          if (scannedData != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card for Scanned Data
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Scanned Data: $scannedData',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Spacer between cards

                  // Card for ID Number
                  if (idNumber != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'ID Number: $idNumber',
                          style: TextStyle(
                              fontSize: fontSize, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No QR code scanned yet.',
                style: TextStyle(fontSize: fontSize),
              ),
            ),

          // Camera preview area with a portion of the screen
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: MobileScanner(
                    onDetect: (capture) {
                      if (isScanning) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          final rawValue = barcode.rawValue;
                          if (rawValue != null) {
                            setState(() {
                              scannedData = rawValue;
                              idNumber = extractIdNumber(rawValue);
                              isScanning = false; // Stop scanning after success
                            });
                            break;
                          }
                        }
                      }
                    },
                  ),
                ),
                // Scanning box with rounded corners
                Container(
                  width: boxSize,
                  height: boxSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red, // Border color
                      width: 4, // Border width
                    ),
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
              ],
            ),
          ),

          // Scan again button with styling
          Padding(
            padding: EdgeInsets.symmetric(horizontal: buttonPadding)
                .copyWith(bottom: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan, // Button background color
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                textStyle: TextStyle(fontSize: fontSize),
              ),
              onPressed: isScanning
                  ? null
                  : () {
                      resetScanner();
                    },
              child: const Text(
                'Scan Again',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to extract ID number from the scanned data
  String? extractIdNumber(String data) {
    final idRegex = RegExp(r'ID\s*:\s*(\w+)', caseSensitive: false);
    final match = idRegex.firstMatch(data);
    return match?.group(1);
  }
}
