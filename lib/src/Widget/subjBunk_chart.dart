import 'package:charts_flutter/flutter.dart' as charts;
import 'package:bunk_manager/src/subjBunk.dart';
import 'package:flutter/material.dart';

class SubjBunkedClassChart extends StatelessWidget {
  final List<SubjBunkedClasses> data;

  SubjBunkedClassChart({@required this.data});

  @override
Widget build(BuildContext context) {

  List<charts.Series<SubjBunkedClasses,DateTime>> series = [
    charts.Series(
      id: "Bunks",
      data: data,
      domainFn: (SubjBunkedClasses series, _) => series.date,
      measureFn: (SubjBunkedClasses series, _) => series.hours,
      colorFn: (SubjBunkedClasses series, _) => series.barColor),
  ];
      return Container(
      height: 250,
      padding: EdgeInsets.all(10),
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
                child: charts.TimeSeriesChart(series, animate: true, animationDuration: Duration(seconds:2),
                behaviors: [
                    new charts.SeriesLegend(entryTextStyle: charts.TextStyleSpec(
                        color: charts.MaterialPalette.black,
                        fontFamily: 'Normal',
                        fontSize: 15),
                   ),
                    //new charts.SlidingViewport(),
                    new charts.PanAndZoomBehavior(),

                ],),
              )
            ],
          ),
        ),
      ),
    );

}

}
