import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:personeltakipapp/helpers/DBHelper.dart';
import 'package:personeltakipapp/helpers/DateHelper.dart';
import 'package:personeltakipapp/helpers/UtilsHelper.dart';
import 'package:personeltakipapp/model/PersonelModel.dart';
import 'package:personeltakipapp/screens/PDFViewerScreen.dart';

class DetayScreen extends StatefulWidget {
  final PersonelModel? PersonelItem;
  const DetayScreen({super.key, required this.PersonelItem});

  @override
  State<DetayScreen> createState() => _DetayScreenState(PersonelItem);
}

class _DetayScreenState extends State<DetayScreen> {
  //Personel bilgisini taşımak için kullanılıyor.
  final PersonelModel? PersonelItem;
  _DetayScreenState(this.PersonelItem) {
    if (this.PersonelItem != null) {
      tcKimlikController.text = PersonelItem?.TCKIMLIKNO ?? "";
      adSoyadController.text = PersonelItem?.ADISOYADI ?? "";
      cinsiyetController.text = PersonelItem?.CINSIYET ?? "";
      telefonController.text = PersonelItem?.TELEFON ?? "";
      imagePath = PersonelItem?.RESIMYOLU;
      if (PersonelItem?.DOGUMTARIHI != null) {
        dogumTarihiController.text =
            DateHelper.GetString(PersonelItem!.DOGUMTARIHI!, "dd.MM.yyyy");
        selectedDate = PersonelItem!.DOGUMTARIHI!;
      }
    }
  }

