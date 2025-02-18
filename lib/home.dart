import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class HiveDatabaseFlutter extends StatefulWidget {
  const HiveDatabaseFlutter({super.key});

  @override
  State<HiveDatabaseFlutter> createState() => _HiveDatabaseFlutterState();
}

class _HiveDatabaseFlutterState extends State<HiveDatabaseFlutter> {
  var peopleBox = Hive.box('Box');
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose

    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void addOrUpdate({String? key}) {
    if (key != null) {
      final person = peopleBox.get(key);
      if (person != null) {
        _nameController.text = person['name'] ?? "";
        _ageController.text = person['age'] ?? "";
      }
    } else {
      _nameController.clear();
      _ageController.clear();
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Enter Your Name'),
              ),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Enter Your Age'),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text;
                  final age = int.tryParse(_ageController.text);
                  if (name.isEmpty || age == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all the fields')),
                    );
                    return;
                  }
                  if (key == null) {
                    final newKey =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    peopleBox.put(newKey, {"name": name, "age": age});
                  } else {
                    peopleBox.put(key, {"name": name, "age": age});
                  }
                  Navigator.pop(context);
                },
                child: Text(key == null ? 'Add' : 'Update'),
              ),
              SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(title: Text('Notes')),
      body: ValueListenableBuilder(
        valueListenable: peopleBox.listenable(),
        builder: (context, box, widget) {
          if (box.isEmpty) {
            return Center(child: Text('No Notes Added'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index).toString();
              final items = box.get(key);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.white,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(items?['name'] ?? 'Unknown'),
                      subtitle: Text("Age:${items?['age'] ?? "Unknown"}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          IconButton(
                            onPressed: () {
                              addOrUpdate(key: key);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              peopleBox.delete(key);
                            },
                            icon: Icon(Icons.delete),
                          ),
                          IconButton(
                            onPressed: () {
                              addOrUpdate(key: key);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              peopleBox.delete(key);
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () => addOrUpdate(),
        child: Icon(Icons.add),
      ),
    );
  }
}
