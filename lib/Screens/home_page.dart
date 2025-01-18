import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'Appointment.dart';
import 'Myth_Screen.dart';
import 'news_page.dart';
import 'plants_screen.dart';
import '../Widgets/Crop_List.dart';

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

  final _pageController = PageController(initialPage: 0);
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pages for bottom navigation bar
    final List<Widget> bottomBarPages = [
      HomePage(),
      CommodityListPage(),
      Plant_Screen(),
      NewsPage(),
      AppointmentPage(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: false,
      appBar: AppBar(
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: bottomBarPages,
      ),
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Colors.white,
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: const Color.fromRGBO(223, 240, 227, 1),
        removeMargins: false,
        bottomBarWidth: 500,
        showShadow: true,
        durationInMilliSeconds: 300,
        itemLabelStyle: const TextStyle(fontSize: 12),
        elevation: 1,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(Icons.home_outlined, color: Color(0xff2a9134)),
            activeItem: Icon(Icons.home, color: Color(0xff137547)),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem:
                Icon(Icons.monetization_on_outlined, color: Color(0xff2a9134)),
            activeItem:
                Icon(Icons.monetization_on_outlined, color: Color(0xff137547)),
            itemLabel: 'Prices',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.local_florist, color: Color(0xff2a9134)),
            activeItem: Icon(Icons.local_florist, color: Color(0xff137547)),
            itemLabel: 'Plants',
          ),
          BottomBarItem(
            inActiveItem:
                Icon(Icons.article_outlined, color: Color(0xff2a9134)),
            activeItem: Icon(Icons.article_outlined, color: Color(0xff137547)),
            itemLabel: 'News',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.access_alarm, color: Color(0xff2a9134)),
            activeItem: Icon(Icons.access_alarm, color: Color(0xff137547)),
            itemLabel: 'Schedule',
          ),
        ],
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
        kIconSize: 24.0,
      ),
    );
  }
}

// Home page content
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final services = [
      'Plant Care Guidance',
      'Crop Price Monitoring',
      'Market Price Forecasting',
      'News Letters',
      'Local Statistics',
      'Disease Pridiction'
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Slideshow Carousel
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 300.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayInterval: Duration(seconds: 3),
              ),
              items: [
                'assets/img1.jpeg',
                'assets/img2.jpeg',
                'assets/img3.jpeg',
                'assets/img4.jpeg',
              ].map((item) {
                return Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Image.asset(item, fit: BoxFit.cover, width: 1000 ,height: 250),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(color: Color(0xff137547)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What is our aim:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 150, // Adjust card height
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return serviceCard(services[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xff137547)),
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
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 150, // Adjust card height
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return serviceCard(services[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget serviceCard(String text) {
    return Container(
      width: 200, // Adjust card width
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Color(0xffe6f5ec),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
