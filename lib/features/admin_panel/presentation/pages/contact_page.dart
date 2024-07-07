import 'dart:convert';

import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/core/widgets/progess_loading.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/show_snackbar.dart';
import 'package:faceq/features/admin_panel/presentation/widgets/NavigationBar/NavigationSideBar.dart';
import 'package:faceq/sl.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class ContactPage extends StatelessWidget {
  ContactPage({super.key});

  static route() =>
      MaterialPageRoute(
          builder: (context) => ContactPage());

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _credentials = sl<Credentials>();

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
      ),
      body:FutureBuilder(future: _sendRequest(), builder: (context,snapshot){
        if(snapshot.hasData && snapshot.data != null){
          final data = snapshot.data;
          final List<String> keys = [];
          for(final key in data!.keys){
            keys.add(key);
          }
          return SingleChildScrollView(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Developers",style: Theme.of(context).textTheme.headlineLarge,),
                ],
              ),
              const SizedBox(
                height: 50.0,
              ),
              ...List.generate(keys.length, (index){
                final peopleName = keys[index];
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration:const BoxDecoration(
                    border:  Border.fromBorderSide(BorderSide(color: Colors.blue,width: 5))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("$peopleName:\n",style: Theme.of(context).textTheme.headlineMedium,),
                      ...List.generate(data[peopleName].length, (index){
                        final link = data[peopleName][index];
                        return Wrap(
                          children: [
                            Text("\n$link",style: Theme.of(context).textTheme.titleLarge,),
                          ],
                        );
                      })
                    ],
                  ),
                );
              })
            ]
          ),);
        }
        return const ProgressLoading();
      })
    );
  }

  Future<Map<String, dynamic>>_sendRequest() async {
    final response = await http.post(Uri.parse("http://${_credentials.address}/getContact"),
        headers: {"Content-Type": "application/json"}, body: jsonEncode({
          'token':_credentials.token
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
