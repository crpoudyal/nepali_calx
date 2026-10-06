/*
 * Copyright (c) 2024 Chudaraj Poudyal
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';

import '../nepali_calx.dart';

const Duration _monthScrollDuration = Duration(milliseconds: 200);

typedef OnSelectedDate<T> = Function(T selectedDate, List<Event>? events);
typedef OnMonthChanged<T> = Function(T selectedDate, List<Event>? events);

class NepaliCalx<T> extends StatefulWidget {
  NepaliCalx({
    super.key,
    this.calendarType = CalendarType.bs,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    this.holidays,
    this.mondayWeek = false,
    this.weekendDays = const [DateTime.saturday],
    this.events,
    this.primaryColor,
    this.weekColor,
    this.holidayColor,
    this.eventColor,
    this.todayDecoration,
    this.selectedDayDecoration,
    this.dayBuilder,
    required this.onDateSelected,
    this.onMonthChanged,
  })  : initialDate = DateUtils.dateOnly(initialDate),
        firstDate = DateUtils.dateOnly(firstDate),
        lastDate = DateUtils.dateOnly(lastDate) {
    assert(
      !this.lastDate.isBefore(this.firstDate),
      'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
      !this.initialDate.isBefore(this.firstDate),
      'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
      !this.initialDate.isAfter(this.lastDate),
      'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.',
    );
  }

  /// The [CalendarType] displayed in the calendar.
  final CalendarType calendarType;

  /// The initially selected [DateTime] that the picker should display.
  final DateTime initialDate;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The List of holiday dates.
  final List<DateTime>? holidays;

  /// List of events assigned to a specified day.
  final List<Event>? events;

  /// Whether start of the week is Sunday or Monday.
  final bool mondayWeek;

  /// List of days in week to be considered as weekend.
  /// Use built-in [DateTime] weekday constants (e.g '1' is for 'DateTime.monday')
  final List<int> weekendDays;

  /// Primary calendar theme color
  final Color? primaryColor;

  /// Week name color
  final Color? weekColor;

  /// Holiday calendar theme color
  final Color? holidayColor;

  /// Event calendar theme color
  final Color? eventColor;

  /// Decoration for today's cell.
  final BoxDecoration? todayDecoration;

  /// Decoration for selected day's cell.
  final BoxDecoration? selectedDayDecoration;

  /// Builds the widget for particular day.
  final Widget Function(DateTime)? dayBuilder;

  /// Called when the user picks a day.
  final OnSelectedDate onDateSelected;

  /// Called when the user changes month.
  final OnMonthChanged? onMonthChanged;

  @override
  State<NepaliCalx> createState() => _NepaliCalxState();
}

class _NepaliCalxState extends State<NepaliCalx> {
  late PageController _pageController;
  late DateTime _selectedDate;
  late DateTime _focusedDate;
  late int _currentMonthIndex;
  late DatePickerMode _displayType;

  int get _totalMonths {
    if (widget.calendarType == CalendarType.ad) {
      return DateUtils.monthDelta(widget.firstDate, widget.lastDate) + 1;
    } else {
      final NepaliDateTime firstDateBs = widget.firstDate.toNepaliDateTime();
      final NepaliDateTime lastDateBs = widget.lastDate.toNepaliDateTime();
      return (lastDateBs.year - firstDateBs.year) * 12 +
          (lastDateBs.month - firstDateBs.month) +
          1;
    }
  }

  int _getPageIndexForDate(DateTime date) {
    if (widget.calendarType == CalendarType.ad) {
      return DateUtils.monthDelta(widget.firstDate, date);
    } else {
      final NepaliDateTime firstDateBs = widget.firstDate.toNepaliDateTime();
      final NepaliDateTime dateBs = date.toNepaliDateTime();
      return (dateBs.year - firstDateBs.year) * 12 +
          (dateBs.month - firstDateBs.month);
    }
  }

  DateTime _getMonthForPageIndex(int index) {
    if (widget.calendarType == CalendarType.ad) {
      return DateTime(widget.firstDate.year, widget.firstDate.month + index, 1);
    } else {
      final NepaliDateTime firstDateBs = widget.firstDate.toNepaliDateTime();
      final int totalMonths = firstDateBs.month + index;
      final int year = firstDateBs.year + ((totalMonths - 1) ~/ 12);
      final int month = ((totalMonths - 1) % 12) + 1;
      return NepaliDateTime(year, month, 1).toDateTime();
    }
  }

  @override
  void initState() {
    super.initState();

    NepaliUtils(Language.nepali);
    _displayType = DatePickerMode.day;
    _selectedDate = widget.initialDate;
    _focusedDate = widget.initialDate;
    _currentMonthIndex = _getPageIndexForDate(_focusedDate)
        .clamp(0, _totalMonths > 0 ? _totalMonths - 1 : 0);
    _pageController = PageController(initialPage: _currentMonthIndex);
  }

  @override
  void didUpdateWidget(NepaliCalx oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.calendarType != widget.calendarType ||
        oldWidget.firstDate != widget.firstDate ||
        oldWidget.lastDate != widget.lastDate) {
      _currentMonthIndex = _getPageIndexForDate(_focusedDate)
          .clamp(0, _totalMonths > 0 ? _totalMonths - 1 : 0);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentMonthIndex);
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Get the days in the month in english calendar
  List<DateTime> _englishDaysInMonth(DateTime date) {
    final first = Utils.firstDayOfMonth(date);
    final daysBefore =
        (widget.mondayWeek ? first.weekday - 1 : first.weekday) % 7;
    final firstToDisplay = first.subtract(Duration(days: daysBefore));
    final last = Utils.lastDayOfMonth(date);
    var daysAfter = 7 - (widget.mondayWeek ? last.weekday - 1 : last.weekday);
    if (daysAfter == 0) {
      daysAfter = 7;
    }

    final lastToDisplay = last.add(Duration(days: daysAfter));
    return Utils.daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  /// Get the days in the month in nepali calendar
  List<DateTime> _nepaliDaysInMonth(DateTime date) {
    NepaliDateTime nepalitDate = date.toNepaliDateTime();
    DateTime first =
        NepaliDateTime(nepalitDate.year, nepalitDate.month, 1).toDateTime();
    int daysInCurrentMonth =
        nepaliDaysInMonths[nepalitDate.year]?[nepalitDate.month] ?? 30;
    DateTime last =
        NepaliDateTime(nepalitDate.year, nepalitDate.month, daysInCurrentMonth)
            .toDateTime();
    final daysBefore =
        (widget.mondayWeek ? first.weekday - 1 : first.weekday) % 7;
    final firstToDisplay = first.subtract(Duration(days: daysBefore));

    var daysAfter = 7 - (widget.mondayWeek ? last.weekday - 1 : last.weekday);
    if (daysAfter == 0) {
      daysAfter = 7;
    }

    final lastToDisplay = last.add(Duration(days: daysAfter));
    return Utils.daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  void _handleDisplayTypeChanged() {
    setState(() {
      _displayType = _displayType == DatePickerMode.day
          ? DatePickerMode.year
          : DatePickerMode.day;
    });
  }

  // called on page changed
  void _handleMonthPageChanged(int monthPage) {
    _currentMonthIndex = monthPage;
    final DateTime newFocusedDate = _getMonthForPageIndex(monthPage);
    if (!Utils.isSameMonth(widget.calendarType, _focusedDate, newFocusedDate)) {
      _focusedDate = newFocusedDate;
      _handleMonthChanged(newFocusedDate);
      setState(() {});
    }
  }

  // on year changed
  void _handleYearChanged(DateTime value) {
    if (value.isBefore(widget.firstDate)) {
      value = widget.firstDate;
    } else if (value.isAfter(widget.lastDate)) {
      value = widget.lastDate;
    }
    _displayType = DatePickerMode.day;
    _focusedDate = value;
    _selectedDate = value;
    _currentMonthIndex = _getPageIndexForDate(value)
        .clamp(0, _totalMonths > 0 ? _totalMonths - 1 : 0);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(_currentMonthIndex);
    }
    _handleMonthChanged(value);
    setState(() {});
  }

  // on month changed
  void _handleMonthChanged(DateTime currentDate) {
    var date = widget.calendarType == CalendarType.ad
        ? currentDate
        : currentDate.toNepaliDateTime();
    List<Event>? monthsEvents = widget.events
        ?.where((item) =>
            item.date != null &&
            Utils.isSameMonth(widget.calendarType, item.date!, currentDate))
        .toList();
    widget.onMonthChanged?.call(date, monthsEvents);
  }

  // on date selected
  void _handleDateSelected(DateTime currentDate) {
    var date = widget.calendarType == CalendarType.ad
        ? currentDate
        : currentDate.toNepaliDateTime();

    List<Event>? todaysEvents = widget.events
        ?.where((item) =>
            item.date != null && Utils.isSameDay(item.date!, currentDate))
        .toList();
    _selectedDate = currentDate;
    _focusedDate = currentDate;
    widget.onDateSelected.call(date, todaysEvents);
    setState(() {});
  }

  // check if event exist in the selected date
  bool _checkEventOnDate(DateTime day, DateTime monthDate) {
    if (widget.events != null) {
      for (Event event in widget.events!) {
        if (event.date != null && Utils.isSameDay(event.date!, day)) {
          if (Utils.isSameMonth(widget.calendarType, day, monthDate)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Widget _buildWeekRow(BuildContext context, int index) {
    final DateTime monthDate = _getMonthForPageIndex(index);
    final List<DateTime> daysInMonth = widget.calendarType == CalendarType.bs
        ? _nepaliDaysInMonth(monthDate)
        : _englishDaysInMonth(monthDate);

    List<String> weeks = [];
    if (widget.mondayWeek) {
      weeks = widget.calendarType == CalendarType.bs
          ? Utils.nepaliMondayWeek
          : Utils.englishMondayWeek;
    } else {
      weeks = widget.calendarType == CalendarType.bs
          ? Utils.nepaliWeek
          : Utils.englishWeek;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final int rows = (daysInMonth.length / 7).ceil();
        final double itemWidth = constraints.maxWidth / 7;
        final double availableGridHeight = constraints.maxHeight - 30.0;
        final double itemHeight = (availableGridHeight > 0 && rows > 0)
            ? (availableGridHeight / rows)
            : itemWidth;
        final double aspectRatio =
            itemHeight > 0 ? (itemWidth / itemHeight) : 1.0;

        return Column(
          children: [
            Table(
              children: <TableRow>[
                TableRow(
                  children: weeks
                      .map(
                        (day) => Center(
                          child: Text(
                            day,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                    color: widget.weekColor ??
                                        Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.color),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daysInMonth.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (context, dayIndex) {
                  DateTime dayToBuild = daysInMonth[dayIndex];
                  Color? mainDayColor;
                  Color? secondaryDayColor =
                      Theme.of(context).textTheme.bodyMedium?.color;
                  BoxDecoration decoration = const BoxDecoration();

                  final bool isCurrentMonthDay = Utils.isSameMonth(
                      widget.calendarType, monthDate, dayToBuild);

                  if (Utils.isSameDay(dayToBuild, _selectedDate) &&
                      isCurrentMonthDay) {
                    mainDayColor = Colors.white;
                    decoration = widget.selectedDayDecoration ??
                        BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          shape: BoxShape.circle,
                        );
                  } else if (Utils.isToday(dayToBuild)) {
                    mainDayColor = Theme.of(context).primaryColorDark;
                    decoration = widget.todayDecoration ??
                        BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          shape: BoxShape.circle,
                        );
                  } else if (!isCurrentMonthDay) {
                    mainDayColor = Colors.grey.withValues(alpha: 0.5);
                    secondaryDayColor = Colors.grey.withValues(alpha: 0.5);
                  } else if (Utils.isWeekend(dayToBuild,
                      weekendDays: widget.weekendDays)) {
                    mainDayColor = widget.holidayColor ??
                        Theme.of(context).colorScheme.secondary;
                  } else if (Utils.holidays(dayToBuild, widget.holidays)) {
                    mainDayColor = widget.holidayColor ??
                        Theme.of(context).colorScheme.secondary;
                  } else {
                    mainDayColor =
                        Theme.of(context).textTheme.bodyMedium?.color;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (isCurrentMonthDay) {
                        _handleDateSelected(dayToBuild);
                      }
                    },
                    child: Container(
                      decoration: decoration,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 3.0,
                        vertical: 2.0,
                      ),
                      child: Stack(
                        children: [
                          widget.dayBuilder == null
                              ? DayBuilder(
                                  dayToBuild: dayToBuild,
                                  calendarType: widget.calendarType,
                                  dayColor: mainDayColor,
                                  secondaryDayColor: secondaryDayColor,
                                )
                              : widget.dayBuilder!(dayToBuild),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Visibility(
                              visible: _checkEventOnDate(dayToBuild, monthDate),
                              child: Container(
                                width: 5.0,
                                height: 5.0,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 10.0,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.eventColor ??
                                      Theme.of(context).colorScheme.secondary,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(1000.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildYearPicker() {
    switch (widget.calendarType) {
      case CalendarType.ad:
        return YearPicker(
          currentDate: _selectedDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectedDate: _selectedDate,
          onChanged: _handleYearChanged,
        );
      case CalendarType.bs:
        return NepaliYearPicker(
          currentDate: _selectedDate.toNepaliDateTime(),
          firstDate: widget.firstDate.toNepaliDateTime(),
          lastDate: widget.lastDate.toNepaliDateTime(),
          initialDate: _focusedDate.toNepaliDateTime(),
          selectedDate: _selectedDate.toNepaliDateTime(),
          onChanged: (date) => _handleYearChanged(date.toDateTime()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFirstMonth = _currentMonthIndex <= 0;
    final bool isLastMonth = _currentMonthIndex >= _totalMonths - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _handleDisplayTypeChanged,
                child: MonthName(
                  date: _focusedDate,
                  primaryColor: widget.primaryColor,
                  calendarType: widget.calendarType,
                ),
              ),
              Visibility(
                visible: _displayType == DatePickerMode.day,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        size: 30.0,
                        color: isFirstMonth
                            ? (widget.primaryColor ??
                                    Theme.of(context).primaryColor)
                                .withValues(alpha: 0.3)
                            : (widget.primaryColor ??
                                Theme.of(context).primaryColor),
                      ),
                      onPressed: isFirstMonth
                          ? null
                          : () {
                              _pageController.previousPage(
                                duration: _monthScrollDuration,
                                curve: Curves.easeInOut,
                              );
                            },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        size: 30.0,
                        color: isLastMonth
                            ? (widget.primaryColor ??
                                    Theme.of(context).primaryColor)
                                .withValues(alpha: 0.3)
                            : (widget.primaryColor ??
                                Theme.of(context).primaryColor),
                      ),
                      onPressed: isLastMonth
                          ? null
                          : () {
                              _pageController.nextPage(
                                duration: _monthScrollDuration,
                                curve: Curves.easeInOut,
                              );
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5.0),
        _displayType == DatePickerMode.day
            ? Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _totalMonths,
                  itemBuilder: _buildWeekRow,
                  onPageChanged: _handleMonthPageChanged,
                ),
              )
            : Expanded(
                child: _buildYearPicker(),
              ),
      ],
    );
  }
}
