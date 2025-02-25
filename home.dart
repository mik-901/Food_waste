import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Loginpage.dart';
import 'analysis.dart';
import 'contact.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String rollNumber;

  const HomePage({super.key, required this.username, required this.rollNumber});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _title = 'Home';
  DateTime _currentTime = DateTime.now();
  File? _image;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
        _updateTime();
      }
    });
  }

  Future<void> _addWastageData(String food, int weight) async {
    await FirebaseFirestore.instance.collection('waste_logs').add({
      'food_item': food,
      'weight': weight,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _showAddWastageDialog() {
    TextEditingController foodController = TextEditingController();
    TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Food Waste"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: foodController, decoration: const InputDecoration(labelText: "Food Item")),
            TextField(controller: weightController, decoration: const InputDecoration(labelText: "Weight (g)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (foodController.text.isNotEmpty && weightController.text.isNotEmpty) {
                _addWastageData(foodController.text, int.parse(weightController.text));
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      _buildHomeContent(),
      AnalysisPage(username: widget.username, rollNumber: widget.rollNumber),
      const ContactPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _title = ["Home", "Analysis", "Contact"][_selectedIndex];
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.contact_mail), label: 'Contact'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserCard(),
          const SizedBox(height: 20),
          _buildWastageSummary(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showAddWastageDialog,
            child: const Text("Log Food Waste"),
          ),
          const SizedBox(height: 20),
          _buildWasteLogs(),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("👋 Hi, ${widget.username}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Roll Number: ${widget.rollNumber}", style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildWastageSummary() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('waste_logs').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        var logs = snapshot.data!.docs;
        double totalWeight = logs.fold(0, (sum, log) => sum + (log['weight'] as num).toDouble());
        return Card(
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text("Total Food Wasted: ${totalWeight.toStringAsFixed(0)}g", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        );
      },
    );
  }

  Widget _buildWasteLogs() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('waste_logs').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        var logs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: logs.length,
          itemBuilder: (context, index) {
            var log = logs[index];
            return Card(
              child: ListTile(
                title: Text(log['food_item']),
                subtitle: Text("${log['weight']} grams"),
                trailing: Text(DateFormat('MMM dd, hh:mm a').format(log['timestamp'].toDate())),
              ),
            );
          },
        );
      },
    );
  }
}

