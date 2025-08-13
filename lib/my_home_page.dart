import 'package:flutter/cupertino.dart';
import 'app_colors.dart' as AppColors;
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
        child: SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.menu, size:24, color: Colors.black),
                    Row(
                      children: [
                        Icon(Icons.search),
                        Icon(Icons.notifications),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
    );
  }
}