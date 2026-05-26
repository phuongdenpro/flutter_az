import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  final email = TextEditingController();

  final password = TextEditingController();
  bool isRed = true;
  bool liked = false;
  bool hide = true;

  @override
  void dispose() {
    email.dispose();

    password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // FocusScope.of(context).unfocus();
        FocusScope.of(context).unfocus();
        // FocusManager.instance.primaryFocus?.unfocus();
        print("Đã bấm");
        print("Unfocus");
        setState(() {
          isRed = !isRed;
        });
      },

      child: Scaffold(
        backgroundColor: isRed ? Colors.amber : Colors.green,
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: formKey,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: "Email"),
                  onTap: () {
                    print("TAP EMAIL");
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Email không được trống";
                    }

                    if (!v.contains("@")) {
                      return "Email không hợp lệ";
                    }

                    return null;
                  },
                ),

                SizedBox(height: 20),

                TextFormField(
                  controller: password,

                  obscureText: hide,

                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        hide ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hide = !hide;
                        });
                      },
                    ),
                  ),

                  validator: (v) {
                    if (v!.length < 6) {
                      return "Ít nhất 6 ký tự";
                    }

                    return null;
                  },
                ),

                SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      print(email.text);
                    }
                  },

                  child: Text("LOGIN"),
                ),
                IconButton(
                  onPressed: () {
                    print("Tim");
                  },

                  icon: Icon(Icons.favorite, color: Colors.red),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      liked = !liked;
                    });
                  },

                  icon: Icon(liked ? Icons.favorite : Icons.add),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
