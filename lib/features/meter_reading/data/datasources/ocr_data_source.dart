import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../../core/error/exceptions.dart';

abstract class OCRDataSource { 
  /// Extracts text from an image file
  Future<String> extractTextFromImage(String imagePath);
}

class OCRDataSourceImpl implements OCRDataSource {  
  final TextRecognizer textRecognizer;

  OCRDataSourceImpl({TextRecognizer? textRecognizer})  
      : textRecognizer = textRecognizer ?? TextRecognizer();

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    try {
      // Create input image from file path
      final inputImage = InputImage.fromFilePath(imagePath);

      // Process image with ML Kit
      final recognizedText = await textRecognizer.processImage(inputImage); 

      // Extract meter reading from recognized text
      final reading = _extractMeterReading(recognizedText.text); 

      // Clean up
      await textRecognizer.close();

      return reading;

    } catch (e) {
      throw OCRException('Failed to extract text from image: $e');
    }
  }

  /// Extracts numeric meter reading from OCR text
  String _extractMeterReading(String text) { 
    // Remove all whitespace and newlines
    final cleanedText = text.replaceAll(RegExp(r'\s+'), ''); 
    // Find all numbers (including decimals)
    final RegExp numberRegex = RegExp(r'\d+\.?\d*'); 
    final matches = numberRegex.allMatches(cleanedText);

    if (matches.isEmpty) {
      throw OCRException('No meter reading found in image');
    }

    // Get all numbers found
    final numbers = matches.map((m) => m.group(0)!).toList();  
    // Return the longest number (likely the meter reading)
    numbers.sort((a, b) => b.length.compareTo(a.length));

    return numbers.first;
  }
}