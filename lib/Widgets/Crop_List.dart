import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Graph_price.dart';

class CommodityListPage extends StatefulWidget {
  @override
  _CommodityListPageState createState() => _CommodityListPageState();
}

class _CommodityListPageState extends State<CommodityListPage> {
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref('market_prices/Maharashtra');
  List<String> cities = [];
  List<Map<String, dynamic>> cropItems = [
    {'name': 'Rice', 'icon': Icons.grass},
    {'name': 'Wheat', 'icon': Icons.agriculture},
    {'name': 'Cotton', 'icon': Icons.inventory_2},
    {'name': 'Corn', 'icon': Icons.eco},
  ];
  String? selectedCity;
  String? selectedCrop;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    final event = await dbRef.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> data = event.snapshot.value as Map;
      setState(() {
        cities = data.values
            .map((entry) => entry['City'].toString())
            .toSet()
            .toList();
      });
    }
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    bool isSelected = selectedCrop == crop['name'];
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCrop = crop['name'];
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              crop['icon'],
              size: 40,
              color: isSelected ? Colors.green : Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              crop['name'],
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      backgroundColor: Color.fromRGBO(223, 240, 227, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: Text('Select City',
                        style: TextStyle(color: Colors.grey)),
                    value: selectedCity,
                    isExpanded: true,
                    icon: Icon(Icons.location_city, color: Colors.green),
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value;
                      });
                    },
                    items: cities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Select Crop',
                style: TextStyle(
                  fontSize: 18,
                  //fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children:
                      cropItems.map((crop) => _buildCropCard(crop)).toList(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedCity != null && selectedCrop != null
                    ? () {
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
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff2a9134), // Light green color
                  // or you could use: Colors.lightGreen
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Show Graph',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
