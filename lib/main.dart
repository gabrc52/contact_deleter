import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mass contact deleter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Mass contact deleter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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
  List<Contact> contacts = [Contact(displayName: 'Please make a query')];
  String query = '';

  void _updateQuery(String _query) {
    setState(() {
      query = _query;
    });
    search();
  }

  Future<void> search() async {
    var _contacts =
        await ContactsService.getContacts(query: query, withThumbnails: false);
    setState(() {
      contacts = _contacts;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          TextField(
            onChanged: _updateQuery,
          ),
          ListTile(
            title: Text('Found ${contacts.length} contacts matching "$query"'),
            leading: const Icon(Icons.contacts),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Are you SURE?'),
                        content: Text(
                          'Are you sure you want to delete ${contacts.length} contacts from ${contacts.first.displayName} to ${contacts.last.displayName}?',
                        ),
                        actions: [
                          TextButton(
                            child: const Text('No, cancel!'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Yes, I am sure'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              showCupertinoDialog(
                                context: context,
                                builder: (context) =>
                                    const CupertinoAlertDialog(
                                  title: Text(
                                    'Please wait, deleting',
                                  ),
                                ),
                              );
                              for (var contact in contacts) {
                                await ContactsService.deleteContact(contact);
                                print('Deleted ${contact.displayName}');
                              }
                              print(
                                  'All contacts have been successfully deleted');
                              Navigator.of(
                                _scaffoldKey.currentContext!,
                              ).pop();
                              search();
                              showCupertinoDialog(
                                context: _scaffoldKey.currentContext!,
                                builder: (context) => CupertinoAlertDialog(
                                  title: const Text(
                                    'Contacts have been successfully deleted',
                                  ),
                                  actions: [
                                    CupertinoButton(
                                      child: const Text('OK'),
                                      onPressed: () => Navigator.of(
                                        _scaffoldKey.currentContext!,
                                      ).pop(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ));
            },
            child: const Text('DELETE all contacts below!'),
          ),
          for (Contact contact in contacts)
            ListTile(title: Text('${contact.displayName}')),
        ],
      ),
    );
  }
}
