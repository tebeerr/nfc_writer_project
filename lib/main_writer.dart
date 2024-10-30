import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() => runApp(NfcWriterApp());

class NfcWriterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NfcWriterScreen(),
    );
  }
}

class NfcWriterScreen extends StatefulWidget {
  @override
  _NfcWriterScreenState createState() => _NfcWriterScreenState();
}

class _NfcWriterScreenState extends State<NfcWriterScreen> {
  String _nfcData = 'Waiting to write data...';

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  // Check NFC availability
  void _checkNfcAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    setState(() {
      _nfcData = isAvailable ? 'NFC available!' : 'NFC not available.';
    });
  }

  // Start NFC write session
  void _writeNfcTag(String data) async {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final ndef = Ndef.from(tag);
        if (ndef != null && ndef.isWritable) {
          final ndefMessage = NdefMessage([
            NdefRecord.createText(data),
          ]);
          await ndef.write(ndefMessage);
          setState(() {
            _nfcData = 'Data written to tag!';
          });
        } else {
          setState(() {
            _nfcData = 'NDEF not supported or not writable.';
          });
        }
        NfcManager.instance.stopSession();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC Writer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_nfcData),
            const SizedBox(height: 20),
            TextField(
              onSubmitted: (value) {
                _writeNfcTag(value); // Write the entered text to NFC tag
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter data to write',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

