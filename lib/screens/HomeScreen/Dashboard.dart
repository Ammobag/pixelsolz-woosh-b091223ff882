// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:whoosh/core/AQI.dart';
import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/BaseScreen.dart';
import 'package:whoosh/core/dataAccess/HubDataAccess.dart';
import 'package:whoosh/core/entities/Chart.dart';
import 'package:whoosh/core/entities/Forecast.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide CornerStyle;
import 'package:flutter/material.dart';
import 'package:whoosh/core/entities/Hub.dart';
import 'package:whoosh/core/entities/HubAqi.dart' hide Data;
import 'package:whoosh/core/entities/HubData.dart' hide Data;
import 'package:whoosh/core/entities/Node.dart';
import 'package:whoosh/core/widgets/TextX.dart';

class _PPMChartData {
  _PPMChartData(this.x, this.y);
  final DateTime x;
  final double y;
}

class _VOCChartData {
  _VOCChartData(this.x, this.y);
  final DateTime x;
  final double y;
}

class _TEMPChartData {
  _TEMPChartData(this.x, this.y);
  final DateTime x;
  final double y;
}

class _HumChartData {
  _HumChartData(this.x, this.y);
  final DateTime x;
  final double y;
}

class _OutdoorForecastChartData {
  _OutdoorForecastChartData(this.x, this.y);
  final DateTime x;
  final int? y;
}

class _FilterChartData {
  _FilterChartData(this.x, this.y);
  final DateTime x;
  final double y;
}

class Dashboard extends BasePage {
  final List<Forecast> outdoorForecast;

  Dashboard({
    Key? key,
    required this.outdoorForecast,
  }) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}
class OutdoorDataSet {
  OutdoorDataSet({
    this.reportingArea,
    this.stateCode,
    this.category,
    this.temp,
    this.percent,
    this.pm2,
    this.ozone,
  });

