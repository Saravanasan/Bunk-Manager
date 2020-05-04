import 'package:bunk_manager/src/forgotPassword.dart';
import 'package:bunk_manager/src/home.dart';
import 'package:flutter/material.dart';
import 'package:bunk_manager/src/signup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:progress_dialog/progress_dialog.dart';

ProgressDialog pr;

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _showPassword = false;
  DateTime currentBackPressTime;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storage = new FlutterSecureStorage();

  TextEditingController valPassword = new TextEditingController();
  TextEditingController valEmail = new TextEditingController();

  Widget _entryFieldEmail(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: valEmail,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true))
        ],
      ),
    );
  }

  Widget _entryFieldPassword(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: valPassword,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
                suffixIcon: IconButton(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: this._showPassword ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  setState(() => this._showPassword = !this._showPassword);
                },
              ),
              filled: true
            )
          )
        ],
      ),
    );
  }

  void login(String email, String password) async{
    String errorMessage; 
    FirebaseUser user;
    pr.show();

    try{
      user = (await _auth.signInWithEmailAndPassword(email: email, password: password)).user;
      if(!user.isEmailVerified){
        errorMessage = "Email not verified";
      }
    }
    catch(e){ errorMessage = e.message; }
    if(errorMessage != null){
      Future.delayed(Duration(seconds: 1)).then((value){
      pr.hide().whenComplete((){});});
      Fluttertoast.showToast(msg: errorMessage, backgroundColor: Colors.black);
    }
    else{
      await storage.write(key: 'email', value: email);
      await storage.write(key: "uid", value: user.uid);
      Future.delayed(Duration(seconds: 2)).then((value){
        pr.hide().whenComplete(() {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage()));});
        }
      );
    }
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: (){
        login(valEmail.text, valPassword.text);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xfffbb448), Color(0xfff7892b)]
          )
        ),
        child: Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      )
    );
  }
  
  Widget _createAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Don\'t have an account ?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => SignUpPage()));
            },
            child: Text(
              'Register',
              style: TextStyle(
                color: Color(0xfff79c4f),
                fontSize: 13,
                fontWeight: FontWeight.w600
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _forgotPasswordLabel() {
    return GestureDetector(
      onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ForgotPassword()));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Bu',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.display1,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.orange,
        ),
        children: [
          TextSpan(
            text: 'nk',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
          TextSpan(
            text: ' Ma',
            style: TextStyle(color: Colors.orange, fontSize: 30),),
          TextSpan(
            text: 'nag',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
          TextSpan(
            text: 'er',
            style: TextStyle(color: Colors.orange, fontSize: 30),
          ),
        ]
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryFieldEmail("Email id"),
        _entryFieldPassword("Password"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    pr.style(
      message: '   Please Wait...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
        color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400
      ),
      messageTextStyle: TextStyle(
        color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w600
      )
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: AlignmentDirectional(0, 0),
              margin: new EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
              child:  _title(),
            ),
            Container(
              margin:  new EdgeInsets.only(
                left: 20.0,
                bottom: 0.0,
                right: 20.0,
                top: 40
              ),
              child: _emailPasswordWidget()
            ),
            Container(
              margin: new EdgeInsets.only(left: 20.0,right:20.0, top: 40),
              child: _submitButton()
            ),
            Container(
              margin: new EdgeInsets.only(top: 30),
              child: _forgotPasswordLabel()
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: _createAccountLabel(),
            ),
          ],
        )
      )
    );
  }
}
