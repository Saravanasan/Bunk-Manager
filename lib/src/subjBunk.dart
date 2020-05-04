import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/foundation.dart';

class SubjBunkedClasses {
  final DateTime date;
  final int hours;
  final subject;
  final charts.Color barColor;
  final String bid;

  SubjBunkedClasses(
    {@required this.date,
    @required this.hours,
    @required this.bid,
    @required this.subject,
    @required this.barColor}
  );
}