import 'dart:math';
import 'dart:developer' as dev;

import 'package:chat_repository/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hydrate_repository/hydrate_repository.dart';
import 'package:intl/intl.dart';
import 'package:meals_repository/meals_repository.dart';
import 'package:steps_repository/steps_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:vitality/blocs/create_hydrate_bloc/create_hydrate_bloc.dart';
import 'package:vitality/blocs/create_meals_bloc/create_meals_bloc.dart';
import 'package:vitality/blocs/create_steps_bloc/create_steps_bloc.dart';
import 'package:vitality/blocs/create_workout_bloc/create_workout_bloc.dart';
import 'package:vitality/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:vitality/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:vitality/components/button.dart';
import 'package:vitality/components/cards.dart';
import 'package:vitality/components/textfields.dart';
import 'package:vitality/components/weight_height_picker.dart';
import 'package:vitality/screens/quick_access/hydrate_screen.dart';
import 'package:vitality/screens/quick_access/meals_screen.dart';
import 'package:vitality/screens/quick_access/steps_screen.dart';
import 'package:vitality/screens/quick_access/workout_screen.dart';
import 'package:workout_repository/workout_repository.dart';

class HomeScreen extends StatefulWidget {
  final String apiKey;
  const HomeScreen({super.key, required this.apiKey});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _vitalityUser = FirebaseFirestore.instance.collection('Users');
  int _selectedIndex = 0;

  final user = FirebaseAuth.instance.currentUser;

  late CollectionReference _stepsCollection;
  List<_StepData> _dailySteps = [];
  List<_StepData> _weeklySteps = [];
  List<_StepData> _monthlySteps = [];
  List<_StepData> _totalSteps = [];

  List<String> workoutQuotes = [
    "The only bad workout is the one that didn’t happen.",
    "Sweat is just fat crying.",
    "No pain, no gain.",
    "Push yourself because no one else is going to do it for you.",
    "Success starts with self-discipline.",
    "The body achieves what the mind believes.",
    "Wake up with determination, go to bed with satisfaction.",
    "You don’t have to be great to start, but you have to start to be great.",
    "Don’t stop until you’re proud.",
    "Your body can stand almost anything. It’s your mind that you have to convince.",
    "Excuses don’t burn calories.",
    "The pain you feel today will be the strength you feel tomorrow.",
    "When you feel like quitting, think about why you started.",
    "The difference between try and triumph is a little 'umph'.",
    "Strive for progress, not perfection.",
    "Fitness is not about being better than someone else, it’s about being better than you used to be."
  ];

  String getRandomQuote() {
    final random = Random();
    int index = random.nextInt(workoutQuotes.length);
    return workoutQuotes[index];
  }

  late String randomQuote;

  final TextEditingController _addStepsController = TextEditingController();

  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _caloriesGainedController =
      TextEditingController();

  final TextEditingController _durationController = TextEditingController();
  final List<String> _workoutRegions = [];
  final TextEditingController _caloriesBurnedController =
      TextEditingController();

  late CollectionReference<Map<String, dynamic>> _mealCollection;
  late CollectionReference _workoutCollection;
  late CollectionReference<Map<String, dynamic>> _hydrateCollection;
  final TextEditingController _waterMeasurementController =
      TextEditingController();
  List<_WorkoutData> _dailyWorkouts = [];

  List<Workout2> _dailyDetailedWorkouts = [];
  List<Workout2> _weeklyDetailedWorkouts = [];
  List<Workout2> _monthlyDetailedWorkouts = [];
  List<Workout2> _totalDetailedWorkouts = [];

  List<Meal> _dailyDetailedMeals = [];
  List<Meal> _weeklyDetailedMeals = [];
  List<Meal> _monthlyDetailedMeals = [];
  List<Meal> _totalDetailedMeals = [];

  List<_MealData> _dailyMeals = [];

  List<_HydrateData> _dailyHydrates = [];
  List<_HydrateData> _weeklyHydrates = [];
  List<_HydrateData> _monthlyHydrates = [];
  List<_HydrateData> _totalHydrates = [];

  int stepsDailyGoal = 10000;
  int stepsWeeklyGoal = 10000;
  int stepsMonthlyGoal = 10000;

  int workoutDailyGoal = 10000;
  int workoutWeeklyGoal = 10000;
  int workoutMonthlyGoal = 10000;

  int mealsDailyGoal = 10000;
  int mealsWeeklyGoal = 10000;
  int mealsMonthlyGoal = 10000;

  int hydrateDailyGoal = 10000;
  int hydrateWeeklyGoal = 10000;
  int hydrateMonthlyGoal = 10000;

  String selectedWaterUnit = 'ml';

  late final apiKey;

  late Chats chat1;

  FocusNode myFocusNode = FocusNode();

  late Stream<List<Map<String, dynamic>>> _messagesStream;

  String _chatName = 'New Chat';

  List<String> _chatList = [];

  Future fetchAndProcessChats() async {
    try {
      // Fetch documents from the 'Chats' collection
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Chats')
          .orderBy("chatName", descending: true)
          .get();

      // Process each document
      for (var doc in snapshot.docs) {
        // Access document data
        var data = doc.data();
        if (!_chatList.contains(data['chatName'])) {
          _chatList.add(data['chatName']);
        }
      }
    } catch (e) {
      // Handle errors
      dev.log('Error fetching chats: $e');
    }
  }

