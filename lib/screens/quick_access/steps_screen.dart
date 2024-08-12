import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:steps_repository/steps_repository.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vitality/blocs/create_steps_bloc/create_steps_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _dailyGoalController = TextEditingController();
  final TextEditingController _weeklyGoalController = TextEditingController();
  final TextEditingController _monthlyGoalController = TextEditingController();

  late CollectionReference _stepsCollection;
  late DocumentReference _goalsDoc;
  
  List<_StepData> _dailySteps = [];
  List<_StepData> _weeklySteps = [];
  List<_StepData> _monthlySteps = [];

  final user = FirebaseAuth.instance.currentUser;
  int dailyGoal = 10000; // Default daily goal
  int weeklyGoal = 70000; // Default weekly goal
  int monthlyGoal = 300000; // Default monthly goal

  @override
  void initState() {
    super.initState();
    steps1 = Steps.empty;
    _stepsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Steps');
    _goalsDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Goals')
        .doc('stepsGoals');

    _fetchStepsData();
    _fetchGoals();
  }

  late Steps steps1;

  Future<void> _addSteps(int steps) async {
    steps1 = steps1.copyWith(
      steps: steps,
    );
    context.read<CreateStepsBloc>().add(CreateSteps(steps: steps1));
    _fetchStepsData();
  }

  Future<void> _fetchStepsData() async {
  QuerySnapshot querySnapshot = await _stepsCollection.get();
  Map<String, int> dailyStepsMap = {};
  Map<String, int> weeklyStepsMap = {};
  Map<String, int> monthlyStepsMap = {};

  for (var doc in querySnapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    DateTime timestamp = (data['timeStamp'] as Timestamp).toDate();
    int steps = data['steps'];

    String timeKey = DateFormat('h:mm a').format(timestamp); // Format time for daily steps
    String weekKey = _weekDayName(timestamp.weekday);
    String monthKey = DateFormat('MMM').format(timestamp);

    // Aggregate daily steps
    if (_isToday(timestamp)) {
      if (dailyStepsMap.containsKey(timeKey)) {
        dailyStepsMap[timeKey] = dailyStepsMap[timeKey]! + steps;
      } else {
        dailyStepsMap[timeKey] = steps;
      }
    }

    // Aggregate weekly steps
    if (_isThisWeek(timestamp)) {
      if (weeklyStepsMap.containsKey(weekKey)) {
        weeklyStepsMap[weekKey] = weeklyStepsMap[weekKey]! + steps;
      } else {
        weeklyStepsMap[weekKey] = steps;
      }
    }

    // Aggregate monthly steps
    if (_isThisMonth(timestamp)) {
      if (monthlyStepsMap.containsKey(monthKey)) {
        monthlyStepsMap[monthKey] = monthlyStepsMap[monthKey]! + steps;
      } else {
        monthlyStepsMap[monthKey] = steps;
      }
    }
  }

  // Convert maps to lists of _StepData
  List<_StepData> dailySteps = dailyStepsMap.entries
      .map((entry) => _StepData(entry.key, entry.value, DateFormat('h:mm a').parse(entry.key)))
      .toList();
  List<_StepData> weeklySteps = weeklyStepsMap.entries
      .map((entry) => _StepData(entry.key, entry.value, DateTime.now().add(Duration(days: _weekDayNumber(entry.key)))))
      .toList();
  List<_StepData> monthlySteps = monthlyStepsMap.entries
      .map((entry) => _StepData(entry.key, entry.value, DateFormat('MMM').parse(entry.key)))
      .toList();

  setState(() {
    _dailySteps = dailySteps;
    _weeklySteps = weeklySteps;
    _monthlySteps = monthlySteps;
  });
}