  String? reportingArea;
  String? stateCode;
  String? category;
  String? temp;
  String? percent;
  String? pm2;
  String? ozone;
}
class _DashboardState extends BaseState<Dashboard> with MasterPage {
  double _indoorData = 0.0;
  Hub _hub = Hub();
  List<HubData> _hubData = [];
  HubAqi? hubAqi;
  initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      getHub();
      
    });
  }

  Future<void> getHub() async {
    final rModel = EmptyBaseApiRequestModel();
    widget.showPageLoader(context, true);
    var res = await HubDataAccess.getHub(rModel);
    widget.showPageLoader(context, false);
    widget.processResponseData(context, res);
    
    if (res.status == false) {
      return;
    }
      final FlutterBlue flutterBlue = FlutterBlue.instance;
      bool isOn = await flutterBlue.isOn;
      if (isOn) {
        flutterBlue.startScan();
        flutterBlue.scanResults.listen((List<ScanResult> results) {
          // print(results);
          for (ScanResult result in results) {
          }
        }, onError: (err) {
          print(err.toString());
          print("error");
        });
        flutterBlue.stopScan();
      }
    setState(() {
      _hub = res.result!;
      print("the hub id");
      print(_hub.nodes);
      // print(_hub.hub!.deviceId ?? "");
      if(_hub.hub != null){
        getHubAqiLogs(_hub.hub!.deviceId);
      }
      //WOOSH_3494540c5918
    });
    getIndoorData(
        _hub.hub!.deviceId!, DateFormat('yyyy-MM-dd').format(DateTime.now()));
  }

  getHubAqiLogs(device_id) async{
    final rModel = EmptyBaseApiRequestModel();
    var res = await HubDataAccess.getHubAqiData(rModel,device_id);
    hubAqi = res.result;
    // print(res.result!.data!.pm25 ?? "");
    // print("hub aqi");
  }

  Future<void> getIndoorData(String hub_id, String device_time) async {
    final rModel = GetHubDataRequestModel();
    rModel.hub_id = hub_id;
    rModel.device_time = device_time;
    widget.showPageLoader(context, true);
    var res = await HubDataAccess.getHubData(rModel);
    if (mounted) widget.showPageLoader(context, false);
    widget.processResponseData(context, res);
    print(res.message);
    print("hello all");
    print(res.result);
    if (res.status == false || res.result == null) {
      return;
    }
    setState(() {
      _indoorData = double.parse(res.result![0].data!.pm25!);
      _hubData = res.result!;
    });
  }

  List<ScatterSeries<dynamic, DateTime>> _getTimeOfDayLineSeries() {
    final List<_PPMChartData> pPMChartData = _hubData
        .map((e) => _PPMChartData(
            DateTime.parse(e.deviceTime!), double.parse(e.data!.pm25!)))
        .toList();
    final List<_OutdoorForecastChartData> outdoorForecastChartData = widget
        .outdoorForecast
        .map((e) => _OutdoorForecastChartData(
            DateTime.parse(e.dateForecast! + "12:00:00"), e.aqi))
        .toList();
    return <ScatterSeries<dynamic, DateTime>>[
      ScatterSeries<_PPMChartData, DateTime>(
        animationDuration: 2500,
        dataSource: pPMChartData,
        xValueMapper: (_PPMChartData sales, _) => sales.x,
        yValueMapper: (_PPMChartData sales, _) => sales.y,
        name: 'Indoor',
        markerSettings: const MarkerSettings(isVisible: true),
      ),
      ScatterSeries<_OutdoorForecastChartData, DateTime>(
        animationDuration: 2500,
        dataSource: outdoorForecastChartData,
        name: 'Outdoor',
        xValueMapper: (_OutdoorForecastChartData sales, _) => sales.x,
        yValueMapper: (_OutdoorForecastChartData sales, _) => sales.y,
        markerSettings: const MarkerSettings(isVisible: true),
      )
    ];
  }

  List<ScatterSeries<dynamic, DateTime>> _getVocSeries() {
    final List<_VOCChartData> pPMChartData = _hubData
        .map((e) => _VOCChartData(
            DateTime.parse(e.deviceTime!), double.parse(e.data !=null ? e.data!.tvoc! : "0")))
        .toList();
    return <ScatterSeries<dynamic, DateTime>>[
      ScatterSeries<_VOCChartData, DateTime>(
        animationDuration: 2500,
        dataSource: pPMChartData,
        xValueMapper: (_VOCChartData sales, _) => sales.x,
        yValueMapper: (_VOCChartData sales, _) => sales.y,
        name: 'Indoor',
        markerSettings: const MarkerSettings(isVisible: true),
      ),
    ];
  }

  List<ScatterSeries<dynamic, DateTime>> _getTemparatureSeries() {
    final List<_TEMPChartData> pPMChartData = _hubData
        .map((e) => _TEMPChartData(
            DateTime.parse(e.deviceTime!), double.parse(e.data !=null ? e.data!.temp! : "0")))
        .toList();
    return <ScatterSeries<dynamic, DateTime>>[
      ScatterSeries<_TEMPChartData, DateTime>(
        animationDuration: 2500,
        dataSource: pPMChartData,
        xValueMapper: (_TEMPChartData sales, _) => sales.x,
        yValueMapper: (_TEMPChartData sales, _) => sales.y,
        name: 'Indoor',
        markerSettings: const MarkerSettings(isVisible: true),
      ),
    ];
  }

  List<ScatterSeries<dynamic, DateTime>> _getHumiditySeries() {
    final List<_HumChartData> pPMChartData = _hubData
        .map((e) => _HumChartData(
            DateTime.parse(e.deviceTime!), double.parse(e.data !=null ? e.data!.hum! : "0")))
        .toList();
    return <ScatterSeries<dynamic, DateTime>>[
      ScatterSeries<_HumChartData, DateTime>(
        animationDuration: 2500,
        dataSource: pPMChartData,
        xValueMapper: (_HumChartData sales, _) => sales.x,
        yValueMapper: (_HumChartData sales, _) => sales.y,
        name: 'Indoor',
        markerSettings: const MarkerSettings(isVisible: true),
      ),
    ];
  }
  

  Widget getFilterCharts() {
    return Column(
      children: _hub.chart!
          .map<Widget>(
            (item) => FilterChartCard(chart: item,nodes: _hub.nodes ?? [],),
          )
          .toList(),
    );
  }

  OutdoorDataSet getOutDoreDatasetForWidget(){
    // print(widget.outdoorForecast.first.reportingArea);
      OutdoorDataSet _outDoorDataSet = widget.outdoorForecast.length > 0 ?   OutdoorDataSet(
        category: widget.outdoorForecast.first.category !=  null ? (widget.outdoorForecast.first.category!.name ?? "") : "",
        reportingArea: widget.outdoorForecast.first.reportingArea,
        stateCode: widget.outdoorForecast.first.stateCode
      ):OutdoorDataSet();
      return _outDoorDataSet;
  }

  OutdoorDataSet getHubAqiDataSet(){
    // print(widget.outdoorForecast.first.reportingArea);
      OutdoorDataSet _outDoorDataSet =  OutdoorDataSet(
        // category: hubAqi !=  null ? (widget.outdoorForecast.first.category!.name ?? "") : "",
        reportingArea: hubAqi?.hubId,
        pm2: hubAqi?.data?.pm25,
        temp: hubAqi?.data?.temp,
        percent: hubAqi?.data?.hum,
        // stateCode: widget.outdoorForecast.first.stateCode
      );
      return _outDoorDataSet;
  }

  Widget getCardOfAqi(OutdoorDataSet outDoorDataSet){
      return Card(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: MediaQuery.of(context).size.height/5,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                SizedBox(height:10),
                Text((outDoorDataSet.reportingArea ?? "") + " " + (outDoorDataSet.stateCode ?? ""),style: TextStyle(
                  fontWeight: FontWeight.w600
                ),),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.grey[100],
                  ),
                  height: MediaQuery.of(context).size.height/7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Container(
                          width: MediaQuery.of(context).size.width/6,child: 
                          Text("Air Quality now",textAlign: TextAlign.center,),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2,vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          width: MediaQuery.of(context).size.width/6,
                          child: Text(
                            outDoorDataSet.category ?? "Good",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Icon(Icons.thermostat),
                        Text(outDoorDataSet.temp ?? "NA")],),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        ImageIcon(
                            AssetImage('assets/images/water-droplet.png'),
                            color: Color(0xFF3A5A98),
                        ),
                        Text(outDoorDataSet.percent ?? "NA")],),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Text("PM2.5"),
                        Text(outDoorDataSet.pm2 ?? "NA")],),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Text("OZONE"),
                        Text(outDoorDataSet.ozone ?? "NA" )],),
                    ],
                  ),
                )
              ],),
            ),
      );
  }

  @override
  Widget body() {
    return SingleChildScrollView(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getCardOfAqi(getOutDoreDatasetForWidget()),
          getCardOfAqi(getHubAqiDataSet()),
          /* Card(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 30,
              ),
              child: Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Column(
                      children: [
                        TextX.heading("Indoor"),
                        SizedBox(
                          height: 200,
                          child: Gauge(
                            value: _indoorData,
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget.outdoorForecast.length > 0
                      ? Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              TextX.heading("Outdoor"),
                              SizedBox(
                                height: 200,
                                child: Gauge(
                                  value: widget.outdoorForecast.first.aqi!
                                      .toDouble(),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ), */
          Container(
            height: 320,
            // color: Colors.green,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      title: ChartTitle(text: 'Perticulate Matter(Last 8 hours)'),
                      legend: Legend(
                        position: LegendPosition.bottom,
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                        toggleSeriesVisibility: false,
                      ),
                      primaryXAxis: DateTimeAxis(
                        intervalType: DateTimeIntervalType.auto,
                        dateFormat: DateFormat.Hm(),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        majorGridLines: MajorGridLines(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        labelFormat: '{value} ppm',
                        axisLine: const AxisLine(width: 0),
                        majorTickLines:
                            const MajorTickLines(color: Colors.transparent),
                      ),
                      series: _getTimeOfDayLineSeries(),
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      title: ChartTitle(text: 'VOC(Last 8 hours)'),
                      legend: Legend(
                        position: LegendPosition.bottom,
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                        toggleSeriesVisibility: false,
                      ),
                      primaryXAxis: DateTimeAxis(
                        intervalType: DateTimeIntervalType.auto,
                        dateFormat: DateFormat.Hm(),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        majorGridLines: MajorGridLines(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        labelFormat: '{value} voc',
                        axisLine: const AxisLine(width: 0),
                        majorTickLines:
                            const MajorTickLines(color: Colors.transparent),
                      ),
                      series: _getVocSeries(),
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      title: ChartTitle(text: 'Temparature(Last 8 hours)'),
                      legend: Legend(
                        position: LegendPosition.bottom,
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                        toggleSeriesVisibility: false,
                      ),
                      primaryXAxis: DateTimeAxis(
                        intervalType: DateTimeIntervalType.auto,
                        dateFormat: DateFormat.Hm(),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        majorGridLines: MajorGridLines(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        labelFormat: '{value} temp',
                        axisLine: const AxisLine(width: 0),
                        majorTickLines:
                            const MajorTickLines(color: Colors.transparent),
                      ),
                      series: _getTemparatureSeries(),
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      title: ChartTitle(text: 'Relative Humidity(Last 8 hours)'),
                      legend: Legend(
                        position: LegendPosition.bottom,
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                        toggleSeriesVisibility: false,
                      ),
                      primaryXAxis: DateTimeAxis(
                        intervalType: DateTimeIntervalType.auto,
                        dateFormat: DateFormat.Hm(),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        majorGridLines: MajorGridLines(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        labelFormat: '{value} hum',
                        axisLine: const AxisLine(width: 0),
                        majorTickLines:
                            const MajorTickLines(color: Colors.transparent),
                      ),
                      series: _getHumiditySeries(),
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
                  ),
                )
              ],
            ),
          ),
          
          /* widget.outdoorForecast.length > 1
              ? 
              Card(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextX.heading("Forecast"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: AQI.getColorCode(
                                      widget.outdoorForecast.last.aqi!
                                          .toDouble(),
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(50),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.outdoorForecast.first.aqi!
                                          .toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                Text(
                                  'Today',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: AQI.getColorCode(
                                      widget.outdoorForecast[1].aqi!.toDouble(),
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(50),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.outdoorForecast[1].aqi!.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                Text(
                                  'Tomorrow',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : Container(), */
          if (_hub.hub == null) Container() else getFilterCharts()
        ],
      ),
    );
  }
}

