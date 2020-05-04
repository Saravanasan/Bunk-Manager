import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

    final FirebaseAuth _auth = FirebaseAuth.instance;
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

Widget _submitButton() {
    return GestureDetector(
      onTap: (){
        forgotPassword(valEmail.text);
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
          'Submit',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      )
    );
  }

  void forgotPassword(String email)async{
    String errorMessage; 
    try{
      await _auth.sendPasswordResetEmail(email: email);
    } on PlatformException catch(err){
      errorMessage = err.message;
    }
    catch(e){
      errorMessage = e.message; 
    }
    if(errorMessage != null){
      Fluttertoast.showToast(msg: errorMessage, backgroundColor: Colors.black);
    }
    else{
      Fluttertoast.showToast(msg: "Password reset link sent successfully");
    }
    
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

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text('Forgot Password'),
        backgroundColor: Colors.deepOrange,
        leading: new IconButton(icon: Icon(Icons.arrow_back), 
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:  Column(
        children: <Widget>[
          Container(
            alignment: AlignmentDirectional(0, 0),
            margin: new EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
            child:  _title(),
          ),
          Container(
            margin:  new EdgeInsets.only(
              left: 20.0,
              bottom: 0.0,
              right: 20.0,
              top: 40
            ),
            child: _entryFieldEmail('Email-id')
          ),
          Container(
            margin: new EdgeInsets.only(left: 20.0,right:20.0, top: 20),
            child: _submitButton()
          ), 
        ],
      )
    );
  }
}
