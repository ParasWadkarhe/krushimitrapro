import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Please login to view appointments'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color.fromRGBO(223, 240, 227, 1),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
        
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
        
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No appointments found'));
            }
        
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final appointments = List<Map<String, dynamic>>.from(data['appointments'] ?? []);
        
                if (appointments.isEmpty) return SizedBox.shrink();
        
                // Sort appointments by timestamp
                appointments.sort((a, b) => (a['timestamp'] as Timestamp)
                    .compareTo(b['timestamp'] as Timestamp));
        
                // Get the first (oldest) and latest appointment dates
                final firstAppointmentTimestamp = appointments.first['timestamp'] as Timestamp;
                final latestAppointmentDate = appointments.last['appointmentDate'] as Timestamp;
        
                // Calculate days since first appointment
                final daysSinceFirst = DateTime.now()
                    .difference(firstAppointmentTimestamp.toDate())
                    .inDays;
        
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.spa,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      data['crop'] ?? 'Unknown Crop',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          'Started ${daysSinceFirst} days ago',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          'Next appointment: ${DateFormat('MMM dd, yyyy').format(latestAppointmentDate.toDate())}',
                          style: TextStyle(color: Colors.green),
                        ),
                        Text(
                          'Total appointments: ${appointments.length}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$daysSinceFirst days',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'monitoring',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Show detailed view of appointments
                      _showAppointmentDetails(context, data['crop'], appointments);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAppointmentDetails(
      BuildContext context,
      String cropName,
      List<Map<String, dynamic>> appointments,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appointment History for $cropName',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final timestamp = (appointment['timestamp'] as Timestamp).toDate();
                    final appointmentDate = (appointment['appointmentDate'] as Timestamp).toDate();

                    return Card(
                      child: ListTile(
                        title: Text(
                          appointment['diseaseName'] ?? 'Unknown Disease',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Created: ${DateFormat('MMM dd, yyyy').format(timestamp)}'),
                            Text('Appointment: ${DateFormat('MMM dd, yyyy').format(appointmentDate)}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}