class Gauge extends StatefulWidget {
  final double value;
  Gauge({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  State<Gauge> createState() => _GaugeState();
}

class _GaugeState extends State<Gauge> {
  @override
  void initState() {
    super.initState();
  }

  String getAnnotation(double value) {
    String message = "";
    if (value <= 50) {
      message = "Good";
    } else if (value > 50 && value <= 100) {
      message = "Satisfactory";
    } else if (value > 100 && value <= 150) {
      message = "Moderate";
    } else if (value > 150 && value <= 200) {
      message = "Poor";
    } else if (value > 200 && value <= 300) {
      message = "Very Poor";
    } else {
      message = "Severe";
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
            showLabels: false,
            showTicks: false,
            startAngle: 270,
            endAngle: 270,
            minimum: 0,
            maximum: 300,
            radiusFactor: 0.8,
            axisLineStyle: const AxisLineStyle(
              thicknessUnit: GaugeSizeUnit.factor,
              thickness: 0.15,
            ),
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                angle: 180,
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.value.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      getAnnotation(widget.value),
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            pointers: <GaugePointer>[
              RangePointer(
                value: widget.value,
                cornerStyle: CornerStyle.bothCurve,
                enableAnimation: true,
                animationDuration: 1200,
                animationType: AnimationType.ease,
                sizeUnit: GaugeSizeUnit.factor,
                color: AQI.getColorCode(widget.value),
                width: 0.15,
              ),
            ]),
      ],
    );
  }
}

