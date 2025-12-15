import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:sample_ui_test_app/login_button.dart';

@widgetbook.UseCase(
  designLink: 'https://www.figma.com/design/YSoR7FTfQm3rujz9RJWbAt/Desh?node-id=650-83&t=RvTUiXg6ickOIBiy-4',
  name: 'Default', 
  type: LoginButton
)
Widget buildLoginButtonUseCase(BuildContext context) {
  return LoginButton(onPressed: () {});
}