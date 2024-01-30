import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
void main() => runApp(MyApp());

class

MyApp

    extends

    StatelessWidget

{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class

MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isRecording = false;
  List<AccelerometerEvent> accelerometerData = [];
  List<GyroscopeEvent> gyroscopeData = [];
  String filePath1 = "";
  String filePath2 = "";
  String filePA = "";
  String filePG="";
  String name = "";

  @override
  Future<String?> showTextInputDialog(
      BuildContext context, {
        required

        String title,
        required

        String initialValue,
      }) async {
    final TextEditingController controller = TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context, controller.text),
            ),
          ],
        );
      },
    );
  }
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (isRecording) {
        setState(() {
          accelerometerData.add(event);

        });
      }
    });
    gyroscopeEvents.listen((GyroscopeEvent event) {
      if (isRecording) {
        setState(() {
          gyroscopeData.add(event);
        });
      }
    });
  }

  void startRecording() async {
    final String? enteredText = await showTextInputDialog(
      context,
      title: "Enter your name",
      initialValue: "Initial value",
    );
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    filePA = (await getExternalStorageDirectory())!.path + " " + formattedTime + "$enteredText Accelorometer.txt";
    filePG = (await getExternalStorageDirectory())!.path + " " + formattedTime + "$enteredText Gyroscope.txt";
    setState(() {
      filePath1=filePA;
      filePath1=filePG;
      isRecording = true;
      accelerometerData.clear();
      gyroscopeData.clear();
    });
  }

  void stopRecording() async {
    setState(() {
      isRecording = false;
    });

    // Write data to text file
    File file1 = File(filePath1);
    File file2 = File(filePath2);
    await file1.writeAsString(accelerometerData.map((event) => "${event.x},${event.y},${event.z}\n").join());
    await file2.writeAsString(gyroscopeData.map((event) => "${event.x},${event.y},${event.z}\n").join());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data Collection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isRecording ? 'Recording...' : 'Not Recording'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isRecording ? stopRecording : startRecording,
              child: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ],
        ),
      ),
    );
  }
}