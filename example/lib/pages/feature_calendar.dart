import 'package:flutter/material.dart';
import 'package:nepali_calx/nepali_calx.dart';

class FeatureCalendar extends StatefulWidget {
  const FeatureCalendar({super.key});

  @override
  State<FeatureCalendar> createState() => _FeatureCalendarState();
}

class _FeatureCalendarState extends State<FeatureCalendar> {
  late CalendarType _calendarType;
  late List<DateTime> _holidays;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _calendarType = CalendarType.bs;
    _holidays = [
      DateTime(2023, 04, 14),
      DateTime(2023, 05, 01),
      DateTime(2023, 05, 14),
      DateTime(2023, 05, 26),
      DateTime(2023, 05, 29),
      DateTime(2023, 07, 21),
      DateTime(2023, 08, 22),
      DateTime(2023, 08, 23),
      DateTime(2023, 08, 30),
      DateTime(2023, 09, 09),
      DateTime(2023, 09, 19),
      DateTime(2023, 09, 29),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar with Features'),
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: NepaliCalx(
              calendarType: _calendarType,
              initialDate: DateTime.now(),
              firstDate: DateTime(1970),
              lastDate: DateTime(2030),
              mondayWeek: false, // true is for Monday, false is  for Sunday
              weekendDays: const [
                DateTime.saturday,
              ],
              holidays: _holidays,
              primaryColor: Colors.purple,
              weekColor: Colors.cyan,
              holidayColor: Colors.deepOrange,
              todayDecoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).primaryColorLight,
                shape: BoxShape.rectangle,
              ),
              selectedDayDecoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).primaryColorDark,
                shape: BoxShape.rectangle,
              ),
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
