import 'package:faceq/features/auth/presentation/widgets/NavigationBar/NavigationSideBar.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  static route()=>MaterialPageRoute(builder: (context)=>ChangePasswordPage());

  final GlobalKey<ScaffoldState> _scaffoldKey =GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Icon(Icons.lock_sharp),
        centerTitle: true,
        leading: IconButton(onPressed: () {
          if (_scaffoldKey.currentState != null) {
            _scaffoldKey.currentState!.openDrawer();
          }
        }, icon:const  Icon(Icons.menu)),
      ),
      drawer: NavigationSideBar(scaffoldKey: _scaffoldKey),
    );
  }
}
