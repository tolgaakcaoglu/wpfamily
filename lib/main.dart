import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:country_codes/country_codes.dart';
import 'package:country_pickers/country.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/akar_icons.dart';
import 'package:iconify_flutter/icons/ant_design.dart';
import 'package:iconify_flutter/icons/bx.dart';
import 'package:iconify_flutter/icons/eva.dart';
import 'package:iconify_flutter/icons/heroicons.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/la.dart';
import 'package:iconify_flutter/icons/lucide.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:language_picker/languages.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wpfamilylastseen/const/colors.dart';
import 'package:wpfamilylastseen/const/localeprovider.dart';
import 'package:wpfamilylastseen/modal/clientmodal.dart';
import 'package:wpfamilylastseen/modal/numbersmodal.dart';
import 'package:wpfamilylastseen/modal/premiummodal.dart';
import 'package:wpfamilylastseen/modal/productsmodal.dart';
import 'package:wpfamilylastseen/modal/settingsmodal.dart';
import 'package:wpfamilylastseen/utils/utils.dart';
import 'package:wpfamilylastseen/widgets/analiticspagewidget.dart';
import 'package:wpfamilylastseen/widgets/homepagepopups.dart';

import 'funct/functions.dart';
import 'l10n/l10n.dart';
import 'widgets/homepagewidgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const SystemUiOverlayStyle(
      statusBarColor: Colorize.alpha, systemNavigationBarColor: Colorize.black);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await CountryCodes.init();
  runApp(const AilApp());
}

class AilApp extends StatelessWidget {
  const AilApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => LocaleProvider(),
        builder: (context, child) {
          final provider = Provider.of<LocaleProvider>(context);
          return MaterialApp(
            title: 'Wp Family Last Seen',
            theme: ThemeData(primarySwatch: Colors.green),
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark,
            locale: provider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: L10n.all,
            darkTheme: ThemeData.dark().copyWith(
              backgroundColor: Colorize.black,
              scaffoldBackgroundColor: Colorize.black,
              dividerTheme: const DividerThemeData(color: Colorize.layer),
              appBarTheme: const AppBarTheme(
                  backgroundColor: Colorize.black, elevation: 0.0),
            ),
            home: const Splash(),
          );
        });
  }
}

