import 'package:bunk_manager/src/loginPage.dart';
import 'package:bunk_manager/src/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  Widget _defaulthome = new LoginPage();

  Map<String, String> _result = await storage.readAll();
  if (_result.isNotEmpty) {
    _defaulthome = new HomePage();
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
    runApp(MyApp(_defaulthome));
  });
}

class MyApp extends StatelessWidget {
  final _defaulthome ;

  MyApp(this._defaulthome);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return MaterialApp(
      title: 'Bunk Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme:GoogleFonts.latoTextTheme(textTheme).copyWith(
          body1: GoogleFonts.montserrat(textStyle: textTheme.body1),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: _defaulthome,
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new HomePage(),
        '/login': (BuildContext context) => new LoginPage()
      },
    );
  }
}
