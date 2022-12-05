import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bx.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/fa6_solid.dart';
import 'package:iconify_flutter/icons/fluent_mdl2.dart';
import 'package:iconify_flutter/icons/game_icons.dart';
import 'package:iconify_flutter/icons/gg.dart';
import 'package:iconify_flutter/icons/wpf.dart';
import 'package:wpfamilylastseen/const/colors.dart';
import 'package:wpfamilylastseen/const/date.dart';
import 'package:wpfamilylastseen/main.dart';
import 'package:wpfamilylastseen/modal/eventsmodal.dart';
import 'package:wpfamilylastseen/modal/numbersmodal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'homepagepopups.dart';

class TextFieldy extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType type;
  final Widget suffix, icon;
  final bool enabled;

  const TextFieldy(
      {Key key,
      @required this.hint,
      this.icon,
      @required this.controller,
      this.suffix,
      @required this.type,
      this.enabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 1,
      enabled: enabled ?? true,
      keyboardType: type,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colorize.layer,
        hintText: hint,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        hintStyle: const TextStyle(color: Colorize.icon),
        prefixIcon: icon != null
            ? SizedBox(
                width: 24.0,
                height: 24.0,
                child: Center(
                  child: icon,
                ),
              )
            : null,
        suffixIcon: suffix,
      ),
    );
  }
}

class HomePageAppBarTitle extends StatelessWidget {
  final bool isPremium;
  const HomePageAppBarTitle({Key key, this.isPremium}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      isPremium ? _premiumLogo() : _buildAppLogo(),
      _buildAppTitle(),
      if (isPremium) _premium(lang)
    ]);
  }

  Padding _buildAppTitle() => const Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: Text('WFLS',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20.0,
              color: Colorize.icon)));

  Widget _premium(lang) => Center(
      child: Text(lang.premium.toUpperCase(),
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w100,
              color: Colorize.icon)));

  Widget _premiumLogo() =>
      const Iconify(GameIcons.sharp_crown, color: Colorize.icon, size: 32);
  SizedBox _buildAppLogo() => SizedBox(
      width: 32.0,
      height: 32.0,
      child: Image.asset('assets/launcher_icon_line.png'));
}

class HomePageFAB extends StatelessWidget {
  final Function pressed;
  const HomePageFAB({Key key, @required this.pressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);
    return FloatingActionButton.extended(
        backgroundColor: Colorize.primary,
        foregroundColor: Colorize.black,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        onPressed: pressed,
        label: _buildLabel(lang),
        icon: _buildIcon());
  }

  Iconify _buildIcon() =>
      const Iconify(FluentMdl2.add_phone, color: Colorize.black);

  Text _buildLabel(AppLocalizations lang) => Text(lang.addNumber,
      style: const TextStyle(
          color: Colorize.black,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w900));
}

class HomePageSwichProButton extends StatelessWidget {
  final Function pressed;
  const HomePageSwichProButton({Key key, @required this.pressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);
    return CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        onPressed: pressed,
        child: Text(lang.switchPro,
            style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: Colorize.primary)));
  }
}

class HomePageIconButton extends StatelessWidget {
  final String icon;
  final Function pressed;

  const HomePageIconButton({
    Key key,
    @required this.icon,
    @required this.pressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.0,
      height: 32.0,
      margin: const EdgeInsets.only(left: 4.0),
      child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: pressed,
          icon: Iconify(icon, color: Colorize.icon)),
    );
  }
}

class HomePageBody extends StatelessWidget {
  final Function(DateTime) tapDate;
  final List<Numbers> phones;
  final DateTime currentDate;
  final String device;
  const HomePageBody(
      {Key key,
      this.phones,
      this.tapDate,
      this.currentDate,
      @required this.device})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          HomePagePhoneList(phones: phones, device: device),
          HomePageActivitiesWidget(
              phones: phones, tapDate: tapDate, currentDate: currentDate),
        ],
      ),
    );
  }
}

class HomePagePhoneList extends StatelessWidget {
  final List<Numbers> phones;
  final String device;
  const HomePagePhoneList({Key key, this.phones, @required this.device})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: phones.length,
      primary: false,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) =>
          HomePagePhoneCardTile(phone: phones[index], device: device),
    );
  }
}

class HomePagePhoneCardTile extends StatefulWidget {
  final Numbers phone;
  final String device;
  const HomePagePhoneCardTile({Key key, this.phone, @required this.device})
      : super(key: key);

  @override
  State<HomePagePhoneCardTile> createState() => _HomePagePhoneCardTileState();
}

class _HomePagePhoneCardTileState extends State<HomePagePhoneCardTile> {
  Numbers phone;
  TextEditingController nameController = TextEditingController();
  bool notification = false;

