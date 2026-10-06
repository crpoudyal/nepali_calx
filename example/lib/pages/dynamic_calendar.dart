import 'package:flutter/material.dart';
import 'package:nepali_calx/nepali_calx.dart';

class DynamicCalendar extends StatefulWidget {
  const DynamicCalendar({super.key});

  @override
  State<DynamicCalendar> createState() => _DynamicCalendarState();
}

class _DynamicCalendarState extends State<DynamicCalendar> {
  late CalendarType _calendarType;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _calendarType = CalendarType.ad;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Calendar'),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (_calendarType == CalendarType.ad) {
                setState(() => _calendarType = CalendarType.bs);
              } else {
                setState(() => _calendarType = CalendarType.ad);
              }
            },
            child: Text(_calendarType == CalendarType.bs ? 'En' : 'ने'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: NepaliCalx(
              initialDate: DateTime.now(),
              calendarType: _calendarType,
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
