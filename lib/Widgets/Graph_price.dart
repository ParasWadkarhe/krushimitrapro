import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class LineGraphPage extends StatefulWidget {
  final String commodity;
  final String city;

  LineGraphPage({required this.commodity, required this.city});

  @override
  _LineGraphPageState createState() => _LineGraphPageState();
}

class _LineGraphPageState extends State<LineGraphPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref('market_prices/Maharashtra');
  DateTime? selectedDate;
  List<DateTime> availableDates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.commodity} Prices in ${widget.city}')),
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

            // Collect all data points
            data.forEach((key, value) {
              if (value['Commodity'] == widget.commodity && value['City'] == widget.city) {
                DateTime date = DateFormat('dd MMM yyyy').parse(value['Date']);
                priceData.add({
                  'date': date,
                  'dateStr': value['Date'],
                  'modelPrice': double.parse(value['Model Price']),
                });
              }
            });

            // Sort data by date
            priceData.sort((a, b) => a['date'].compareTo(b['date']));

            // Create a set of unique dates using dateStr for comparison
            Set<String> uniqueDateStrs = {};
            List<Map<String, dynamic>> uniquePriceData = [];

            // Keep only the first occurrence of each date
            for (var entry in priceData) {
              String dateStr = DateFormat('dd MMM yyyy').format(entry['date']);
              if (!uniqueDateStrs.contains(dateStr)) {
                uniqueDateStrs.add(dateStr);
                uniquePriceData.add(entry);
              }
            }

            // Update available dates with unique dates
            availableDates = uniquePriceData.map((e) => e['date'] as DateTime).toList();

            // Set initial selected date if not set
            selectedDate ??= availableDates.first;

            // Filter data from selected date to today
            List<Map<String, dynamic>> filteredData = uniquePriceData
                .where((entry) => entry['date'].isAfter(selectedDate!) ||
                entry['date'].isAtSameMomentAs(selectedDate!))
                .toList();

            // Convert filtered data to FlSpot
            List<FlSpot> spots = filteredData.asMap().entries.map((entry) {
              int index = entry.key;
              return FlSpot(index.toDouble(), entry.value['modelPrice']);
            }).toList();

            // Calculate statistics for filtered data
            double maxPrice = filteredData.map((e) => e['modelPrice']).reduce((a, b) => a > b ? a : b);
            double minPrice = filteredData.map((e) => e['modelPrice']).reduce((a, b) => a < b ? a : b);
            double priceVariation = maxPrice - minPrice;
            double avgPrice = filteredData.map((e) => e['modelPrice']).reduce((a, b) => a + b) / filteredData.length;

            // Calculate overall average (including all dates)
            double overallAvg = uniquePriceData.map((e) => e['modelPrice']).reduce((a, b) => a + b) / uniquePriceData.length;

            return Column(
              children: [
                // Date selector
                Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: availableDates.length,
                    itemBuilder: (context, index) {
                      DateTime date = availableDates[index];
                      bool isSelected = selectedDate?.isAtSameMomentAs(date) ?? false;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            DateFormat('dd MMM').format(date),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Chart
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 2.4,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 3000, // Set fixed maximum value for Y axis
                        minY: 0,    // Set minimum value to 0
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '₹${rod.toY.toStringAsFixed(2)}\n',
                                const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index % 5 == 0 && index >= 0 && index < filteredData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat('dd/MM').format(filteredData[index]['date']),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                // Show intervals of 500 for better readability
                                if (value % 500 == 0) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: 500, // Add gridlines at 500 intervals
                        ),
                        borderData: FlBorderData(show: true),
                        barGroups: spots.map((spot) {
                          return BarChartGroupData(
                            x: spot.x.toInt(),
                            barRods: [
                              BarChartRodData(
                                toY: spot.y,
                                color: Color(0xff137547),
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: overallAvg,
                              color: Colors.red.withOpacity(0.8),
                              strokeWidth: 2,
                              dashArray: [5, 5],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.topRight,
                                padding: const EdgeInsets.only(right: 5, bottom: 5),
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                labelResolver: (line) => 'Avg: ₹${overallAvg.toStringAsFixed(2)}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Statistics card
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Statistics (${DateFormat('dd MMM yyyy').format(selectedDate!)} - Today)',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Average',
                              '₹${avgPrice.toStringAsFixed(2)}',
                              Icons.analytics,
                              Colors.blue,
                            ),
                            _buildStatItem(
                              'Maximum',
                              '₹${maxPrice.toStringAsFixed(2)}',
                              Icons.arrow_upward,
                              Colors.green,
                            ),
                            _buildStatItem(
                              'Minimum',
                              '₹${minPrice.toStringAsFixed(2)}',
                              Icons.arrow_downward,
                              Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Price Variation',
                              '₹${priceVariation.toStringAsFixed(2)}',
                              Icons.compare_arrows,
                              Colors.orange,
                            ),
                            _buildStatItem(
                              'Overall Average',
                              '₹${overallAvg.toStringAsFixed(2)}',
                              Icons.timeline,
                              Colors.purple,
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(child: Text('No price data available'));
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}