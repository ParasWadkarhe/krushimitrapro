import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:krushimitra/Screens/Welcome.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final List<Widget> bottomBarPages = [
      HomePage(),
      CommodityListPage(),
      Plant_Screen(),
      NewsPage(),
      AppointmentPage(),
    ];

    return Scaffold(
      extendBody: false,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: bottomBarPages,
        ),
      ),
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Colors.white,
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: const Color(0xff2a9134),
        removeMargins: false,
        bottomBarWidth: 500,
        showShadow: true,
        durationInMilliSeconds: 300,
        itemLabelStyle: const TextStyle(fontSize: 12),
        elevation: 1,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: FaIcon(
              FontAwesomeIcons.house,
              color: Color(0xff137547),
            ),
            activeItem: FaIcon(
              FontAwesomeIcons.houseChimney,
              color: Colors.white,
            ),
          ),
          BottomBarItem(
            inActiveItem: FaIcon(
              FontAwesomeIcons.moneyBill,
              color: Color(0xff137547),
            ),
            activeItem: FaIcon(
              FontAwesomeIcons.moneyBill,
              color: Colors.white,
            ),
          ),
          BottomBarItem(
            inActiveItem: FaIcon(
              FontAwesomeIcons.leaf,
              color: Color(0xff137547),
            ),
            activeItem: FaIcon(
              FontAwesomeIcons.leaf,
              color: Colors.white,
            ),
          ),
          BottomBarItem(
            inActiveItem: FaIcon(
              FontAwesomeIcons.newspaper,
              color: Color(0xff137547),
            ),
            activeItem: FaIcon(
              FontAwesomeIcons.newspaper,
              color: Colors.white,
            ),
          ),
          BottomBarItem(
            inActiveItem: FaIcon(
              FontAwesomeIcons.clock,
              color: Color(0xff137547),
            ),
            activeItem: FaIcon(
              FontAwesomeIcons.clock,
              color: Colors.white,
            ),
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

class HomePage extends StatelessWidget {
  final List<String> services = [
    'Plant Care Guidance',
    'Crop Price Monitoring',
    'Market Price Forecasting',
    'News Letters',
    'Local Statistics',
    'Disease Prediction',
  ];
  final List<String> imgList = [
    'assets/2.png',
    'assets/3.png',
    'assets/4.png',
    'assets/5.png',
  ];
  final List<IconData> serviceIcons = [
    FontAwesomeIcons.seedling,
    FontAwesomeIcons.moneyBillTrendUp,
    FontAwesomeIcons.chartLine,
    FontAwesomeIcons.envelopeOpenText,
    FontAwesomeIcons.chartArea,
    FontAwesomeIcons.virus,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 40),
                    Text("Hi,", style: TextStyle(fontSize: 50)),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Farmer", style: TextStyle(fontSize: 50)),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    );
                  },
                  icon: const Icon(FontAwesomeIcons.signOut),
                  iconSize: 40,
                ),
              ),
            ],
          ),

          // Slideshow Carousel
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 300.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayInterval: const Duration(seconds: 3),
              ),
              items: imgList.map((item) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Image.asset(
                      item,
                      fit: BoxFit.cover,
                      width: 1200,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: const Divider(color: Colors.grey),
          ),

          // Services Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Our Services:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return serviceCard(services[index], serviceIcons[index]);
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: const Divider(color: Colors.grey),
                ),
                const Text(
                  'Visit our website for more statistics :',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  child: TextButton(
                      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xff137547))),
                      onPressed: () {
                        launchUrl(Uri.parse('https://krushimitra-six.vercel.app/'));
                      },
                      child: Text(
                        "Krushi-Mitra.org",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget serviceCard(String text, IconData icon) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xffe6f5ec),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Color(0xff137547)),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
