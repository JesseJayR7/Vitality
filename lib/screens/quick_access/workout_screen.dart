// import 'dart:developer';

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:vitality/blocs/create_workout_bloc/create_workout_bloc.dart';
import 'package:vitality/components/textfields.dart';
import 'package:workout_repository/workout_repository.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _durationController = TextEditingController();
  final List<String> _workoutRegions = [];
  final TextEditingController _caloriesBurnedController =
      TextEditingController();

  late CollectionReference _workoutCollection;
  List<_WorkoutData> _dailyWorkouts = [];
  List<_WorkoutData> _weeklyWorkouts = [];
  List<_WorkoutData> _monthlyWorkouts = [];

  final TextEditingController _dailyGoalController = TextEditingController();
  final TextEditingController _weeklyGoalController = TextEditingController();
  final TextEditingController _monthlyGoalController = TextEditingController();

  int dailyGoal = 10000; // Default daily goal
  int weeklyGoal = 70000; // Default weekly goal
  int monthlyGoal = 300000; // Default monthly goal

  final user = FirebaseAuth.instance.currentUser;

  late DocumentReference _goalsDoc;

  @override
  void initState() {
    super.initState();
    workout1 = Workout.empty;
    _workoutCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Workout');
    _goalsDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Goals')
        .doc('workoutGoals');

    _fetchWorkoutData();
    _fetchGoals();
  }

  late Workout workout1;

  Future<void> _addWorkout(List<String> workoutRegions, String duration,
      double caloriesBurned) async {
    workout1 = workout1.copyWith(
      caloriesBurned: caloriesBurned,
      duration: duration,
      workoutRegions: workoutRegions,
    );
    context.read<CreateWorkoutBloc>().add(CreateWorkout(workout: workout1));
    _fetchWorkoutData();
  }

  Future<void> _fetchWorkoutData() async {
    QuerySnapshot querySnapshot = await _workoutCollection.get();
    Map<String, double> dailyWorkoutsMap = {};
    Map<String, double> weeklyWorkoutsMap = {};
    Map<String, double> monthlyWorkoutsMap = {};

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime timestamp = (data['timeStamp'] as Timestamp).toDate();
      double caloriesBurned = data['caloriesBurned'];

      String timeKey = DateFormat('h:mm a')
          .format(timestamp); // Format time for daily workouts
      String weekKey = _weekDayName(timestamp.weekday);
      String monthKey = DateFormat('MMM').format(timestamp);

      // Aggregate daily workouts
      if (_isToday(timestamp)) {
        if (dailyWorkoutsMap.containsKey(timeKey)) {
          dailyWorkoutsMap[timeKey] =
              dailyWorkoutsMap[timeKey]! + caloriesBurned;
        } else {
          dailyWorkoutsMap[timeKey] = caloriesBurned;
        }
      }

      // Aggregate weekly workouts
      if (_isThisWeek(timestamp)) {
        if (weeklyWorkoutsMap.containsKey(weekKey)) {
          weeklyWorkoutsMap[weekKey] =
              weeklyWorkoutsMap[weekKey]! + caloriesBurned;
        } else {
          weeklyWorkoutsMap[weekKey] = caloriesBurned;
        }
      }

      // Aggregate monthly workouts
      if (_isThisMonth(timestamp)) {
        if (monthlyWorkoutsMap.containsKey(monthKey)) {
          monthlyWorkoutsMap[monthKey] =
              monthlyWorkoutsMap[monthKey]! + caloriesBurned;
        } else {
          monthlyWorkoutsMap[monthKey] = caloriesBurned;
        }
      }
    }

    // Convert maps to lists of _WorkoutData
    List<_WorkoutData> dailyWorkouts = dailyWorkoutsMap.entries
        .map((entry) => _WorkoutData(
            entry.key, entry.value, DateFormat('h:mm a').parse(entry.key)))
        .toList();
    List<_WorkoutData> weeklyWorkouts = weeklyWorkoutsMap.entries
        .map((entry) => _WorkoutData(entry.key, entry.value,
            DateTime.now().add(Duration(days: _weekDayNumber(entry.key)))))
        .toList();
    List<_WorkoutData> monthlyWorkouts = monthlyWorkoutsMap.entries
        .map((entry) => _WorkoutData(
            entry.key, entry.value, DateFormat('MMM').parse(entry.key)))
        .toList();

    setState(() {
      _dailyWorkouts = dailyWorkouts;
      _weeklyWorkouts = weeklyWorkouts;
      _monthlyWorkouts = monthlyWorkouts;
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
      'Sun': 7
    };
    return weekDays[weekday] ?? 0;
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
    DateTime startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysFromMonday));
    DateTime endOfWeek = startOfWeek
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    return date.isAfter(startOfWeek) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
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
              onPressed: _showAddWorkoutDialog,
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
                    text: 'Wo',
                  ),
                  TextSpan(
                    text: 'rkouts',
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
            _buildTabContent('Day', _dailyWorkouts),
            _buildTabContent('Week', _weeklyWorkouts),
            _buildTabContent('Month', _monthlyWorkouts),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String period, List<_WorkoutData> data) {
    var mediaQuery = MediaQuery.of(context).size;
    // ignore: avoid_types_as_parameter_names
    double totalCalories =
        data.fold(0.0, (sum, item) => sum + item.caloriesBurned);
    String goalPeriod = '';
  int goal = 0;
  double percentage = 0.0;

    switch (period) {
      case 'Day':
        goal = dailyGoal;
        goalPeriod = 'day';
        percentage = totalCalories / dailyGoal;
        break;
      case 'Week':
        goal = weeklyGoal;
        goalPeriod = 'week';
        percentage = totalCalories / weeklyGoal;
        break;
      case 'Month':
        goal = monthlyGoal;
        goalPeriod = 'month';
        percentage = totalCalories / monthlyGoal;
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
                '$totalCalories calories burned\nGoal: $goal calories per $goalPeriod\n${goal - totalCalories <= 0 ? 'Goal Achieved' : '${goal - totalCalories} more calories left to burn'}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: mediaQuery.width * 0.05,
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.blue,
            ),
            SizedBox(height: mediaQuery.height * 0.05),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: TextStyle(
                    fontSize: mediaQuery.width * 0.03,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: TextStyle(
                    fontSize: mediaQuery.width * 0.03,
                  ),
                ),
                title: ChartTitle(
                  text: 'Workout Progress - $period',
                  textStyle: TextStyle(
                    fontSize: mediaQuery.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  textStyle: TextStyle(
                    fontSize: mediaQuery.width * 0.045,
                  ),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <ChartSeries<_WorkoutData, String>>[
                  ColumnSeries<_WorkoutData, String>(
                    dataSource: data.take(7).toList(),
                    xValueMapper: (_WorkoutData workout, _) => workout.timeKey,
                    yValueMapper: (_WorkoutData workout, _) =>
                        workout.caloriesBurned,
                    name: 'Calories Burned',
                    color: Colors.blue,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                        fontSize: mediaQuery.width * 0.035,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
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


  void _showAddWorkoutDialog() {
    var mediaQuery = MediaQuery.of(context).size;
    List<String> availableRegions = [
      'Abs',
      'Chest',
      'Legs',
      'Arms',
      'Back',
      'Cardio'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add Workout',
                style: TextStyle(
                  fontSize: mediaQuery.width * 0.06,
                ),
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LightTextFieldsTime(
                        title: 'Duration',
                        controller: _durationController,
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      SizedBox(height: mediaQuery.height * 0.02),
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: availableRegions.map((region) {
                          bool isSelected = _workoutRegions.contains(region);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _workoutRegions.remove(region);
                                } else {
                                  _workoutRegions.add(region);
                                }
                              });
                            },
                            child: Container(
                              width: mediaQuery.width * 0.3,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[300]!,
                                  width: isSelected ? 3.0 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  region,
                                  style: TextStyle(
                                    fontSize: mediaQuery.width * 0.045,
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: mediaQuery.height * 0.02),
                      LightTextFieldsNumber(
                          title: 'Calories Burned',
                          controller: _caloriesBurnedController,
                          prefixIcon: const Icon(Icons.local_fire_department)),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: mediaQuery.width * 0.05,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_workoutRegions.isNotEmpty) {
                        _addWorkout(
                            _workoutRegions,
                            _durationController.text,
                            double.tryParse(_caloriesBurnedController.text) ??
                                0.0);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 5),
                            content: Text(
                              'Workout recorded',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.surface),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 5),
                            content: Text(
                              'Select a workout region',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.surface),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: mediaQuery.width * 0.05,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _WorkoutData {
  final String timeKey;
  final double caloriesBurned;
  final DateTime dateTime;

  _WorkoutData(this.timeKey, this.caloriesBurned, this.dateTime);
}
