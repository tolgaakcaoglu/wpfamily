import 'dart:async';
import 'package:country_codes/country_codes.dart';
import 'package:country_pickers/country.dart';
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
import 'package:url_launcher/url_launcher.dart';
import 'package:wpfamilylastseen/const/colors.dart';
import 'package:wpfamilylastseen/const/localeprovider.dart';
import 'package:wpfamilylastseen/modal/premiummodal.dart';
import 'package:wpfamilylastseen/privacyandpolicytexts.dart';
import 'package:wpfamilylastseen/widgets/analiticspagewidget.dart';
import 'package:wpfamilylastseen/widgets/homepagepopups.dart';
import 'funct/functions.dart';
import 'l10n/l10n.dart';
import 'modal/phonemodal.dart';
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
            home: const HomePage(),
          );
        });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int phoneAddedLimit = 3;
  bool isPremium = false;

  String imeiNo;
  String version;
  String locale;

  TextEditingController newPhoneNameField =
      TextEditingController(); // Yeni telefon eklendiğinde "telefon ismi" değerini sağlayan controller
  TextEditingController newPhoneNumberField =
      TextEditingController(); // Yeni telefon eklendiğinde "telefon numarası" değerini sağlayan controller
  List<Phone> _phones; // Tüm kayıtlı telefon bilgilerini bu değişken tutacak
  List<PremiumPackage>
      _premiumPackages; // Tüm premium paket bilgilerini bu değişken tutacak
  DateTime
      activitesDateFilter; // Aktivitelerin filtrelendiği tarih bilgisini tutan eleman
  String phoneCode = '+90';

  @override
  void initState() {
    super.initState();

    _init();
    setState(() {});
  }

  _init() {
    _getPhones(); // Kayıtlı telefonları json'dan alan fonksiyon
    _getPremiumPackages(); // Kayıtlı premium paketlerini json'dan alan fonksiyon

    setState(() {});
  }

  

  void _getPhones() async {
    List<Phone> copy = await Funcs.getPhones();
    if (mounted) {
      setState(() {
        _phones = copy;
      });
      if (copy.isNotEmpty) {
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
      if (copy.isEmpty) {
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
    List<PremiumPackage> copy = await Funcs.getPremiumPackages();
    if (mounted) {
      setState(() {
        _premiumPackages = copy;
      });
    }
  }

  newPhoneAddButtonFunction(context) => () {
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
            _phones.add(Phone.build(
              {
                "countryCode": phoneCode,
                "number": newPhoneNumberField.text.replaceAll(' ', '').trim(),
                "label": newPhoneNameField.text.trim(),
                "status": "waiting",
                "created": "2022-10-16 14:52:45.070840",
                "activities": []
              },
            ));
            newPhoneNameField.clear();
            newPhoneNumberField.clear();
            setState(() {});
            Navigator.pop(context);
            // Yeni telefon ekleme ekranı kapanıyor ve alttaki başarılı komutu çalışıyor
            // ? Başarısız olma durumunda
            // failedPopUp(context); // fonksiyonunu çalıştırabilirsiniz
            successPopUp(context);
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

          // TODO ! SAYFA DATALARINI YENİLEYEN FONKSİYON İHTİYAÇ YOKSA KALDIR
          HomePageIconButton(icon: Ion.refresh_circle, pressed: () => _init()),

          HomePageIconButton(
              icon: Eva.settings_fill,
              pressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsPage(packages: _premiumPackages),
                  ))),
          const SizedBox(width: 16.0),
        ],
      ),
      body: _phones == null
          ? const Center(child: CircularProgressIndicator())
          : _phones.isNotEmpty
              ? HomePageBody(
                  phones: _phones,
                  currentDate: activitesDateFilter,
                  // ! ACTİVİTELERİN TARİH FİLTERİSİ DEĞİŞTİĞİNDE GELEN TARİH VERİSİ
                  tapDate: (DateTime date) {
                    setState(() {
                      activitesDateFilter = date;
                    });
                  },
                )
              : const SizedBox(),
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
  final Phone phone;
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
  final List<PremiumPackage> packages;
  const SettingsPage({Key key, @required this.packages}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String supportEmail = 'tolga@aildev.com'; //! TODO DESTEK EMAİLİNİ GİRİN
  String googlePlayAddress =
      'https://bionluk.com/aildev'; //! TODO GOOGLE PLAY ADRESİNİ GİRİN

  Widget buildCupertinoItem(Language language) =>
      Center(child: Text(language.name));

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
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
        "onTap": () => navigate(const PolicyAndPrivacyPage(page: 'policy')),
      },
      {
        "icon": MaterialSymbols.privacy_tip_outline_rounded,
        "title": lang.privacypolicy,
        "onTap": () => navigate(const PolicyAndPrivacyPage(page: 'privacy')),
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
      body: SingleChildScrollView(
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
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      tileColor: Colorize.layer,
                      horizontalTitleGap: 8.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      leading:
                          Iconify(list[index]['icon'], color: Colorize.icon),
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
                        style: const TextStyle(color: Colorize.primary)),
                  ],
                ),
              ),
              const Text('ID: F3AF-8NQI-OH3DQ-PIINF',
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
  const PolicyAndPrivacyPage({Key key, @required this.page}) : super(key: key);

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
          child: Text(page == "privacy" ? privacyText : policyText),
        ),
      ),
    );
  }
}
