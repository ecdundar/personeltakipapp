import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:personeltakipapp/helpers/DBHelper.dart';
import 'package:personeltakipapp/model/PersonelModel.dart';
import 'package:personeltakipapp/screens/DetayScreen.dart';
import 'package:personeltakipapp/screens/QRScreen.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<PersonelModel>? personelListe = null;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    EasyLoading.show(status: "Liste Yükleniyor...").then((value) {
      DBHelper().getPersonelList().then((value) {
        EasyLoading.dismiss();
        personelListe = value;
        setState(() {});
      });
    });
  }

  void showActionSheet(BuildContext ctx, PersonelModel model) {
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
                      //tel: diye yazınca aramaya gidiyor.
                      launchUrlString("tel:${model.TELEFON}");
                    },
                    child: Text('Personel Telefon Et')),
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      //sms: diye yazınca aramaya gidiyor.
                      launchUrlString("sms:${model.TELEFON}");
                    },
                    child: Text('Personel SMS Gönder')),
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) =>
                                  QRScreen(PersonelItem: model))));
                    },
                    child: Text('Personel QR Code')),
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

  Future<void> readBarcode(BuildContext context) async {
    String result = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Vazgeç", true, ScanMode.QR);
    if (result.isNotEmpty) {
      var model = await DBHelper().getPersonel(result);
      if (model != null) {
        openDetayScreen(context, model);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Personel bilgisi bulunamadı !'),
        ));
      }
    }
  }

  void redirectToMarket() {
    StoreRedirect.redirect(
      androidAppId: "com.ecdyazilim.hayatmobile",
      iOSAppId: "1529071858",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personel Listesi"),
        actions: [
          GestureDetector(
              onTap: () {
                //openDetayScreen(context, null);
                readBarcode(context);
              },
              child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.qr_code_2, color: Colors.white))),
          GestureDetector(
              onTap: () {
                redirectToMarket();
              },
              child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.web, color: Colors.white)))
        ],
      ),
      body: Container(
        color: Colors.white,
        child: ListView.separated(
            itemBuilder: (extd, index) {
              return GestureDetector(
                  onTap: () {
                    openDetayScreen(context, personelListe![index]);
                  },
                  onLongPress: () {
                    showActionSheet(context, personelListe![index]);
                  },
                  child: Slidable(
                      key: Key(index.toString()),
                      direction: Axis.horizontal,
                      endActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            padding: EdgeInsets.all(20.0),
                            onPressed: (BuildContext ctx) {
                              personelSil(
                                  personelListe![index], index, context);
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Personel Sil',
                          )
                        ],
                      ),
                      child: personelListe![index].toView()));
            },
            separatorBuilder: (sep, index) {
              return Divider();
            },
            itemCount: personelListe?.length ?? 0),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 15, right: 15),
        child: FloatingActionButton(
            heroTag: "button1", //Birden fazla kullanımında istiyor.
            backgroundColor: Colors.blue,
            onPressed: () {
              openDetayScreen(context, null);
            },
            child: Icon(Icons.add)),
      ),
    );
  }

  void personelSil(PersonelModel model, int index, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Burulaş Personel Takip'),
            content: Text(
                'Personel [${model.ADISOYADI}] kaydını silmek istediğinizden emin misiniz?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Vazgeç')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    DBHelper().deletePersonel(model).then((value) {
                      personelListe!.removeAt(index);
                      setState(() {});
                    });
                  },
                  child: Text('Evet, Sil'))
            ],
          );
        });
  }

  Future<void> openDetayScreen(
      BuildContext context, PersonelModel? model) async {
    //Eğer DetayScreen den true dönersek liste yenilenecek, değilse aynen kalacak

    if (model == null) {
      final result = await Navigator.pushNamed(context, "/Detay");
      if (result != null && result == true) {
        refreshData();
      }
    } else {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => DetayScreen(PersonelItem: model))));
      if (result != null && result == true) {
        refreshData();
      }
    }
  }
}
