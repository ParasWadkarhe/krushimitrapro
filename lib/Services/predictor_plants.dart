import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

Future<List> preprocessImage(File imageFile) async {
  // Load image from file
  var image = img.decodeImage(imageFile.readAsBytesSync());

  // Resize the image to 224x224
  var resizedImage = img.copyResize(image!, width: 224, height: 224);

  // Convert image to a 4D tensor [1, 224, 224, 3]
  var input = List.generate(224, (y) {
    return List.generate(224, (x) {
      var pixel = resizedImage.getPixel(x, y);
      return [
        img.getRed(pixel) / 255.0,  // Normalize to [0, 1]
        img.getGreen(pixel) / 255.0, // Normalize to [0, 1]
        img.getBlue(pixel) / 255.0,  // Normalize to [0, 1]
      ];
    });
  });

  return [input]; // Return as a batch of 1 image
}

Future<int> processImageAndPredict(BuildContext context, File imageFile) async {
  // Preprocess the image
  var inputImage = await preprocessImage(imageFile);

  // Load the model
  final interpreter = await Interpreter.fromAsset('assets/plants.tflite');

  // Prepare the output buffer
  var output = List.generate(1, (index) => List.filled(38, 0.0));

  // Run the model
  interpreter.run(inputImage, output);

  // Close the interpreter
  interpreter.close();

  // Get the predicted class
  var predictedClass = getPredictedClass(output[0]);

  return predictedClass;
}

int getPredictedClass(List<double> output) {
  // Find the index of the maximum value in the output list
  int predictedClass = output.indexWhere((value) => value == output.reduce((a, b) => a > b ? a : b));
  return predictedClass;
}


