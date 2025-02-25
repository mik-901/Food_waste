import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisPage extends StatefulWidget {
  final String username;
  final String rollNumber;

  const AnalysisPage({super.key, required this.username, required this.rollNumber});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  double totalWastage = 0;
  List<BarChartGroupData> barGroups = [];

  @override
  void initState() {
    super.initState();
    _fetchWasteData();
  }

  Future<void> _fetchWasteData() async {
    FirebaseFirestore.instance.collection('waste_logs').snapshots().listen((snapshot) {
      double total = 0;
      List<BarChartGroupData> tempBars = [];
      int index = 0;

      for (var doc in snapshot.docs) {
        double weight = (doc['weight'] as num).toDouble();
        total += weight;
        tempBars.add(BarChartGroupData(x: index, barRods: [BarChartRodData(toY: weight, color: Colors.blueAccent, width: 18)]));
        index++;
      }

      setState(() {
        totalWastage = total;
        barGroups = tempBars;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Waste Analysis'), backgroundColor: Colors.green),
      body: Column(
        children: [
          Text("Total Waste: ${totalWastage.toStringAsFixed(0)}g", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
          Expanded(child: BarChart(BarChartData(barGroups: barGroups, borderData: FlBorderData(show: false)))),
        ],
      ),
    );
  }
}





