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
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';

import '../../nepali_calx.dart';

class MonthName extends StatelessWidget {
  const MonthName({
    super.key,
    required this.date,
    required this.calendarType,
    required this.primaryColor,
  });

  final DateTime date;
  final CalendarType calendarType;
  final Color? primaryColor;

  @override
  Widget build(BuildContext context) {
    TextStyle? titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(color: primaryColor ?? Theme.of(context).primaryColor);

    TextStyle? subTitleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
        fontSize: 12.0, color: primaryColor ?? Theme.of(context).primaryColor);

    String title;
    String subtitle;

    if (calendarType == CalendarType.bs) {
      NepaliDateTime nepaliDate = date.toNepaliDateTime();
      title = NepaliDateFormat('MMMM yyyy').format(nepaliDate);
      NepaliDateTime startBs =
          NepaliDateTime(nepaliDate.year, nepaliDate.month, 1);
      DateTime startAd = startBs.toDateTime();
      int daysInMonth =
          nepaliDaysInMonths[nepaliDate.year]?[nepaliDate.month] ?? 30;
      NepaliDateTime endBs =
          NepaliDateTime(nepaliDate.year, nepaliDate.month, daysInMonth);
      DateTime endAd = endBs.toDateTime();
      subtitle = startAd.month == endAd.month
          ? DateFormat.MMMM().format(startAd)
          : '${DateFormat.MMMM().format(startAd)}/${DateFormat.MMMM().format(endAd)}';
    } else {
      title = DateFormat('MMMM yyyy').format(date);
      DateTime startAd = DateTime(date.year, date.month, 1);
      DateTime endAd = Utils.lastDayOfMonth(date);
      NepaliDateTime startBs = startAd.toNepaliDateTime();
      NepaliDateTime endBs = endAd.toNepaliDateTime();
      subtitle = startBs.month == endBs.month
          ? NepaliDateFormat.MMMM().format(startBs)
          : '${NepaliDateFormat.MMMM().format(startBs)}/${NepaliDateFormat.MMMM().format(endBs)}';
    }

    return SizedBox(
      height: 48.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            title,
            style: titleStyle,
          ),
          Text(
            subtitle,
            style: subTitleStyle,
          ),
        ],
      ),
    );
  }
}
