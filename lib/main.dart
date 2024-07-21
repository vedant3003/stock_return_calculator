import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

enum SampleItem { BSE, NSE }

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
  SampleItem? selectedItem;

  DateTime selectedDate1 = DateTime(2005, 1, 1);
  DateTime selectedDate2 = DateTime(2005, 1, 1);

  int _currentValue = 3;

  Future<Null> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate1,
        firstDate: DateTime(2005, 1, 1),
        lastDate: DateTime.now().subtract(Duration(days: 1)));
    if (picked != null && picked != selectedDate1)
      setState(() {
        selectedDate1 = picked;
      });
  }

  Future<Null> _selectDate2(BuildContext context) async {
    final DateTime? picked2 = await showDatePicker(
        context: context,
        initialDate: selectedDate2,
        firstDate: selectedDate1.add(Duration(days: 1)),
        lastDate: DateTime.now().subtract(Duration(days: 1)));
    if (picked2 != null && picked2 != selectedDate2)
      setState(() {
        selectedDate2 = picked2;
      });
  }

  String message = ' ';

  void _submitClicked() {
    setState(() {
      message = 'Submit Clicked';
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
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        PopupMenuButton<SampleItem>(
                          initialValue: selectedItem,
                          onSelected: (SampleItem item) {
                            setState(() {
                              selectedItem = item;
                            });
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<SampleItem>>[
                            const PopupMenuItem<SampleItem>(
                              value: SampleItem.BSE,
                              child: Text('BSE'),
                            ),
                            const PopupMenuItem<SampleItem>(
                              value: SampleItem.NSE,
                              child: Text('NSE'),
                            ),
                          ],
                          child: const OutlinedButton(
                            onPressed: null,
                            child: Text('Choose Stock Exchange',
                                style: TextStyle(color: Colors.blueGrey)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 35),
                  const Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Stock Symbol',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
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
              SizedBox(height: 40),
              Row(
                children: [
                  Text(
                    message,
                    style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 16,
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
