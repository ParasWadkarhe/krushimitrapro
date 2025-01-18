import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Graph_price.dart';

class CommodityListPage extends StatefulWidget {
  @override
  _CommodityListPageState createState() => _CommodityListPageState();
}

class _CommodityListPageState extends State<CommodityListPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref('market_prices/Maharashtra');

  List<String> cities = [];
  List<String> crops = [];
  String? selectedCity;
  String? selectedCrop;

  @override
  void initState() {
    super.initState();
    fetchCitiesAndCrops();
  }

  Future<void> fetchCitiesAndCrops() async {
    final event = await dbRef.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> data = event.snapshot.value as Map;

      setState(() {
        cities = data.values.map((entry) => entry['City'].toString()).toSet().toList();
        crops = data.values.map((entry) => entry['Commodity'].toString()).toSet().toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(223, 240, 227, 1),  // Set background color
      appBar: AppBar(
        title: Text('Select Crop and City'),
        backgroundColor: Colors.green,  // Set app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                hint: Text('Select City', style: TextStyle(color: Colors.green)),  // Set dropdown hint color
                value: selectedCity,
                onChanged: (value) {
                  setState(() {
                    selectedCity = value;
                  });
                },
                items: cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city, style: TextStyle(color: Colors.green)),  // Set dropdown item color
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              DropdownButton<String>(
                hint: Text('Select Crop', style: TextStyle(color: Colors.green)),  // Set dropdown hint color
                value: selectedCrop,
                onChanged: (value) {
                  setState(() {
                    selectedCrop = value;
                  });
                },
                items: crops.map((crop) {
                  return DropdownMenuItem(
                    value: crop,
                    child: Text(crop, style: TextStyle(color: Colors.green)),  // Set dropdown item color
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (selectedCity != null && selectedCrop != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LineGraphPage(
                          city: selectedCity!,
                          commodity: selectedCrop!,
                        ),
                      ),
                    );
                  }
                },
                child: Text('Show Graph', style: TextStyle(color: Colors.white)),  // Button text color
                style: ElevatedButton.styleFrom(foregroundColor: Colors.green),  // Set button background color
              ),
            ],
          ),
        ),
      ),
    );
  }
}
