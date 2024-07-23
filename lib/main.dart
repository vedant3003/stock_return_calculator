import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

//enum SampleItem { BSE, NSE }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Sailor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Stock Sailor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  //String? se1='BSE';
  //String? se2='NSE';
  //SampleItem? selectedItem;
  String selectedItem = 'Choose Stock Exchange';

  DateTime selectedDate1 = DateTime(2006, 1, 1);
  DateTime selectedDate2 = DateTime.now().subtract(Duration(days: 2));

  int _currentValue = 3;

  Future<Null> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate1,
        firstDate: DateTime(2006, 1, 1),
        lastDate: DateTime.now().subtract(Duration(days: 1)));
    if (picked != null && picked != selectedDate1)
      setState(() {
        selectedDate1 = picked;
      });
  }

  Future<Null> _selectDate2(BuildContext context) async {
    final DateTime? picked2 = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(Duration(days: 2)),
        firstDate: selectedDate1.add(Duration(days: 1)),
        lastDate: DateTime.now().subtract(Duration(days: 1)));
    if (picked2 != null && picked2 != selectedDate2)
      setState(() {
        selectedDate2 = picked2;
      });
  }

  String symbol = '';

  double? startDateHigh = 0.0;
  double? startDateLow = 0.0;
  double? endDateHigh = 0.0;
  double? endDateLow = 0.0;
  double? startDateValue = 0.0;
  double? endDateValue = 0.0;
  double? change = 0.0;
  String? roundedChange = '';

  Map<String, dynamic> _info = {};

  Future<void> _fetchInfo() async {
    print('HI$symbol');
    final url =
        'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=E8X9AFDQ3F1NSHV1';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        _info = json.decode(response.body);
      });
      print('Posts loaded');
      log('Full JSON data: ${jsonEncode(_info)}');
    } else {
      throw Exception('Failed to load posts');
    }
  }

  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        symbol = _controller.text;
      });
      _fetchInfo();
    });
  }

  void _getStartValues(String date) {
    final timeSeries = _info['Time Series (Daily)'];
    if (timeSeries != null) {
      print('Time Series Data Found');
      final dateWise = timeSeries[date];
      if (dateWise != null) {
        final high = dateWise['2. high'];
        final low = dateWise['3. low'];
        setState(() {
          startDateHigh = double.tryParse(high);
          startDateLow = double.tryParse(low);
          startDateValue = (startDateHigh! + startDateLow!) / 2;
        });
      } else {
        print('Date $date not found in data');
      }
    } else {
      print('Time Series data not available');
    }
  }

  void _getEndValues(String date) {
    final timeSeries = _info['Time Series (Daily)'];
    if (timeSeries != null) {
      final dateWise = timeSeries[date];
      if (dateWise != null) {
        final high = dateWise['2. high'];
        final low = dateWise['3. low'];
        setState(() {
          endDateHigh = double.tryParse(high);
          endDateLow = double.tryParse(low);
          endDateValue = (endDateHigh! + endDateLow!) / 2;
        });
      } else {
        print('Date $date not found in data');
      }
    } else {
      print('Time Series data not available');
    }
  }

  String message = ' ';

  void _submitClicked() {
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(selectedDate1);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(selectedDate2);
    print(symbol);
    _getStartValues(formattedStartDate);
    _getEndValues(formattedEndDate);
    setState(() {
      change = _currentValue * (endDateValue! - startDateValue!);
      roundedChange = change?.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 50.0),
        child: Form(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /*Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        PopupMenuButton<String>(
                          initialValue: selectedItem,
                          onSelected: (String item) {
                            setState(() {
                              selectedItem = item;
                            });
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'BSE',
                              child: Text('BSE'),
                            ),
                            const PopupMenuItem<String>(
                             value: 'NSE',
                              child: Text('NSE'),
                            ),
                          ],
                          child: OutlinedButton(
                            onPressed: null,
                            child: Text(selectedItem,
                                style: TextStyle(color: Colors.black54)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 35),
                  const Expanded(
                    flex: 6,*/
                  //child: //Column(
                  //children: [
                  SizedBox(width: 80),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Stock Symbol',
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: 16, // Ending TextStyle widget
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple, // Border color
                            width: 2.0,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                            // Border color when disabled
                            width: 2.0,
                          ),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 80),
                  //],
                  //),
                  //),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        NumberPicker(
                          value: _currentValue,
                          minValue: 0,
                          maxValue: 1000,
                          onChanged: (value) =>
                              setState(() => _currentValue = value),
                        ),
                        Text('Quantity'),
                      ],
                    ),
                  ),
                  SizedBox(width: 25),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Text("${selectedDate1.toLocal()}".split(' ')[0]),
                        SizedBox(
                          height: 10.0,
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDate1(context),
                          child: Text('Select Start Date'),
                        ),
                        SizedBox(height: 40),
                        Text("${selectedDate2.toLocal()}".split(' ')[0]),
                        SizedBox(
                          height: 10.0,
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDate2(context),
                          child: Text('Select End Date'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _submitClicked,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.purpleAccent,
                      // Text color
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      // Button size
                      textStyle:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      // Text style
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                      ),
                      elevation: 20, // Shadow effect
                    ),
                    child: Text('Submit'),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Stock Selected: $symbol',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Quantity: $_currentValue',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 20),
                  Text(
                    'Net Change: $roundedChange',
                    style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
