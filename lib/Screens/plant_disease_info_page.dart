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

  const DiseaseInfoPage({
    required this.diseaseIndex,
    this.location_,
    this.timestamp,
  });

  @override
  _DiseaseInfoPageState createState() => _DiseaseInfoPageState();
}

class _DiseaseInfoPageState extends State<DiseaseInfoPage> {
  final TextEditingController _cropNameController = TextEditingController();
  final GeminiService _geminiService = GeminiService();

  int _currentView = 0; // 0: gemini, 1: disease info, 2: appointment
  String _diseaseName = '';
  String _summary = '';
  List<String> _schedule = [];
  DateTime? _nextAppointment;

  @override
  void initState() {
    super.initState();
    _diseaseName = DiseaseInfoPage.diseaseNames[widget.diseaseIndex];
    _fetchGeminiDetails(_diseaseName, widget.timestamp, widget.location_);
  }

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

  Future<void> _saveAppointment() async {
    if (_cropNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to save appointments')),
        );
        return;
      }

      final crop = _cropNameController.text;
      final docId = '${user.uid}_${crop.toLowerCase()}';

      final appointmentData = {
        'timestamp': Timestamp.now(),
        'diseaseName': _diseaseName,
        'cropName': crop,
        'appointmentDate': _nextAppointment,
        'userId': user.uid,
      };

      final docRef = FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId);

      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final appointments = List<Map<String, dynamic>>.from(data['appointments'] ?? []);
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
        const SnackBar(content: Text('Appointment saved successfully')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  HomeScreen()),
      );
      _cropNameController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving appointment: $e')),
      );
    }
  }

  void _toggleView() {
    setState(() {
      _currentView = (_currentView + 1) % 3;
    });
  }

  Widget _buildGeminiResponseCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_summary.isNotEmpty) ...[
                const Text(
                  'Summary:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _summary,
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
              ],
              if (_schedule.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Activity Schedule:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                ..._schedule.map(
                      (s) => Text(
                    '- $s',
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ),
              ],
              if (_nextAppointment != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Next Appointment: ${_nextAppointment!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentForm() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Schedule Appointment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Disease Name:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _diseaseName,
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cropNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Crop Name',
                labelStyle: TextStyle(color: Colors.green),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            if (_nextAppointment != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Next Appointment Date:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _nextAppointment!.toLocal().toString().split(' ')[0],
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Appointment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$title:',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            ...items.map(
                  (item) => Text(
                '- $item',
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseNameCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Disease Name:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _diseaseName,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(223, 240, 227, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(223, 240, 227, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Disease Information',
            style: TextStyle(color: Colors.green)
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: _toggleView,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Next'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildDiseaseNameCard(),
            if (_currentView == 0)
              _buildGeminiResponseCard()
            else if (_currentView == 1)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('plant_disease_db')
                    .doc('${widget.diseaseIndex}')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('No information available'));
                  }

                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  List<String> symptoms = List<String>.from(data['symptoms'] ?? []);
                  List<String> precautions = List<String>.from(data['precautions'] ?? []);
                  List<String> treatment = List<String>.from(data['treatment'] ?? []);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildInfoCard('Symptoms', symptoms),
                      _buildInfoCard('Precautions', precautions),
                      _buildInfoCard('Treatment', treatment),
                    ],
                  );
                },
              )
            else
              _buildAppointmentForm(),
          ],
        ),
      ),
    );
  }
}