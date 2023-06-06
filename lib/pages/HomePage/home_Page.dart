import 'package:flutter/material.dart';
import 'package:purmaster/pages/SettingPage/setting_page.dart';
import 'package:purmaster/widget/custom_widget.dart';
import 'package:provider/provider.dart';
import 'package:purmaster/pages/HomePage/home_page_models.dart';
import 'package:purmaster/main_models.dart';
import 'package:purmaster/pages/SettingPage/setting_page_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomePageControll homePageControll;
  late WeatherControll weatherControll;
  late SettingPageControll settingPageControll;

  @override
  void initState() {
    super.initState();
    homePageControll = HomePageControll(homeContext: context);
    weatherControll = WeatherControll();
    reqestPermission.checkLocationPermission().then(
          (value) => value == true ? weatherControll.getWeatherInfo() : null,
        );
    settingPageControll = SettingPageControll(settingContext: context);
  }

  @override
  void dispose() {
    super.dispose();
    mqttClient.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: homePageControll),
        ChangeNotifierProvider.value(value: weatherControll),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xffffffff),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned(
                child: SizedBox(
                    height: 180,
                    child: PurMasterAppBar(
                      context: context,
                      title: '淨化大師',
                      settingButton: true,
                      userName: userInfo.name,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingPage(
                                    settingPageControll: settingPageControll)));
                      },
                    )),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                    const WeatherCard(),
                    SingleChildScrollView(
                      child: Column(
                        children: const [
                          //.....here is appBody
                          HomePageInner()
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////Widget////////////////////

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
        width: 320,
        height: 150,
        padding: const EdgeInsets.all(0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 120,
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20),
                      child: Icon(
                        context.watch<WeatherControll>().weatherIconData,
                        size: 50,
                      ),
                    ),
                    Text(
                      context.watch<WeatherControll>().weatherState,
                      style: const TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 120,
                width: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                          ),
                          Text(
                            '${context.watch<WeatherControll>().city} ${context.watch<WeatherControll>().town}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            iconSize: 20,
                            onPressed: () => context
                                .read<WeatherControll>()
                                .getWeatherInfo(),
                            icon: const Icon(
                              Icons.refresh,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Icon(
                            Icons.thermostat_outlined,
                            size: 30,
                          ),
                          Text(
                            '${context.watch<WeatherControll>().temp}C',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(
                            Icons.water_drop_outlined,
                            size: 30,
                          ),
                          Text(
                            '${context.watch<WeatherControll>().humd}%',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ]);
  }
}

class HomePageInner extends StatelessWidget {
  const HomePageInner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: MediaQuery.of(context).size.height * 0.5,
      child: GridView.count(
        primary: false,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        children: [
          ...context.watch<HomePageControll>().deviceBtnList,
          AddDeviceButton(
            onPress: () {
              Navigator.pushNamed(context, '/addNewDevicePage').then((value) {
                if (value != null) {
                  context
                      .read<HomePageControll>()
                      .addBtn(value as Map<String, dynamic>);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
