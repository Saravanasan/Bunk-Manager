import 'dart:ui';
import 'package:bunk_manager/src/Widget/bunk_chart.dart';
import 'package:bunk_manager/src/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:bunk_manager/src/bunk.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bunk_manager/src/subjBunk.dart';
import 'package:bunk_manager/src/Widget/subjBunk_chart.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  DateTime date = DateTime.now();

  TextEditingController valSubject = new TextEditingController();
  TextEditingController valCredits = new TextEditingController();
  TextEditingController valDate = new TextEditingController();
  TextEditingController valHours = new TextEditingController();

  RegExp regSubject = new RegExp(r"([a-zA-Z]{3,30}\s*)+");
  RegExp regCredits = new RegExp(r"^[0-9]{1}$");
  RegExp regHours = new RegExp(r"^[0-9]{1}$");

  var uuid = Uuid();
  
  int bunkhours=0;

  final databaseReference = Firestore.instance;
  final storage = new FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<BunkedClasses> data = [];
  final List<SubjBunkedClasses> bunk = [];

  String addError, updateError, delError, delCardError;
  String uid;

  void initState() {
    super.initState();
    
    try{
      storage.read(key: 'uid').then((value){
      setState(() {
      uid = value;  
      });
      
    });
    }catch(e){
      print(e);
    }
    

  }


  void addSubject(String subject, String credit) async{
    String uid = await storage.read(key: 'uid');
    try{
      String docid = subject+uid;
      DocumentReference ref = databaseReference.document('bunks/'+docid);
      ref.setData({
        'subject': subject,
        'credit': int.parse(credit),
        'roll':uid,
        'bunk': []
      });       
    }catch(e){
      addError = e.message;
      Fluttertoast.showToast(msg: e.message);
    }
    if(addError == null){
      Fluttertoast.showToast(msg: "Subject added successfully");
    }
  }


  void _onAlertWithCustomContentPressed(context) async{
    Alert(
      context: context,
      title: "Enroll Subject",
      content: Column(
        children: <Widget>[
          TextField(
            maxLength: 15,
            controller: valSubject,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            decoration: InputDecoration(
              labelText: 'Subject',
              
            ),
          ),
          TextField(
            controller: valCredits,
            decoration: InputDecoration(
              labelText: 'Credits',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1)
            ],
          ),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            if(valSubject.text.isEmpty){
              Fluttertoast.showToast(msg: 'Invalid Subject');
            }
            else{
              addSubject(valSubject.text, valCredits.text);
              valSubject.clear();
              valCredits.clear();
              Navigator.pop(context);
            }
          },
          child: Text(
            "Submit",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ]
    ).show();
  }

  void deletebunk(String bid, String sub, dynamic data)async{

    try{
      String docid = sub+uid;
      await databaseReference.collection("bunks").document(docid).updateData({"bunk":FieldValue.arrayRemove([data])});
    }
    catch(e){
      delError = e.message;
      Fluttertoast.showToast(msg: e.message);
    }
    if(delError == null){
      bunk.removeWhere((data)=>data.bid == bid);
      Fluttertoast.showToast(msg: 'Successfully deleted');
    }
  }


  List<SubjBunkedClasses> eachGraph(AsyncSnapshot<dynamic> snapshot){
    bunk.clear();
    try{
      for(int i=0 ; i<snapshot.data['bunk'].length;i++ ){
      print(snapshot.data['bunk'][i]['bunkhour']);
      bunk.add(SubjBunkedClasses(
      date: DateTime(DateTime.parse(snapshot.data['bunk'][i]['bunkdate'].toDate().toString()).year, DateTime.parse(snapshot.data['bunk'][i]['bunkdate'].toDate().toString()).month, DateTime.parse(snapshot.data['bunk'][i]['bunkdate'].toDate().toString()).day), 
      hours: snapshot.data['bunk'][i]['bunkhour'], 
      barColor: charts.ColorUtil.fromDartColor(Colors.orange), 
      subject: snapshot.data['subject'],
      bid: snapshot.data['bunk'][i]['bid']));  
    }
    }catch(e){
      print(e);
    }
    return bunk;    
  }

  void bunkModule(context, String sub) async{
    Alert(
      context: context,
      title: sub,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection("bunks").document(sub+uid).snapshots(),
                builder: (context,snapshot) {
                  if(!snapshot.hasData){
                    CircularProgressIndicator();
                  }   
                  return SubjBunkedClassChart(data: eachGraph(snapshot));
                }
              ), 
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height *0.3,
              child: StreamBuilder(
                stream: Firestore.instance.collection("bunks").document(sub+uid).snapshots(),
                builder: (context,snapshot) {
                  if(!snapshot.hasData){
                    CircularProgressIndicator();
                  }
                  return ListView(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(8),
                    children:  List.generate(snapshot.data['bunk'].length,( generator){
                      var date = DateTime.parse(snapshot.data['bunk'][generator]['bunkdate'].toDate().toString());
                      var format = "${date.day}-${date.month}-${date.year}";
                      return Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  alignment: Alignment.center,
                                  child :  Text(format, style: TextStyle(fontSize: 17)),
                                )
                              ],
                            )
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  alignment: Alignment.center,
                                  child :  Text(snapshot.data['bunk'][generator]['bunkhour'].toString(), style: TextStyle(fontSize: 17)),
                                )
                              ],
                            )
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  alignment: Alignment.center,
                                  child :  IconButton(
                                    alignment: Alignment.center,
                                    icon: Icon(Icons.delete),
                                    onPressed: (){
                                      deletebunk(snapshot.data['bunk'][generator]['bid'], sub, snapshot.data['bunk'][generator]);
                                    },
                                  ),
                                )
                              ],
                            )
                          ),
                        ]
                      );
                    },
                  )
                );
                } 
              ),
              ),
          ]
        ),
      )
    ).show();
  }


  void logout() async {
    String errorMessage; 
    try{
      await _auth.signOut();  
    }
    catch(e){ errorMessage = e.message; }
    if(errorMessage != null){
      Fluttertoast.showToast(msg: errorMessage, backgroundColor: Colors.black);
    }
    else{
      await storage.deleteAll();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
    }   
  }

  void _showDialog(String subject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Are you sure want to delete"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                deleteCard(subject);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteCard(String subject)async{
    try{
      await databaseReference.collection("bunks").where('subject', isEqualTo: subject).where('roll', isEqualTo: uid)
      .getDocuments().then((onValue)=>
        onValue.documents.forEach((val)=>
          val.reference.delete()
        )
      );
    }
    catch(e){
      delCardError = e.message;
      Fluttertoast.showToast(msg: e.message);
    }
    if(delCardError == null){
      data.removeWhere((data)=>data.subject == subject);
      bunk.removeWhere((bunksubj)=>bunksubj.subject == subject);
      Fluttertoast.showToast(msg: 'Deleted Successfully');
    }
  }


  void addbunk(String subj, DateTime date, String hours)async{
    try{
      String docid = subj+uid ;
      await databaseReference.collection('bunks').document(docid).updateData({'bunk':FieldValue.arrayUnion([{'bunkhour':int.parse(hours), 'bunkdate':Timestamp.fromDate(date), 'bid': uuid.v1()}])});
    }catch(e){
      addError = e.message;
      Fluttertoast.showToast(msg: e.message);
    }
    if(addError == null){
      Fluttertoast.showToast(msg: 'Successfully bunked');
    }   
  }

  void bunkclass(String subjectName)async{
    Alert(
      context: context,
      title: "Bunk Class",
      content: Column(
        children: <Widget>[
      TextFormField(
        controller: valDate..text=((DateTime.now().day).toString() + '-' +(DateTime.now().month).toString() +'-'+(DateTime.now().year).toString() ),
        decoration: InputDecoration(
        labelText: "Click here to pick a date",
        ), 
        onTap: () async{
          FocusScope.of(context).requestFocus(new FocusNode());
          try{
            date = await showDatePicker(
            context: context, 
            initialDate:DateTime.now(),
            firstDate:DateTime(1900),
            lastDate: DateTime(2100),
            );
            var format = "${date.day}-${date.month}-${date.year}";
            valDate.text = format;
          }
          catch(e){
            date = DateTime.now();
            valDate.text = ((DateTime.now().day).toString() + '-' +(DateTime.now().month).toString() +'-'+(DateTime.now().year).toString());
            Fluttertoast.showToast(msg: 'No date selected, setting default value');
          }
        },),
          TextField(
            controller: valHours,
            decoration: InputDecoration(
              labelText: 'No. of hours',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1)
              ],
          ),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () async{
            try{
              print(date);
            }catch(e){print(e);}
              addbunk(subjectName, date, valHours.text);
              valHours.clear();
              valDate.clear();
              date = DateTime.now();
              Navigator.pop(context);
            },
          child: Text(
            "Submit",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ]
    ).show();
  }

  List<BunkedClasses> totalData(AsyncSnapshot<dynamic> snapshot){
    print(snapshot.data.documents.map((document)=>{
      for(int i=0 ; i<document['bunk'].length;i++ ){
        bunkhours = bunkhours + document['bunk'][i]['bunkhour']
      },      
      data.add(BunkedClasses(hours: bunkhours,barColor:  charts.ColorUtil.fromDartColor(Colors.orange), subject: document['subject'] )),
      bunkhours=0
    } 
  ));
  return data;
  }

  String bunkcalc(dynamic value){
    int bunkNo = 0;
    for(int i=0 ; i<value['bunk'].length;i++ ){
      bunkNo = bunkNo + value['bunk'][i]['bunkhour'];
    }
    return bunkNo.toString();
  }

  @override
   Widget build(BuildContext context) {
     print(uid);
    return Scaffold(
      appBar: AppBar(      
        title: const Text('Bunk Manager'),
        backgroundColor: Colors.deepOrange,
        actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.power_settings_new),
          tooltip: 'Logout',
          onPressed: () {
            logout();
          },
        ),
        ]
      ),
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: (uid == null)?CircularProgressIndicator():
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[ 
            Container(
              child: new StreamBuilder(
                stream: Firestore.instance.collection('bunks').where("roll", isEqualTo: uid).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(!snapshot.hasData){
                    return Center(child: CircularProgressIndicator() );
                  } 
                  return BunkedClassChart(data: totalData(snapshot));                     
                }
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection('bunks').where('roll', isEqualTo: uid).snapshots(),
                builder: (context,snapshot) {
                  if(!snapshot.hasData){
                    return Center(child: CircularProgressIndicator() );
                  }
                  return GridView.count(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,                 
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    mainAxisSpacing: 30,
                    children:  snapshot.data.documents.map<Widget>((value) {
                      return  Card(
                        borderOnForeground: true,
                        margin: EdgeInsets.only(left: 25, right:25),
                        child: SingleChildScrollView(
                        child: InkWell(
                          splashColor: Colors.orange,
                            onTap: () {
                              bunkModule(context, value['subject']);
                            },
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  height: 20,
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    alignment: Alignment.topRight,
                                    onPressed: (){
                                      _showDialog(value['subject']);
                                    }
                                  )
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  height: 45,
                                  margin: EdgeInsets.only(left:10),
                                  child: RichText(
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(text: "Subject : ", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                                        TextSpan(text: value['subject'], style: TextStyle(fontSize: 15, color: Colors.black)),
                                      ]
                                    ),
                                  ) 
                                ),
                                SizedBox(height: 13),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  height: 50,
                                  margin: EdgeInsets.only(left:10),
                                  child: RichText(
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(text: "Number of bunked classes : ", style: TextStyle(fontSize: 15, color: Colors.black,fontWeight: FontWeight.bold)),
                                        TextSpan(text: bunkcalc(value), style: TextStyle(fontSize: 15, color: Colors.black)),
                                      ]
                                    ),
                                  ) 
                                ),
                                Container(
                                  child: FlatButton(
                                    color: Colors.deepOrange,
                                    textColor: Colors.white,
                                    disabledColor: Colors.grey,
                                    disabledTextColor: Colors.black,
                                    padding: EdgeInsets.all(1.0),
                                    splashColor: Colors.deepOrange,
                                    onPressed: () {
                                      bunkclass(value['subject']);
                                    },
                                    child: Text(
                                      "Bunk",
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  )
                                )
                              ],
                            )
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              ),                 
            ),                
            Container(
              margin: EdgeInsets.only(top:20, right:20,  bottom: 20),
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: 'Add Subject',
                backgroundColor: Colors.deepOrange,
                tooltip: "Add Subject",
                onPressed: (){
                  _onAlertWithCustomContentPressed(context);
                },
                child: Icon(Icons.add),
              ),
            )
          ],
        ),
      ),
    );
  }
}