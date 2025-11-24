import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:job_management_system/features/admin/presentation/pages/Admin_page.dart';
import 'package:job_management_system/features/technician/presentation/bloc/pages/technician_home_page.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    // Validate form first
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              _emailCtrl.text.trim(),
              _passwordCtrl.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Field Service Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
  if (state is AuthFailure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.message)),
    );
  } else if (state is AuthSuccess) {
    // Decide target screen based on roles
    final roles = state.roles; // make sure AuthSuccess has this

    if (roles.contains('ADMIN') || roles.contains('COMPANY_ADMIN') || roles.contains('DISPATCHER')) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) =>  AdminDashboardPage()),
      );
    } else if (roles.contains('TECHNICIAN')) {
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TechnicianHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unknown role')),
      );
    }
  }
},

          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter email';
                      }
                      // Optional basic email check
                      if (!v.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter password';
                      }
                      if (v.length < 4) {
                        return 'Password too short';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onLogin,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
