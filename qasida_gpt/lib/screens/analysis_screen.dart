import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/network_service.dart';

class PoemAnalysisScreen extends StatefulWidget {
  const PoemAnalysisScreen({super.key});

  @override
  PoemAnalysisScreenState createState() => PoemAnalysisScreenState();
}

class PoemAnalysisScreenState extends State<PoemAnalysisScreen> {
  final NetworkService _networkService = NetworkService();
  final TextEditingController _inputController = TextEditingController();
  String _analysisResult = '';
  bool _isAnalyzing = false;

  String prompt = 'أكتب قصيدة قصيرة';

  String _meter = '';

  String _overallSentiment = '';
  Map<String, double> _sentimentPercentages = {};

  int _verseCount = 0;

  String _emotionalTone = '';

  String _poemTheme = '';

  Map<String, int> _wordFrequency = {};

  String _classifiedTheme = '';

  String _analyzedRhyme = "";

  Future<void> _getRhymeAnalysis(String poem) async {
    try {
      final data = await _networkService.analyzeRhyme(poem);
      setState(() {
        _analyzedRhyme = data['rhyme'];
      });
    } catch (e) {
      // ... handle errors ...
    }
  }

  Future<void> _getThemeClassification(String poem) async {
    
    try {
      final data = await _networkService.classifyTheme(poem);

      setState(() {
        _classifiedTheme = data['theme'];
      });
    } catch (e) {
      // ... error handling ...
    }
  }

  Future<void> _analyzeWordFrequency(String poem) async {
    // 1. Tokenize the poem (split into words)
    List<String> words = poem.toLowerCase().split(RegExp(r'\s+'));

    // 2. Count word frequency
    Map<String, int> wordCounts = {};
    for (var word in words) {
      wordCounts[word] = (wordCounts[word] ?? 0) + 1;
    }

    // 3. Sort by frequency (descending)
    var sortedWordCounts = Map.fromEntries(
      wordCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    // 4. Take the top 5 and convert to Map
    setState(() {
      _wordFrequency = {
        for (var entry in sortedWordCounts.entries.take(5))
          entry.key: entry.value
      };
    });
  }

  Future<void> _getThemeAnalysis(String poem) async {
    try {
      final data =
          await _networkService.analyzeTheme(poem); 
      setState(() {
        _poemTheme = data['theme'];
      });
    } catch (e) {
      // ... Error handling ...
    }
  }

  Future<void> _getEmotionalToneAnalysis(String poem) async {
    try {
      final data = await _networkService
          .analyzeEmotionalTone(poem); 
      setState(() {
        _emotionalTone = data['emotional_tone'];
      });
    } catch (e) {
      // ... Error handling ...
    }
  }

  Future<void> analyzePoem(String poem) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final analysisResult =
          await _networkService.analyzePoem(poem);
      setState(() {
        _analysisResult = analysisResult;
      });
    } catch (e) {
      setState(() {
        _analysisResult = "Error: $e";
      });
    }

    // meter analysis
    try {
      final meterAnalysis = await _networkService.analyzeMeter(poem);
      setState(() {
        _meter = meterAnalysis['meter'];
      });
    } catch (e) {
      // ... error handling ...
    }

    //Theme classification
    _getThemeClassification(poem);

    //Sentiment analysis
    try {
      final data = await _networkService.analyzeSentiment(poem);
      setState(() {
        _overallSentiment = data['overall_sentiment'];
        _sentimentPercentages =
            Map<String, double>.from(data['sentiment_percentages']);
        _verseCount = data['verse_sentiments'].length;
      });
    } catch (e) {
      // Handle errors (e.g., display an error message)
      print('Error: $e');
    }

    //Rhyme analysis
    _getRhymeAnalysis(poem);

    //Word Frequency
    _analyzeWordFrequency(poem);

    //Emotional tone analysis
    _getEmotionalToneAnalysis(poem);

    //Theme analysis
    _getThemeAnalysis(poem);

