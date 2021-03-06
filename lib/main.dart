import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email And Password Login',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection("users").doc(user!.uid).get().then(
      (value) {
        loggedInUser = UserModel.fromMap(value.data());
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Home Page"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              Text(
                "Username: ${loggedInUser.firstName}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text("E-mail: ${loggedInUser.email}",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(
                height: 400,
              ),
              MaterialButton(
                elevation: 3,
                minWidth: double.maxFinite,
                height: 50,
                onPressed: () {
                  logout(context);
                },
                color: Colors.blue,
                child: const Text('Logout',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [Colors.black, Colors.transparent],
          ).createShader(rect),
          blendMode: BlendMode.darken,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/login2.jpeg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: Colors.transparent,
          body: Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Sign in to continue',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 150),
                        TextFormField(
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          autofocus: false,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Please Enter Your Email");
                            }
                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                .hasMatch(value)) {
                              return ("Please Enter a valid email");
                            }
                            return null;
                          },
                          onSaved: (value) {
                            emailController.text = value!;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            fillColor: Colors.white24,
                            filled: true,
                            icon: const Icon(
                              Icons.mail_outline,
                              color: Colors.white,
                            ),
                            hintText: "Email",
                            hintStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        TextFormField(
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          cursorColor: Colors.white,
                          autofocus: false,
                          controller: passwordController,
                          obscureText: true,
                          validator: (value) {
                            RegExp regex = RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return ("Password is required for login");
                            }
                            if (!regex.hasMatch(value)) {
                              return ("Enter Valid Password(Min. 6 Character)");
                            }
                          },
                          onSaved: (value) {
                            passwordController.text = value!;
                          },
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            fillColor: Colors.white24,
                            filled: true,
                            icon: const Icon(Icons.vpn_key_outlined,
                                color: Colors.white),
                            hintText: "Password",
                            hintStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                        MaterialButton(
                          elevation: 0,
                          minWidth: double.maxFinite,
                          height: 50,
                          onPressed: () {
                            signIn(
                                emailController.text, passwordController.text);
                          },
                          color: Colors.white24,
                          child: const Text('Login',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: 15),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(color: Colors.white),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RegistrationScreen()));
                                },
                                child: const Text(
                                  "  Sign Up",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              )
                            ])
                      ],
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  // login function
  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((uid) => {
                  Fluttertoast.showToast(msg: "Login Successful"),
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomeScreen())),
                });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";

            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        print(error.code);
      }
    }
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;

  String? errorMessage;

  final _formKey = GlobalKey<FormState>();
  final firstNameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [Colors.black, Colors.transparent],
          ).createShader(rect),
          blendMode: BlendMode.darken,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/login.jpeg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: Colors.transparent,
          body: Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Register',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 45),
                        TextFormField(
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          autofocus: false,
                          controller: firstNameEditingController,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            RegExp regex = RegExp(r'^.{3,}$');
                            if (value!.isEmpty) {
                              return ("First Name cannot be Empty");
                            }
                            if (!regex.hasMatch(value)) {
                              return ("Enter Valid name(Min. 3 Character)");
                            }
                            return null;
                          },
                          onSaved: (value) {
                            firstNameEditingController.text = value!;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            fillColor: Colors.white24,
                            filled: true,
                            icon: const Icon(Icons.account_box,
                                color: Colors.white),
                            hintText: "Username...",
                            hintStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          autofocus: false,
                          controller: emailEditingController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Please Enter Your Email");
                            }
                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                .hasMatch(value)) {
                              return ("Please Enter a valid email");
                            }
                            return null;
                          },
                          onSaved: (value) {
                            firstNameEditingController.text = value!;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            fillColor: Colors.white24,
                            filled: true,
                            icon: const Icon(Icons.mail, color: Colors.white),
                            hintText: "E-mail...",
                            hintStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          autofocus: false,
                          controller: passwordEditingController,
                          obscureText: true,
                          validator: (value) {
                            RegExp regex = RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return ("Password is required for login");
                            }
                            if (!regex.hasMatch(value)) {
                              return ("Enter Valid Password(Min. 6 Character)");
                            }
                          },
                          onSaved: (value) {
                            firstNameEditingController.text = value!;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            fillColor: Colors.white24,
                            filled: true,
                            icon:
                                const Icon(Icons.vpn_key, color: Colors.white),
                            hintText: "Password...",
                            hintStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                        MaterialButton(
                          elevation: 0,
                          minWidth: double.maxFinite,
                          height: 50,
                          onPressed: () {
                            signUp(emailEditingController.text,
                                passwordEditingController.text);
                          },
                          color: Colors.white24,
                          child: const Text('Sign Up',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) => {postDetailsToFirestore()})
            .catchError((e) {
          Fluttertoast.showToast(msg: e!.message);
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        print(error.code);
      }
    }
  }

  postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.firstName = firstNameEditingController.text;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "Account created successfully!");

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false);
  }
}

class UserModel {
  String? uid;
  String? email;
  String? firstName;

  UserModel({this.uid, this.email, this.firstName});

  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
    };
  }
}
