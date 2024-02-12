import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/bloc/auth/auth_bloc.dart';
import 'package:sms/bloc/auth/auth_event.dart';
import 'package:sms/bloc/auth/auth_state.dart';
import 'package:sms/screens/home_screen_staff.dart';
import 'package:sms/screens/home_screen_student.dart';
import 'package:sms/widgets/radio_list_tile.dart';
import 'package:sms/widgets/text_form_field.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  String userType = ''; // State variable to store selected user type

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);

    return BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
            ),
          );
        } else if (state is AuthAuthenticated) {
          if (userType.isNotEmpty) {
            // Navigate to the corresponding home screen based on the selected user type
            switch (userType) {
              case 'Student':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreenStudent()),
                );
                break;
              case 'Staff':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreenStaff()),
                );
                break;
            }
          }
        }
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/students.png',
                    width: 100.0,
                    height: 100.0,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: UserTypeRadioTile(
                          title: 'Student/Parent',
                          value: 'Student',
                          groupValue: userType,
                          onChanged: (newValue) {
                            setState(() {
                              userType = newValue.toString();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: UserTypeRadioTile(
                          title: 'Staff',
                          value: 'Staff',
                          groupValue: userType,
                          onChanged: (newValue) {
                            setState(() {
                              userType = newValue.toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Email TextFormField
                      CustomTextFormField(
                        label: 'Email',
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      // Password TextFormField
                      CustomTextFormField(
                        label: 'Password',
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      // User type radio buttons
                      ElevatedButton(
                        onPressed: () {
                          if (userType.isNotEmpty) {
                            // Dispatch login event if a user type is selected
                            authBloc.add(LoginButtonPressed(
                              email: email,
                              password: password,
                            ));
                          } else {
                            // Show error message if no user type is selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a user type.'),
                              ),
                            );
                          }
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