    setState(() {
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QasidaGPT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: _buildPoemInput()),
            const SizedBox(width: 16.0),
            Expanded(flex: 1, child: _buildAnalysisResult()),
          ],
        ),
      ),
    );
  }

  Widget _buildPoemInput() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch, // Use stretch for full width buttons
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 8.0), // Add padding around title
          child: Text(
            'Write or Paste Your Poem:',
            style: Theme.of(context)
                .textTheme
                .titleLarge, 
          ),
        ),
        Expanded(
          child: TextField(
            controller: _inputController,
            maxLines: null,
            expands: true,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'اكتب قصيدتك هنا...',
              hintTextDirection: TextDirection.rtl,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
                  Colors.grey[200],
              contentPadding: const EdgeInsets.all(16),

          
            ),
            textAlignVertical: TextAlignVertical.top,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Space buttons evenly
            children: [
              Expanded(
                // Expand buttons to fill width
                child: ElevatedButton(
                  onPressed: _isAnalyzing
                      ? null
                      : () => analyzePoem(_inputController.text),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                        48), // Use fromHeight for consistent height
                    textStyle: Theme.of(context)
                        .textTheme
                        .labelLarge, // Use button text style
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Match border radius
                    ),
                  ),
                  child: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                
                child: OutlinedButton(
                  onPressed: () {
                    _inputController.clear();
                    setState(() {
                      _analysisResult =
                          'Analysis will be displayed here'; 
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48), // Consistent height
                    textStyle: Theme.of(context).textTheme.labelLarge,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Match border radius
                    ),
                  ),
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16), // Add bottom padding
      ],
    );
  }

  Widget _buildAnalysisResult() {
    if (_isAnalyzing) {
      return SpinKitFadingCircle(
        color: Theme.of(context).primaryColor,
      );
    } else if (_analysisResult.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Enter a poem to start analysis',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SpinKitWave(color: Colors.grey[400], size: 24),
        ],
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Cards take full width
          children: [
            // Meter Card
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: _buildAnalysisCard(
                    title: 'Meter Analysis',
                    content: Text('Meter: $_meter'),
                  ),
                ),

                const SizedBox(width: 16),

                // Verse Count Card
                Expanded(
                  child: _buildAnalysisCard(
                    title: 'Verse Count',
                    content: Text('Number of Verses: $_verseCount'),
                  ),
                ),
              ],
            ),

            Row(
              children: [
                //Rhyme analysis
                Expanded(
                  child: _buildAnalysisCard(
                    title: 'Rhyme Analysis',
                    content: Text(_analyzedRhyme),
                  ),
                ),

                const SizedBox(width: 16),

                // Theme Classification Card
                Expanded(
                  child: _buildAnalysisCard(
                    title: 'Theme Class',
                    content: Text(_classifiedTheme),
                  ),
                ),
              ],
            ),

            // Word Frequency Chart
            _buildAnalysisCard(
              title: 'Most Frequent Words',
              content: SizedBox(
                height: 250,
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(
                    labelPlacement:
                        LabelPlacement.onTicks, // Place labels on ticks
                    majorGridLines:
                        MajorGridLines(width: 0), // Remove grid lines
                    labelStyle: TextStyle(fontSize: 10), // Adjust font size
                  ),
                  primaryYAxis: const NumericAxis(
                    minimum: 0, // Start y-axis from 0
                    majorGridLines:
                        MajorGridLines(width: 0.5), // Thin grid lines
                  ),
                  plotAreaBorderWidth: 0, // Remove plot area border
                  title: const ChartTitle(
                    textStyle:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  series: <CartesianSeries<MapEntry<String, int>, String>>[
                    BarSeries<MapEntry<String, int>, String>(
                      dataSource: _wordFrequency.entries.toList(),
                      xValueMapper: (MapEntry<String, int> entry, _) =>
                          entry.key,
                      yValueMapper: (MapEntry<String, int> entry, _) =>
                          entry.value,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true, // Show data labels on bars
                        labelAlignment:
                            ChartDataLabelAlignment.outer, // Position labels
                      ),
                      color: Colors.blue[400], // Customize bar color
                    ),
                  ],
                  tooltipBehavior:
                      TooltipBehavior(enable: true), // Enable tooltips
                ),
              ),
            ),

            // Theme Card
            _buildAnalysisCard(
              title: 'Theme Analysis',
              content: Text(_poemTheme),
            ),

            // Sentiment Card

            _buildAnalysisCard(
              title: 'Sentiment Analysis',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Sentiment: $_overallSentiment',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    height: 200,
                    child: SfCircularChart(
                      legend: const Legend(
                        isVisible: true,
                        position: LegendPosition.right,
                        orientation: LegendItemOrientation.vertical,
                        textStyle: TextStyle(fontSize: 12),
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CircularSeries>[
                        PieSeries<MapEntry<String, double>, String>(
                          dataSource: _sentimentPercentages.entries.toList(),
                          xValueMapper: (MapEntry<String, double> data, _) =>
                              data.key.substring(0, 1).toUpperCase() +
                              data.key.substring(1),
                          yValueMapper: (MapEntry<String, double> data, _) =>
                              data.value,
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            textStyle: TextStyle(fontSize: 12),
                          ),
                          pointColorMapper: (MapEntry<String, double> data, _) {
                            switch (data.key) {
                              case 'positive':
                                return Colors.green[400];
                              case 'negative':
                                return Colors.red[400];
                              default:
                                return Colors.grey[400];
                            }
                          },
                          radius: '80%',
                          explode: true,
                          explodeIndex: _overallSentiment.toLowerCase() ==
                                  'positive'
                              ? 0
                              : _overallSentiment.toLowerCase() == 'negative'
                                  ? 1
                                  : 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Emotional Spectrum Card
            _buildAnalysisCard(
              title: 'Emotional Spectrum',
              content: Text(_emotionalTone),
            ),
            // Poem Analysis
            if (_analysisResult.isNotEmpty) ...[
              // Conditionally render
              _buildAnalysisCard(
                title: 'Poem Analysis',
                content: Text(_analysisResult),
              ),
            ],
            const SizedBox(height: 48), // Space at the bottom
          ],
        ),
      );
    }
  }

  // Helper function to build analysis cards
  Widget _buildAnalysisCard({required String title, required Widget content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              
            ),
            const SizedBox(height: 8.0),
            Directionality(
              // Use Directionality to control text direction
              textDirection: TextDirection.rtl,
              child: content, 
            ),
          ],
        ),
      ),
    );
  }
}
