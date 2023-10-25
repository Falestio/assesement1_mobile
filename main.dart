import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StockPage(),
    );
  }
}

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  var stockData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  _fetchData() async {
    final response = await http.get(
        Uri.parse('https://api.polygon.io/v2/aggs/ticker/F/range/1/day/2023-01-09/2023-02-09?adjusted=true&sort=asc&limit=120&apiKey=mDdo7rbkgwwXh9zAELJeLLACWGW3KPzX'));
    if (response.statusCode == 200) {
      setState(() {
        stockData = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kode Saham: ${stockData != null ? stockData['ticker'] : '...'}'),
            ElevatedButton(
              onPressed: _fetchData,
              child: Text('Refresh Data'),
            ),
            Expanded(
              child: stockData == null
                  ? Container()
                  : LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d), width: 1)),
                  minX: 0,
                  maxX: stockData['results'].length.toDouble(),
                  minY: stockData['results'][0]['h'],
                  maxY: stockData['results'].last['h'],
                  lineBarsData: [
                    LineChartBarData(
                      spots: stockData['results']
                          .map<FlSpot>((result) => FlSpot(
                          stockData['results'].indexOf(result).toDouble(),
                          result['h']))
                          .toList(),
                      isCurved: true,
                      // color: [Colors.cyan],
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
