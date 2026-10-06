import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calx/nepali_calx.dart';
import 'package:nepali_utils/nepali_utils.dart';

void main() {
  group('Utils tests', () {
    test('isSameDay accurately checks year, month, and day', () {
      final dt1 = DateTime(2024, 5, 1, 0, 0, 0);
      final dt2 = DateTime(2024, 5, 1, 23, 59, 59);
      final dt3 = DateTime(2024, 5, 2, 0, 0, 0);

      expect(Utils.isSameDay(dt1, dt2), isTrue);
      expect(Utils.isSameDay(dt1, dt3), isFalse);
    });

    test('holidays accurately matches holiday dates regardless of time', () {
      final holiday = DateTime(2024, 5, 1, 0, 0, 0);
      final sameDayNoon = DateTime(2024, 5, 1, 12, 0, 0);
      final nextDayNoon = DateTime(2024, 5, 2, 12, 0, 0);

      expect(Utils.holidays(sameDayNoon, [holiday]), isTrue);
      expect(Utils.holidays(nextDayNoon, [holiday]), isFalse);
    });

    test('isSameMonth works for AD and BS', () {
      final ad1 = DateTime(2024, 5, 10);
      final ad2 = DateTime(2024, 5, 25);
      final ad3 = DateTime(2024, 6, 1);

      expect(Utils.isSameMonth(CalendarType.ad, ad1, ad2), isTrue);
      expect(Utils.isSameMonth(CalendarType.ad, ad1, ad3), isFalse);

      NepaliUtils(Language.nepali);
      final bs1 = NepaliDateTime(2081, 1, 5).toDateTime();
      final bs2 = NepaliDateTime(2081, 1, 25).toDateTime();
      final bs3 = NepaliDateTime(2081, 2, 1).toDateTime();

      expect(Utils.isSameMonth(CalendarType.bs, bs1, bs2), isTrue);
      expect(Utils.isSameMonth(CalendarType.bs, bs1, bs3), isFalse);
    });

    test('nepaliDaysInMonths has valid month day limits', () {
      final days = initializeDaysInMonths();
      expect(days.containsKey(2080), isTrue);
      expect(days[2080]!.length, equals(13)); // index 0 + 12 months
      expect(days[2080]![1], inInclusiveRange(28, 32));
    });
  });

  group('NepaliCalx Widget tests', () {
    testWidgets('renders calendar in AD mode and selects a date',
        (tester) async {
      DateTime? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: NepaliCalx(
                initialDate: DateTime(2024, 5, 15),
                firstDate: DateTime(2020, 1, 1),
                lastDate: DateTime(2028, 12, 31),
                calendarType: CalendarType.ad,
                onDateSelected: (date, events) {
                  selected = date is NepaliDateTime ? date.toDateTime() : date;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NepaliCalx), findsOneWidget);
      expect(find.text('May 2024'), findsOneWidget);

      // Tap on day 20
      final day20Finder = find.text('20');
      expect(day20Finder, findsWidgets);
      await tester.tap(day20Finder.first);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
    });

    testWidgets('renders calendar in BS mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: NepaliCalx(
                initialDate: DateTime(2024, 5, 15),
                firstDate: DateTime(2020, 1, 1),
                lastDate: DateTime(2028, 12, 31),
                calendarType: CalendarType.bs,
                onDateSelected: (date, events) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NepaliCalx), findsOneWidget);
    });

    testWidgets('navigates to next and previous month using chevron buttons',
        (tester) async {
      DateTime? monthChangedDate;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: NepaliCalx(
                initialDate: DateTime(2024, 5, 15),
                firstDate: DateTime(2020, 1, 1),
                lastDate: DateTime(2028, 12, 31),
                calendarType: CalendarType.ad,
                onDateSelected: (date, events) {},
                onMonthChanged: (date, events) {
                  monthChangedDate =
                      date is NepaliDateTime ? date.toDateTime() : date;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('May 2024'), findsOneWidget);

      // Click chevron right to go to June 2024
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.text('June 2024'), findsOneWidget);
      expect(monthChangedDate?.month, equals(6));

      // Click chevron left to return to May 2024
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('May 2024'), findsOneWidget);
      expect(monthChangedDate?.month, equals(5));
    });

    testWidgets('supports dynamic calendar type switching via didUpdateWidget',
        (tester) async {
      CalendarType currentType = CalendarType.ad;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          currentType = currentType == CalendarType.ad
                              ? CalendarType.bs
                              : CalendarType.ad;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                ),
                body: SizedBox(
                  height: 500,
                  child: NepaliCalx(
                    initialDate: DateTime(2024, 5, 15),
                    firstDate: DateTime(2020, 1, 1),
                    lastDate: DateTime(2028, 12, 31),
                    calendarType: currentType,
                    onDateSelected: (date, events) {},
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('May 2024'), findsOneWidget);

      // Toggle to BS
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // In BS mode, title is in Nepali
      expect(find.byType(NepaliCalx), findsOneWidget);
    });

    testWidgets('opens and selects date from showNepaliCalxDialog',
        (tester) async {
      DateTime? dialogResult;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await showNepaliCalxDialog(
                    context: context,
                    initialDate: DateTime(2024, 5, 15),
                    firstDate: DateTime(2020, 1, 1),
                    lastDate: DateTime(2028, 12, 31),
                    calendarType: CalendarType.ad,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);

      // Tap on day 18 in dialog
      final day18Finder = find.text('18');
      expect(day18Finder, findsWidgets);
      await tester.tap(day18Finder.first);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(dialogResult, isNotNull);
      expect(dialogResult?.day, equals(18));
    });
  });
}
