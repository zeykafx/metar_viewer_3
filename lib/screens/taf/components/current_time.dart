import 'dart:async';

import 'package:material_ui/material_ui.dart';

class CurrentTime extends StatefulWidget {
  const new({super.key});

  @override
  State<CurrentTime> createState() => _CurrentTimeState();
}

class _CurrentTimeState extends State<CurrentTime> {
  DateTime currentTime = DateTime.now().toUtc();
  String get utcClock {
    String pad(int n) => n.toString().padLeft(2, '0');
    final t = currentTime;
    return '${pad(t.hour)}:${pad(t.minute)}:${pad(t.second)} UTC';
  }

  late Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateTime.now().toUtc();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      utcClock,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).dividerColor),
    );
  }
}
