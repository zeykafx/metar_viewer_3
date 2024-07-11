import 'package:flutter/material.dart';
import 'package:metar_viewer_3/api/avwx.dart';

class TafPage extends StatefulWidget {
  const TafPage({Key? key}) : super(key: key);

  @override
  State<TafPage> createState() => _TafPageState();
}

class _TafPageState extends State<TafPage> {
  AvwxApi avwxApi = AvwxApi();

  @override
  void initState() {
    super.initState();
    avwxApi.getTaf();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("TAF Page"),
    );
  }
}
