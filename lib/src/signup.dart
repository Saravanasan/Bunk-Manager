import 'package:flutter/material.dart';
import 'package:bunk_manager/src/loginPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progress_dialog/progress_dialog.dart';

ProgressDialog pr;

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController valName = new TextEditingController();
  TextEditingController valRoll = new TextEditingController();
  TextEditingController valEmail = new TextEditingController();
  TextEditingController valPassword = new TextEditingController();
  TextEditingController valCPassword = new TextEditingController();

  bool _bName = true, _bRoll = true, _bEmail = true, _bPassword = true, _bCPassword = true;
  bool _showPassword = false, _showCPassword = false;

  RegExp regName = new RegExp(r"([a-zA-Z]{3,30}\s*)+");
  RegExp regRoll = new RegExp(r"^[0-9]{10}$");
  RegExp regEmail = new RegExp(r"[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
      "\\@" +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
      "(" +
      "\\." +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
      ")+");
  RegExp regPassword = new RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$");

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)
            )
          ],
        ),
      ),
    );
  }

  Widget _entryFieldName(String title) {
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
            controller: valName,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            onChanged: (val){
              if(regName.hasMatch(val)){
                _bName = true;
              } 
              else {
               _bName = false;
             }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
              errorText: _bName ? null : "Enter valid Name", 
            )
          )
        ],
      ),
    );
  }

  Widget _entryFieldNumber(String title) {
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
            controller: valRoll,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            onChanged: (val){
              if(regRoll.hasMatch(val)){
                _bRoll = true;
              } 
              else {
               _bRoll = false;
              }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
              errorText: _bRoll ? null : "Enter valid roll number",
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)
            ],
          )
        ],
      ),
    );
  }

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
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            onChanged: (val){
              if(regEmail.hasMatch(val)){
                _bEmail = true;
            } else {
                _bEmail = false;
            }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
              errorText: _bEmail ? null : "Enter valid Email-id", 
            )
          )
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
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            obscureText: !_showPassword,
            onChanged: (val){
              if(regPassword.hasMatch(val)){
                _bPassword = true;
              }
                else {
                _bPassword = false;
              }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: this._showPassword ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  setState(() => this._showPassword = !this._showPassword);
                },
              ),
              errorText: _bPassword ? null : "Invalid Password. Example - Password@24", 
            )
          )
        ],
      ),
    );
  }

  Widget _entryFieldCPassword(String title) {
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
            controller: valCPassword,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            obscureText: !_showCPassword,
            onChanged: (val){
              if(valPassword.text == valCPassword.text){
                _bCPassword = true;
              }
              else{
                _bCPassword = false;
              }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: this._showCPassword ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  setState(() => this._showCPassword = !this._showCPassword);
                },
              ),
              errorText: _bCPassword ? null : "Password does not match", 
            )
          )
        ],
      ),
    );
  }

  void register(String name, String roll, String email, String password) async{
    String errorMessage; 
    FirebaseUser user;
    pr.show();
    try{
      user = (await _auth.createUserWithEmailAndPassword(email: email, password: password)).user;
    }
    catch(e){ errorMessage = e.message; }
    if(errorMessage != null){
      Future.delayed(Duration(seconds: 1)).then((value){
      pr.hide().whenComplete((){});});
      Fluttertoast.showToast(msg: errorMessage, backgroundColor: Colors.black);
    }
    else{
      try{
        user.sendEmailVerification();
        Future.delayed(Duration(seconds: 2)).then((value){
          pr.hide().whenComplete(() {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
          });
        });
        Fluttertoast.showToast(msg: 'Verification link sent to email successfully', backgroundColor: Colors.black);
      }
      catch(e){
        Future.delayed(Duration(seconds: 1)).then((value){
        pr.hide().whenComplete((){});});
        Fluttertoast.showToast(msg: e, backgroundColor: Colors.black);
      }
    }
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: (){
        register(valName.text, valRoll.text, valEmail.text, valPassword.text);
        valName.clear();
        valRoll.clear();
        valEmail.clear();
        valCPassword.clear();
        valCPassword.clear();
      },
      child : Container(      
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
              spreadRadius: 2
            )
          ],
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xfffbb448), Color(0xfff7892b)]
          )
        ),
        child: Text(
          'Register Now',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Already have an account ?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
              'Login',
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
        _entryFieldName("Username"),
        _entryFieldNumber("Roll Number"),
        _entryFieldEmail("Email id"),
        _entryFieldPassword("Password"),
        _entryFieldCPassword("Confirm Password"),
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
      resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: new EdgeInsets.only(top:50),
              child: _backButton(),
            ),
            Container(
              alignment: AlignmentDirectional(0, 0),
              margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
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
              margin: new EdgeInsets.only(left: 20.0,right:20.0, top: 40),
              child: _loginAccountLabel(),
            ),
          ],
        ),
      ),  
    );
  }
}
