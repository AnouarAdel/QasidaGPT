import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkService {

  

  Future<String> generatePoem(Map<String, String?> parameters) async {
    final url = Uri.parse('http://localhost:5000/generate_poem');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(parameters),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['poem'];
    } else {
      // Handle errors appropriately (e.g., show an error message to the user)
      throw Exception('Failed to generate poem: ${response.statusCode}');
    }
  }

  Future<String> analyzePoem(String poem) async {
    final url = Uri.parse('http://localhost:5000/analyze_poem');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'poem': poem}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['analysis']; 
    } else {
      throw Exception('Failed to analyze poem: ${response.statusCode}');
    }
  }

  Future<String> getChatResponse(List<Map<String, dynamic>> messages) async {
    final url = Uri.parse('http://localhost:5000/generate_chat_response');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'messages': messages}), // Send the message history
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['response'];
    } else {
      throw Exception('Failed to get chat response: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> analyzeRhyme(String poem) async {
    final url = Uri.parse('http://localhost:5000/analyze_rhyme');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'poem': poem}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to analyze rhyme: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> classifyTheme(String poem) async {
    final url = Uri.parse('http://localhost:5000/classify_theme');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'poem': poem}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to classify theme: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> analyzeEmotionalTone(String poem) async {
    final url = Uri.parse('http://localhost:5000/analyze_emotional_tone');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'poem': poem}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      
      throw Exception(
          'Failed to analyze emotional tone: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> analyzeTheme(String poem) async {
    final url = Uri.parse('http://localhost:5000/analyze_theme');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'poem': poem}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to analyze theme: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> analyzeMeter(String poem) async {
    final response = await http.post(
      Uri.parse("http://localhost:5000/analyze_meter"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'poem': poem}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to analyze meter: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> analyzeSentiment(String poem) async {
    final url = Uri.parse('http://localhost:5000/analyze_sentiment');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'poem': poem}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      
      throw Exception('Failed to analyze sentiment: ${response.statusCode}');
    }
  }

  Future<void> resetConversation() async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/reset'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to reset conversation');
    }
  }
}
