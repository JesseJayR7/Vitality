import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:meals_repository/meals_repository.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:vitality/blocs/create_meals_bloc/create_meals_bloc.dart';
import 'package:vitality/components/textfields.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _caloriesGainedController =
      TextEditingController();

  final TextEditingController _dailyGoalController = TextEditingController();
  final TextEditingController _weeklyGoalController = TextEditingController();
  final TextEditingController _monthlyGoalController = TextEditingController();

  late CollectionReference<Map<String, dynamic>> _mealCollection;
  late DocumentReference _goalsDoc;

  List<_MealData> _dailyMeals = [];
  List<_MealData> _weeklyMeals = [];
  List<_MealData> _monthlyMeals = [];

  final user = FirebaseAuth.instance.currentUser;
  int dailyGoal = 10000; // Default daily goal
  int weeklyGoal = 70000; // Default weekly goal
  int monthlyGoal = 300000; // Default monthly goal

  @override
  void initState() {
    super.initState();
    meals1 = Meals.empty;
    _mealCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Meals');
    _goalsDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Goals')
        .doc('mealsGoals');

    _fetchMealData();
    _fetchGoals();
  }

  late Meals meals1;

  Future<void> _addMeal(String mealName, double caloriesGained) async {
    meals1 = meals1.copyWith(
      caloriesGained: caloriesGained,
      mealName: mealName,
    );
    context.read<CreateMealsBloc>().add(CreateMeals(meals: meals1));

    _fetchMealData();
  }

  Future<void> _fetchMealData() async {
    QuerySnapshot querySnapshot = await _mealCollection.get();
    Map<String, double> dailyMealsMap = {};
    Map<String, double> weeklyMealsMap = {};
    Map<String, double> monthlyMealsMap = {};

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime timestamp = (data['timeStamp'] as Timestamp).toDate();
      double caloriesGained = data['caloriesGained'];

      String timeKey =
          DateFormat('h:mm a').format(timestamp); // Format time for daily meals
      String weekKey = _weekDayName(timestamp.weekday);
      String monthKey = DateFormat('MMM').format(timestamp);

      // Aggregate daily meals
      if (_isToday(timestamp)) {
        if (dailyMealsMap.containsKey(timeKey)) {
          dailyMealsMap[timeKey] = dailyMealsMap[timeKey]! + caloriesGained;
        } else {
          dailyMealsMap[timeKey] = caloriesGained;
        }
      }

      // Aggregate weekly meals
      if (_isThisWeek(timestamp)) {
        if (weeklyMealsMap.containsKey(weekKey)) {
          weeklyMealsMap[weekKey] = weeklyMealsMap[weekKey]! + caloriesGained;
        } else {
          weeklyMealsMap[weekKey] = caloriesGained;
        }
      }

      // Aggregate monthly meals
      if (_isThisMonth(timestamp)) {
        if (monthlyMealsMap.containsKey(monthKey)) {
          monthlyMealsMap[monthKey] =
              monthlyMealsMap[monthKey]! + caloriesGained;
        } else {
          monthlyMealsMap[monthKey] = caloriesGained;
        }
      }
    }

    // Convert maps to lists of _MealData
    List<_MealData> dailyMeals = dailyMealsMap.entries
        .map((entry) => _MealData(
            entry.key, entry.value, DateFormat('h:mm a').parse(entry.key)))
        .toList();
    List<_MealData> weeklyMeals = weeklyMealsMap.entries
        .map((entry) => _MealData(entry.key, entry.value,
            DateTime.now().add(Duration(days: _weekDayNumber(entry.key)))))
        .toList();
    List<_MealData> monthlyMeals = monthlyMealsMap.entries
        .map((entry) => _MealData(
            entry.key, entry.value, DateFormat('MMM').parse(entry.key)))
        .toList();

    setState(() {
      _dailyMeals = dailyMeals;
      _weeklyMeals = weeklyMeals;
      _monthlyMeals = monthlyMeals;
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
              onPressed: _showAddMealDialog,
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
                    text: 'Me',
                  ),
                  TextSpan(
                    text: 'als',
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
            _buildTabContent('Day', _dailyMeals),
            _buildTabContent('Week', _weeklyMeals),
            _buildTabContent('Month', _monthlyMeals),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String period, List<_MealData> data) {
    var mediaQuery = MediaQuery.of(context).size;
    double totalCalories =
        data.fold(0.0, (sum, item) => sum + item.caloriesGained);
    String goalPeriod = '';
    int goal = 0;
    double percentage = 0.0;

    switch (period) {
      case 'Day':
        goal = dailyGoal;
        percentage = totalCalories / dailyGoal;
        goalPeriod = 'day';
        break;
      case 'Week':
        goal = weeklyGoal;
        percentage = totalCalories / weeklyGoal;
        goalPeriod = 'week';
        break;
      case 'Month':
        goal = monthlyGoal;
        percentage = totalCalories / monthlyGoal;
        goalPeriod = 'month';
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
                '$totalCalories calories gained\nGoal: $goal calories per $goalPeriod\n${goal - totalCalories <= 0 ? 'Goal Achieved' : '${goal - totalCalories} more calories left to gain'}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: mediaQuery.width * 0.05,
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: mediaQuery.height * 0.03),
            Text(
              '$period Meals Chart',
              style: TextStyle(
                fontSize: mediaQuery.width * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: mediaQuery.height * 0.03),
            SizedBox(
              height: 270,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    textStyle: TextStyle(
                      fontSize: mediaQuery.width * 0.045,
                    )),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <ChartSeries<_MealData, String>>[
                  ColumnSeries<_MealData, String>(
                    dataSource: data.take(7).toList(),
                    xValueMapper: (_MealData meals, _) => meals.time,
                    yValueMapper: (_MealData meals, _) => meals.caloriesGained,
                    color: Theme.of(context).colorScheme.primary,
                    name: 'Calories Gained',
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

  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Meal'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LightTextFieldsText(
                  title: 'Meal Name',
                  controller: _mealNameController,
                  prefixIcon: const Icon(Icons.food_bank),
                ),
                LightTextFieldsNumber(
                  title: 'Calories Gained',
                  controller: _caloriesGainedController,
                  prefixIcon: const Icon(Icons.local_fire_department),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addMeal(_mealNameController.text,
                      double.parse(_caloriesGainedController.text));
                  _mealNameController.clear();
                  _caloriesGainedController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class _MealData {
  _MealData(this.time, this.caloriesGained, this.timestamp);

  final String time;
  final double caloriesGained;
  final DateTime timestamp;
}