class Splash extends StatefulWidget {
  const Splash({Key key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String timezone;
  @override
  void initState() {
    super.initState();

    _getLocation();

    Timer(
        const Duration(milliseconds: 800),
        () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      locale: Localizations.localeOf(context).countryCode,
                      timezone: timezone,
                    ))));
  }

  _getLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionLocation;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionLocation = await location.hasPermission();

    if (permissionLocation == PermissionStatus.denied) {
      permissionLocation = await location.requestPermission();
      if (permissionLocation != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();

    if (mounted) {
      var zone = await Utils.getTimezone(locationData);

      setState(() {
        timezone = zone;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class HomePage extends StatefulWidget {
  final String locale, timezone;
  const HomePage({Key key, @required this.locale, @required this.timezone})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int phoneAddedLimit = 3;
  bool isPremium = false;

  Client client;
  bool error = false;

  TextEditingController newPhoneNameField = TextEditingController();
  TextEditingController newPhoneNumberField = TextEditingController();
  List<Numbers> _phones;
  List<PremiumPackage> _premiumPackages;
  List<Products> _products;
  DateTime activitesDateFilter;
  String phoneCode = '+90';

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String device = '';
  String devicemodel = '';

  @override
  void initState() {
    super.initState();

    _init();
    setState(() {});
  }

  _init() {
    _getDevice();
    if (mounted) {
      _registerMethod();

      setState(() {});

      if (mounted) {
        _getPhones();
        _getPremiumPackages();
        _getProducts();
        setState(() {});
      }
    }
  }

  _getDevice() async {
    try {
      if (Platform.isAndroid) {
        var info = await deviceInfoPlugin.androidInfo;
        device = info.id.replaceAll('.', '-');
        devicemodel = info.model;
      } else if (Platform.isIOS) {
        var info = await deviceInfoPlugin.iosInfo;
        device = info.utsname.nodename;
        devicemodel = info.utsname.machine;
      }

      setState(() {});
    } on PlatformException {
      debugPrint('error');
      error = true;
    }

    setState(() {});
  }

  _registerMethod() async {
    var json = await Funcs.register(
        device, widget.timezone, widget.locale, devicemodel);
    if (mounted) {
      if (json == "error") {
        setState(() {
          error = true;
        });
      } else {
        Client c = Client.build(jsonDecode(json));

        setState(() {
          client = c;
        });
      }
    }
  }

  void _getPhones() async {
    var body = await Funcs.numbers(device);
    if (body == "error") {
      setState(() {
        error = true;
        return;
      });
    }

    if (mounted) {
      List list = jsonDecode(body);
      setState(() {
        _phones = list.map((e) => Numbers.build(jsonDecode(e))).toList();
      });
      if (_phones.isNotEmpty) {
        Timer(
          const Duration(seconds: 5),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrialFreePremium(
                premiumStatus: (status) {
                  setState(() {
                    isPremium = status;
                  });
                },
              ),
            ),
          ),
        );
      }
      if (_phones.isEmpty) {
        newPhoneAddPopUp(
          context,
          newPhoneNameField,
          newPhoneNumberField,
          (Country country) {
            setState(() {
              phoneCode = country.phoneCode;
            });
          },
          newPhoneAddButtonFunction(context),
        );
      }
    }
  }

  void _getPremiumPackages() async {
    List<PremiumPackage> list = await Funcs.getPremiumPackages();

    if (mounted) {
      _premiumPackages = list;
    }
  }

  void _getProducts() async {
    var body = await Funcs.products(device);
    if (body == "error") {
      setState(() {
        error = true;
      });
      return;
    }
    if (mounted) {
      List list = jsonDecode(body);
      setState(() {
        _products = list.map((e) => Products.build(e)).toList();
      });
    }
  }

  newPhoneAddButtonFunction(context) => () async {
        // Numara Ekleme Popup'una ait "Takibe Başla (Kaydet)" butonuna ait fonksiyon

        // Input alanlarının dolu olup olmadığı kontrol ediliyor
        if (newPhoneNameField.text.trim().isEmpty ||
            newPhoneNumberField.text.trim().isEmpty) {
          //Input alanları boş ise bu uyarı mesajı veriliyor
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context).addPhoneNullFieldError);
        } else {
          //input alanları dolu ise buradaki fonksiyonlar çalışıyor

          // kayıtlı telefon sayısı kontrol edilip, cihaz ekleme limitimiz dolmuş mu diye bakıyor
          if (_phones.length < phoneAddedLimit) {
            // cihaz kaydetme limitimiz dolmadıysa burası çalışıyor ve yeni telefon bilgilerini cihazlarımıza kaydetmesi bekleniyor
            var body = await Funcs.addNumber(
                newPhoneNameField.text.trim(),
                newPhoneNumberField.text.replaceAll(' ', '').trim(),
                phoneCode,
                'token',
                'detail',
                device);
            if (body == "error") {
              failedPopUp(context);
            } else {
              _init();
              Navigator.pop(context);
              newPhoneNameField.clear();
              newPhoneNumberField.clear();
              successPopUp(context);
            }
            // _phones.add(Phone.build(
            //     {
            //       "countryCode": phoneCode,
            //       "number": newPhoneNumberField.text.replaceAll(' ', '').trim(),
            //       "label": newPhoneNameField.text.trim(),
            //       "status": "waiting",
            //       "created": "2022-10-16 14:52:45.070840",
            //       "activities": []
            //     },
            //   ));

            setState(() {});
          } else {
            // Telefon ekleme limitimizin dolu olduğu durumda bu kısım çalışıyor
            newPhoneNameField.clear();
            newPhoneNumberField.clear();
            setState(() {});
            Navigator.of(context)
              ..pop()
              ..push(MaterialPageRoute(
                  builder: (context) =>
                      PricesOptionsPage(packages: _premiumPackages)));
            // Ekleme ekran popup'ı kapanıyor ve Premium paket alma ekranı açılıyor
            // hata popup'ı gösteriliyor
            failedPopUp(context);
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context).addPhoneLimitError);
          }
        }
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: HomePageFAB(
          pressed: () => newPhoneAddPopUp(
                context,
                newPhoneNameField,
                newPhoneNumberField,
                (Country country) {
                  setState(() {
                    phoneCode = country.phoneCode;
                  });
                },
                newPhoneAddButtonFunction(context),
              )),
      appBar: AppBar(
        title: HomePageAppBarTitle(isPremium: isPremium),
        actions: [
          if (_premiumPackages != null && !isPremium)
            HomePageSwichProButton(
                pressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PricesOptionsPage(packages: _premiumPackages)))),
          HomePageIconButton(icon: Ion.refresh_circle, pressed: () => _init()),
          HomePageIconButton(
              icon: Eva.settings_fill,
              pressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                        packages: _premiumPackages, device: device),
                  ))),
          const SizedBox(width: 16.0),
        ],
      ),
      body: client == null
          ? const Center(child: CircularProgressIndicator())
          : !error
              ? HomePageBody(
                  phones: _phones,
                  currentDate: activitesDateFilter,
                  device: device,
                  // ! ACTİVİTELERİN TARİH FİLTERİSİ DEĞİŞTİĞİNDE GELEN TARİH VERİSİ
                  tapDate: (DateTime date) {
                    setState(() {
                      activitesDateFilter = date;
                    });
                  },
                )
              : const Center(child: Text('Connection error')),
    );
  }
}

