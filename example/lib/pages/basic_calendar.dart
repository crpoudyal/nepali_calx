import 'package:flutter/material.dart';
import 'package:nepali_calx/nepali_calx.dart';

class BasicCalendar extends StatefulWidget {
  const BasicCalendar({super.key});

  @override
  State<BasicCalendar> createState() => _BasicCalendarState();
}

class _BasicCalendarState extends State<BasicCalendar> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Calendar'),
      ),
      body: Column(
        children: [
          Expanded(
            child: NepaliCalx(
              initialDate: DateTime.now(),
              firstDate: DateTime(1970),
              lastDate: DateTime(2030),
              onMonthChanged: (date, events) {
                setState(() {
                  _selectedDate = date;
                });
              },
              onDateSelected: (date, events) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Selected Date: $_selectedDate'),
            ),
        ],
      ),
    );
  }
}
