import 'package:flutter/material.dart';
import 'package:flutter_ui/pages/profile_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();

    super.dispose();
  }

  void register() {
  if (formKey.currentState!.validate()) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          name: nameController.text,
          email: emailController.text,
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },

      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Đăng kí"),
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: formKey,

            child: Column(
              children: [
                const SizedBox(height: 40),

                const Icon(Icons.person_add, size: 80, color: Colors.blue),

                const SizedBox(height: 30),

                // NAME
                TextFormField(
                  controller: nameController,

                  decoration: const InputDecoration(
                    labelText: "Name",
                    prefixIcon: Icon(Icons.person),

                    border: OutlineInputBorder(),
                  ),

                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Nhập tên";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // EMAIL
                TextFormField(
                  controller: emailController,

                  keyboardType: TextInputType.emailAddress,

                  decoration: const InputDecoration(
                    labelText: "Email",

                    prefixIcon: Icon(Icons.email),

                    border: OutlineInputBorder(),
                  ),

                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Nhập email";
                    }

                    if (!v.contains("@")) {
                      return "Email không hợp lệ";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // PASSWORD
                TextFormField(
                  controller: passwordController,

                  obscureText: hidePassword,

                  decoration: InputDecoration(
                    labelText: "Password",

                    prefixIcon: const Icon(Icons.lock),

                    border: const OutlineInputBorder(),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },

                      icon: Icon(
                        hidePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),

                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return "Ít nhất 6 ký tự";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // CONFIRM
                TextFormField(
                  controller: confirmController,

                  obscureText: hideConfirm,

                  decoration: InputDecoration(
                    labelText: "Confirm Password",

                    prefixIcon: const Icon(Icons.lock),

                    border: const OutlineInputBorder(),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hideConfirm = !hideConfirm;
                        });
                      },

                      icon: Icon(
                        hideConfirm ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),

                  validator: (v) {
                    if (v != passwordController.text) {
                      return "Mật khẩu không khớp";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,

                  height: 50,

                  child: ElevatedButton(
                    onPressed: register,

                    child: const Text("REGISTER"),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("Đã có tài khoản? Đăng nhập"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
