import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'controllers/navigation_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          NavigationController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QasidaGPT',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'QasidaGPT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Future<String?> getIbmAccessToken(String apiKey) async {
    // Define the URL for IBM Cloud Identity Token Service
    const String url = "https://iam.cloud.ibm.com/identity/token";

    // Define the headers
    final Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    };

    // Define the body (payload)
    final Map<String, String> body = {
      "grant_type": "urn:ibm:params:oauth:grant-type:apikey",
      "apikey": apiKey,
    };

    // Make the POST request
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the response body to extract the access token
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final String accessToken = jsonResponse['access_token'];
      print('Access Token: $accessToken');
      return accessToken;
    } else {
      // If the request failed, print the error
      print('Failed to get token. Status code: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationController = Provider.of<NavigationController>(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: navigationController.isNavigationRailExtended,
            selectedIndex: navigationController.selectedIndex,
            groupAlignment: -1.0,
            onDestinationSelected: (int index) {
              navigationController.onDestinationSelected(index);
            },
            leading: IconButton(
              onPressed: () {
                navigationController.toggleNavigationRail();
              },
              icon: const Icon(Icons.menu),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.create_outlined),
                selectedIcon: Icon(Icons.create),
                label: Text('Poem Generator'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Poem Analysis'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('Chat'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1.0, width: 1.0),
          Expanded(
            child: navigationController.buildCurrentScreen(),
          ),
        ],
      ),
    );
  }
}