  Future fetchAndProcessSpecificChatHistory(String chatName) async {
    try {
      // Fetch documents from the 'Chats' collection
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Chats')
          .where("chatName", isEqualTo: chatName)
          .orderBy('timeStamp', descending: false)
          .get();

      // Process documents into a list of formatted strings
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return '${data['type']}: ${data['text']}'; // Format each message
      }).toList();
    } catch (e) {
      // Handle errors
      dev.log('Error fetching chats: $e');
    }
  }

  ChatUser? currentUser, otherUser;

  // Fetch the full chat history
  List chatHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeModel();

    currentUser = ChatUser(
      id: 'userId',
      firstName: 'You',
    );

    otherUser = ChatUser(
        id: 'botId',
        firstName: 'Bot',
        profileImage:
            'https://static.vecteezy.com/system/resources/previews/004/261/144/large_2x/woman-meditating-in-nature-and-leaves-concept-illustration-for-yoga-meditation-relax-recreation-healthy-lifestyle-illustration-in-flat-cartoon-style-free-vector.jpg');

    _messagesStream = getMessages(_chatName);
    fetchAndProcessChats();

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
            const Duration(milliseconds: 500),
            () => WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    scrollDown();
                  }
                }));
      }
    });

    chat1 = Chats.empty;

    _getCurrentLocation().then((value) {
      lat = '${value.latitude}';
      long = '${value.longitude}';
      setState(() {
        locationMessage = 'Latitude: $lat , Longitude: $long';
      });
      _liveLocation();
    });
    workout1 = Workout.empty;
    meals1 = Meals.empty;
    steps1 = Steps.empty;
    hydrate1 = Hydrate.empty;

    randomQuote = getRandomQuote();
    _stepsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Steps');
    _workoutCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Workout');
    _mealCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Meals');
    _hydrateCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Hydrate');

    _fetchStepsData();
    _fetchWorkoutData();
    _fetchDetailedWorkoutData();
    _fetchMealData();
    _fetchDetailedMealData();
    _fetchHydrateData();

    _fetchGoals();
  }

  @override
  void dispose() {
    // _scrollController.dispose();
    myFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  Future<void> addMessage(Map<String, dynamic> messageData) async {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Chats')
        .add(messageData);
  }

  Stream<List<Map<String, dynamic>>> getMessages(String chatName) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Chats')
        .where("chatName", isEqualTo: chatName)
        .orderBy('timeStamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> _fetchGoals() async {
    try {
      //
      // Steps
      //

      DocumentSnapshot stepsDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Goals')
          .doc('stepsGoals')
          .get();
      if (stepsDoc.exists) {
        setState(() {
          stepsDailyGoal = stepsDoc['dailyGoal'];
          stepsWeeklyGoal = stepsDoc['weeklyGoal'];
          stepsMonthlyGoal = stepsDoc['monthlyGoal'];
        });
      }

      //
      // Workout
      //

      DocumentSnapshot workoutDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Goals')
          .doc('workoutGoals')
          .get();
      if (workoutDoc.exists) {
        setState(() {
          workoutDailyGoal = workoutDoc['dailyGoal'];
          workoutWeeklyGoal = workoutDoc['weeklyGoal'];
          workoutMonthlyGoal = workoutDoc['monthlyGoal'];
        });
      }

      //
      // Meals
      //
      DocumentSnapshot mealsDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Goals')
          .doc('mealsGoals')
          .get();
      if (mealsDoc.exists) {
        setState(() {
          mealsDailyGoal = mealsDoc['dailyGoal'];
          mealsWeeklyGoal = mealsDoc['weeklyGoal'];
          mealsMonthlyGoal = mealsDoc['monthlyGoal'];
        });
      }

      //
      // Hydrate
      //
      DocumentSnapshot hydrateDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Goals')
          .doc('hydrateGoals')
          .get();
      if (hydrateDoc.exists) {
        setState(() {
          hydrateDailyGoal = hydrateDoc['dailyGoal'];
          hydrateWeeklyGoal = hydrateDoc['weeklyGoal'];
          hydrateMonthlyGoal = hydrateDoc['monthlyGoal'];
        });
      }
    } catch (e) {
      dev.log('Error fetching goals: $e');
    }
  }

  late Workout workout1;
  late Meals meals1;
  late Steps steps1;

  Future<void> _fetchStepsData() async {
    QuerySnapshot querySnapshot = await _stepsCollection.get();
    Map<String, int> dailyStepsMap = {};
    Map<String, int> weeklyStepsMap = {};
    Map<String, int> monthlyStepsMap = {};
    Map<String, int> totalStepsMap = {};

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime timestamp = (data['timeStamp'] as Timestamp).toDate();
      int steps = data['steps'];

      String timeKey =
          DateFormat('h:mm a').format(timestamp); // Format time for daily steps
      String weekKey = _weekDayName(timestamp.weekday);
      String monthKey = DateFormat('MMM').format(timestamp);
      String totalKey = DateFormat('MMM yyyy').format(timestamp);

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

      totalStepsMap.update(
        totalKey,
        (value) => value + steps,
        ifAbsent: () => steps,
      );
    }

    // Convert maps to lists of _StepData
    List<_StepData> dailySteps = dailyStepsMap.entries
        .map((entry) => _StepData(
            entry.key, entry.value, DateFormat('h:mm a').parse(entry.key)))
        .toList();
    List<_StepData> weeklySteps = weeklyStepsMap.entries
        .map((entry) => _StepData(entry.key, entry.value,
            DateTime.now().add(Duration(days: _weekDayNumber(entry.key)))))
        .toList();
    List<_StepData> monthlySteps = monthlyStepsMap.entries
        .map((entry) => _StepData(
            entry.key, entry.value, DateFormat('MMM').parse(entry.key)))
        .toList();
    List<_StepData> totalSteps = totalStepsMap.entries
        .map((entry) => _StepData(
            entry.key, entry.value, DateFormat('MMM yyyy').parse(entry.key)))
        .toList();

    setState(() {
      _dailySteps = dailySteps;
      _weeklySteps = weeklySteps;
      _monthlySteps = monthlySteps;
      _totalSteps = totalSteps;
    });
  }

  Future<void> _fetchWorkoutData() async {
    QuerySnapshot querySnapshot = await _workoutCollection.get();
    Map<String, double> dailyWorkoutsMap = {};

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime timestamp = (data['timeStamp'] as Timestamp).toDate();
      double caloriesBurned = data['caloriesBurned'];

      String timeKey = DateFormat('h:mm a')
          .format(timestamp); // Format time for daily workouts

      // Aggregate daily workouts
      if (_isToday(timestamp)) {
        if (dailyWorkoutsMap.containsKey(timeKey)) {
          dailyWorkoutsMap[timeKey] =
              dailyWorkoutsMap[timeKey]! + caloriesBurned;
        } else {
          dailyWorkoutsMap[timeKey] = caloriesBurned;
        }
      }
    }

    // Convert maps to lists of _WorkoutData
    List<_WorkoutData> dailyWorkouts = dailyWorkoutsMap.entries
        .map((entry) => _WorkoutData(
            entry.key, entry.value, DateFormat('h:mm a').parse(entry.key)))
        .toList();
    setState(() {
      _dailyWorkouts = dailyWorkouts;
    });
  }

  Future<void> _fetchDetailedWorkoutData() async {
    QuerySnapshot querySnapshot = await _workoutCollection.get();
    List<Workout2> dailyWorkouts = [];
    List<Workout2> weeklyWorkouts = [];
    List<Workout2> monthlyWorkouts = [];
    List<Workout2> totalWorkouts = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime timestamp = (data['timeStamp'] as Timestamp).toDate();
      double caloriesBurned = data['caloriesBurned'];
      String name = data['workoutRegions'].join(', ');
      String duration = data['duration'];

      // Aggregate daily workouts
      if (_isToday(timestamp)) {
        dailyWorkouts.add(Workout2(
          name: name,
          duration: duration,
          caloriesBurned: caloriesBurned,
          timestamp: timestamp,
        ));
      }

      // Aggregate weekly workouts
      if (_isThisWeek(timestamp)) {
        weeklyWorkouts.add(Workout2(
          name: name,
          duration: duration,
          caloriesBurned: caloriesBurned,
          timestamp: timestamp,
        ));
      }

      // Aggregate monthly workouts
      if (_isThisMonth(timestamp)) {
        monthlyWorkouts.add(Workout2(
          name: name,
          duration: duration,
          caloriesBurned: caloriesBurned,
          timestamp: timestamp,
        ));
      }

      totalWorkouts.add(Workout2(
        name: name,
        duration: duration,
        caloriesBurned: caloriesBurned,
        timestamp: timestamp,
      ));
    }

    setState(() {
      _dailyDetailedWorkouts = dailyWorkouts;
      _weeklyDetailedWorkouts = weeklyWorkouts;
      _monthlyDetailedWorkouts = monthlyWorkouts;
      _totalDetailedWorkouts = totalWorkouts;
    });
  }

  Future<void> _fetchMealData() async {
    QuerySnapshot querySnapshot = await _mealCollection.get();
    Map<String, double> dailyMealsMap = {};

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime timestamp = (data['timeStamp'] as Timestamp).toDate();
      double caloriesGained = data['caloriesGained'];

      String timeKey =
          DateFormat('h:mm a').format(timestamp); // Format time for daily meals

      // Aggregate daily meals
      if (_isToday(timestamp)) {
        if (dailyMealsMap.containsKey(timeKey)) {
          dailyMealsMap[timeKey] = dailyMealsMap[timeKey]! + caloriesGained;
        } else {
          dailyMealsMap[timeKey] = caloriesGained;
        }
      }
    }

    // Convert maps to lists of _MealData
    List<_MealData> dailyMeals = dailyMealsMap.entries
        .map((entry) => _MealData(
            entry.key, entry.value, DateFormat('h:mm a').parse(entry.key)))
        .toList();
    setState(() {
      _dailyMeals = dailyMeals;
    });
  }

  Future<void> _fetchDetailedMealData() async {
    QuerySnapshot querySnapshot = await _mealCollection.get();
    List<Meal> dailyMeals = [];
    List<Meal> weeklyMeals = [];
    List<Meal> monthlyMeals = [];
    List<Meal> totalMeals = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime timestamp = (data['timeStamp'] as Timestamp).toDate();
      double calories = data['caloriesGained'];
      String name = data['mealName'];

      // Aggregate daily meals
      if (_isToday(timestamp)) {
        dailyMeals.add(Meal(
          name: name,
          calories: calories,
          timestamp: timestamp,
        ));
      }

      // Aggregate weekly meals
      if (_isThisWeek(timestamp)) {
        weeklyMeals.add(Meal(
          name: name,
          calories: calories,
          timestamp: timestamp,
        ));
      }

      // Aggregate monthly meals
      if (_isThisMonth(timestamp)) {
        monthlyMeals.add(Meal(
          name: name,
          calories: calories,
          timestamp: timestamp,
        ));
      }

      totalMeals.add(Meal(
        name: name,
        calories: calories,
        timestamp: timestamp,
      ));
    }

    setState(() {
      _dailyDetailedMeals = dailyMeals;
      _weeklyDetailedMeals = weeklyMeals;
      _monthlyDetailedMeals = monthlyMeals;
      _totalDetailedMeals = totalMeals;
    });
  }

  Future<void> _fetchHydrateData() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _hydrateCollection.get();
    Map<String, double> dailyHydratesMap = {};
    Map<String, double> weeklyHydratesMap = {};
    Map<String, double> monthlyHydratesMap = {};
    Map<String, double> totalHydratesMap = {};

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      DateTime timestamp = (data['timeStamp'] as Timestamp).toDate();
      double waterMeasurement = data['waterMeasurement'];
      String waterUnit = data['waterUnit'];

      // Convert oz to ml if necessary
      if (waterUnit == 'oz') {
        waterMeasurement *= 29.5735;
      }

      String timeKey = DateFormat('h:mm a')
          .format(timestamp); // Format time for daily hydrates
      String weekKey = _weekDayName(timestamp.weekday);
      String monthKey = DateFormat('MMM').format(timestamp);
      String totalKey = DateFormat('MMM yyyy').format(timestamp);

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

      totalHydratesMap.update(
        totalKey,
        (value) => value + waterMeasurement,
        ifAbsent: () => waterMeasurement,
      );
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
    List<_HydrateData> totalHydrates = totalHydratesMap.entries
        .map((entry) => _HydrateData(
              entry.key,
              entry.value,
              DateFormat('MMM yyyy').parse(entry.key),
            ))
        .toList();

    setState(() {
      _dailyHydrates = dailyHydrates;
      _weeklyHydrates = weeklyHydrates;
      _monthlyHydrates = monthlyHydrates;
      _totalHydrates = totalHydrates;
    });
  }

  bool _isToday(DateTime date) {
    DateTime now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
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

  double convertLbsToKg(double weightLbs) {
    return weightLbs / 2.20462;
  }

  double calculateCaloriesPerStep(double weight, String unit) {
    double weightKg = unit == 'lbs' ? convertLbsToKg(weight) : weight;
    return 0.57 * weightKg * 0.0005;
  }

  double calculateTotalCaloriesBurned(int steps, double weight, String unit,
      double workoutCaloriesBurned, double mealCalouriesGained) {
    double caloriesPerStep = calculateCaloriesPerStep(weight, unit);
    return (steps * caloriesPerStep) +
        workoutCaloriesBurned -
        mealCalouriesGained;
  }

  double convertCmToMeters(double heightCm) {
    return heightCm / 100.0;
  }

  double convertInchesToMeters(double heightInches) {
    return heightInches * 0.0254;
  }

  double calculateStrideLength(double height, String unit, String gender) {
    double heightMeters;
    if (unit == 'cm') {
      heightMeters = convertCmToMeters(height);
    } else if (unit == 'inches') {
      heightMeters = convertInchesToMeters(height);
    } else {
      heightMeters = height; // Assuming height is already in meters
    }

    double strideLengthFactor = (gender == 'female') ? 0.415 : 0.413;
    return heightMeters * strideLengthFactor;
  }

  double calculateTotalDistance(
      int steps, double height, String unit, String gender) {
    double strideLength = calculateStrideLength(height, unit, gender);
    return steps * strideLength;
  }

  bool isWeightHeightExpanded = false;

  double _weight = 68.0;
  double _height = 172.0;

  String _weightUnit = 'kg';
  String _heightUnit = 'cm';

  final double _minWeightKg = 40.0;
  final double _maxWeightKg = 150.0;
  final double _minWeightLbs = 88.0;
  final double _maxWeightLbs = 330.0;
  final double _minHeightCm = 100.0;
  final double _maxHeightCm = 220.0;
  final double _minHeightIn = 39.4;
  final double _maxHeightIn = 86.6;

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKeyChatName = GlobalKey<FormState>();

  late Hydrate hydrate1;

  Future<void> _addSteps() async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          var mediaQuery = MediaQuery.of(context).size;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * (3 / 100),
                    left: MediaQuery.of(context).size.width * (5 / 100),
                    right: MediaQuery.of(context).size.width * (5 / 100),
                    bottom: MediaQuery.of(ctx).viewInsets.bottom +
                        MediaQuery.of(context).size.height * (3 / 100)),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    LightTextFieldsNumber(
                        title: 'Add Steps',
                        controller: _addStepsController,
                        prefixIcon: const Icon(Icons.directions_walk)),
                    SizedBox(
                      height: mediaQuery.height * 0.03,
                    ),
                    SizedBox(
                        width: mediaQuery.width,
                        child: LightPrimaryShortButton(
                            onPress: () {
                              steps1 = steps1.copyWith(
                                steps: int.parse(_addStepsController.text),
                              );
                              context
                                  .read<CreateStepsBloc>()
                                  .add(CreateSteps(steps: steps1));
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 5),
                                  content: Text(
                                    'Steps added',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        fontSize: mediaQuery.width * 0.045),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              );
                            },
                            title: 'Add Steps')),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _addWorkout() async {
    List<String> availableRegions = [
      'Abs',
      'Chest',
      'Legs',
      'Arms',
      'Back',
      'Cardio'
    ];
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          var mediaQuery = MediaQuery.of(context).size;
          return BlocProvider(
            create: (context) => CreateWorkoutBloc(
                workoutRepository: FirebaseWorkoutRepository()),
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * (3 / 100),
                        left: MediaQuery.of(context).size.width * (5 / 100),
                        right: MediaQuery.of(context).size.width * (5 / 100),
                        bottom: MediaQuery.of(ctx).viewInsets.bottom +
                            MediaQuery.of(context).size.height * (3 / 100)),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
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
                              bool isSelected =
                                  _workoutRegions.contains(region);
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
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
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
                              prefixIcon:
                                  const Icon(Icons.local_fire_department)),
                          SizedBox(
                            height: mediaQuery.height * 0.03,
                          ),
                          SizedBox(
                              width: mediaQuery.width,
                              child: LightPrimaryShortButton(
                                  onPress: () {
                                    if (_formKey.currentState!.validate()) {
                                      if (_workoutRegions.isNotEmpty) {
                                        workout1 = workout1.copyWith(
                                          caloriesBurned: double.tryParse(
                                                  _caloriesBurnedController
                                                      .text) ??
                                              0.0,
                                          duration: _durationController.text,
                                          workoutRegions: _workoutRegions,
                                        );
                                        context.read<CreateWorkoutBloc>().add(
                                            CreateWorkout(workout: workout1));

                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            duration:
                                                const Duration(seconds: 5),
                                            content: Text(
                                              'Workout added',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surface,
                                                  fontSize:
                                                      mediaQuery.width * 0.045),
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            duration:
                                                const Duration(seconds: 5),
                                            content: Text(
                                              'Select a workout region',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surface),
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  title: 'Add Workout')),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        });
  }

  Future<void> _addMeal() async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          var mediaQuery = MediaQuery.of(context).size;
          return BlocProvider(
            create: (context) =>
                CreateMealsBloc(mealsRepository: FirebaseMealsRepository()),
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * (3 / 100),
                        left: MediaQuery.of(context).size.width * (5 / 100),
                        right: MediaQuery.of(context).size.width * (5 / 100),
                        bottom: MediaQuery.of(ctx).viewInsets.bottom +
                            MediaQuery.of(context).size.height * (3 / 100)),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
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
                          SizedBox(
                            height: mediaQuery.height * 0.03,
                          ),
                          SizedBox(
                              width: mediaQuery.width,
                              child: LightPrimaryShortButton(
                                  onPress: () {
                                    if (_formKey.currentState!.validate()) {
                                      meals1 = meals1.copyWith(
                                        caloriesGained: double.parse(
                                            _caloriesGainedController.text),
                                        mealName: _mealNameController.text,
                                      );
                                      context
                                          .read<CreateMealsBloc>()
                                          .add(CreateMeals(meals: meals1));

                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 5),
                                          content: Text(
                                            'Meal added',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                                fontSize:
                                                    mediaQuery.width * 0.045),
                                          ),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  title: 'Add Meal')),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        });
  }

  Future<void> _addHydrate() async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          var mediaQuery = MediaQuery.of(context).size;
          return BlocProvider(
            create: (context) => CreateHydrateBloc(
                hydrateRepository: FirebaseHydrateRepository()),
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * (3 / 100),
                        left: MediaQuery.of(context).size.width * (5 / 100),
                        right: MediaQuery.of(context).size.width * (5 / 100),
                        bottom: MediaQuery.of(ctx).viewInsets.bottom +
                            MediaQuery.of(context).size.height * (3 / 100)),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          TextFormField(
                            controller: _waterMeasurementController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Water Measurement'),
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
                          SizedBox(
                            height: mediaQuery.height * 0.03,
                          ),
                          SizedBox(
                              width: mediaQuery.width,
                              child: LightPrimaryShortButton(
                                  onPress: () {
                                    if (_formKey.currentState!.validate()) {
                                      hydrate1 = hydrate1.copyWith(
                                          waterMeasurment: double.parse(
                                              _waterMeasurementController.text),
                                          waterUnit: selectedWaterUnit);
                                      context.read<CreateHydrateBloc>().add(
                                          CreateHydrate(hydrate: hydrate1));

                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 5),
                                          content: Text(
                                            'Water added',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                                fontSize:
                                                    mediaQuery.width * 0.045),
                                          ),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  title: 'Add Water')),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        });
  }

  Widget _buildDailyActivitySummary(BuildContext context, MyUserState state) {
    int totalSteps = _dailySteps.fold(0, (sum, item) => sum + item.steps);
    double totalWorkout =
        _dailyWorkouts.fold(0, (sum, item) => sum + item.caloriesBurned);
    double totalMeals =
        _dailyMeals.fold(0, (sum, item) => sum + item.caloriesGained);
    var mediaQuery = MediaQuery.of(context).size;
    double totalCaloriesBurned = calculateTotalCaloriesBurned(
        totalSteps,
        state.user!.weightValue,
        state.user!.weightUnit,
        totalWorkout,
        totalMeals);
    double totalDistance = calculateTotalDistance(totalSteps,
        state.user!.heightValue, state.user!.heightUnit, state.user!.gender);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Daily Activity Summary',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: mediaQuery.width * 0.06,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: mediaQuery.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActivityItem(
                  context,
                  'Steps',
                  Icons.directions_walk,
                  totalSteps.toString(), // Replace with actual data
                ),
                _buildActivityItem(
                  context,
                  'Calories',
                  Icons.local_fire_department,
                  '${totalCaloriesBurned.toStringAsFixed(1)} kcal', // Replace with actual data
                ),
                _buildActivityItem(
                  context,
                  'Distance',
                  Icons.place,
                  '${totalDistance.toStringAsFixed(1)} km', // Replace with actual data
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      BuildContext context, String label, IconData icon, String value) {
    var mediaQuery = MediaQuery.of(context).size;
    return Column(
      children: [
        Icon(icon,
            size: mediaQuery.width * 0.1,
            color: Theme.of(context).colorScheme.primary),
        SizedBox(height: mediaQuery.height * 0.01),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: mediaQuery.width * 0.05,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: mediaQuery.width * 0.04,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: mediaQuery.width * 0.06,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: mediaQuery.height * 0.01),
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickAccessButton(context, 'Steps', Icons.directions_walk,
                    () {
                  Get.to(() => BlocProvider(
                        create: (context) => CreateStepsBloc(
                            stepsRepository: FirebaseStepsRepository()),
                        child: const StepsScreen(),
                      ));
                }, () {
                  _addSteps().then((_) {
                    _fetchStepsData();
                  });
                }),
                SizedBox(
                  width: mediaQuery.width * 0.07,
                ),
                _buildQuickAccessButton(
                    context, 'Workout', Icons.fitness_center, () {
                  Get.to(() => BlocProvider(
                        create: (context) => CreateWorkoutBloc(
                            workoutRepository: FirebaseWorkoutRepository()),
                        child: const WorkoutScreen(),
                      ));
                }, () {
                  _addWorkout().then((_) {
                    _fetchWorkoutData();
                    _fetchDetailedWorkoutData();
                  });
                }),
                SizedBox(
                  width: mediaQuery.width * 0.07,
                ),
                _buildQuickAccessButton(context, 'Meal', Icons.restaurant, () {
                  Get.to(() => BlocProvider(
                        create: (context) => CreateMealsBloc(
                            mealsRepository: FirebaseMealsRepository()),
                        child: const MealScreen(),
                      ));
                }, () {
                  _addMeal().then((_) {
                    _fetchMealData();

                    _fetchDetailedMealData();
                  });
                }),
                SizedBox(
                  width: mediaQuery.width * 0.08,
                ),
                _buildQuickAccessButton(context, 'Hydrate', Icons.local_drink,
                    () {
                  Get.to(() => BlocProvider(
                        create: (context) => CreateHydrateBloc(
                            hydrateRepository: FirebaseHydrateRepository()),
                        child: const HydrateScreen(),
                      ));
                }, () {
                  _addHydrate().then((_) {
                    _fetchHydrateData();
                  });
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context,
    String label,
    IconData icon,
    void Function()? onPressed,
    void Function()? onLongPress,
  ) {
    var mediaQuery = MediaQuery.of(context).size;
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: EdgeInsets.all(mediaQuery.width * 0.04),
              child: Icon(
                icon,
                size: mediaQuery.width * 0.065,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        SizedBox(height: mediaQuery.height * 0.01),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: mediaQuery.width * 0.04,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthMetrics(BuildContext context, MyUserState state) {
    var mediaQuery = MediaQuery.of(context).size;
    late double weight;
    late double height;
    if (state.user!.weightUnit == 'kg') {
      weight = state.user!.weightValue;
    } else if (state.user!.weightUnit == 'lbs') {
      weight = state.user!.weightValue * 0.453592;
    }

    if (state.user!.heightUnit == 'in') {
      height = state.user!.heightValue * 0.0254;
    } else if (state.user!.heightUnit == 'cm') {
      height = state.user!.heightValue / 100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Metrics',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: mediaQuery.width * 0.06,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: mediaQuery.height * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMetricItem(
                context,
                'Weight',
                '${state.user!.weightValue}${state.user!.weightUnit}',
                Icons.monitor_weight),
            _buildMetricItem(
                context,
                'Height',
                '${state.user!.heightValue}${state.user!.heightUnit}',
                Icons.height),
            _buildMetricItem(
                context,
                'BMI',
                (weight / (height * height)).toStringAsFixed(1),
                Icons.assessment), // Replace with actual BMI calculation
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(
      BuildContext context, String label, String value, IconData icon) {
    var mediaQuery = MediaQuery.of(context).size;
    return Column(
      children: [
        Icon(icon,
            size: mediaQuery.width * 0.1,
            color: Theme.of(context).colorScheme.primary),
        SizedBox(height: mediaQuery.height * 0.01),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: mediaQuery.width * 0.05,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: mediaQuery.width * 0.04,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalQuote(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            '"$randomQuote"',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: mediaQuery.width * 0.05,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsAndProgress(BuildContext context, MyUserState state) {
    var mediaQuery = MediaQuery.of(context).size;
    int dailySteps = _dailySteps.fold(0, (sum, item) => sum + item.steps);
    double dailyCaloriesBurned =
        _dailyWorkouts.fold(0, (sum, item) => sum + item.caloriesBurned);
    double dailyCaloriesGained =
        _dailyMeals.fold(0, (sum, item) => sum + item.caloriesGained);
    double dailyWaterDrank =
        _dailyHydrates.fold(0, (sum, item) => sum + item.waterMeasurement);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goals & Progress',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: mediaQuery.width * 0.06,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: mediaQuery.height * 0.01),
        // _buildGoalItem(
        //     context,
        //     'Weight Goal',
        //     '200kg',
        //     '${state.user!.weightValue} ${state.user!.weightUnit}',
        //     200,
        //     state.user!.weightValue.toInt()),
        _buildGoalItem(
            context,
            'Step Goal',
            '${NumberFormat('#,###').format(stepsDailyGoal)} stps',
            '${NumberFormat('#,###').format(dailySteps)} stps',
            stepsDailyGoal,
            dailySteps),
        _buildGoalItem(
            context,
            'Workout Goal',
            '${NumberFormat('#,###').format(workoutDailyGoal)} cals burned',
            '${NumberFormat('#,###').format(dailyCaloriesBurned)} cals',
            workoutDailyGoal,
            dailyCaloriesBurned.toInt()),
        _buildGoalItem(
            context,
            'Meal Goal',
            '${NumberFormat('#,###').format(mealsDailyGoal)} cals gained',
            '${NumberFormat('#,###').format(dailyCaloriesGained)} cals',
            mealsDailyGoal,
            dailyCaloriesGained.toInt()),
        _buildGoalItem(
            context,
            'Hydration Goal',
            '${NumberFormat('#,###').format(hydrateDailyGoal)} ml',
            '${NumberFormat('#,###').format(dailyWaterDrank)} ml',
            hydrateDailyGoal,
            dailyWaterDrank.toInt()),
      ],
    );
  }

  Widget _buildGoalItem(BuildContext context, String label, String target,
      String current, int targetValue, int currentValue) {
    var mediaQuery = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: mediaQuery.width * 0.05,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: mediaQuery.height * 0.01),
        LinearProgressIndicator(
          value: currentValue / targetValue,
          backgroundColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: mediaQuery.height * 0.005),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current: $current',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: mediaQuery.width * 0.04,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              'Target: $target',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: mediaQuery.width * 0.04,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: mediaQuery.height * 0.02),
      ],
    );
  }

  Widget _buildRecentActivities(
      BuildContext context, List<dynamic> recentActivities) {
    var mediaQuery = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: mediaQuery.width * 0.06,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: mediaQuery.height * 0.01),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentActivities.length,
          itemBuilder: (context, index) {
            var activity = recentActivities[index];
            if (activity is Step) {
              return ListTile(
                leading: Icon(
                  Icons.directions_walk,
                  size: mediaQuery.width * 0.1,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Steps: ${activity.steps}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: mediaQuery.width * 0.05,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Timestamp: ${DateFormat('yyyy-MM-dd HH:mm').format(activity.timestamp)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: mediaQuery.width * 0.04,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            } else if (activity is Workout2) {
              return ListTile(
                leading: Icon(
                  Icons.fitness_center,
                  size: mediaQuery.width * 0.1,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Workout Session: ${activity.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: mediaQuery.width * 0.05,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Duration: ${activity.duration} mins\nCalories: ${activity.caloriesBurned} kcal\nTimestamp: ${DateFormat('yyyy-MM-dd HH:mm').format(activity.timestamp)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: mediaQuery.width * 0.04,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            } else if (activity is Meal) {
              return ListTile(
                leading: Icon(
                  Icons.fastfood,
                  size: mediaQuery.width * 0.1,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Meal: ${activity.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: mediaQuery.width * 0.05,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Calories: ${activity.calories} kcal\nTimestamp: ${DateFormat('yyyy-MM-dd HH:mm').format(activity.timestamp)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: mediaQuery.width * 0.04,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }
            return const SizedBox
                .shrink(); // Placeholder for any other types of activities
          },
        ),
      ],
    );
  }

  Future<List<dynamic>> fetchRecentActivities() async {
    // Fetch recent steps, workouts, and meals (replace with your actual database fetch logic)
    List<Step> recentSteps = await fetchRecentStepsFromDB();
    List<Workout2> recentWorkouts = await fetchRecentWorkoutsFromDB();
    List<Meal> recentMeals = await fetchRecentMealsFromDB();

    // Combine and sort steps, workouts, and meals by timestamp in descending order
    List<dynamic> combinedActivities = [
      ...recentSteps,
      ...recentWorkouts,
      ...recentMeals
    ];
    combinedActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Return the top 3 most recent activities
    return combinedActivities.take(3).toList();
  }

  Future<List<Step>> fetchRecentStepsFromDB() async {
    try {
      // Reference to your Firestore collection
      CollectionReference stepsCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Steps');

      // Query for fetching steps sorted by timestamp in descending order and limited to 3 records
      QuerySnapshot querySnapshot = await stepsCollection
          .orderBy('timeStamp', descending: true)
          .limit(3)
          .get();

      // Convert QuerySnapshot to List<Step>
      List<Step> steps = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        int steps = data['steps'];
        Timestamp timestamp = data['timeStamp'];
        return Step(
          steps: steps,
          timestamp: timestamp.toDate(),
        );
      }).toList();

      return steps;
    } catch (e) {
      dev.log('Error fetching recent steps: $e');
      return []; // Handle error case or return default value
    }
  }

  Future<List<Workout2>> fetchRecentWorkoutsFromDB() async {
    try {
      // Reference to your Firestore collection
      CollectionReference workoutsCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Workout');

      // Query for fetching workouts sorted by timestamp in descending order and limited to 3 records
      QuerySnapshot querySnapshot = await workoutsCollection
          .orderBy('timeStamp', descending: true)
          .limit(3)
          .get();

      // Convert QuerySnapshot to List<Workout>
      List<Workout2> workouts = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> workoutType = data['workoutRegions'];
        String duration = data['duration'];
        double caloriesBurned = data['caloriesBurned'];
        Timestamp timestamp = data['timeStamp'];

        return Workout2(
          name: workoutType.join(', '),
          duration: duration,
          caloriesBurned: caloriesBurned,
          timestamp: timestamp.toDate(),
        );
      }).toList();

      return workouts;
    } catch (e) {
      dev.log('Error fetching recent workouts: $e');
      return []; // Handle error case or return default value
    }
  }

  Future<List<Meal>> fetchRecentMealsFromDB() async {
    try {
      // Reference to your Firestore collection
      CollectionReference mealsCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Meals');

      // Query for fetching meals sorted by timestamp in descending order and limited to 3 records
      QuerySnapshot querySnapshot = await mealsCollection
          .orderBy('timeStamp', descending: true)
          .limit(3)
          .get();

      // Convert QuerySnapshot to List<Meal>
      List<Meal> meals = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String name = data['mealName'];
        double calories = data['caloriesGained'];
        Timestamp timestamp = data['timeStamp'];

        return Meal(
          name: name,
          calories: calories,
          timestamp: timestamp.toDate(),
        );
      }).toList();

      return meals;
    } catch (e) {
      dev.log('Error fetching recent meals: $e');
      return []; // Handle error case or return default value
    }
  }

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late GenerativeModel _model;

  bool _isLoading = false;

  Map<String, dynamic> stepDataToMap(_StepData stepData) {
    return {
      'period': stepData.period,
      'steps(stps)': stepData.steps,
      'timestamp': stepData.timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> workoutDataToMap(Workout2 workoutData) {
    return {
      'workoutName': workoutData.name,
      'duration': workoutData.duration,
      'caloriesBurned(cal)': workoutData.caloriesBurned,
      'timestamp': workoutData.timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> mealDataToMap(Meal workoutData) {
    return {
      'mealName': workoutData.name,
      'caloriesGained(cal)': workoutData.calories,
      'timestamp': workoutData.timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> hydrateDataToMap(_HydrateData workoutData) {
    return {
      'period': workoutData.time,
      'caloriesGained(ml)': workoutData.waterMeasurement,
      'timestamp': workoutData.timeStamp.toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> _initializeUserData() async {
    Map<String, dynamic> userData = {
      'age': 25,
      'gender': 'male',
      'steps': 10000,
      'caloriesBurned': 500,
    };
    try {
      _fetchGoals();
      // Perform the query and wait for the result
      final querySnapshot =
          await _vitalityUser.where("email", isEqualTo: user!.email).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document from the query results
        final document = querySnapshot.docs.first;

        userData = {
          'name': document.data()['name'],
          'email': document.data()['email'],
          'dateOfBirth': document.data()['dateOfBirth'],
          'gender': document.data()['gender'],
          'weightValue': document.data()['weightValue'],
          'weightUnit': document.data()['weightUnit'],
          'heightValue': document.data()['heightValue'],
          'heightUnit': document.data()['heightUnit'],
          'accountCreatedAt': document.data()['createdAt'],
          'accountUpdatedAt': document.data()['updatedAt'],
          //
          //Steps
          //
          'dailySteps': _dailySteps.map(stepDataToMap).toList(),
          'weeklySteps': _weeklySteps.map(stepDataToMap).toList(),
          'monthlySteps': _monthlySteps.map(stepDataToMap).toList(),
          'totalSteps': _totalSteps.map(stepDataToMap).toList(),
          'stepsDailyGoal(stps)': stepsDailyGoal,
          'stepsWeeklyGoal(stps)': stepsWeeklyGoal,
          'stepsMonthlyGoal(stps)': stepsMonthlyGoal,
          // Meals
          'dailyMeals': _dailyDetailedMeals.map(mealDataToMap).toList(),
          'weeklyMeals': _weeklyDetailedMeals.map(mealDataToMap).toList(),
          'monthlyMeals': _monthlyDetailedMeals.map(mealDataToMap).toList(),
          'totalMeals': _totalDetailedMeals.map(mealDataToMap).toList(),
          'mealsDailyGoal(cal)': mealsDailyGoal,
          'mealsWeeklyGoal(cal)': mealsWeeklyGoal,
          'mealsMonthlyGoal(cal)': mealsMonthlyGoal,
          // Workouts
          'dailyWorkouts':
              _dailyDetailedWorkouts.map(workoutDataToMap).toList(),
          'weeklyWorkouts':
              _weeklyDetailedWorkouts.map(workoutDataToMap).toList(),
          'monthlyWorkouts':
              _monthlyDetailedWorkouts.map(workoutDataToMap).toList(),
          'totalWorkouts':
              _totalDetailedWorkouts.map(workoutDataToMap).toList(),
          'workoutDailyGoal(cal)': workoutDailyGoal,
          'workoutWeeklyGoal(cal)': workoutWeeklyGoal,
          'workoutMonthlyGoal(cal)': workoutMonthlyGoal,
          // Hydrates
          'dailyHydrates': _dailyHydrates.map(hydrateDataToMap).toList(),
          'weeklyHydrates': _weeklyHydrates.map(hydrateDataToMap).toList(),
          'monthlyHydrates': _monthlyHydrates.map(hydrateDataToMap).toList(),
          'totalHydrates': _totalHydrates.map(hydrateDataToMap).toList(),
          'hydrateDailyGoal(ml)': hydrateDailyGoal,
          'hydrateWeeklyGoal(ml)': hydrateWeeklyGoal,
          'hydrateMonthlyGoal(ml)': hydrateMonthlyGoal,
        };
        return userData;
      } else {
        dev.log('No user found with the provided email.');
      }
    } catch (e) {
      dev.log('Error retrieving user name: $e');
    }

    return userData;
  }

  Future<void> _initializeChatHistory(String chatName) async {
    try {
      // Fetch chat history
      final fetchedChatHistory =
          await fetchAndProcessSpecificChatHistory(_chatName);
      setState(() {
        chatHistory = fetchedChatHistory;
      });
    } catch (e) {
      // Handle errors
      dev.log('Error initializing chat history: $e');
    }
  }

  Future<void> _initializeModel() async {
    apiKey = "AIzaSyDsVfGu1yePj-579ILoqIFOPbWBrVq5qtQ";
    if (apiKey.isEmpty) {
      dev.log('API key is not set.');
      return;
    }
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<void> _sendMessage(String message) async {
    final Map<String, dynamic> userData = await _initializeUserData();

    dev.log(chatHistory.toString());

    // Combine user data with the message for context
    final userDataContext =
        'My Profile: Name: ${userData['name']}, Email: ${userData['email']}, Date Of Birth: ${userData['dateOfBirth']}, Gender: ${userData['gender']}, Weight Value: ${userData['weightValue']}, Weight Unit: ${userData['weightUnit']}, Height Value: ${userData['heightValue']}, Height Unit: ${userData['heightUnit']}, Account Created At: ${userData['accountCreatedAt']}, Account Updated At: ${userData['accountUpdatedAt']}, My Area/Location/Address: $_address, Daily Steps: ${userData['dailySteps']}, Weekly Steps: ${userData['weeklySteps']}, Monthly Steps: ${userData['monthlySteps']}, Total Steps: ${userData['totalSteps']}, Steps Daily Goal(stps): ${userData['stepsDailyGoal(stps)']}, Steps Weekly Goal(stps): ${userData['stepsWeeklyGoal(stps)']}, Steps Monthly Goal(stps): ${userData['stepsMonthlyGoal(stps)']}, Daily Meals: ${userData['dailyMeals']}, Weekly Meals: ${userData['weeklyMeals']}, Monthly Meals: ${userData['monthlyMeals']}, Total Meals: ${userData['totalMeals']}, Meals Daily Goal(cal): ${userData['mealsDailyGoal(cal)']}, Meals Weekly Goal(cal): ${userData['mealsWeeklyGoal(cal)']}, Meals Monthly Goal(cal): ${userData['mealsMonthlyGoal(cal)']}, Daily Workouts: ${userData['dailyWorkouts']}, Weekly Workouts: ${userData['weeklyWorkouts']}, Monthly Workouts: ${userData['monthlyWorkouts']}, Total Workouts: ${userData['totalWorkouts']}, Workouts Daily Goal(cal): ${userData['workoutDailyGoal(cal)']}, Workouts Weekly Goal(cal): ${userData['workoutWeeklyGoal(cal)']}, Workouts Monthly Goal(cal): ${userData['workoutMonthlyGoal(cal)']}, Daily Hydrates: ${userData['dailyHydrates']}, Weekly Hydrates: ${userData['weeklyHydrates']}, Monthly Hydrates: ${userData['monthlyHydrates']}, Total Hydrates: ${userData['totalHydrates']}, Hydrates Daily Goal(ml): ${userData['hydrateDailyGoal(ml)']}, Hydrates Weekly Goal(ml): ${userData['hydrateWeeklyGoal(ml)']}, Hydrates Monthly Goal(ml): ${userData['hydrateMonthlyGoal(ml)']},';
    
    final fullMessage = '''
You are ONLY referring to data in the Current User Messages. Anything under chat history is just background information and should not influence your responses or prompt questions.

- **Do Not Ask About Chat History:** Use chat history only to avoid repeating information but do not ask questions based on it.
- **Clarify Current User Messages:** If something in the Current User Message is unclear, ask for clarification related to that specific message only.
- **Avoid Redundancy:** Ensure your responses do not repeat or ask about details already covered in the Current User Message.
- **Handling Unclear Statements:** If a statement is unclear, ask for clarification directly or state that you do not understand. Do not refer to chat history.
- **Incorporate Data:** Always remember and use any meal, hydrate, workout, or steps data provided. Recommendations and answers should be based on $_address unless otherwise specified.
- **Personal References:** Avoid referring to me as "The user" or "${userData['name']}'s profile". Use appropriate names or titles.
- **Location and Time:** Use the name of the place instead of latitude and longitude. Format dates and times simply, e.g., "6:00 AM".
- **Hydrate Data:** Treat hydrate data the same as water data.

User Data: $userDataContext
Chat History: $chatHistory
Current User Message: ${message.trim()}
''';


    String chatTitle =
        'Generate a concise title based on $message, make it only ONE title. Your response should ONLY BE THE TITLE';

    try {
      _messages.add({'type': 'user', 'text': message});

      setState(() {
        _isLoading = true;
      });

      // Prepare the content for the AI model
      final content = [Content.text(fullMessage)];

      // Make the API call to generate content
      final response = await _model.generateContent(content);

      // Extract the bot's response
      final botMessage = response.text;

      if (_chatName == 'New Chat') {
        final title = [Content.text(chatTitle)];
        final titleResponse = await _model.generateContent(title);
        final botTitleMessage = titleResponse.text;
        _chatName = botTitleMessage!.trim();
        _messagesStream = getMessages(_chatName);
      }

      // Store user message
      await addMessage(
        {
          'type': 'user',
          'text': message,
          'timeStamp': FieldValue.serverTimestamp(),
          'chatName': _chatName,
        },
      ).then(
        (value) async {
          await addMessage(
            {
              'type': 'bot',
              'text': botMessage!,
              'timeStamp': FieldValue.serverTimestamp(),
              'chatName': _chatName,
            },
          ).then(
            (value) {
              _messages.add({'type': 'bot', 'text': botMessage});
            },
          );
        },
      );

      // Store bot response

      setState(() {
        _isLoading = false;
      });

      final updatedChatHistory = await fetchAndProcessSpecificChatHistory(_chatName);

      setState(() {
      chatHistory = updatedChatHistory;
    });
      fetchAndProcessChats();
    } catch (e) {
      if (e is GenerativeAIException) {
        // Handle the specific AI exception
        dev.log('Generative AI Exception: ${e.message}');

        // Update the state to stop loading and show an error message
        setState(() {
          _messages.add({
            'type': 'bot',
            'text': 'Sorry, we could not generate a response at this time.'
          });
          _isLoading = false; // Hide loading indicator
        });
      } else {
        // Handle other exceptions
        dev.log('An unexpected error occurred: $e');

        // Update the state to stop loading and show a generic error message
        setState(() {
          _messages.add({
            'type': 'bot',
            'text': 'An unexpected error occurred. Please try again later.'
          });
          _isLoading = false; // Hide loading indicator
        });
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  late String lat;
  late String long;

  String locationMessage = 'Unknown';

  //Get Current Location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request for access');
    }

    return await Geolocator.getCurrentPosition();
  }

  String? _address;

  //Listen to location updates
  Future<void> _liveLocation() async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Position positions = await _getCurrentLocation();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(positions.latitude, positions.longitude);
    Placemark place = placemarks[0];

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();

      setState(() {
        locationMessage = 'Latitude: $lat , Longitude: $long';
        _address =
            '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
        dev.log(_address!);
      });
    });
  }

  final TextEditingController _chatNameController = TextEditingController();

  void _showSetChatNameDialog() {
    _chatNameController.text = _chatName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Chat Name'),
          content: Form(
            key: _formKeyChatName,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a chat name';
                    }
                    return null;
                  },
                  controller: _chatNameController,
                  decoration: const InputDecoration(labelText: 'Chat Name...'),
                ),
              ],
            ),
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
              onPressed: () async {
                if (_formKeyChatName.currentState!.validate()) {
                  QuerySnapshot<Map<String, dynamic>> snapshot =
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user!.uid)
                          .collection('Chats')
                          .where("chatName", isEqualTo: _chatName)
                          .get();

                  WriteBatch batch = FirebaseFirestore.instance.batch();

                  // Process each document
                  for (var doc in snapshot.docs) {
                    batch.update(doc.reference,
                        {'chatName': _chatNameController.text.trim()});
                  }

                  await batch.commit();
                  setState(() {
                    _chatName = _chatNameController.text.trim();
                  });
                  _messagesStream = getMessages(_chatName);
                  fetchAndProcessChats();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _widgetOptions(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    Future deletePatientsDialogue() => showDialog(
        context: context,
        builder: ((context) => Container(
              padding: const EdgeInsets.all(20),
              child: AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text(
                  'Are you sure that you want to delete this chat?',
                  style: TextStyle(
                    fontSize: mediaQuery.width * 0.038,
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LightSmallButtonError(
                          onPress: () {
                            Navigator.of(context).pop();
                          },
                          title: 'Cancel'),
                      SizedBox(
                        width: mediaQuery.width * 0.125,
                      ),
                      LightSmallButton(
                          onPress: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 1),
                                content: Text(
                                  'Deleting Chat...',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                            QuerySnapshot<Map<String, dynamic>> snapshot =
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(user!.uid)
                                    .collection('Chats')
                                    .where("chatName", isEqualTo: _chatName)
                                    .get();

                            WriteBatch batch =
                                FirebaseFirestore.instance.batch();

                            // Process each document
                            for (var doc in snapshot.docs) {
                              batch.delete(doc.reference);
                            }

                            await batch.commit();

                            setState(() {
                              _chatList.remove(_chatName);
                              _chatName = 'New Chat';
                            });
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 2),
                                content: Text(
                                  'Deleted chat',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                          },
                          title: 'Delete')
                    ],
                  )
                ],
              ),
            )));

    return [
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: BlocBuilder<MyUserBloc, MyUserState>(
            builder: (context, state) {
              if (state.status == MyUserStatus.success) {
                _weight = state.user!.weightValue;
                _height = state.user!.heightValue;

                _weightUnit = state.user!.weightUnit;
                _heightUnit = state.user!.heightUnit;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${state.user!.name}!',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: mediaQuery.width * 0.08,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: mediaQuery.height * 0.02),
                      // Daily Activity Summary
                      _buildDailyActivitySummary(context, state),
                      SizedBox(height: mediaQuery.height * 0.04),
                      // Key Features
                      _buildQuickAccess(context),
                      SizedBox(height: mediaQuery.height * 0.04),
                      // Health Metrics
                      _buildHealthMetrics(context, state),
                      SizedBox(height: mediaQuery.height * 0.04),
                      // Motivational Quotes
                      _buildMotivationalQuote(context),
                      SizedBox(height: mediaQuery.height * 0.04),
                      // Goals and Progress
                      _buildGoalsAndProgress(context, state),
                      SizedBox(height: mediaQuery.height * 0.04),
                      // Recent Activities
                      FutureBuilder(
                        future: fetchRecentActivities(),
                        builder:
                            (context, AsyncSnapshot<List<dynamic>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Text('No recent activities found.');
                          } else {
                            List<dynamic> recentActivities = snapshot.data!;
                            return _buildRecentActivities(
                                context, recentActivities);
                          }
                        },
                      ),
                    ],
                  ),
                );
              } else if (state.status == MyUserStatus.loading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    'Error Loading Data, please ensure you are connected to the internet',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: mediaQuery.width * 0.05,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
            },
          ),
        ),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: PopupMenuButton<String>(
                  onSelected: (String value) {
                    // Handle chat selection here
                    _selectChat(value);
                  },
                  itemBuilder: (BuildContext context) {
                    return _chatList.map((String chatName) {
                      return PopupMenuItem<String>(
                        value: chatName,
                        child: Text(chatName),
                      );
                    }).toList();
                  },
                  icon: const Icon(Icons.chat),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onLongPress: () {
                    if (_chatName != 'New Chat') {
                      _showSetChatNameDialog();
                    }
                  },
                  child: Text(
                    _chatName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: mediaQuery.width * 0.07,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 35,
                ),
                onPressed: () {
                  setState(() {
                    _chatName = 'New Chat';
                    _messagesStream = getMessages(_chatName);
                  });
                },
              ),
              if (_chatName != 'New Chat') ...[
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 30,
                  ),
                  onPressed: () async {
                    deletePatientsDialogue();
                  },
                ),
              ]
            ],
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!;

                // Convert your message data to DashChat's ChatMessage format
                final chatMessages = messages
                    .map((msg) {
                      return ChatMessage(
                        text: msg['text']!,
                        user: ChatUser(
                          id: msg['type'] == 'user' ? 'userId' : 'botId',
                          firstName: msg['type'] == 'user' ? 'You' : 'Bot',
                          profileImage: msg['type'] == 'user'
                              ? 'https://static.vecteezy.com/system/resources/previews/007/783/637/non_2x/world-health-day-illustration-concept-flat-illustration-isolated-on-white-background-vector.jpg'
                              : 'https://static.vecteezy.com/system/resources/previews/004/261/144/large_2x/woman-meditating-in-nature-and-leaves-concept-illustration-for-yoga-meditation-relax-recreation-healthy-lifestyle-illustration-in-flat-cartoon-style-free-vector.jpg',
                        ),
                        createdAt: msg['timeStamp'] != null
                            ? (msg['timeStamp'] as Timestamp).toDate()
                            : DateTime.now(),
                      );
                    })
                    .toList()
                    .reversed
                    .toList();

                return DashChat(
                  currentUser: currentUser!,
                  messages: chatMessages,
                  messageOptions: const MessageOptions(
                    showOtherUsersAvatar: true,
                  ),
                  inputOptions: InputOptions(
                    alwaysShowSend: true,
                    inputDecoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    autocorrect: true,
                  ),
                  readOnly: true,
                  onSend: (message) {
                    // _sendMessage(message.text);
                  },
                );
              },
            ),
          ),
          Form(
            key: _formKey2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a message';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: _isLoading
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.send),
                    onPressed: () {
                      if (_formKey2.currentState!.validate()) {
                        _sendMessage(_controller.text);
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: BlocBuilder<MyUserBloc, MyUserState>(
            builder: (context, state) {
              if (state.status == MyUserStatus.success) {
                return Column(
                  children: [
                    SizedBox(
                      width: mediaQuery.width * 0.9,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  width: mediaQuery.width *
                                      0.30, // Adjust width as needed
                                  height: mediaQuery.width *
                                      0.30, // Adjust height as needed
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  child: Transform.scale(
                                      scale: 1.5,
                                      child: Image.asset(
                                        'images/profilepicture.png',
                                      ))),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      state.user!.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: mediaQuery.width * 0.055,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: mediaQuery.height * 0.003,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        state.user!.gender,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: mediaQuery.width * 0.050,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        width: mediaQuery.width * 0.01,
                                      ),
                                      if (state.user!.gender == 'Male') ...[
                                        Icon(Icons.male,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                      ] else if (state.user!.gender ==
                                          'Female') ...[
                                        Icon(Icons.female,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                      ] else if (state.user!.gender ==
                                          'Other') ...[
                                        Icon(Icons.transgender,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                      ],
                                    ],
                                  ),
                                  SizedBox(
                                    height: mediaQuery.height * 0.003,
                                  ),
                                  Text(
                                    'Born on ${state.user!.dateOfBirth}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: mediaQuery.width * 0.050,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: mediaQuery.height * 0.003,
                                  ),
                                  Text(
                                    'Joined on ${DateFormat('dd-MM-yyyy').format(DateFormat('dd-MM-yyyy HH:mm').parse(state.user!.createdAt))}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: mediaQuery.width * 0.050,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: mediaQuery.height * 0.05,
                          ),
                          //
                          // Measurement Details
                          //
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Measurement Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: mediaQuery.width * 0.065,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              SizedBox(
                                width: mediaQuery.width * 0.8,
                                child: Divider(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline, // Color of the divider
                                  thickness: 2, // Thickness of the divider
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: mediaQuery.height * 0.02,
                          ),
                          //
                          // Weight
                          //
                          SmallAnyCards(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Weight',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: mediaQuery.width * 0.05,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                        SizedBox(
                                          width: mediaQuery.width * 0.01,
                                        ),
                                        Icon(Icons.monitor_weight,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                      ],
                                    ),
                                    Text(
                                      state.user!.weightValue.toString() +
                                          state.user!.weightUnit,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: mediaQuery.width * 0.065,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          //
                          // Height
                          //
                          SmallAnyCards(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Height',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: mediaQuery.width * 0.05,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                        SizedBox(
                                          width: mediaQuery.width * 0.01,
                                        ),
                                        Icon(Icons.height,
                                            size: 25,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                      ],
                                    ),
                                    Text(
                                      state.user!.heightValue.toString() +
                                          state.user!.heightUnit,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: mediaQuery.width * 0.065,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: mediaQuery.height * 0.01,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isWeightHeightExpanded =
                                    !isWeightHeightExpanded;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: mediaQuery.width * 0.05,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                SizedBox(
                                  width: mediaQuery.width * 0.01,
                                ),
                                Icon(Icons.edit,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.outline),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: isWeightHeightExpanded
                                ? mediaQuery.height * 0.36
                                : 0.0,
                            child: SingleChildScrollView(
                              child: SmallAnyCards(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  child: Column(
                                    children: [
                                      WeightHeightPicker(
                                        heightUnit: _heightUnit,
                                        heightValue: _height,
                                        onChangedHeight: (value) {
                                          setState(() {
                                            _height = value;
                                          });
                                        },
                                        onChangedWeight: (value) {
                                          setState(() {
                                            _weight = value;
                                          });
                                        },
                                        onUnitChangedHeight: (unit) {
                                          setState(() {
                                            _heightUnit = unit;
                                            // Convert current height to the new unit
                                            if (unit == 'cm') {
                                              _height = (_height * 2.54).clamp(
                                                  _minHeightCm, _maxHeightCm);
                                            } else {
                                              _height = (_height / 2.54).clamp(
                                                  _minHeightIn, _maxHeightIn);
                                            }
                                          });
                                        },
                                        onUnitChangedWeight: (unit) {
                                          setState(() {
                                            _weightUnit = unit;
                                            // Convert current weight to the new unit
                                            if (unit == 'kg') {
                                              _weight = (_weight / 2.20462)
                                                  .clamp(_minWeightKg,
                                                      _maxWeightKg);
                                            } else {
                                              _weight = (_weight * 2.20462)
                                                  .clamp(_minWeightLbs,
                                                      _maxWeightLbs);
                                            }
                                          });
                                        },
                                        weightUnit: _weightUnit,
                                        weightValue: _weight,
                                      ),
                                      SizedBox(
                                        height: mediaQuery.height * 0.01,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          await _vitalityUser
                                              .doc(state.user!.id)
                                              .update({
                                            "weightValue": _weight,
                                            "weightUnit": _weightUnit,
                                            "heightValue": _height,
                                            "heightUnit": _heightUnit,
                                            "updatedAt":
                                                DateFormat('dd-MM-yyyy HH:mm')
                                                    .format(DateTime.now()),
                                          });
                                          MyUser updatedUser = MyUser.empty;
                                          updatedUser = updatedUser.copyith(
                                            id: state.user!.id,
                                            email: state.user!.email,
                                            name: state.user!.name,
                                            createdAt: state.user!.createdAt,
                                            dateOfBirth:
                                                state.user!.dateOfBirth,
                                            gender: state.user!.gender,
                                            heightUnit: _heightUnit,
                                            heightValue: _height,
                                            updatedAt:
                                                DateFormat('dd-MM-yyyy HH:mm')
                                                    .format(DateTime.now()),
                                            weightUnit: _weightUnit,
                                            weightValue: _weight,
                                          );
                                          setState(() {
                                            context.read<MyUserBloc>().add(
                                                UpdateMyUser(
                                                    myUser: updatedUser));
                                            isWeightHeightExpanded = false;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                duration:
                                                    const Duration(seconds: 5),
                                                content: Text(
                                                  'Updated form',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .surface),
                                                ),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                              ),
                                            );
                                          });
                                        },
                                        child: Text(
                                          'Update',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: mediaQuery.width * 0.052,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),

                          SizedBox(
                            height: mediaQuery.height * 0.02,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: mediaQuery.height * 0.03,
                    ),
                    SizedBox(
                        width: mediaQuery.width,
                        child: LightSecondaryShortButton(
                            onPress: () {
                              context
                                  .read<SignInBloc>()
                                  .add(const SignOutRequired());
                            },
                            title: 'Log Out')),
                  ],
                );
              } else if (state.status == MyUserStatus.loading) {
                return CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onSurface,
                );
              } else {
                return const Center(
                    child: Text(
                        'Error Loading Data, please ensure you are connected to the internet'));
              }
            },
          ),
        ),
      ),
    ];
  }

  void _selectChat(String chatName) {
    // Handle chat selection, e.g., navigate to the selected chat
    setState(() {
// Update the selected chat
      _chatName = chatName;
      _messagesStream = getMessages(_chatName);
      _initializeChatHistory(_chatName);
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    List<Widget> pages = _widgetOptions(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          toolbarHeight: 70,
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: mediaQuery.width * 0.12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Vita',
                        ),
                        TextSpan(
                          text: 'lity',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary, // Change the color of the number "15" to green
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: mediaQuery.width * 0.03,
                  ),
                  Container(
                    width: mediaQuery.width * 0.12, // Adjust width as needed
                    height: mediaQuery.width * 0.12, // Adjust height as needed
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundImage: const AssetImage('images/logo.jpg'),
                      radius:
                          mediaQuery.width * 0.125, // Adjust radius as needed
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant, // Background color inside the CircleAvatar
                    ),
                  ),
                ],
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: pages[_selectedIndex],
        bottomNavigationBar: Container(
          color: Theme.of(context).colorScheme.onSurface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
            child: GNav(
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                color: Theme.of(context).colorScheme.surface,
                activeColor: Theme.of(context).colorScheme.surface,
                tabBorderRadius: 15,
                tabBackgroundColor: Theme.of(context).colorScheme.outline,
                padding: const EdgeInsets.all(16),
                gap: 8,
                onTabChange: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                tabs: const [
                  GButton(
                    icon: Icons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: Icons.thumb_up,
                    text: 'Recommendations',
                  ),
                  GButton(
                    icon: Icons.person,
                    text: 'Account',
                  ),
                ]),
          ),
        ));
  }
}

class _StepData {
  _StepData(this.period, this.steps, this.timestamp);

  final String period;
  final int steps;
  final DateTime timestamp;
}

class _WorkoutData {
  final String timeKey;
  final double caloriesBurned;
  final DateTime dateTime;

  _WorkoutData(this.timeKey, this.caloriesBurned, this.dateTime);
}

class _MealData {
  _MealData(this.time, this.caloriesGained, this.timestamp);

  final String time;
  final double caloriesGained;
  final DateTime timestamp;
}

class Step {
  final int steps;
  final DateTime timestamp;

  Step({required this.steps, required this.timestamp});
}

class Workout2 {
  final String name;
  final String duration;
  final double caloriesBurned;
  final DateTime timestamp;

  Workout2(
      {required this.name,
      required this.duration,
      required this.caloriesBurned,
      required this.timestamp});
}

class Meal {
  final String name;
  final double calories;
  final DateTime timestamp;

  Meal({
    required this.name,
    required this.calories,
    required this.timestamp,
  });
}

class _HydrateData {
  final String time;
  final double waterMeasurement;
  final DateTime timeStamp;

  _HydrateData(this.time, this.waterMeasurement, this.timeStamp);
}
