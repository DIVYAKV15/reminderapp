import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  //it sets the default icon for the notifications to be displayed in the app to 'app_icon'.
  //initialization settings for local notification
  //by passing the android settings parameter
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  //this initialize the local notification  plugin for the specified settings
  // allowing the app to send and display local notifications.
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MaterialApp(home: ReminderAPp()));
}

class ReminderAPp extends StatefulWidget {
  @override
  State<ReminderAPp> createState() => _ReminderAPpState();
}

class _ReminderAPpState extends State<ReminderAPp> {
  final textController = TextEditingController();

  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  DateTime? selectedDateTime;

  @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   //configure setting specific to android for local notifications
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');
  //   //it sets the default icon for the notifications to be displayed in the app to 'app_icon'.
  //   //initialization settings for local notification
  //   //by passing the android settings parameter
  //   const InitializationSettings initializationSettings =
  //       InitializationSettings(android: initializationSettingsAndroid);
  //   //this initialize the local notification  plugin for the specified settings
  //   // allowing the app to send and display local notifications.
  //   flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Reminder app")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: TextField(
                  controller: textController,
                  decoration:
                      const InputDecoration(hintText: "Enter reminder text"),
                ),
              ),
              ElevatedButton(
                onPressed: () => selectDateTime(context),
                child: Text(selectedDateTime == null
                    ? "Select date and time"
                    : "Change date and time"),
              ),
              if (selectedDateTime != null) ...[
                Text('selected date and time :${selectedDateTime!.toLocal()}'),
                ElevatedButton(
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      scheduleNotification(
                          textController.text, selectedDateTime);
                      textController.clear();
                      setState(() {
                        selectedDateTime = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Reminder Set Successfully"),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter reminder text'),
                        ),
                      );
                    }
                  },
                  child: const Text('set Reminder'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  //this function displays a date picker and a time picker dialog to the user, allowing them to select a specific date and time.
  // It then updates the state of the widget with the selected date and time.
  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    // Specifies the latest selectable date in the date picker as 365 days (1 year) from the current date.
    if (picked != null) {
      final TimeOfDay? time =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null) {
        setState(() {
          selectedDateTime = DateTime(
              picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> scheduleNotification(
      String text, DateTime? selectedDateTime) async {
    if (selectedDateTime != null) {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Reminder',
        text,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your channel id',
            'your channel name',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Reminder',
        text,
        tz.TZDateTime.from(selectedDateTime!, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your channel id',
            'your channel name',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

// Future<void> scheduleNotification(
//     String text, DateTime? selectedDateTime) async {
//   //These settings determine how the notification will be displayed on Android devices.
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails('your Channel_id', 'your channel name',
//           importance: Importance.max,
//           priority: Priority.high,
//           ticker: 'ticker');
//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);
//  await  flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       'Reminder',
//       text,
//       tz.TZDateTime.from(selectedDateTime!, tz.local),
//       platformChannelSpecifics,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents
//           .dateAndTime); // Scheduled date and time, notificationDetails, uiLocalNotificationDateInterpretation: uiLocalNotificationDateInterpretation)
//   // await flutterLocalNotificationsPlugin.show(
//   //     0, 'reminder', text, platformChannelSpecifics);
// }
}

//this initState method initializes the local notifications plugin for the Flutter app with settings specific to Android.
// It ensures that the app is properly configured to handle local notifications on Android devices.
