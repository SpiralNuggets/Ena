import 'package:accountable/backend/app_state.dart';
import 'package:accountable/presentation/pages/addTransaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:accountable/services/ocr_service.dart';
import 'dart:io';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  bool isAutomaticUpload = false;
  final OcrService _ocrService = OcrService();
  String? _selectedFilePath;
  Map<String, String?>? _ocrResult;
  bool _isProcessing = false;

  Future<void> _pickAndProcessFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        setState(() {
          _selectedFilePath = filePath;
          _ocrResult = null;
          _isProcessing = true;
        });

        print("Selected file: $filePath");

        Map<String, String?> ocrData =
            await _ocrService.extractSlipData(filePath);

        setState(() {
          _ocrResult = ocrData;
          _isProcessing = false;
        });

        if (_ocrResult != null) {
          print(
              "OCR Result: Recipient: ${_ocrResult!['recipient']}, Amount: ${_ocrResult!['amount']}");
          if (mounted) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => AddTransaction(
                  initialAmount: _ocrResult!['amount'],
                  initialNotes: _ocrResult!['recipient'],
                ),
              ),
            );
          }
        } else {
          print("OCR failed or returned null.");
          if (mounted) {
            _showErrorMessage('Failed to extract data from slip.');
          }
        }
      } else {
        print("File picking cancelled.");
      }
    } catch (e) {
      print("Error during file picking or OCR: $e");
      if (mounted) {
        _showErrorMessage('Error: $e');
      }
      setState(() {
        _selectedFilePath = null;
        _ocrResult = null;
        _isProcessing = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGrey6,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Upload E-Slip',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Automatic Upload',
                      style: TextStyle(fontSize: 16),
                    ),
                    CupertinoSwitch(
                      value: isAutomaticUpload,
                      onChanged: (value) {
                        setState(() {
                          isAutomaticUpload = value;
                        });
                      },
                      activeColor: CupertinoColors.activeBlue,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 50),
              const Icon(
                CupertinoIcons.cloud_upload,
                color: CupertinoColors.systemIndigo,
                size: 80,
              ),
              const SizedBox(height: 30),
              CupertinoButton.filled(
                onPressed: _isProcessing ? null : _pickAndProcessFile,
                disabledColor: CupertinoColors.systemGrey3,
                child: _isProcessing
                    ? const CupertinoActivityIndicator(
                        color: CupertinoColors.white,
                      )
                    : const Text('SELECT FILE'),
              ),
              if (_selectedFilePath != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Selected: ${_selectedFilePath!.split(Platform.pathSeparator).last}',
                  style: const TextStyle(color: CupertinoColors.systemGrey),
                ),
              ],
              if (_ocrResult != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Recipient: ${_ocrResult!['recipient'] ?? 'N/A'}',
                ),
                Text(
                  'Amount: ${_ocrResult!['amount'] ?? 'N/A'}',
                ),
              ],
              const Spacer(),
              CupertinoButton(
                onPressed: () {
                  print("Manual transaction button pressed");
                  Navigator.of(context, rootNavigator: true).push(
                    CupertinoPageRoute(
                      builder: (context) => const AddTransaction(),
                    ),
                  );
                },
                color: CupertinoColors.systemGrey2,
                child: const Text(
                  'Add a transaction manually',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