  @override
  void initState() {
    setState(() {
      phone = widget.phone;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colorize.layer,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
            margin: const EdgeInsets.only(left: 40.0),
            decoration: BoxDecoration(
              color: phone.status == 0 ? Colorize.layer : Colorize.amber,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: phone.status == 0
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Iconify(
                        Bx.time_five,
                        size: 10.0,
                        color: Colorize.text,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        lang.procesing,
                        style: const TextStyle(
                          fontSize: 10.0,
                          color: Colorize.text,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Iconify(
                        Gg.danger,
                        size: 10.0,
                        color: Colorize.black,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        lang.onHold,
                        style: const TextStyle(
                          fontSize: 10.0,
                          color: Colorize.black,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 8.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Iconify(
                    Carbon.phone_voice_filled,
                    size: 32.0,
                    color: Colorize.icon,
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        phone.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '+${phone.countryCode}${phone.number}',
                        style: const TextStyle(color: Colorize.icon),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => editPhonePopUp(context, phone, (status) {
                        setState(() {
                          notification = status;
                        });
                      }, notification, nameController, widget.device),
                      icon: const Iconify(
                        Fa6Solid.pen_to_square,
                        color: Colorize.icon,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnaliticsPage(phone: phone),
                          )),
                      icon: const Iconify(
                        Wpf.statistics,
                        color: Colorize.icon,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomePageActivitiesWidget extends StatefulWidget {
  final Function(DateTime) tapDate;
  final List<Numbers> phones;
  final DateTime currentDate;
  const HomePageActivitiesWidget(
      {Key key, this.phones, this.tapDate, this.currentDate})
      : super(key: key);

  @override
  State<HomePageActivitiesWidget> createState() =>
      _HomePageActivitiesWidgetState();
}

class _HomePageActivitiesWidgetState extends State<HomePageActivitiesWidget> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          HomeActivitiesHeader(
              tapDate: widget.tapDate, currentDate: widget.currentDate),
          HomeActivitiesTabBar(
              selectedTab: selectedTab,
              phones: widget.phones,
              changed: (v) {
                setState(() => selectedTab = v);
              }),
          HomeActivitiesListView(
            tabIndex: selectedTab,
            phones: widget.phones,
          ),
        ],
      ),
    );
  }
}

class HomeActivitiesHeader extends StatelessWidget {
  final Function(DateTime) tapDate;
  final DateTime currentDate;
  const HomeActivitiesHeader({Key key, this.tapDate, this.currentDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          lang.activities,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colorize.text,
            fontSize: 24.0,
          ),
        ),
        InkWell(
          // aktivitelerin tarhi filtresi
          onTap: () =>
              showDatePopUp(context, currentDate ?? DateTime.now(), tapDate),
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colorize.layer,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              currentDate != null
                  ? '${currentDate.day.toString()} ${getMonth(context, currentDate.month)}'
                  : '${DateTime.now().day.toString()} ${getMonth(context, DateTime.now().month)}',
              style: const TextStyle(color: Colorize.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeActivitiesTabBar extends StatelessWidget {
  final List<Numbers> phones;
  final Function changed;
  final int selectedTab;
  const HomeActivitiesTabBar(
      {Key key, this.phones, this.changed, this.selectedTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: CupertinoSlidingSegmentedControl(
          backgroundColor: Colorize.layer,
          padding: const EdgeInsets.all(4.0),
          groupValue: selectedTab,
          onValueChanged: changed,
          thumbColor: Colorize.primary,

          // TODO  TELEFONLARIN AKTİVİTELERİ BİRLEŞTİRİLİP TÜMÜ SEKMESİ OLARAK SIFIRINCI DİZİNE EKLENECEK
          // ! DİKKAT ! EN AZ 1 CİHAZ EKLENECEK DE OLSA TÜMÜ SEKMESİ OLMAK ZORUNDADIR
          // ! KURAL GEREĞİ SEKME SAYISI 1 OLAMAZ EN AZ İKİ OLMALIDIR
          // ! HİÇ CİHAZ EKLENMEDİYSE SEKME GÖRÜNMEZ DURUMDADIR
          children: phones
              .asMap()
              .entries
              .map((e) => Text(e.value.name,
                  style: TextStyle(
                      color: selectedTab == e.key
                          ? Colorize.black
                          : Colorize.text)))
              .toList()
              .asMap()),
    );
  }
}

class HomeActivitiesListView extends StatelessWidget {
  final List<Numbers> phones;
  final int tabIndex;
  const HomeActivitiesListView({Key key, this.tabIndex, this.phones})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);
    return phones[tabIndex].events.isEmpty
        ? Container(
            width: MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            decoration: BoxDecoration(
              color: Colorize.layer,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: [
                const Iconify(
                  Carbon.recently_viewed,
                  size: 64.0,
                  color: Colorize.icon,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    lang.nullActivityText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colorize.textSec,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  lang.nullActivityCaption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colorize.icon),
                ),
              ],
            ),
          )
        : ListView(
            primary: false,
            shrinkWrap: true,
            children: phones[tabIndex]
                .events
                .map((a) => ActivityCard(
                      phone: phones[tabIndex],
                      activity: a,
                    ))
                .toList());
  }
}

class ActivityCard extends StatelessWidget {
  final Numbers phone;
  final Events activity;
  const ActivityCard({Key key, this.phone, this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: Colorize.layer, borderRadius: BorderRadius.circular(8.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(phone.name, overflow: TextOverflow.ellipsis),
              Text(
                activity.onlineHour,
                style: const TextStyle(fontSize: 12.0, color: Colorize.icon),
              )
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                activity.duraction,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                lang.activeTime,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 8.0,
                  color: Colorize.icon,
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(activity.offlineDate, overflow: TextOverflow.ellipsis),
              Text(
                activity.offlineHour,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colorize.icon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
