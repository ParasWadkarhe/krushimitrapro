import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'news_page.dart';
import 'plants_screen.dart';
import '../Widgets/Crop_List.dart';
import 'Welcome.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<String> imgList = [
    'assets/img1.jpeg',
    'assets/img2.jpeg',
    'assets/img3.jpeg',
    'assets/img4.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(223, 240, 227, 1),
        title: const Center(
            child: Text(
          'Home Page',
          style: TextStyle(
              fontFamily: 'SourceSans3',
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.green),
        )),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(223, 240, 227, 1),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Text(
                  'Navigation Menu',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SourceSans3',
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.local_florist, color: Colors.green),
              title: Text('Plants', style: TextStyle(color: Colors.green)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Plant_Screen()),
                );
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.monetization_on_outlined, color: Colors.green),
              title: Text('Prices', style: TextStyle(color: Colors.green)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CommodityListPage()),
                );
              },
            ),
            ListTile(
              leading:
              Icon(Icons.article_outlined, color: Colors.green),
              title: Text('News', style: TextStyle(color: Colors.green)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewsPage()),
                );
              },
            ),
            const Divider(
                color: Colors.green,
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.green),
                  title: Text('Logout', style: TextStyle(color: Colors.green)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    );
                  },
                ),
              ],
            ),
            // Other menu items...
          ],
        ),
      ),
      body: Container(
        color: const Color.fromRGBO(223, 240, 227, 1),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Slideshow Carousel
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 250.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    autoPlayInterval: Duration(seconds: 3),
                  ),
                  items: imgList
                      .map((item) => Container(
                            child: Center(
                              child: Image.asset(item,
                                  fit: BoxFit.cover, width: 1000),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const Divider(
                color: Colors.green,
              ),
              // "What services we provide" section with animations
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What Services We Provide:',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    SizedBox(height: 10),

                    // Animated List of services
                    AnimationLimiter(
                      child: Column(
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 3000),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: widget,
                            ),
                          ),
                          children: [
                            serviceItem('1. Plant Care Guidance'),
                            serviceItem('2. Animal Husbandry Tips'),
                            serviceItem('3. Crop Price Monitoring'),
                            serviceItem('4. Market Price Forecasting'),
                            serviceItem('5. Expert Consultation'),
                            serviceItem('6. Local Statistic'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                color: Colors.green,
              ),

              // "Contact Us" section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Us:',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.green),
                        SizedBox(width: 10),
                        Text(
                          '+91 12345 67890',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.green),
                        SizedBox(width: 10),
                        Text(
                          'tanaynaphade35@gmail.com',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.green),
                        SizedBox(width: 10),
                        Text(
                          'Ravet, Pune, Maharashtra',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to return the animated service item
  Widget serviceItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
