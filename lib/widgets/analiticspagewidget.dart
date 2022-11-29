import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:wpfamilylastseen/const/colors.dart';
import 'package:wpfamilylastseen/const/date.dart';
import 'package:wpfamilylastseen/modal/phonemodal.dart';
import 'package:wpfamilylastseen/widgets/analiticspagepopup.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChartWidget extends StatefulWidget {
  final Phone phone;
  const ChartWidget({Key key, @required this.phone}) : super(key: key);

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  List<Color> gradientColors = [
    Colorize.primary,
    Colorize.red,
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
              color: Colorize.layer,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                right: 16,
                left: 16,
                top: 16,
                bottom: 8,
              ),
              child: LineChart(
                showAvg ? avgData() : mainData(),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'AVG',
              style: TextStyle(
                fontSize: 10,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colorize.textSec,
      fontSize: 10,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('01:00', style: style);
        break;
      case 4:
        text = const Text('04:00', style: style);
        break;
      case 7:
        text = const Text('07:00', style: style);
        break;
      case 10:
        text = const Text('10:00', style: style);
        break;
      case 13:
        text = const Text('13:00', style: style);
        break;
      case 16:
        text = const Text('16:00', style: style);
        break;
      case 19:
        text = const Text('19:00', style: style);
        break;
      case 22:
        text = const Text('22:00', style: style);
        break;

      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(context, double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colorize.textSec,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '00';
        break;
      case 2:
        text = '08';
        break;
      case 4:
        text = '16';
        break;
      case 6:
        text = '24';
        break;
      case 8:
        text = '32';
        break;
      case 10:
        text = '40';
        break;
      case 12:
        text = '48';
        break;
      case 14:
        text = '56';
        break;
      case 16:
        text = '64';
        break;
      case 18:
        text = '72';
        break;
      default:
        return Container();
    }

    var lang = AppLocalizations.of(context);

    return Text(text + lang.second, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 2,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colorize.layer,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colorize.layer,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) =>
                leftTitleWidgets(context, value, meta),
            reservedSize: 52,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colorize.layer),
      ),
      minX: 0,
      maxX: 24,
      minY: 0,
      maxY: 20,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            // ! TODO AKTİVİTE DİLİMİNE GÖRE X VE Y DEĞERLERİNİ GİRİP ŞEKİLLENDİRİLECEK

            // phone değişkeni içeride mevcut
            // isteğine göre database'de phone.activities > içerisinde datayı tutup burada gösterebilirsin.
            FlSpot(0, 0),
            FlSpot(4.9, 6),
            FlSpot(9, 3.1),
            FlSpot(16, 1),
            FlSpot(24, 4),
          ],
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: false,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) =>
                leftTitleWidgets(context, value, meta),
            reservedSize: 52,
            interval: 1,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2),
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2),
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AnaliticsOnlineGraph extends StatelessWidget {
  final Phone phone;
  final int selectedOnlineGraphTab;
  final Function(int) onValueChanged;
  const AnaliticsOnlineGraph(
      {Key key,
      @required this.phone,
      @required this.selectedOnlineGraphTab,
      @required this.onValueChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: CupertinoSlidingSegmentedControl(
            backgroundColor: Colorize.layer,
            padding: const EdgeInsets.all(4.0),
            groupValue: selectedOnlineGraphTab,
            thumbColor: Colorize.primary,
            children: {
              0: Text(lang.activeTime,
                  style: TextStyle(
                      color: selectedOnlineGraphTab == 0
                          ? Colorize.black
                          : Colorize.text)),
              1: Text(lang.activeNumber,
                  style: TextStyle(
                      color: selectedOnlineGraphTab == 1
                          ? Colorize.black
                          : Colorize.text)),
            },
            onValueChanged: onValueChanged,
          ),
        ),
        ChartWidget(phone: phone),
      ],
    );
  }
}

class AnaliticsWeeklyData extends StatelessWidget {
  final bool onWeekly;
  final Function(bool) onWeeklySlideChanged;
  final DateTime selectedDate;
  final Function(DateTime) dateChanged;
  const AnaliticsWeeklyData(
      {Key key,
      this.onWeekly,
      this.onWeeklySlideChanged,
      this.dateChanged,
      this.selectedDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnaliticsWeeklyDataTabBar(
          onWeekly: onWeekly,
          selectedDate: selectedDate,
          onWeeklySlideChanged: onWeeklySlideChanged,
          dateChanged: dateChanged,
        ),
        AnaliticsActivitiesListView(phones: null, tabIndex: onWeekly ? 1 : 0),
      ],
    );
  }
}

class AnaliticsWeeklyDataTabBar extends StatelessWidget {
  final bool onWeekly;
  final Function(bool) onWeeklySlideChanged;
  final Function(DateTime) dateChanged;
  final DateTime selectedDate;
  const AnaliticsWeeklyDataTabBar({
    Key key,
    this.onWeekly,
    this.onWeeklySlideChanged,
    this.dateChanged,
    this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: CupertinoSlidingSegmentedControl(
              backgroundColor: Colorize.layer,
              padding: const EdgeInsets.all(4.0),
              groupValue: onWeekly,
              thumbColor: Colorize.primary,
              children: {
                false: Text(lang.daily,
                    style: TextStyle(
                        color: onWeekly == false
                            ? Colorize.black
                            : Colorize.text)),
                true: Text(lang.weekly,
                    style: TextStyle(
                        color:
                            onWeekly == true ? Colorize.black : Colorize.text)),
              },
              onValueChanged: onWeeklySlideChanged),
        ),
        InkWell(
          // aktivitelerin tarih filtresi
          onTap: () => showAnaliticsDatePopUp(
              context, selectedDate ?? DateTime.now(), dateChanged),
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colorize.layer,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              selectedDate != null
                  ? '${selectedDate.day.toString()} ${getMonth(context, selectedDate.month)}'
                  : '${DateTime.now().day.toString()} ${getMonth(context, DateTime.now().month)}',
              style: const TextStyle(color: Colorize.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class AnaliticsActivitiesListView extends StatelessWidget {
  final List<Phone> phones;
  final int tabIndex;
  const AnaliticsActivitiesListView({Key key, this.tabIndex, this.phones})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);
    return phones == null || phones[tabIndex].activities.isEmpty
        ? Container(
            width: MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            decoration: BoxDecoration(
              color: Colorize.layer,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: [
                const Iconify(
                  Carbon.recently_viewed,
                  size: 64.0,
                  color: Colorize.icon,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    lang.nullActivityText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colorize.textSec,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  lang.nullActivityCaption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colorize.icon),
                ),
              ],
            ),
          )
        : ListView(primary: false, shrinkWrap: true, children: const [
            AnaliticsActivityCard(phone: null, activity: null),
          ]);
  }
}

class AnaliticsActivityCard extends StatelessWidget {
  final Phone phone;
  final Activite activity;
  const AnaliticsActivityCard({Key key, this.phone, this.activity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: Colorize.layer, borderRadius: BorderRadius.circular(8.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(phone.label, overflow: TextOverflow.ellipsis),
              Text(
                activity.startingTime,
                style: const TextStyle(fontSize: 12.0, color: Colorize.icon),
              )
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '00:07',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                lang.activeTime,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 8.0,
                  color: Colorize.icon,
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('2 Agu', overflow: TextOverflow.ellipsis),
              Text(
                activity.endTime,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colorize.icon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
