import 'package:cloudbelly_app/screens/Login/api_service.dart';
import 'package:cloudbelly_app/screens/Login/signup.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login-screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _formKey;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  Future<void> _submitForm() async {
    // Perform signup logic
    String email = _emailController.text;
    String pass = _phoneController.text;
    // Add your signup logic here

    // For example, print the values:
    int code = await login(email, pass);
    if (code == 201) {
      toastification.show(
        backgroundColor: Colors.green,
        context: context,
        title: 'Signup successfull',
        foregroundColor: Colors.white,
        primaryColor: Colors.white,
        autoCloseDuration: const Duration(seconds: 5),
      );
      Navigator.pushNamed(context, "/tabs-screen");
    } else
      toastification.show(
        backgroundColor: Colors.red,
        context: context,
        title: 'Signup failed',
        foregroundColor: Colors.white,
        primaryColor: Colors.white,
        autoCloseDuration: const Duration(seconds: 5),
      );
    Navigator.pushNamed(context, "/tabs-screen");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromRGBO(177, 217, 216, 1),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(25),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle SIGN UP click
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: Color(0xFFFA6E00),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Log in to your store',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'your e-mail here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          // if (value.isEmpty) {
                          //   return 'Please enter your email';
                          // }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        controller: _phoneController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'your password here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {},
                      ),
                      SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          _submitForm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(250, 110, 0, 1),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Error message placeholder
                    ],
                  ),
                ),
                // Flash messages can be displayed here
                SizedBox(height: 20),
                Text(
                  'Or',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    SocialButton(text: 'Continue with Whatsapp'),
                    SocialButton(text: 'Continue with Google'),
                    SocialButton(text: 'Continue with Facebook'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
