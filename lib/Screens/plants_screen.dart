import 'package:free_map/services/fm_service.dart';
import 'package:geolocator/geolocator.dart'; // Add geolocator package
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'home_page.dart';
import 'plant_disease_info_page.dart';
import '../Services/predictor_plants.dart';
import 'package:geocode/geocode.dart';

class Plant_Screen extends StatefulWidget {
  const Plant_Screen({Key? key}) : super(key: key);

  @override
  _Plant_ScreenState createState() => _Plant_ScreenState();
}

class _Plant_ScreenState extends State<Plant_Screen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isCameraMode = true;
  Position? _currentPosition;
  String? _region;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.high);
      await _controller?.initialize();
      setState(() {});
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _askUserDetailsAndNavigate();
    }
  }

  Future<void> _askUserDetailsAndNavigate() async {
    final addressController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Enter Image Details"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Text(selectedDate == null
                            ? "Pick Date"
                            : "${selectedDate!.toLocal()}".split(' ')[0]),
                      ),
                    ],
                  ),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: "Address"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );

    final enteredAddress = addressController.text;

    if (selectedDate != null && enteredAddress.isNotEmpty) {
      setState(() {
        _region = enteredAddress;
        _selectedDateTime = selectedDate; // Save the selected date
      });
      _predictDisease();
    } else {
      print("Error: Date or address not provided");
    }
  }

  // Fetch the current location and get the region name
  Future<void> _fetchLocationAndPredict() async {
    await _getCurrentLocation(); // Ensure location is fetched before prediction
    if (_image != null && _region != null) {
      _predictDisease(); // Trigger prediction after location is fetched
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Location permissions are denied");
        _region = "Location Permission Denied";
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _currentPosition = position;

      // Fetch the region
      final data = await FMService().getAddress(
        lat: position.latitude,
        lng: position.longitude,
      );
      setState(() {
        _region = data?.address ?? "Unknown Region";
      });
    } catch (e) {
      print("Error fetching location: $e");
      setState(() {
        _region = "Error Fetching Region";
        _selectedDateTime = DateTime.now();
      });
    }
  }

  // Take a photo using the camera
  Future<void> _takePhoto() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final XFile photo = await _controller!.takePicture();
      setState(() {
        _image = File(photo.path);
      });
      await _fetchLocationAndPredict(); // Fetch location and predict after taking the photo
    }
  }

  // Trigger plant disease prediction
  void _predictDisease() async {
    if (_image != null && _region != null) {
      var predictedClass = await processImageAndPredict(context, _image!);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DiseaseInfoPage(
            diseaseIndex: predictedClass - 1,
            location_: _region!,
            timestamp: _selectedDateTime ?? DateTime.now(),
          ),
        ),
      );
    } else {
      print("Error: Image or region not available");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(223, 240, 227, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(223, 240, 227, 1),
        title: const Center(
          child: Text(
            'Plant Disease Detection',
            style: TextStyle(
                fontFamily: 'SourceSans3',
                fontSize: 25,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: Colors.green),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.green),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          if (_isCameraMode && _controller != null && _controller!.value.isInitialized)
            Positioned.fill(
              child: CameraPreview(_controller!),
            )
          else if (_image != null)
            Positioned.fill(
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "gallery_button",
                  onPressed: _pickImageFromGallery,
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.photo_library,
                    color: Color.fromRGBO(223, 240, 227, 1),
                  ),
                ),
                SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: "capture_button",
                  onPressed: _takePhoto,
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.camera_alt,
                    color: Color.fromRGBO(223, 240, 227, 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }
}
