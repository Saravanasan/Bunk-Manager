import 'package:charts_flutter/flutter.dart' as charts;
import 'package:bunk_manager/src/bunk.dart';
import 'package:flutter/material.dart';

class BunkedClassChart extends StatelessWidget {
  final List<BunkedClasses> data;

  BunkedClassChart({@required this.data});

  @override
  Widget build(BuildContext context) {

    List<charts.Series<BunkedClasses, String>> series = [
      charts.Series(
        id: "Bunks",
        data: data,
        domainFn: (BunkedClasses series, _) => series.subject,
        measureFn: (BunkedClasses series, _) => series.hours,
        colorFn: (BunkedClasses series, _) => series.barColor
      ),
    ];
      return Container(
      height: 400,
      padding: EdgeInsets.all(20),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                "Bunked classes",
                style: Theme.of(context).textTheme.body2,
              ),
              Expanded(
                child: charts.BarChart(series, animate: true, animationDuration: Duration(seconds:2),
                domainAxis: new charts.OrdinalAxisSpec(
                    renderSpec: charts.SmallTickRendererSpec(labelRotation: 45, labelStyle: new charts.TextStyleSpec(
                      fontSize: 10, // size in Pts.
                    ),
                  ),
                  viewport: new charts.OrdinalViewport('Networks', 3),
                ),
                behaviors: [
                  new charts.SeriesLegend(entryTextStyle: charts.TextStyleSpec(
                    color: charts.MaterialPalette.black,
                    fontFamily: 'Normal',
                    fontSize: 15
                  ),),
                  new charts.SlidingViewport(),
                  new charts.PanAndZoomBehavior(),
                ],
              ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
