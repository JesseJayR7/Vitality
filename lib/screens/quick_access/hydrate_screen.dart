import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrate_repository/hydrate_repository.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:vitality/blocs/create_hydrate_bloc/create_hydrate_bloc.dart';

class HydrateScreen extends StatefulWidget {
  const HydrateScreen({Key? key}) : super(key: key);

  @override
  State<HydrateScreen> createState() => _HydrateScreenState();
}

class _HydrateScreenState extends State<HydrateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _waterMeasurementController = TextEditingController();
  String selectedWaterUnit = 'ml';
  final TextEditingController _dailyGoalController = TextEditingController();
  final TextEditingController _weeklyGoalController = TextEditingController();
  final TextEditingController _monthlyGoalController = TextEditingController();

  late CollectionReference<Map<String, dynamic>> _hydrateCollection;
  late DocumentReference<Map<String, dynamic>> _goalsDoc;

  List<_HydrateData> _dailyHydrates = [];
  List<_HydrateData> _weeklyHydrates = [];
  List<_HydrateData> _monthlyHydrates = [];

  final user = FirebaseAuth.instance.currentUser;
  int dailyGoal = 2000; // Default daily goal in ml
  int weeklyGoal = 14000; // Default weekly goal in ml
  int monthlyGoal = 60000; // Default monthly goal in ml

  @override
  void initState() {
    super.initState();
    hydrate1 = Hydrate.empty;
    _hydrateCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Hydrate');
    _goalsDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Goals')
        .doc('hydrateGoals');

    _fetchHydrateData();
    _fetchGoals();
  }

  late Hydrate hydrate1;

  Future<void> _addHydrate() async {
    hydrate1 = hydrate1.copyWith(
      waterMeasurment: double.parse(_waterMeasurementController.text),
      waterUnit: selectedWaterUnit
    );
    context.read<CreateHydrateBloc>().add(CreateHydrate(hydrate: hydrate1));

    _fetchHydrateData();
  }

  Future<void> _fetchHydrateData() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _hydrateCollection.get();
    Map<String, double> dailyHydratesMap = {};
    Map<String, double> weeklyHydratesMap = {};
    Map<String, double> monthlyHydratesMap = {};

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      DateTime timestamp = (data['timeStamp'] as Timestamp).toDate();
      double waterMeasurement = data['waterMeasurement'];
      String waterUnit = data['waterUnit'];

      // Convert oz to ml if necessary
      if (waterUnit == 'oz') {
        waterMeasurement *= 29.5735;
      }

      String timeKey = DateFormat('h:mm a').format(timestamp); // Format time for daily hydrates
      String weekKey = _weekDayName(timestamp.weekday);
      String monthKey = DateFormat('MMM').format(timestamp);

      // Aggregate daily hydrates
      if (_isToday(timestamp)) {
        dailyHydratesMap.update(
          timeKey,
          (value) => value + waterMeasurement,
          ifAbsent: () => waterMeasurement,
        );
      }

      // Aggregate weekly hydrates
      if (_isThisWeek(timestamp)) {
        weeklyHydratesMap.update(
          weekKey,
          (value) => value + waterMeasurement,
          ifAbsent: () => waterMeasurement,
        );
      }

      // Aggregate monthly hydrates
      if (_isThisMonth(timestamp)) {
        monthlyHydratesMap.update(
          monthKey,
          (value) => value + waterMeasurement,
          ifAbsent: () => waterMeasurement,
        );
      }
    }

    // Convert maps to lists of _HydrateData
    List<_HydrateData> dailyHydrates = dailyHydratesMap.entries
        .map((entry) => _HydrateData(
              entry.key,
              entry.value,
              DateFormat('h:mm a').parse(entry.key),
            ))
        .toList();
    List<_HydrateData> weeklyHydrates = weeklyHydratesMap.entries
        .map((entry) => _HydrateData(
              entry.key,
              entry.value,
              DateTime.now().add(Duration(days: _weekDayNumber(entry.key))),
            ))
        .toList();
    List<_HydrateData> monthlyHydrates = monthlyHydratesMap.entries
        .map((entry) => _HydrateData(
              entry.key,
              entry.value,
              DateFormat('MMM').parse(entry.key),
            ))
        .toList();

    setState(() {
      _dailyHydrates = dailyHydrates;
      _weeklyHydrates = weeklyHydrates;
      _monthlyHydrates = monthlyHydrates;
    });
  }

  int _weekDayNumber(String weekday) {
    const weekDays = {
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
    };
    return weekDays[weekday] ?? 0;
  }

  bool _isToday(DateTime date) {
    DateTime now = DateTime.now();
    return now.year == date.year && now.month == date.month && now.day == date.day;
  }

  bool _isThisWeek(DateTime date) {
    DateTime now = DateTime.now();
    int daysFromMonday = now.weekday - 1;
    DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromMonday));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  bool _isThisMonth(DateTime date) {
    DateTime now = DateTime.now();
    return now.year == date.year && now.month == date.month;
  }

  String _weekDayName(int weekday) {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekDays[weekday - 1];
  }

  Future<void> _fetchGoals() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _goalsDoc.get();
      if (doc.exists) {
        setState(() {
          dailyGoal = doc['dailyGoal'];
          weeklyGoal = doc['weeklyGoal'];
          monthlyGoal = doc['monthlyGoal'];
        });
      }
    } catch (e) {
      log('Error fetching goals: $e');
    }
  }

  Future<void> _setGoals() async {
    try {
      await _goalsDoc.set({
        'dailyGoal': dailyGoal,
        'weeklyGoal': weeklyGoal,
        'monthlyGoal': monthlyGoal,
      });
    } catch (e) {
      log('Error setting goals: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 120,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add,
                size: 35,
              ),
              onPressed: _showAddHydrateDialog,
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                size: 35,
              ),
              onPressed: _showSetGoalDialog,
            ),
          ],
          title: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: mediaQuery.width * 0.1,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  const TextSpan(
                    text: 'Hydr',
                  ),
                  TextSpan(
                    text: 'ate',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          bottom: TabBar(
            labelStyle: TextStyle(
              fontSize: mediaQuery.width * 0.05,
              color: Theme.of(context).colorScheme.primary,
            ),
            tabs: const [
              Tab(
                text: 'Daily',
              ),
              Tab(
                text: 'Weekly',
              ),
              Tab(
                text: 'Monthly',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDailyHydrateTab(),
            _buildWeeklyHydrateTab(),
            _buildMonthlyHydrateTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyHydrateTab() {
    double totalHydrate = _dailyHydrates.fold(0, (sum, hydrate) => sum + hydrate.waterMeasurement);
    double percent = totalHydrate / dailyGoal;
    var mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: mediaQuery.height * 0.03),
            Text(
              'Daily Statistics',
              style: TextStyle(
                fontSize: mediaQuery.width * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: mediaQuery.height * 0.03),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: CircularPercentIndicator(
                      radius: 150,
                      lineWidth: 15.0,
                      animation: true,
                      percent: percent > 1.0 ? 1.0 : percent,
                      center: Text(
                        '${(percent * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 24.0),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Goal: $dailyGoal ml',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Total: $totalHydrate ml',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildChart(_dailyHydrates),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyHydrateTab() {
    double totalHydrate = _weeklyHydrates.fold(0, (sum, hydrate) => sum + hydrate.waterMeasurement);
    double percent = totalHydrate / weeklyGoal;
    var mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: mediaQuery.height * 0.03),
            Text(
              'Weekly Statistics',
              style: TextStyle(
                fontSize: mediaQuery.width * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: mediaQuery.height * 0.03),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: CircularPercentIndicator(
                      radius: 150,
                      lineWidth: 15.0,
                      animation: true,
                      percent: percent > 1.0 ? 1.0 : percent,
                      center: Text(
                        '${(percent * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 24.0),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Goal: $weeklyGoal ml',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Total: $totalHydrate ml',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildChart(_weeklyHydrates),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyHydrateTab() {
    double totalHydrate = _monthlyHydrates.fold(0, (sum, hydrate) => sum + hydrate.waterMeasurement);
    double percent = totalHydrate / monthlyGoal;
    var mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: mediaQuery.height * 0.03),
            Text(
              'Monthly Statistics',
              style: TextStyle(
                fontSize: mediaQuery.width * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: mediaQuery.height * 0.03),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: CircularPercentIndicator(
                      radius: 150,
                      lineWidth: 15.0,
                      animation: true,
                      percent: percent > 1.0 ? 1.0 : percent,
                      center: Text(
                        '${(percent * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 24.0),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Goal: $monthlyGoal ml',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Total: $totalHydrate ml',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildChart(_monthlyHydrates),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<_HydrateData> hydrateData) {
 var mediaQuery = MediaQuery.of(context).size;
    return Container(
      height: 350,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
         legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    textStyle: TextStyle(
                      fontSize: mediaQuery.width * 0.045,
                    )),
        series: <ChartSeries<_HydrateData, String>>[
          ColumnSeries<_HydrateData, String>(
            name: 'ml of water drank',
            dataSource: hydrateData,
            xValueMapper: (_HydrateData hydrate, _) => hydrate.time,
            yValueMapper: (_HydrateData hydrate, _) => hydrate.waterMeasurement,
             dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                        fontSize: mediaQuery.width * 0.035,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  void _showAddHydrateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _waterMeasurementController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Water Measurement'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid measurement';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedWaterUnit,
                  items: <String>['ml', 'oz'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedWaterUnit = value!;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _addHydrate();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSetGoalDialog() {
    _dailyGoalController.text = dailyGoal.toString();
    _weeklyGoalController.text = weeklyGoal.toString();
    _monthlyGoalController.text = monthlyGoal.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _dailyGoalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Daily Goal (ml)'),
                onChanged: (value) {
                  setState(() {
                    dailyGoal = int.tryParse(value) ?? 0;
                  });
                },
              ),
              TextFormField(
                controller: _weeklyGoalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Weekly Goal (ml)'),
                onChanged: (value) {
                  setState(() {
                    weeklyGoal = int.tryParse(value) ?? 0;
                  });
                },
              ),
              TextFormField(
                controller: _monthlyGoalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Monthly Goal (ml)'),
                onChanged: (value) {
                  setState(() {
                    monthlyGoal = int.tryParse(value) ?? 0;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _setGoals();
                  Navigator.of(context).pop();
                },
                child: const Text('Set'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HydrateData {
  final String time;
  final double waterMeasurement;
  final DateTime timeStamp;

  _HydrateData(this.time, this.waterMeasurement, this.timeStamp);
}
