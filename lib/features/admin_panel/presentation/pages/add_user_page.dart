import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/core/widgets/progess_loading.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/local_storage/delete_credentials.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/show_snackbar.dart';
import 'package:faceq/features/admin_panel/presentation/widgets/NavigationBar/NavigationSideBar.dart';
import 'package:faceq/features/admin_panel/presentation/widgets/fieldBuilder.dart';
import 'package:faceq/features/auth/presentation/pages/check_password_page.dart';
import 'package:faceq/sl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  static route() => MaterialPageRoute(
      builder: (context) => AddUserPage());

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _name = TextEditingController();

  final _surName = TextEditingController();

  final _fatherName = TextEditingController();

  File? _image;
  String? _groupName;

  final ImagePicker _imagePicker = ImagePicker();

  final _credentials = sl<Credentials>();
  Widget requestButton = const ProgressLoading();
  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _surName.dispose();
    _getRequestButtonClickable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Icon(
          Icons.person_add_sharp,
          color: Theme.of(context).iconTheme.color,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...fieldBuilder("Введите имя", _name, context),
            ...fieldBuilder("Введите фамилию", _surName, context),
            ...fieldBuilder("Введите отчество", _fatherName, context),
            FutureBuilder(
                future: _getGroups(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final data = snapshot.data;
                    return Container(
                        margin: const EdgeInsets.all(20.0),
                        child: DropdownSearch<String>(
                            onChanged: (group) {
                              if (group != null) {
                                setState(() {
                                  _groupName = group;
                                });
                              }
                            },
                            items: List.generate(data!.length, (index) {
                              return data[index];
                            }),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              baseStyle: Theme.of(context).textTheme.labelLarge,
                              dropdownSearchDecoration: InputDecoration(
                                  enabledBorder: Theme.of(context)
                                      .inputDecorationTheme
                                      .enabledBorder,
                                  labelStyle: Theme.of(context)
                                      .inputDecorationTheme
                                      .labelStyle,
                                  errorStyle: Theme.of(context)
                                      .inputDecorationTheme
                                      .errorStyle,
                                  helperStyle: Theme.of(context)
                                      .inputDecorationTheme
                                      .helperStyle,
                                  border: OutlineInputBorder(),
                                  labelText: "Выберите группу"),
                            ),
                            popupProps: PopupProps.menu(
                              itemBuilder: (context, name, b) {
                                return InkWell(
                                  onTap: () {},
                                  child: ListTile(
                                    title: Text(
                                      name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                  ),
                                );
                              },
                              menuProps: MenuProps(
                                  shadowColor:
                                      Theme.of(context).iconTheme.color,
                                  backgroundColor: Theme.of(context)
                                      .scaffoldBackgroundColor),
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                  autocorrect: false,
                                  style: Theme.of(context).textTheme.labelLarge,
                                  decoration: InputDecoration(
                                    enabledBorder: Theme.of(context)
                                        .inputDecorationTheme
                                        .enabledBorder,
                                    hintStyle: Theme.of(context)
                                        .inputDecorationTheme
                                        .hintStyle,
                                    errorStyle: Theme.of(context)
                                        .inputDecorationTheme
                                        .errorStyle,
                                    helperStyle: Theme.of(context)
                                        .inputDecorationTheme
                                        .helperStyle,
                                  )),
                            )
                            // selectedItem: data[0],
                            ));
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    );
                  }
                }),
            Container(
              // height: 100.0,
              margin: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      height: 20.0,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Выберите источник изоброжения: ",
                      style: TextStyle(color: Colors.blue.shade400),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      height: 2.0,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: Platform.isWindows?MainAxisAlignment.center:MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        await _imagePicker
                            .pickImage(source: ImageSource.gallery)
                            .then((pickedImage) {
                          if (pickedImage != null) {
                            setState(() {
                              _image = File(pickedImage.path);
                            });
                          }
                        });
                      },
                      child: const Text("Галерея")),
                  Platform.isWindows?Container():ElevatedButton(
                      onPressed: () async {
                        await _imagePicker
                            .pickImage(source: ImageSource.camera)
                            .then((pickedImage) {
                          if (pickedImage != null) {
                            setState(() {
                              _image = File(pickedImage.path);
                            });
                          }
                        });
                      },
                      child: const Text("Камера"))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _image == null ? "Файл не выбран " : "Файл выбран ",
                    style: TextStyle(color: Colors.blue.shade400),
                  ),
                  _image == null
                      ? const Icon(
                          Icons.close,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                ],
              ),
            ),
            Divider(
              height: 20.0,
              color: Theme.of(context).iconTheme.color,
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50.0),
              child: requestButton,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _sendRequest() async {
    // final dio = Dio();
    // final formData = FormData.fromMap({
    //   'token': widget.storageResult['token'],
    //   'name': _name.text,
    //   'surname': _surName.text,
    //   'group': _groupName,
    //   "fathers_name": _fatherName.text,
    //   'photo': await MultipartFile.fromFile(_image!.path)
    // });
    //
    // print("SENDING THESE FOR ADDING USER: $formData");
    // await dio
    //     .post("http://${widget.storageResult['address']}/addUser",
    //         options: Options(headers: {"Content-type": "multipart/form-data"}),
    //         data: formData)
    //     .then((response) {
    //   print(
    //       "STATUS CODE: ${response.statusCode} |\nSTATUS MESSAGE: ${response.statusMessage} |\n DATA: ${response.data}");
    // });
    setState(() {
      requestButton = const ProgressLoading();
    });
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("http://${_credentials.address}/addUser"),

    );
    request.files.add(await http.MultipartFile.fromPath('photo', _image!.path));
    request.fields.addAll({'token':_credentials.token,
      'name': _name.text,
      'surname': _surName.text,
      'group': _groupName!,
      "fathers_name": _fatherName.text,});
    request.send().then((response){
      if(response.statusCode == 200){
        setState(() {
          _name.clear();
          _surName.clear();
          _groupName = null;
          _image = null;
          _fatherName.clear();
        });
        showSnackBar("Пользователь успешно добавлено", context, Colors.green);
        _getRequestButtonClickable();
      }else{
        showSnackBar("Status code: ${response.statusCode}", context, Colors.red);
        _getRequestButtonClickable();
      }
    },onError: (err){
      showSnackBar("Status code: ${err.toString()}", context, Colors.red);
      _getRequestButtonClickable();
    });
  }

  Future<List<dynamic>> _getGroups() async {
    try {
      final response = await http.post(
        Uri.parse("http://${_credentials.address}/getGroups"),
        body: jsonEncode({
          'token': _credentials.token,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final body = jsonDecode(response.body);
        if (!body['is_token_valid']) {
          _getRequestButtonClickable();
          _signOut();
          return [];
        } else {
          _getRequestButtonClickable();
          return body['groups'] as List<dynamic>;
        }
      } else {
        _getRequestButtonClickable();
        showSnackBar("Error occurred in client side",
            _scaffoldKey.currentState!.context, Colors.red);
        return [];
      }
    } catch (err) {
      _getRequestButtonClickable();
      showSnackBar(
          err.toString(), _scaffoldKey.currentState!.context, Colors.red);
      return [];
    }
  }

  _signOut() {
    deleteCredentials();
    Navigator.pushAndRemoveUntil(_scaffoldKey.currentState!.context,
        CheckPasswordPage.route(), (route) => false);
  }
  _getRequestButtonClickable(){
    setState(() {
      requestButton = ElevatedButton(
          onPressed: () async {
            if (_image == null ||
                _name.text.isEmpty ||
                _surName.text.isEmpty ||
                _groupName == null) {
              showSnackBar("Заполните все поля правильно ! ", context,
                  Colors.red);
            } else {
              _sendRequest();
            }
          },
          child: const Text("Добавить пользователя"));
    });
  }
}
