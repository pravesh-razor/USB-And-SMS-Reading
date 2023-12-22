import 'package:checkusbandsms/customdrawer.dart';
import 'package:checkusbandsms/usb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];

  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _textEditingController = TextEditingController();

  void showMyDialog() async {
    var result = await Get.defaultDialog(
      barrierDismissible: false,
      title: 'Enter Sender Number',
      content: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(labelText: 'Enter text'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Access the entered text using _textEditingController.text
                    Get.back(result: _textEditingController.text);
                    await checkSMSs();
                  },
                  child: Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Clear the text field
                    _textEditingController.clear();
                    Get.back();
                    await checkSMSs();
                  },
                  child: Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (result != null && result is String) {
      // Handle the result (text entered in the dialog)
      print('Entered text: $result');
      _textEditingController.text = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter SMS Inbox App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SMS Inbox Example'),
          actions: [
            IconButton(
                onPressed: () {
                  showMyDialog();
                },
                icon: const Icon(Icons.phone_android_outlined))
          ],
        ),
        drawer: CustomDrawer(),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: _messages.isNotEmpty
              ? _MessagesListView(
                  messages: _messages,
                )
              : Center(
                  child: Text(
                    'No messages to show.\n Tap refresh button...',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await checkSMSs();
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Future<void> checkSMSs() async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [
          SmsQueryKind.inbox,
          // SmsQueryKind.sent,
        ],
        address: _textEditingController.text,
        // count: 10,
      );
      debugPrint('sms inbox messages: ${messages.length}');

      setState(() => _messages = messages);
    } else {
      await Permission.sms.request();
    }
  }
}

class _MessagesListView extends StatelessWidget {
  const _MessagesListView({
    Key? key,
    required this.messages,
  }) : super(key: key);

  final List<SmsMessage> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int i) {
        var message = messages[i];

        return ListTile(
          title: Text('${message.sender} [${message.date}]'),
          subtitle: Text('${message.body}'),
        );
      },
    );
  }
}