class FilterChartCard extends StatefulWidget {
  final Chart chart;
  final List<Node> nodes;
  FilterChartCard({Key? key, required this.chart, required this.nodes}) : super(key: key);

  @override
  _FilterChartCardState createState() => _FilterChartCardState();
}

class _FilterChartCardState extends State<FilterChartCard> {
  String dropdownValue = "Past Day";
  List<ScatterSeries<_FilterChartData, DateTime>>? currentPressureScatterSeries;
  List<LineSeries<_FilterChartData, DateTime>>? temperatureLineSeries;
  List<LineSeries<_FilterChartData, DateTime>>? humidityLineSeries;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      createSeries(dropdownValue);
    });
  }

  createSeries(
    String duration,
  ) {
    List<_FilterChartData> currentPressureChartData = <_FilterChartData>[];
    List<_FilterChartData> temperatureChartData = <_FilterChartData>[];
    List<_FilterChartData> humidityChartData = <_FilterChartData>[];
    var now = DateTime.now();
    var now_1d = now.subtract(Duration(days: 1));
    var now_1w = now.subtract(Duration(days: 7));
    var now_1m = now.subtract(Duration(days: 30));
    var now_2m = now.subtract(Duration(days: 60));
    var now_3m = now.subtract(Duration(days: 90));
    int numberOfDays = duration == "Past Day"
        ? 1
        : duration == "Past Week"
            ? 7
            : duration == "Past Month"
                ? 30
                : duration == "Past 2 Months"
                    ? 60
                    : 90;
    List<Data> requiredData = [];
    if (numberOfDays == 1) {
      requiredData = widget.chart.data!
          .where((element) => DateTime.parse(element.date!).isAfter(now_1d))
          .toList();
    } else if (numberOfDays == 7) {
      requiredData = widget.chart.data!
          .where((element) => DateTime.parse(element.date!).isAfter(now_1w))
          .toList();
    } else if (numberOfDays == 30) {
      requiredData = widget.chart.data!
          .where((element) => DateTime.parse(element.date!).isAfter(now_1m))
          .toList();
    } else if (numberOfDays == 60) {
      requiredData = widget.chart.data!
          .where((element) => DateTime.parse(element.date!).isAfter(now_2m))
          .toList();
    } else if (numberOfDays == 90) {
      requiredData = widget.chart.data!
          .where((element) => DateTime.parse(element.date!).isAfter(now_3m))
          .toList();
    }
    for (var i = 0; i < requiredData.length; i++,) {
      var relativeHumidity = -6 + 125 * requiredData[i].humidity! / pow(2, 16);
      var relativeTemperature =
          -46.85 + 175.72 * requiredData[i].temperature! / pow(2, 16);
      currentPressureChartData.add(
        _FilterChartData(
          DateTime.parse(requiredData[i].date!),
          requiredData[i].currentPressure!,
        ),
      );
      temperatureChartData.add(
        _FilterChartData(
          DateTime.parse(requiredData[i].date!),
          relativeTemperature,
        ),
      );
      humidityChartData.add(
        _FilterChartData(
          DateTime.parse(requiredData[i].date!),
          relativeHumidity,
        ),
      );
    }
    var newCurrentPressureScatterSeries =
        <ScatterSeries<_FilterChartData, DateTime>>[
      ScatterSeries<_FilterChartData, DateTime>(
        animationDuration: 1000,
        dataSource: currentPressureChartData,
        xValueMapper: (_FilterChartData chartData, _) => chartData.x,
        yValueMapper: (_FilterChartData chartData, _) => chartData.y,
        name: widget.chart.id,
        markerSettings: const MarkerSettings(isVisible: true),
        trendlines: <Trendline>[
          Trendline(type: TrendlineType.polynomial, color: Colors.blue)
        ],
      ),
    ];
    var newTemperatureLineSeries = <LineSeries<_FilterChartData, DateTime>>[
      LineSeries<_FilterChartData, DateTime>(
        animationDuration: 1000,
        dataSource: temperatureChartData,
        xValueMapper: (_FilterChartData chartData, _) => chartData.x,
        yValueMapper: (_FilterChartData chartData, _) => chartData.y,
        name: widget.chart.id,
        markerSettings: const MarkerSettings(isVisible: true),
      ),
    ];
    var newHumidityLineSeries = <LineSeries<_FilterChartData, DateTime>>[
      LineSeries<_FilterChartData, DateTime>(
        animationDuration: 1000,
        dataSource: humidityChartData,
        xValueMapper: (_FilterChartData chartData, _) => chartData.x,
        yValueMapper: (_FilterChartData chartData, _) => chartData.y,
        name: widget.chart.id,
        markerSettings: const MarkerSettings(isVisible: true),
      ),
    ];
    setState(() {
      currentPressureScatterSeries = newCurrentPressureScatterSeries;
      temperatureLineSeries = newTemperatureLineSeries;
      humidityLineSeries = newHumidityLineSeries;
    });
  }

  getNodeName(id){
    print(id);
    // print();
     Node node = widget.nodes.firstWhere((element) => element.deviceId == id);
    return node.vanityName ?? "";
    //widget.chart.id
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextX.subHeading(
                          
                          getNodeName(widget.chart.id)
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Fiter ID: ${widget.chart.id}"),
                            SizedBox(height: 2,),
                            Text("Filter Size: 16*25*1"),
                            SizedBox(height: 2,),
                            Text("Filter Rating: Merv 13"),
                            SizedBox(height: 2,),
                            Text("Est. Filter Life Remaining: 75 days"),
                            SizedBox(height: 2,),
                            Text("Average Household Air Exchanges: 2.4"),
                            SizedBox(height: 2,),
                            Text("Filter Install Date"),
                          ],
                        ),
                        /* Text(
                          widget.chart.data!.last.currentPressure.toString(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: AQI.getColorCode(
                              widget.chart.data!.first.currentPressure!
                                  .toDouble(),
                            ),
                          ),
                        ) */
                      ],
                    ),
                    /* DropdownButton<String>(
                      value: dropdownValue,
                      icon: Icon(Icons.arrow_downward),
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                        createSeries(dropdownValue);
                      },
                      items: [
                        "Past Day",
                        "Past Week",
                        "Past Month",
                        "Past 2 Months",
                        "Past 3 Months"
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ) */
                  ],
                ),
                Container(
                  height: 300,
                  
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SfCartesianChart(
                        title: ChartTitle(
                          text: "Differential Pressure(Last 80 min)",
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        plotAreaBorderWidth: 0,
                        primaryXAxis: DateTimeAxis(
                          intervalType: DateTimeIntervalType.auto,
                          dateFormat: DateFormat.Hm(),
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                          majorGridLines: MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          labelFormat: '{value} pa',
                          axisLine: AxisLine(width: 0),
                          majorTickLines:
                              MajorTickLines(color: Colors.transparent),
                        ),
                        series: currentPressureScatterSeries,
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                      SfCartesianChart(
                        title: ChartTitle(
                          text: "Temperature(Last 80 min)",
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        plotAreaBorderWidth: 0,
                        primaryXAxis: DateTimeAxis(
                          intervalType: DateTimeIntervalType.auto,
                          dateFormat: DateFormat.Hm(),
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                          majorGridLines: MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          labelFormat: '{value} F',
                          axisLine: AxisLine(width: 0),
                          majorTickLines:
                              MajorTickLines(color: Colors.transparent),
                        ),
                        series: temperatureLineSeries,
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                      SfCartesianChart(
                        title: ChartTitle(
                          text: "Humidity(Last 80 min)",
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        plotAreaBorderWidth: 0,
                        primaryXAxis: DateTimeAxis(
                          intervalType: DateTimeIntervalType.auto,
                          dateFormat: DateFormat.Hm(),
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                          majorGridLines: MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          labelFormat: '{value} %',
                          axisLine: AxisLine(width: 0),
                          majorTickLines:
                              MajorTickLines(color: Colors.transparent),
                        ),
                        series: humidityLineSeries,
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
