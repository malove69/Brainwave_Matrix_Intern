import 'package:flutter/material.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  TextEditingController taskController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? dueDate; // New variable for due date
  bool isImportant = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    dueDate = DateTime.now(); // Initialize with current date
  }

  // Function to show the Date and Time selection menu
  void _showDateTimeMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Task Date Picker
              GestureDetector(
                onTap: () => _selectDate(context, isDueDate: false),
                child: ListTile(
                  title: const Text('Select Task Date'),
                  subtitle: Text(
                    selectedDate == null
                        ? 'No Date Chosen'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                ),
              ),
              const Divider(),
              // Task Time Picker
              GestureDetector(
                onTap: () => _selectTime(context),
                child: ListTile(
                  title: const Text('Select Task Time'),
                  subtitle: Text(
                    selectedTime == null
                        ? 'No Time Chosen'
                        : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.access_time),
                ),
              ),
              const Divider(),
              // Due Date Picker
              GestureDetector(
                onTap: () => _selectDate(context, isDueDate: true),
                child: ListTile(
                  title: const Text('Select Due Date'),
                  subtitle: Text(
                    dueDate == null
                        ? 'No Due Date Chosen'
                        : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                ),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to open the Date Picker (for Task or Due Date)
  Future<void> _selectDate(BuildContext context, {required bool isDueDate}) async {
    final DateTime initialDate = (isDueDate ? dueDate : selectedDate) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2125),
    );

    if (picked != null) {
      setState(() {
        if (isDueDate) {
          dueDate = picked; // Set the due date
        } else {
          selectedDate = picked; // Set the task date
        }
      });
    }
  }

  // Function to open the Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay initialTime = selectedTime ?? TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
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

            // Button to open the Date and Time menu
            GestureDetector(
              onTap: () => _showDateTimeMenu(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Select Date and Time',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDate == null || selectedTime == null
                      ? 'No Date or Time Chosen'
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: (selectedDate == null || selectedTime == null)
                        ? (isDarkMode ? Colors.grey : Colors.black)
                        : (isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Display Due Date
            Text(
              dueDate == null
                  ? 'No Due Date Set'
                  : 'Due Date: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Importance Toggle
            Row(
              children: [
                const Text('Mark as Important'),
                Checkbox(
                  value: isImportant,
                  onChanged: (bool? value) {
                    setState(() {
                      isImportant = value ?? false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Save Task Button
            ElevatedButton.icon(
              onPressed: () {
                String taskName = taskController.text.trim();
                if (taskName.isNotEmpty && selectedDate != null && selectedTime != null && dueDate != null) {
                  final taskDateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );

                  Navigator.pop(
                    context,
                    {
                      'name': taskName,
                      'dateTime': taskDateTime,
                      'dueDate': dueDate,
                      'isImportant': isImportant,
                    },
                  );
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Save Task'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
