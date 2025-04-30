import 'package:flutter/material.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  TextEditingController taskController = TextEditingController();
  DateTime? selectedDateTime;
  bool isImportant = false;
  bool isStarred = true; // New starred state

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateTime.now();
  }

  // Show DateTime Picker
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2125),
    );

    if (picked != null && picked != selectedDateTime) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime!),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveTask() {
    if (taskController.text.isNotEmpty && selectedDateTime != null) {
      Navigator.pop(context, {
        'name': taskController.text,
        'dueDateTime': selectedDateTime,
        'isImportant': isImportant,
        'starred': isStarred, // Include starred info
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a task name and date/time')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDateTime(context),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDarkMode ? Colors.grey.shade700 : Colors.blueAccent,
                ),
                child: Text(
                  'Due: ${selectedDateTime?.day}/${selectedDateTime?.month}/${selectedDateTime?.year} ${selectedDateTime?.hour}:${selectedDateTime?.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: isImportant,
                  onChanged: (bool? value) {
                    setState(() {
                      isImportant = value!;
                    });
                  },
                ),
                const Text('Important Task'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isStarred ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      isStarred = !isStarred;
                    });
                  },
                ),
                const Text('Mark as Starred'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveTask,
              icon: const Icon(Icons.check),
              label: const Text('Save Task'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}

