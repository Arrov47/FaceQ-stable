import 'dart:convert';

import 'package:faceq/core/widgets/progess_loading.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/show_snackbar.dart';
import 'package:faceq/features/admin_panel/presentation/widgets/NavigationBar/NavigationSideBar.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class ContactPage extends StatelessWidget {
  ContactPage({super.key, required this.storageResult});

  final Map<String, dynamic> storageResult;

  static route(Map<String, dynamic> storageResult) =>
      MaterialPageRoute(
          builder: (context) => ContactPage(storageResult: storageResult));

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Icon(
          Icons.support_agent_sharp,
          color: Theme
              .of(context)
              .iconTheme
              .color,
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              if (_scaffoldKey.currentState != null) {
                _scaffoldKey.currentState!.openDrawer();
              }
            },
            icon: const Icon(Icons.menu)),
      ),
      drawer: NavigationSideBar(
        scaffoldKey: _scaffoldKey,
        storageResult: storageResult,
      ),
      body:FutureBuilder(future: _sendRequest(), builder: (context,snapshot){
        if(snapshot.hasData && snapshot.data != null){
          final data = snapshot.data;
          return Center(child: Column(
            children: List.generate(data!.length, (_){
              Widget widget = const Text("");
              for(final key in data.keys){
                widget = Text("$key : ${data[key]}\n",style: Theme.of(context).textTheme.headlineLarge);
              }
              return widget;
            })
          ),);
        }
        return const ProgressLoading();
      })
    );
  }

  Future<Map<String, dynamic>>_sendRequest() async {
    final response = await http.post(Uri.parse("http://${storageResult['address']}/getContact"),
        headers: {"Content-Type": "application/json"}, body: jsonEncode({
          'token':storageResult['token']
        }));
    try{
      if(response.statusCode == 200){
        return jsonDecode(response.body);
      }else{
        showSnackBar("Status code: ", _scaffoldKey.currentState!.context, Colors.red);
        return {};
      }
    }catch(err){
      showSnackBar("Error: ${err.toString()}", _scaffoldKey.currentState!.context, Colors.red);
      return {};
    }

  }
}
