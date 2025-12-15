import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:sample_ui_test_app/login_form.dart';

@widgetbook.UseCase(
  designLink: 'https://www.figma.com/design/YSoR7FTfQm3rujz9RJWbAt/Desh?node-id=643-69&t=RvTUiXg6ickOIBiy-4',
  name: 'LoginForm',
  type: LoginForm
)
Widget buildLoginFormUseCase(BuildContext context) {
  return Container(
    color: const Color(0xFFFFF7F7),
    padding: const EdgeInsets.all(24.0),
    child: LoginForm(
      onLoginPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login pressed')),
        );
      },
    ),
  );
}
