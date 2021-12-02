import 'package:MusicAppUnit/Dispositivos/cores_degrade.dart';
import 'package:MusicAppUnit/Configuradores/supabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController controller = TextEditingController();
  Uuid uuid = const Uuid();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future _addUserData(String name) async {
    int? status;
    await Hive.box('settings').put('name', name.trim());
    final DateTime now = DateTime.now();
    final List createDate = now
        .toUtc()
        .add(const Duration(hours: 5, minutes: 30))
        .toString()
        .split('.')
      ..removeLast()
      ..join('.');

    String userId = uuid.v1();
    status = await SupaBase().createUser({
      'id': userId,
      'name': name,
      'accountCreatedOn': '${createDate[0]} IST',
      'timeZone':
          "Zone: ${now.timeZoneName} Offset: ${now.timeZoneOffset.toString().replaceAll('.000000', '')}",
    });

    while (status == null || status == 409) {
      userId = uuid.v1();
      status = await SupaBase().createUser({
        'id': userId,
        'name': name,
        'accountCreatedOn': '${createDate[0]} IST',
        'timeZone':
            "Zone: ${now.timeZoneName} Offset: ${now.timeZoneOffset.toString().replaceAll('.000000', '')}",
      });
    }
    await Hive.box('settings').put('userId', userId);
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                  child: Image.asset(
                'assets/imageminicial2.png',
                fit: BoxFit.fill,
                width: 1100,
              )),
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Container(
                                    child: Image.asset(
                                  'assets/musicboxLogin.png',
                                  fit: BoxFit.fill,
                                  width: 350,
                                ))
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                      top: 5, bottom: 5, left: 10, right: 10),
                                  height: 57.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5.0,
                                        offset: Offset(0.0, 3.0),
                                      )
                                    ],
                                  ),
                                  child: TextField(
                                      controller: controller,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1.5,
                                              color: Colors.transparent),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.person_pin,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        border: InputBorder.none,
                                        hintText: AppLocalizations.of(context)!
                                            .enterName,
                                        hintStyle: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      onSubmitted: (String value) {
                                        if (value.trim() == '') {
                                          _addUserData(
                                              AppLocalizations.of(context)!
                                                  .guest);
                                        } else {
                                          _addUserData(value.trim());
                                        }
                                        Hive.box('settings')
                                            .put('auth', 'done');
                                      }),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (controller.text.trim() == '') {
                                      _addUserData('Guest');
                                    } else {
                                      _addUserData(controller.text.trim());
                                    }
                                    Hive.box('settings').put('auth', 'done');
                                    Navigator.popAndPushNamed(context, '/pref');
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    height: 55.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5.0,
                                          offset: Offset(0.0, 3.0),
                                        )
                                      ],
                                    ),
                                    child: Center(
                                        child: Text(
                                      AppLocalizations.of(context)!.getStarted,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
