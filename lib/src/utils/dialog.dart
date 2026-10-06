import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';

import '../../nepali_calx.dart';

Future<DateTime?> showNepaliCalxDialog({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  CalendarType? calendarType,
  List<DateTime?> value = const [],
  List<DateTime>? holidays,
  List<Event>? events,
  bool mondayWeek = false,
  List<int> weekendDays = const [DateTime.saturday],
  Color? primaryColor,
  Color? weekColor,
  Color? holidayColor,
  Color? eventColor,
  BoxDecoration? todayDecoration,
  BoxDecoration? selectedDayDecoration,
  Widget Function(DateTime)? dayBuilder,
  double? height,
  BorderRadius? borderRadius,
  bool useRootNavigator = true,
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black54,
  bool useSafeArea = true,
  Color? dialogBackgroundColor,
  RouteSettings? routeSettings,
  String? barrierLabel,
}) {
  final DateTime effectiveInitialDate = initialDate ?? DateTime.now();
  final DateTime effectiveFirstDate = firstDate ?? DateTime(1970);
  final DateTime effectiveLastDate =
      lastDate ?? DateTime(effectiveInitialDate.year + 10);

  var dialog = Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
    backgroundColor: dialogBackgroundColor ?? Theme.of(context).canvasColor,
    shape: RoundedRectangleBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(10),
    ),
    clipBehavior: Clip.antiAlias,
    child: Container(
      height: height ?? (MediaQuery.of(context).size.width * 1.1),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: NepaliCalx(
        initialDate: effectiveInitialDate,
        firstDate: effectiveFirstDate,
        lastDate: effectiveLastDate,
        calendarType: calendarType ?? CalendarType.bs,
        holidays: holidays,
        events: events,
        mondayWeek: mondayWeek,
        weekendDays: weekendDays,
        primaryColor: primaryColor,
        weekColor: weekColor,
        holidayColor: holidayColor,
        eventColor: eventColor,
        todayDecoration: todayDecoration,
        selectedDayDecoration: selectedDayDecoration,
        dayBuilder: dayBuilder,
        onDateSelected: (date, events) {
          final DateTime result =
              date is NepaliDateTime ? date.toDateTime() : date as DateTime;
          Navigator.of(context).pop(result);
        },
      ),
    ),
  );

  return showDialog<DateTime?>(
    context: context,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: (BuildContext context) => dialog,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
  );
}
