import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isRecording = false;
  List<String> accelerometerData = [];
  List<String> gyroscopeData = [];
  String filePath1 = "";
  String filePath2 = "";
  String filePA = "";
  String filePG = "";
  DateTime recordingStartTime = DateTime.now();

  @override
  Future<String?> showTextInputDialog(
      BuildContext context, {
        required String title,
        required String initialValue,
      }) async {
    final TextEditingController controller =
    TextEditingController(text: initialValue);

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
    accelerometerEventStream(samplingPeriod:Duration(milliseconds: 20) ).listen((AccelerometerEvent event) {
      if (isRecording) {
        DateTime now = DateTime.now();
        String formattedTime = DateFormat('HH:mm:ss:ms').format(now);
        int elapsedTime = now.difference(recordingStartTime).inMilliseconds;
        String data =
            "$formattedTime, $elapsedTime, ${event.x},${event.y},${event.z}";
        setState(() {
          accelerometerData.add(data);
        });
      }
    });

    gyroscopeEventStream(samplingPeriod: Duration(milliseconds: 20)).listen((GyroscopeEvent event) {
      if (isRecording) {
        DateTime now = DateTime.now();
        String formattedTime = DateFormat('HH:mm:ss:ms').format(now);
        int elapsedTime = now.difference(recordingStartTime).inMilliseconds;
        String data =
            "$formattedTime, $elapsedTime, ${event.x},${event.y},${event.z}";
        setState(() {
          gyroscopeData.add(data);
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
    recordingStartTime = now;
    String formattedTime = DateFormat('HH:mm:ss').format(now);

    filePA =
        (await getExternalStorageDirectory())!.path +
            "$enteredText" +
            " " +
            formattedTime +
            " Accelerometer.txt";
    filePG =
        (await getExternalStorageDirectory())!.path +
            "$enteredText" +
            " " +
            formattedTime +
            " Gyroscope.txt";
    setState(() {
      filePath1 = filePA.replaceAll("files", "");
      filePath2 = filePG.replaceAll("files", "");
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
    await file1.writeAsString(accelerometerData.join('\n'));
    await file2.writeAsString(gyroscopeData.join('\n'));
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
