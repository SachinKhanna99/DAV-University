import 'package:davteacher/HomeScreen.dart';
import 'package:davteacher/SecondPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:HomeScreen(),
    );
  }
}
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> {


  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  bool _signin = false;


  Future<FirebaseUser> signUp(String email, String Password) async {
    AuthResult result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: Password);
    FirebaseUser user = result.user;
    assert(user != null);
    assert(await user.getIdToken() != null);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SecondPage()));
    return user;
  }

  Future<FirebaseUser> signin(String email, String password) async {
    AuthResult result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    assert(user != null);
    assert(await user.getIdToken() != null);
    _signin = true;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SignUp")
        , centerTitle: true,),
      body: Container(
        child: Center(
          child: Form(
            key: _globalKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: emailcontroller,
                  decoration: InputDecoration(
                      hintText: "Email", labelText: "Email*"),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val.isEmpty) {
                      return "Please fill it";
                    } else {
                      return null;
                    }
                  },
                ),
                TextFormField(
                  controller: passwordcontroller,
                  validator: (val) {
                    if (val.isEmpty) {
                      return "Please enter password";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      hintText: "Password", labelText: "Password*"),
                ),
                SizedBox(height: 20,),

                RaisedButton(
                  elevation: 10,
                  child: Text("Register"),
                  onPressed: () async {
                    if (_globalKey.currentState.validate()) {
                      signUp(emailcontroller.text, passwordcontroller.text);
                    }
                  },
                ),
                SizedBox(height: 50,),
                RaisedButton(
                  child: Text("Login"),
                  elevation: 20,
                  onPressed: () {
                    signin(emailcontroller.text, passwordcontroller.text).then((
                        value) =>
                        Navigator.push(context, MaterialPageRoute(builder: (
                            context) => SecondPage())));
                  },
                ),
                SizedBox(height: 20),
                OutlineButton(

                  onPressed: ()async {
                  await  sigingooge().siginwithgoogle().whenComplete(() {
                      Navigator.of(context).push(MaterialPageRoute(builder: (
                          context) {
                        return SecondPage();
                      }));
                    });
                  },

                  splashColor: Colors.lightBlue,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),),

                  highlightElevation: 0,

                  borderSide: BorderSide(color: Colors.grey),

                  child: Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10),

                    child: Row(children: <Widget>[

                      Image(image: AssetImage('assets/google.webp'),

                        height: 35.0,),

                      Padding(

                        padding: const EdgeInsets.only(left: 10.0),

                        child: Text("Sign in with Google",
                          style: TextStyle(fontSize: 20, color: Colors.blue)
                          , textAlign: TextAlign.center,),

                      )

                    ],),),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
  class sigingooge {

    String email;
    String name;


    final FirebaseAuth _auth = FirebaseAuth.instance;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    Future<String> siginwithgoogle() async {
      final GoogleSignInAccount account = await googleSignIn.signIn();
      final GoogleSignInAuthentication authentication = await account
          .authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: authentication.idToken,
          accessToken: authentication.accessToken);

      final AuthResult result = await _auth.signInWithCredential(credential);
      final FirebaseUser user = result.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      assert(user.email != null);
      assert(user.displayName != null);
      assert(user.photoUrl != null);

      name = user.displayName;
      email = user.email;

      if (name.contains(" ")) {
        name = name.substring(0, name.indexOf(" "));
      }

      final FirebaseUser currentuser = await _auth.currentUser();
      assert(user.uid == currentuser.uid);
      return 'Signin google Succeed $user';
    }
    void Signoutgoogle() async{
      await googleSignIn.signOut();
      print("Sign Out");
    }

  }

