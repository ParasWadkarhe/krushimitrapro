import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Services/gemini_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';

class DiseaseInfoPage extends StatefulWidget {
  final int diseaseIndex;
  final String? location_;
  final DateTime? timestamp;
  static const List<String> diseaseNames = [
    'Tomato Late Blight',
    'Tomato healthy',
    'Grape healthy',
    'Orange Haunglongbing (Citrus greening)',
    'Soybean healthy',
    'Squash Powdery mildew',
    'Potato healthy',
    'Corn (maize) Northern Leaf Blight',
    'Tomato Early blight',
    'Tomato Septoria leaf spot',
    'Corn (maize) Cercospora leaf spot Gray leaf spot',
    'Strawberry Leaf scorch',
    'Peach healthy',
    'Apple Apple scab',
    'Tomato Tomato Yellow Leaf Curl Virus',
    'Tomato Bacterial spot',
    'Apple Black rot',
    'Blueberry healthy',
    'Cherry (including sour) Powdery mildew',
    'Peach Bacterial spot',
    'Apple Cedar apple rust',
    'Tomato Target Spot',
    'Pepper bell healthy',
    'Grape Leaf blight (Isariopsis Leaf Spot)',
    'Potato Late blight',
    'Tomato Tomato mosaic virus',
    'Strawberry healthy',
    'Apple healthy',
    'Grape Black rot',
    'Potato Early blight',
    'Cherry (including sour) healthy',
    'Corn (maize) Common rust',
    'Grape Esca (Black Measles)',
    'Raspberry healthy',
    'Tomato Leaf Mold',
    'Tomato Spider mites Two-spotted spider mite',
    'Pepper bell Bacterial spot',
    'Corn (maize) healthy'
  ];

  DiseaseInfoPage({
    required this.diseaseIndex,
    this.location_,
    this.timestamp,
  });

  @override
  _DiseaseInfoPageState createState() => _DiseaseInfoPageState();
}

class _DiseaseInfoPageState extends State<DiseaseInfoPage> {
  final TextEditingController _diseaseNameController = TextEditingController();
  final TextEditingController _cropNameController = TextEditingController();
  final GeminiService _geminiService = GeminiService();

  String _summary = '';
  List<String> _schedule = [];
  DateTime? _nextAppointment;

  Future<void> _fetchGeminiDetails(
      String diseaseName, DateTime? timestamp, String? location) async {
    try {
      final result = await _geminiService.fetchDiseaseDetails(
          diseaseName, timestamp, location);
      setState(() {
        _summary = result['summary'] as String;
        _schedule = List<String>.from(result['schedule']);
        _nextAppointment = result['nextAppointment'] as DateTime;
      });
    } catch (error) {
      setState(() {
        _summary = 'Failed to fetch data: $error';
        _schedule = [];
        _nextAppointment = null;
      });
    }
  }

  // ... previous imports and code remains the same until _saveAppointment function ...

  Future<void> _saveAppointment() async {
    if (_cropNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to save appointments')),
        );
        return;
      }

      final crop = _cropNameController.text;
      final docId =
          '${user.uid}_${crop.toLowerCase()}'; // Create unique ID for farmer-crop combination

      final appointmentData = {
        'timestamp': Timestamp.now(),
        'diseaseName': _diseaseNameController.text,
        'cropName': crop,
        'appointmentDate': _nextAppointment,
        'userId': user.uid, // Store user ID for reference
      };

      final docRef = FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId); // Using combined ID for document

      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final appointments =
            List<Map<String, dynamic>>.from(data['appointments'] ?? []);
        appointments.add(appointmentData);

        await docRef.update({
          'appointments': appointments,
          'lastUpdated': Timestamp.now(),
        });
      } else {
        await docRef.set({
          'userId': user.uid,
          'crop': crop,
          'appointments': [appointmentData],
          'createdAt': Timestamp.now(),
          'lastUpdated': Timestamp.now(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment saved successfully')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
      _cropNameController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving appointment: $e')),
      );
    }
  }

// ... rest of the code remains the same ...

  @override
  void initState() {
    super.initState();
    _diseaseNameController.text =
        DiseaseInfoPage.diseaseNames[widget.diseaseIndex];
    _fetchGeminiDetails(
        _diseaseNameController.text, widget.timestamp, widget.location_);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(223, 240, 227, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(223, 240, 227, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
            Text('Disease Information', style: TextStyle(color: Colors.green)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Input Section
            Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Disease Name:',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _diseaseNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter disease name',
                      ),
                    ),
                    if (_summary.isNotEmpty ||
                        _schedule.isNotEmpty ||
                        _nextAppointment != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            'Summary:',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _summary,
                            style: TextStyle(fontSize: 16, color: Colors.green),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Activity Schedule:',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          SizedBox(height: 10),
                          ..._schedule.map((s) => Text('- $s',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.green))),
                          SizedBox(height: 20),
                          if (_nextAppointment != null)
                            Text(
                              'Next Appointment: ${_nextAppointment!.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Appointment Section
            Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Schedule Appointment',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _cropNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Crop Name',
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _saveAppointment,
                      child: Text('Save Appointment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Disease Details Section
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('plant_disease_db')
                  .doc('${widget.diseaseIndex}')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('No information available'));
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;
                List<String> symptoms =
                    List<String>.from(data['symptoms'] ?? []);
                List<String> precautions =
                    List<String>.from(data['precautions'] ?? []);
                List<String> treatment =
                    List<String>.from(data['treatment'] ?? []);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Text(
                      'Disease: ${DiseaseInfoPage.diseaseNames[widget.diseaseIndex]}',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    SizedBox(height: 20),
                    _buildInfoCard('Symptoms', symptoms),
                    _buildInfoCard('Precautions', precautions),
                    _buildInfoCard('Treatment', treatment),
                  ],
                );
              },
            ),

            // Time and Location Section
            if (widget.timestamp != null || widget.location_ != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (widget.timestamp != null)
                      Text(
                        'Timestamp: ${widget.timestamp!.toLocal().toString()}',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    if (widget.location_ != null)
                      Text(
                        'Location: ${widget.location_}',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$title:',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            SizedBox(height: 10),
            ...items.map((item) => Text('- $item',
                style: TextStyle(fontSize: 16, color: Colors.green))),
          ],
        ),
      ),
    );
  }
}
