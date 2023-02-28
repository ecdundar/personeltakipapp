import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController =
      new TextEditingController(text: '');
  TextEditingController passwordController =
      new TextEditingController(text: '');
  bool beniHatirla = false;
  int _CurrentVersion = 25;

  @override
  void initState() {
    //form_load öncesi initcomponent, formcreate gibi
    super.initState();
    loadLogin();
    checkAppVersion();
    getDeviceInfo();
  }

  void checkAppVersion() {
    var apiVersion = 20;
    if (apiVersion > _CurrentVersion) {
      StoreRedirect.redirect(
        androidAppId: "com.ecdyazilim.hayatmobile",
        iOSAppId: "1529071858",
      );
    }
  }

  void getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      print(androidInfo.host);
    }
    if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      print(iosInfo.model);
    }
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    print(deviceInfo.toString());
    final allInfo = deviceInfo.data;
    print(allInfo.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 100,
                width: 200,
                child: Image.asset('lib/assets/images/bursakart-burulas.png'),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(5),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Kullanıcı Adı'),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(5),
                child: TextField(
                  controller: passwordController,
                  obscureText: true, //Şifre için metnin gizlenmesini sağlar.
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Kullanıcı Şifre'),
                ),
              ),
              SizedBox(height: 20),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlutterSwitch(
                        value: beniHatirla,
                        onToggle: (value) {
                          beniHatirla = value;
                          setState(() {});
                        }),
                    OutlinedButton.icon(
                      icon: Icon(
                        Icons.account_box,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Kullanıcı Giriş Yap',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue)),
                      onPressed: () {
                        girisYap(context);
                      },
                    )
                  ]),
              SizedBox(height: 50),
              TextButton(
                  onPressed: () {},
                  child: Text(
                    'Şifremi Unuttum',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ))
            ]),
      ),
    );
  }

  void girisYap(BuildContext context) {
    //Klavyeyi Kapat
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (usernameController.text == 'admin' &&
        passwordController.text == '123456') {
      saveLogin();
      Navigator.pushReplacementNamed(context, "/List");
    } else {
      EasyLoading.showToast('Kullanıcı adı ve/veya şifreniz hatalıdır !');
    }
  }

  Future<void> saveLogin() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setString("Username", beniHatirla ? usernameController.text : "");
    shared.setString("Password", beniHatirla ? passwordController.text : "");
    shared.setBool("BeniHatirla", beniHatirla);
  }

  void loadLogin() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    beniHatirla = await shared.getBool("BeniHatirla") ?? false;
    if (beniHatirla) {
      usernameController.text = await shared.getString("Username") ?? "";
      passwordController.text = await shared.getString("Password") ?? "";
    }
    setState(() {});
  }
}
