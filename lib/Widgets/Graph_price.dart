import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class LineGraphPage extends StatelessWidget {
  final String commodity;
  final String city;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref('market_prices/Maharashtra');

  LineGraphPage({required this.commodity, required this.city});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$commodity Prices in $city')),
      body: StreamBuilder<DatabaseEvent>(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;
            List<Map<String, dynamic>> priceData = [];

            data.forEach((key, value) {
              if (value['Commodity'] == commodity && value['City'] == city) {
                priceData.add({
                  'date': value['Date'],
                  'modelPrice': double.parse(value['Model Price']),
                });
              }
            });

            // Sort data by date
            priceData.sort((a, b) {
              DateTime dateA = DateFormat('dd MMM yyyy').parse(a['date']);
              DateTime dateB = DateFormat('dd MMM yyyy').parse(b['date']);
              return dateA.compareTo(dateB);
            });

            // Convert sorted data to FlSpot
            List<FlSpot> spots = priceData.asMap().entries.map((entry) {
              int index = entry.key;
              return FlSpot(index.toDouble(), entry.value['modelPrice']);
            }).toList();

            // Extract list of dates for X-axis labels
            List dates = priceData.map((entry) => entry['date']).toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  minY: 2000,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index % 5 == 0 && index >= 0 && index < dates.length) {
                            DateTime date = DateFormat('dd MMM yyyy').parse(dates[index]);
                            return Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 50 == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                        interval: 50,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.lightBlue.withOpacity(0.2),
                      ),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 250),
              ),
            );
          }

          return Center(child: Text('No price data available'));
        },
      ),
    );
  }
}