class TrialFreePremium extends StatelessWidget {
  final Function(bool) premiumStatus;
  const TrialFreePremium({Key key, this.premiumStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);
    Row options(String text) => Row(
          children: [
            const Iconify(AkarIcons.circle_check_fill, color: Colorize.primary),
            const SizedBox(width: 8.0),
            Text(text),
          ],
        );

    return Scaffold(
      body: Banner(
        message: lang.tryFree.toUpperCase(),
        location: BannerLocation.topEnd,
        color: Colorize.primary,
        textStyle: const TextStyle(
            color: Colorize.black, fontSize: 10.0, fontWeight: FontWeight.w900),
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            standartTitle(lang.freeTrialTitle),
                            const SizedBox(height: 16.0),
                            options(lang.freeTrialLabel1),
                            const SizedBox(height: 8.0),
                            options(lang.freeTrialLabel2),
                            const SizedBox(height: 8.0),
                            options(lang.freeTrialLabel3),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: CupertinoButton(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colorize.primary,
                          onPressed: () {
                            premiumStatus(true);
                            Navigator.pop(context);
                            // TODO  8 SAAT PREMİUM DENEME SÜRECİNİ BAŞLAT
                          },
                          child: Text(
                            lang.freeTrialTryButton,
                            style: const TextStyle(
                                color: Colorize.black, fontSize: 16.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      standartCaption(lang.freeTrialCaption),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                    onPressed: () {
                      premiumStatus(false);
                      Navigator.pop(context);
                    },
                    child: Text(lang.close.toUpperCase(),
                        style: const TextStyle(color: Colorize.textSec))),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PricesOptionsPage extends StatefulWidget {
  final List<PremiumPackage> packages;
  const PricesOptionsPage({Key key, this.packages}) : super(key: key);

  @override
  State<PricesOptionsPage> createState() => _PricesOptionsPageState();
}

class _PricesOptionsPageState extends State<PricesOptionsPage> {
  int selectedPackage = 0;
  Row options(String text) => Row(
        children: [
          const Iconify(AkarIcons.circle_check_fill, color: Colorize.primary),
          const SizedBox(width: 8.0),
          Text(text),
        ],
      );

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          standartTitle(lang.pricesOptionsTitle),
                          const SizedBox(height: 16.0),
                          options(lang.freeTrialLabel1),
                          const SizedBox(height: 8.0),
                          options(lang.freeTrialLabel2),
                          const SizedBox(height: 8.0),
                          options(lang.freeTrialLabel3),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: GridView.builder(
                        primary: false,
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1 / 1,
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: widget.packages.length,
                        itemBuilder: (context, index) => InkWell(
                          onTap: () {
                            setState(() {
                              selectedPackage = index;
                            });

                            // ! widget.packages[index] İLE PAKET BİLGİLERİNE ERİŞEBİLİRSİN.

                            // !PAKET ADI => widget.packages[index].packageName;
                            // !PAKET FİYATI => widget.packages[index].price;
                            // !PAKET ETİKETİ => widget.packages[index].tag;
                          },
                          borderRadius: BorderRadius.circular(16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: index == selectedPackage
                                  ? Colorize.primary
                                  : Colorize.layer,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(widget.packages[index].tag.toUpperCase(),
                                      style: const TextStyle(fontSize: 10.0)),
                                  Text(
                                    widget.packages[index].packageName,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${widget.packages[index].price}₺',
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: CupertinoButton(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colorize.primary,
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO  PREMIUM PAKET SEÇİLDİKTEN SONRA ÖDEMEYE YÖNLENDİR
                        },
                        child: Text(
                          lang.contin,
                          style: const TextStyle(
                              color: Colorize.black, fontSize: 16.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    standartCaption(lang.pricesOptionsCaption),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(lang.close.toUpperCase(),
                      style: const TextStyle(color: Colorize.textSec))),
            ),
          )
        ],
      ),
    );
  }
}

class AnaliticsPage extends StatefulWidget {
  final Numbers phone;
  const AnaliticsPage({Key key, @required this.phone}) : super(key: key);

  @override
  State<AnaliticsPage> createState() => _AnaliticsPageState();
}

class _AnaliticsPageState extends State<AnaliticsPage> {
  int selectedOnlineGraphTab = 0;
  bool onWeekly = false;
  DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(lang.activities)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AnaliticsOnlineGraph(
                phone: widget.phone,
                selectedOnlineGraphTab: selectedOnlineGraphTab,
                onValueChanged: (int value) {
                  setState(() {
                    selectedOnlineGraphTab = value;
                  });
                },
              ),
              AnaliticsWeeklyData(
                onWeekly: onWeekly,
                selectedDate: selectedDate,
                onWeeklySlideChanged: (bool v) {
                  setState(() {
                    onWeekly = v;
                  });
                },
                dateChanged: (DateTime date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final String device;
  final List<PremiumPackage> packages;
  const SettingsPage({Key key, @required this.packages, @required this.device})
      : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String supportEmail = 'dest@mail.co'; //! TODO DESTEK EMAİLİNİ GİRİN
  String googlePlayAddress = 'https://'; //! TODO GOOGLE PLAY ADRESİNİ GİRİN

  Settings settings;
  bool error = false;

  Widget buildCupertinoItem(Language language) =>
      Center(child: Text(language.name));

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  void initState() {
    super.initState();

    _getSettings();
  }

  _getSettings() async {
    var body = await Funcs.settings(widget.device);
    if (body == "error") {
      setState(() {
        error = true;
      });
    } else {
      Settings s = Settings.build(jsonDecode(body));

      setState(() {
        settings = s;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    navigate(Widget widget) => Navigator.push(
        context, MaterialPageRoute(builder: (context) => widget));

    List<Map> list = [
      {
        "icon": Bx.support,
        "title": lang.support,
        "onTap": () async {
          final Uri url = Uri(
            scheme: 'mailto',
            path: supportEmail,
            query: encodeQueryParameters(<String, String>{
              'subject': lang.emailSupportSubject,
              'body': lang.emailSupportBody
            }),
          );

          if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
            throw 'Could not launch $url';
          }
        },
      },
      {
        "icon": Lucide.file_terminal,
        "title": lang.termsofuse,
        "onTap": () => navigate(
            PolicyAndPrivacyPage(page: 'policy', content: settings.termsOfUse)),
      },
      {
        "icon": MaterialSymbols.privacy_tip_outline_rounded,
        "title": lang.privacypolicy,
        "onTap": () => navigate(PolicyAndPrivacyPage(
            page: 'privacy', content: settings.privacyPolicy)),
      },
      {
        "icon": La.google_play,
        "title": lang.rateus,
        "onTap": () async {
          final Uri url = Uri.parse(googlePlayAddress);

          if (!await launchUrl(url)) {
            throw 'Could not launch $url';
          }
        },
      },
      {
        "icon": AntDesign.check_circle_outlined,
        "title": lang.premiumBenefits,
        "onTap": () => navigate(PricesOptionsPage(packages: widget.packages)),
      },
      {
        "icon": Heroicons.language_solid,
        "title": AppLocalizations.of(context).changeLang,
        "onTap": () => navigate(const ChangeLangaugePage()),
      }
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(lang.generalSettings),
      ),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : error
              ? const Center(child: Text('Connection error'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                tileColor: Colorize.layer,
                                horizontalTitleGap: 8.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                leading: Iconify(list[index]['icon'],
                                    color: Colorize.icon),
                                title: Text(list[index]['title']),
                                onTap: list[index]['onTap'],
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('E-posta: ',
                                  style: TextStyle(color: Colorize.text)),
                              Text(supportEmail,
                                  style:
                                      const TextStyle(color: Colorize.primary)),
                            ],
                          ),
                        ),
                        const Text('ID: null',
                            style: TextStyle(color: Colorize.icon)),
                        const SizedBox(height: 24.0),
                        Opacity(
                            opacity: 0.5,
                            child: Text(AppLocalizations.of(context).language)),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class ChangeLangaugePage extends StatefulWidget {
  const ChangeLangaugePage({Key key}) : super(key: key);

  @override
  State<ChangeLangaugePage> createState() => _ChangeLangaugePageState();
}

class _ChangeLangaugePageState extends State<ChangeLangaugePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context).changeLang)),
      body: ListView.builder(
        itemCount: L10n.all.length,
        itemBuilder: (context, index) => ListTile(
            title: Text(CountryCodes.detailsForLocale(L10n.all[index]).name),
            onTap: () {
              final provider =
                  Provider.of<LocaleProvider>(context, listen: false);
              provider.setLocale(L10n.all[index]);
            },
            trailing: L10n.all[index].languageCode ==
                    Localizations.localeOf(context).languageCode
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null),
      ),
    );
  }
}

class PolicyAndPrivacyPage extends StatelessWidget {
  final String page;
  final String content;
  const PolicyAndPrivacyPage({
    Key key,
    @required this.page,
    @required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title:
              Text(page == "privacy" ? lang.privacypolicy : lang.termsofuse)),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(content),
        ),
      ),
    );
  }
}
