import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/foundation.dart';

class BunkedClasses {
  final String subject;
  final int hours;
  final charts.Color barColor;

  BunkedClasses(
    {@required this.subject,
    @required this.hours,
    @required this.barColor}
  );
}