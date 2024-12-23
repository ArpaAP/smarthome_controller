import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:smarthome_controller/pages/connection.dart';
import 'package:smarthome_controller/pages/home.dart';
import 'package:smarthome_controller/pages/preferences.dart';

import 'firebase_options.dart';
import 'modules/socketio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // final remoteConfig = FirebaseRemoteConfig.instance;
  // await remoteConfig.setConfigSettings(RemoteConfigSettings(
  //   fetchTimeout: const Duration(minutes: 1),
  //   minimumFetchInterval: const Duration(hours: 1),
  // ));
  //
  // await remoteConfig.fetchAndActivate();

  SocketApi.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartHome Controller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          enableFeedback: true,
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        primaryColor: Colors.deepPurple,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color.fromRGBO(235, 232, 241, 1.0),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final pageController = PageController(initialPage: 0, keepPage: true);
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const HomePage(),
    const SizedBox(),
    const ConnectionPage(),
    const PreferencesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'SmartHome Controller',
          style: TextStyle(fontSize: 16),
        ),
        toolbarHeight: 48,
      ),
      body: Listener(
        onPointerDown: (_) {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.focusedChild?.unfocus();
          }
        },
        child: PageView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(
              decelerationRate: ScrollDecelerationRate.fast,
            ),
          ),
          controller: pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(
            () {
              _selectedIndex = index;
              pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutQuart,
              );
            },
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
            tooltip: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.memory),
            label: '어시스턴트',
            tooltip: '어시스턴트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi),
            label: '통신',
            tooltip: '통신',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
            tooltip: '설정',
          ),
        ],
      ),
    );
  }
}
