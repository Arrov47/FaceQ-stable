import 'dart:io';

import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/core/widgets/progess_loading.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/show_snackbar.dart';
import 'package:faceq/features/admin_panel/presentation/widgets/NavigationBar/NavigationSideBar.dart';
import 'package:faceq/sl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ChangeUserFacePage extends StatefulWidget {
  const ChangeUserFacePage({super.key});

  static route() => MaterialPageRoute(
        builder: (context) => ChangeUserFacePage(),
      );

  @override
  State<ChangeUserFacePage> createState() => _ChangeUserFacePageState();
}

class _ChangeUserFacePageState extends State<ChangeUserFacePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _userID = TextEditingController();
  Widget? requestButton;
  File? _image;
  final _credentials = sl<Credentials>();
  @override
  void initState() {
    super.initState();
    _getRequestButtonClickable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Icon(
          Icons.change_circle_sharp,
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
            Container(
              height: 100.0,
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: TextField(
                style: Theme.of(context).textTheme.labelLarge,
                controller: _userID,
                decoration: const InputDecoration(
                    hintText: "Введите id пользователя",
                    helperText:
                        "Например: fe37ba49-6bf0-4f5b-af10-a42e0ac41da3",
                    border: OutlineInputBorder()),
              ),
            ),
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
                mainAxisAlignment: Platform.isWindows
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        await ImagePicker()
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
                  Platform.isWindows
                      ? Container()
                      : ElevatedButton(
                          onPressed: () async {
                            await ImagePicker()
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
            SizedBox(
              height: 25.0,
            ),
            requestButton ?? ProgressLoading(),
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
    if (_image != null) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("http://${_credentials.address}/changeUserFace"),
      );
      request.files
          .add(await http.MultipartFile.fromPath('photo', _image!.path));
      request.fields.addAll({
        'token': _credentials.token,
        'uuid': _userID.text,
      });
      request.send().then((response) {
        if (response.statusCode == 200) {
          setState(() {
            _image = null;
          });
          _getRequestButtonClickable();
          showSnackBar("Свойство успешно изменены", context, Colors.green);
        } else {
          _getRequestButtonClickable();
          showSnackBar(
              "Status code: ${response.statusCode}", context, Colors.red);
        }
      }, onError: (err) {
        _getRequestButtonClickable();
        showSnackBar("Status code: ${err.toString()}", context, Colors.red);
      });
    } else {
      _getRequestButtonClickable();
      showSnackBar("Выберите изоброжение", context, Colors.red);
    }
  }

  _getRequestButtonClickable() {
    setState(() {
      requestButton = ElevatedButton(
          onPressed: () => _sendRequest(),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("Изменить"),
          ));
    });
  }
}
