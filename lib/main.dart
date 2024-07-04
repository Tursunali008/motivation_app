import 'package:flutter/material.dart';
import 'package:motivation_app/provider/motivation_provider.dart';
import 'package:motivation_app/screen/motivation_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuoteProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Motivational Quotes',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: QuoteScreen(),
      ),
    );
  }
}
