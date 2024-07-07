import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/features/admin_panel/presentation/pages/add_group_page.dart';
import 'package:faceq/features/admin_panel/presentation/pages/add_user_page.dart';
import 'package:faceq/features/admin_panel/presentation/pages/change_password_page.dart';
import 'package:faceq/features/admin_panel/presentation/pages/change_user_face_page.dart';
import 'package:faceq/features/admin_panel/presentation/pages/contact_page.dart';
import 'package:faceq/features/admin_panel/presentation/pages/dates_page.dart';
import 'package:faceq/features/admin_panel/presentation/pages/delete_group_page.dart';
import 'package:faceq/features/admin_panel/presentation/pages/delete_user_page.dart';
import 'package:faceq/features/admin_panel/presentation/widgets/NavigationBar/NavigationItemBuilder.dart';
import 'package:faceq/features/auth/presentation/pages/check_password_page.dart';
import 'package:faceq/sl.dart';
import 'package:flutter/material.dart';

class NavigationSideBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const NavigationSideBar({
    super.key,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    print("Side BAR STORAGE ${sl<Credentials>().address}, ${sl<Credentials>().token}");
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Admin",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          actions: [
            IconButton(
                onPressed: () {
                  if (scaffoldKey.currentState != null) {
                    scaffoldKey.currentState!.closeDrawer();
                  }
                },
                icon: const Icon(Icons.close))
          ],
        ),
        body: SingleChildScrollView(
          child: Wrap(
            runSpacing: 2.0,
            children: [
              ...NavigationItemBuilder(Icons.bar_chart_outlined, "Отчёт",
                  route: DatesPage.route(), context: context),
              ...NavigationItemBuilder(
                  Icons.change_circle_sharp, "Изменить свойство пользоавтеля",
                  route: ChangeUserFacePage.route(), context: context),
              ...NavigationItemBuilder(Icons.lock_sharp, "Изменить пароль",
                  route: ChangePasswordPage.route(), context: context),
              ...NavigationItemBuilder(Icons.group_add_sharp, "Добавить группу",
                  route: AddGroupPage.route(), context: context),
              ...NavigationItemBuilder(
                  Icons.group_remove_sharp, "Удалить группу",
                  route: DeleteGroupPage.route(), context: context),
              ...NavigationItemBuilder(
                  Icons.person_add_sharp, "Добавить пользователя",
                  route: AddUserPage.route(), context: context),
              ...NavigationItemBuilder(
                  Icons.person_remove_sharp, "Удалить пользователя",
                  route: DeleteUserPage.route(), context: context),
              const Divider(
                color: Colors.grey,
              ),
              ...NavigationItemBuilder(
                  Icons.support_agent_sharp, "Связь с нами",
                  route: ContactPage.route(), context: context),
              ...NavigationItemBuilder(Icons.logout_sharp, "Выйти",
                  context: context, route: CheckPasswordPage.route(),signOut: true),
            ],
          ),
        ),
      ),
    );
  }
}