int _weekDayNumber(String weekday) {
  const weekDays = {'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6, 'Sun': 7};
  return weekDays[weekday] ?? 0;
}

  Future<void> _fetchGoals() async {
    try {
      DocumentSnapshot doc = await _goalsDoc.get();
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

  bool _isToday(DateTime date) {
  DateTime now = DateTime.now();
  return now.year == date.year &&
      now.month == date.month &&
      now.day == date.day;
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
              onPressed: _showAddStepsDialog,
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
                    text: 'St',
                  ),
                  TextSpan(
                    text: 'eps',
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
                text: 'Day',
              ),
              Tab(
                text: 'Week',
              ),
              Tab(
                text: 'Month',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent('Day', _dailySteps),
            _buildTabContent('Week', _weeklySteps),
            _buildTabContent('Month', _monthlySteps),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String period, List<_StepData> data) {
  var mediaQuery = MediaQuery.of(context).size;
  // ignore: avoid_types_as_parameter_names
  int totalSteps = data.fold(0, (sum, item) => sum + item.steps);
  int goal = 0;
  String goalPeriod = '';
  double percentage = 0.0;

  switch (period) {
    case 'Day':
      goal = dailyGoal;
      goalPeriod = 'day';
      percentage = totalSteps / dailyGoal;
      break;
    case 'Week':
      goal = weeklyGoal;
      goalPeriod = 'week';
      percentage = totalSteps / weeklyGoal;
      break;
    case 'Month':
      goal = monthlyGoal;
      goalPeriod = 'month';
      percentage = totalSteps / monthlyGoal;
      break;
  }

  return Center(
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$period Statistics',
            style: TextStyle(
              fontSize: mediaQuery.width * 0.08,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: mediaQuery.height * 0.03),
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 13.0,
            animation: true,
            percent: percentage.clamp(0.0, 1.0),
            center: Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: mediaQuery.width * 0.05,
              ),
            ),
            footer: Text(
              '$totalSteps steps\nGoal: $goal steps per $goalPeriod\n${goal - totalSteps <= 0 ? 'Steps Completed' : '${goal - totalSteps} steps left'}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: mediaQuery.width * 0.045,
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: mediaQuery.height * 0.03),
          _buildChart(data),
        ],
      ),
    ),
  );
}

Widget _buildChart(List<_StepData> data) {
  var mediaQuery = MediaQuery.of(context).size;
  if (data.isEmpty) {
    return const Text('No data available');
  }

  // Sort data by timestamp in ascending order
  data.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  return SizedBox(
    height: 300,
    child: SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      legend: Legend(isVisible: true, position: LegendPosition.bottom, textStyle: TextStyle(
                      fontSize: mediaQuery.width * 0.045,
                    ),),
      series: <ChartSeries<_StepData, String>>[
        ColumnSeries<_StepData, String>(
          dataSource: data.take(7).toList(),
          xValueMapper: (_StepData steps, _) => steps.period,
          yValueMapper: (_StepData steps, _) => steps.steps,
          color: Theme.of(context).colorScheme.primary,
          name: 'Steps Taken',          
          dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      fontSize: mediaQuery.width * 0.035,
                    ),
                  ),
        )
      ],
    ),
  );
}



  void _showAddStepsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Steps'),
          content: TextField(
            controller: _stepsController,
            decoration: const InputDecoration(hintText: 'Enter steps'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                int steps = int.parse(_stepsController.text);
                _addSteps(steps);
                _stepsController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
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
          title: const Text('Set Goals'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _dailyGoalController,
                decoration: const InputDecoration(labelText: 'Daily Goal'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: _weeklyGoalController,
                decoration: const InputDecoration(labelText: 'Weekly Goal'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: _monthlyGoalController,
                decoration: const InputDecoration(labelText: 'Monthly Goal'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  dailyGoal = int.parse(_dailyGoalController.text);
                  weeklyGoal = int.parse(_weeklyGoalController.text);
                  monthlyGoal = int.parse(_monthlyGoalController.text);
                });
                _setGoals();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _StepData {
  _StepData(this.period, this.steps, this.timestamp);

  final String period;
  final int steps;
  final DateTime timestamp;
}