  TextEditingController tcKimlikController = TextEditingController();
  TextEditingController adSoyadController = TextEditingController();
  TextEditingController cinsiyetController = TextEditingController();
  TextEditingController dogumTarihiController = TextEditingController();
  TextEditingController telefonController = TextEditingController();
  DateTime? selectedDate; //Seçili tarihi DateTime almak için kullandık.
  Future<void> selectDogumTarihi(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: new DateTime(1970),
        lastDate: DateTime.now());
    if (pickedDate != null) {
      selectedDate = pickedDate;
      dogumTarihiController.text =
          DateHelper.GetString(pickedDate, "dd.MM.yyyy");
    }
  }

  final List<String> cinsiyetList = ['ERKEK', 'KADIN'];
  Future selectCinsiyet(BuildContext context) {
    return showDialog(
        context: context,
        builder: (dcontext) {
          var dialog = AlertDialog(
            title: Text('Cinsiyet Seçiniz'),
            content: SingleChildScrollView(
              //Telefon boyutuna göre sığmama durumu ile karşılaşmamak için SingleChildScrollView kullandık.
              child: Container(
                  width: double
                      .infinity, //Alert ekranı widthini ayarlamak için kullanıyoruz.
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: cinsiyetList
                        .map((e) => RadioListTile(
                              title: Row(children: [
                                Icon(e == "ERKEK" ? Icons.male : Icons.female),
                                SizedBox(width: 20),
                                Text(e)
                              ]),
                              value: e,
                              groupValue: cinsiyetController.text,
                              selected: cinsiyetController.text == e,
                              onChanged: (value) {
                                cinsiyetController.text = value.toString();
                                setState(() {});
                                Navigator.of(dcontext).pop();
                              },
                            ))
                        .toList(),
                  )),
            ),
          );
          return dialog;
        });
  }

  void personelKaydet(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      //Kaydet
      var model = this.PersonelItem ?? new PersonelModel();
      model.TCKIMLIKNO = tcKimlikController.text;
      model.ADISOYADI = adSoyadController.text;
      model.TELEFON = telefonController.text;
      model.DOGUMTARIHI = selectedDate;
      model.CINSIYET = cinsiyetController.text;
      model.RESIMYOLU = imagePath;

      if (this.PersonelItem != null) {
        DBHelper().updatePersonel(model).then((value) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Personel kaydedildi.')));
          Navigator.pop(context, true);
        }).catchError((onError) {
          //hata mesajını gösterebiliriz.
          EasyLoading.showError('Personel Kaydedilemedi.' + onError.toString());
        });
      } else {
        DBHelper().insertPersonel(model).then((value) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Personel kaydedildi.')));
          Navigator.pop(context, true);
        }).catchError((onError) {
          //hata mesajını gösterebiliriz.
          EasyLoading.showError('Personel Kaydedilemedi.' + onError.toString());
        });
      }
    }
  }

  Future<void> selectImage(BuildContext ctx) async {
    //Yetki Kontrolü Yaptığımız YEr
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();
    if ((statuses[Permission.camera] == PermissionStatus.denied ||
            statuses[Permission.camera] ==
                PermissionStatus.permanentlyDenied) ||
        (statuses[Permission.storage] == PermissionStatus.denied ||
            statuses[Permission.storage] ==
                PermissionStatus.permanentlyDenied)) {
      openAppSettings();
    } else {
      showSecim(ctx);
    }
  }

  void showSecim(BuildContext ctx) {
    showCupertinoDialog(
        context: ctx,
        barrierDismissible: true,
        builder: (builder) => Align(
            alignment: Alignment.bottomCenter,
            child: CupertinoActionSheet(
              message: Text("Lütfen seçim yapınız !"),
              actions: [
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      selectImageFromGallery();
                    },
                    child: Text('Galeri')),
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      selectImageFromCamera();
                    },
                    child: Text('Kamera')),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'Vazgeç',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )));
  }

  String? imagePath = null;
  Future<void> selectImageFromGallery() async {
    XFile? _file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxHeight: 300, maxWidth: 300);
    if (_file != null) {
      imagePath = _file.path;
      setState(() {});
    }
  }

  Future<void> selectImageFromCamera() async {
    XFile? _file = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 300, maxWidth: 300);
    if (_file != null) {
      imagePath = _file.path;
      setState(() {});
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    //Telefon bilgisinin belli bir formatta girilmesi için eklendi (Mask)
    var maskFormatter = new MaskTextInputFormatter(
        mask: '0 (###) ### ## ##',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy);
    return Scaffold(
      appBar: AppBar(title: Text("Personel Detay")),
      body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(20),
              child: Form(
                  //Validation kullanmak için Form nesnesini ekledik.
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Center(
                              child: Container(
                            color: Colors.yellow,
                            width: 200,
                            height: 150,
                            child: GestureDetector(
                                onTap: () {
                                  selectImage(context);
                                },
                                child: imagePath != null
                                    ? Image.file(
                                        File(imagePath!),
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl:
                                            "http://via.placeholder.com/200x150",
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      )),
                          ))),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: TextFormField(
                          //Validation kullanacaksak TextFormField gerekiyor.
                          controller: tcKimlikController,
                          keyboardType:
                              TextInputType.number, //Aktif klavye görünümü
                          maxLength: 11,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'T.C. Kimlik No',
                              prefixIcon:
                                  Icon(Icons.card_membership), //sol icon
                              suffixIcon:
                                  tcKimlikController.text.isNotEmpty //sağ ikon
                                      ? IconButton(
                                          icon: Icon(Icons.clear_outlined),
                                          onPressed: () {
                                            tcKimlikController.text = "";
                                          },
                                        )
                                      : null),
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "T.C. Kimlik No boş olamaz";
                            }
                            if (value.trim().length != 11) {
                              return "T.C. Kimlik No 11 rakamdan oluşmalıdır.";
                            }
                            if (UtilsHelper.isTCKimlikNo(
                                    int.parse(value.trim())) ==
                                false) {
                              return "Lütfen geçerli bir T.C. Kimlik No giriniz.";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: TextField(
                          controller: adSoyadController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Adı Soyadı',
                              prefixIcon: Icon(Icons.account_box_outlined)),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: TextField(
                          controller: cinsiyetController,
                          readOnly: true,
                          showCursor: false,
                          enableInteractiveSelection: false,
                          onTap: (() {
                            selectCinsiyet(context);
                          }),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Cinsiyet',
                              prefixIcon: Icon(Icons.person)),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: TextField(
                          showCursor: false, //imleci gösterme
                          readOnly: true, //readonly yap
                          enableInteractiveSelection:
                              false, //tıklanmaya bağlı renklendirme yapma
                          controller: dogumTarihiController,
                          onTap: () {
                            selectDogumTarihi(context);
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Doğum Tarihi',
                              prefixIcon: Icon(Icons.calendar_month)),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: TextField(
                          controller: telefonController,
                          inputFormatters: [maskFormatter],
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Cep Telefonu',
                              prefixIcon: Icon(Icons.phone)),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  /*MaterialPageRoute(
                                      builder: ((context) => PDFViewerScreen(
                                            PdfUrl:
                                                'https://online.burulas.com.tr/Ebelge/Sorgula/c903d9f5-a047-4b77-8823-78b1a560bef6',
                                          )))*/
                                  MaterialPageRoute(
                                      builder: ((context) => PDFViewerScreen(
                                            PdfUrl:
                                                'https://online.burulas.com.tr/Ebelge/Sorgula/c903d9f5-a047-4b77-8823-78b1a560bef6',
                                          ))));
                            },
                            child: Text("Aydınlatma Metni")),
                      ),
                      SizedBox(height: 20),
                      Container(
                          width: MediaQuery.of(context)
                              .size
                              .width, //Ekranın size ini almak için kullanıyoruz.
                          child: ElevatedButton.icon(
                              onPressed: () {
                                personelKaydet(context);
                              },
                              icon: Icon(Icons.save),
                              label: Text('Personel Kaydet')))
                    ],
                  )))),
    );
  }
}
