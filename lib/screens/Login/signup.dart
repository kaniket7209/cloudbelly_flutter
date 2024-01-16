import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'api_service.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(177, 217, 216, 1),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(25),
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
                  // Handle Login click
                  Navigator.pushNamed(context, '/login');
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFFFA6E00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SignUpForm(),
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
    );
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _userType = 'Customer';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 20),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email...',
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black26, width: 1, strokeAlign: 1),
                    borderRadius: BorderRadius.all(Radius.circular(10))
                    // borderRadius: BorderRadius.circular(10),
                    ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter your phone number...',
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black26, width: 1, strokeAlign: 1),
                    borderRadius: BorderRadius.all(Radius.circular(10))
                    // borderRadius: BorderRadius.circular(10),
                    ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(250, 110, 0, 1), width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Create a password...',
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black26, width: 1, strokeAlign: 1),
                    borderRadius: BorderRadius.all(Radius.circular(10))
                    // borderRadius: BorderRadius.circular(10),
                    ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _openUserTypeModal(context);
              },
              child: Container(
                padding: EdgeInsets.all(15),
                // margin: EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black26),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _userType,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
            SizedBox(
              height: 26,
            ),
            ElevatedButton(
              onPressed: () {
                _submitForm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(250, 110, 0, 1),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Sign Up',
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
    );
  }

  void _openUserTypeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                title: Text('Customer'),
                onTap: () {
                  _selectUserType('Customer');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Vendor'),
                onTap: () {
                  _selectUserType('Vendor');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Supplier'),
                onTap: () {
                  _selectUserType('Supplier');
                  Navigator.pop(context);
                },
              ),
              // Add more options as needed
            ],
          ),
        );
      },
    );
  }

  void _selectUserType(String userType) {
    setState(() {
      _userType = userType;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Perform signup logic
      String email = _emailController.text;
      String phone = _phoneController.text;
      String password = _passwordController.text;
      String selectedUserType = _userType;

      // Add your signup logic here

      // For example, print the values:
      print('Email: $email');
      print('Phone: $phone');
      print('Password: $password');
      print('User Type: $selectedUserType');
      int code = await signUp(email, password, phone, selectedUserType);
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
  }
}

class SocialButton extends StatelessWidget {
  final String text;

  const SocialButton({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
