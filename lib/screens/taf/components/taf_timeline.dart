import 'dart:math' as math;

import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metar_viewer_3/models/taf.dart';

class TafTimeline extends StatelessWidget {
  final Taf? taf;
  const TafTimeline({super.key, required this.taf});

  static const double _minLabelGapPx = 28.0;

  static const double _labelStepPx = 34.0;

  static const double _minPxPerHour = 40.0;

  String formatDatetime(DateTime? time1, DateTime? time2) {
    if (time1 == null || time2 == null) {
      return "Time";
    }
    DateTime time1Local = time1.toUtc();
    DateTime time2Local = time2.toUtc();

    return "${time1Local.hour}Z to ${time2Local.hour}Z";
  }

  Widget buildForecastItem(BuildContext context, TafForecast forecast, DateTime tafStart, double totalHours, double timelineWidth) {
    DateTime forecastStart = forecast.startTime.toUtc();
    DateTime forecastEnd = forecast.endTime.toUtc();
    double forecastLength = forecastEnd.difference(forecastStart).inMinutes / 60.0;
    double pixelsPerHour = timelineWidth / totalHours;

    double shift = (forecastStart.difference(tafStart).inMinutes / 60.0) * pixelsPerHour;
    shift = shift.clamp(0.0, timelineWidth);
    double itemWidth = (forecastLength * pixelsPerHour).clamp(0.0, timelineWidth - shift);
    double itemHeight = 80;

    Color forecastColor = forecast.getFlightRulesColor(context);

    return SizedBox(
      width: timelineWidth,
      height: itemHeight,
      child: Row(
        children: [
          if (shift > 0) SizedBox(width: shift),
          SizedBox(
            width: itemWidth,
            height: itemHeight,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), color: Theme.of(context).colorScheme.surfaceContainer),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Card(
                margin: EdgeInsets.zero,
                color: forecastColor.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(13),
                  side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5), width: 0.8),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 2,
                    children: [
                      // don't write anything if the forecast is tiny
                      if (forecastLength <= 1)
                        ...[]
                      else if (forecastLength < 3) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: forecastColor),
                          child: Text(
                            forecast.flightRules,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 8),
                          ),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: forecastColor),
                              child: Text(
                                forecast.flightRules,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            Text(forecast.type, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(formatDatetime(forecastStart, forecastEnd)),
                        if (forecast.windSpeed != null && forecast.windDirection != null)
                          Text("${forecast.windDirection!.repr}° @ ${forecast.windSpeed!.repr}kt", style: TextStyle(color: Theme.of(context).dividerColor)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _xForHour(double pxPerHour, int tick) => tick * pxPerHour;

  Widget _buildAxis(BuildContext context, DateTime start, double timelineWidth, double pxPerHour, int lastTick) {
    ColorScheme scheme = Theme.of(context).colorScheme;
    TextStyle labelStyle = (Theme.of(context).textTheme.bodySmall ?? const TextStyle()).copyWith(
      color: scheme.onSurfaceVariant,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    String label(int tick) => "${(start.hour + tick) % 24}Z";

    double textWidth(int tick) {
      TextPainter painter = TextPainter(
        text: TextSpan(text: label(tick), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      return painter.width;
    }

    double leftFor(int tick) {
      double tw = textWidth(tick);
      if (tick == 0) return 0.0;
      double x = _xForHour(pxPerHour, tick);
      if (x >= timelineWidth - 1.0) {
        return math.max(0.0, timelineWidth - tw);
      }
      return (x - tw / 2).clamp(0.0, math.max(0.0, timelineWidth - tw));
    }

    double centerFor(int tick) => leftFor(tick) + textWidth(tick) / 2;

    int step = math.max(1, (_labelStepPx / pxPerHour).ceil());

    List<int> candidates = <int>[0];
    for (int tick = step; tick < lastTick; tick += step) {
      candidates.add(tick);
    }
    if (lastTick > 0) candidates.add(lastTick);

    // drop labels that would collide with the label that follows,
    // we prefer to keep the later one so that the end of the period always has a label
    List<int> picked = <int>[];
    for (int tick in candidates) {
      while (picked.isNotEmpty && picked.last != 0 && centerFor(tick) - centerFor(picked.last) < _minLabelGapPx) {
        picked.removeLast();
      }
      if (picked.isEmpty || centerFor(tick) - centerFor(picked.last) >= _minLabelGapPx) {
        picked.add(tick);
      }
    }

    return SizedBox(
      width: timelineWidth,
      height: 16,
      child: Stack(
        children: [
          for (int tick in picked)
            if (textWidth(tick) <= timelineWidth)
              Positioned(
                left: leftFor(tick),
                top: 0,
                child: Text(label(tick), style: labelStyle, maxLines: 1),
              ),
        ],
      ),
    );
  }

  Widget buildTimeline(BuildContext context, Taf taf) {
    DateTime start = taf.startTime.toUtc();
    DateTime end = taf.endTime.toUtc();

    double totalHours = end.difference(start).inMinutes / 60.0;
    if (totalHours <= 0) totalHours = 24.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        double viewportWidth = constraints.maxWidth;
        if (viewportWidth <= 0) return const SizedBox.shrink();

        // when the screen is wide enought to show the entire timeline it'll be stretched to fill the screen
        // otherwise we make it scroll
        double timelineWidth = math.max(viewportWidth, totalHours * _minPxPerHour);
        double pxPerHour = timelineWidth / totalHours;
        int lastTick = totalHours.floor(); // ticks at every hour between start and end

        Widget timeline = SizedBox(
          width: timelineWidth,
          child: Stack(
            children: [
              if (lastTick > 1)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TimelineGridPainter(pxPerHour: pxPerHour, lastTick: lastTick, color: Theme.of(context).dividerColor.withValues(alpha: 0.18)),
                  ),
                ),

              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAxis(context, start, timelineWidth, pxPerHour, lastTick),
                  const SizedBox(height: 8.0),
                  Column(
                    children: [
                      for (TafForecast forecast in taf.forecast) ...[
                        buildForecastItem(context, forecast, start, totalHours, timelineWidth).animate().fadeIn(duration: 300.ms, curve: Curves.easeInOutQuad),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        if (timelineWidth <= viewportWidth) {
          return timeline;
        }
        return SingleChildScrollView(scrollDirection: Axis.horizontal, child: timeline);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(25)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22.0),
          child: taf == null ? Center(child: Text("Timeline")) : buildTimeline(context, taf!),
        ),
      ),
    );
  }
}

class _TimelineGridPainter extends CustomPainter {
  _TimelineGridPainter({required this.pxPerHour, required this.lastTick, required this.color});

  final double pxPerHour;
  final int lastTick;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    for (int tick = 1; tick < lastTick; tick++) {
      double x = tick * pxPerHour;
      canvas.drawLine(Offset(x, 20), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_TimelineGridPainter oldDelegate) => oldDelegate.pxPerHour != pxPerHour || oldDelegate.lastTick != lastTick || oldDelegate.color != color;
}
