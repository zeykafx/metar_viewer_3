import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:metar_viewer_3/main.dart';
import 'package:metar_viewer_3/screens/components/settings_section.dart';
import 'package:metar_viewer_3/screens/settings/settings_store.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: const [
          GeneralSettings(),
          WeatherSection(),
          AboutSection(),
        ],
      ),
    );
  }
}

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  SettingsStore settingsStore = SettingsStore();

  TextEditingController metarController = TextEditingController();
  TextEditingController tafController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return SettingsSection(
        title: "General",
        children: [
          ListTile(
            title: const Text(
              "Dark Mode",
            ),
            subtitle: Text(
              "${settingsStore.darkMode ? "Disable" : "Enable"} dark mode",
            ),
            onTap: () {
              MyApp.of(context).changeThemeMode(!settingsStore.darkMode ? ThemeMode.dark : ThemeMode.light);
              settingsStore.setDarkMode(!settingsStore.darkMode);
            },
            trailing: Switch(
              value: settingsStore.darkMode,
              onChanged: (bool value) {
                MyApp.of(context).changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                settingsStore.setDarkMode(value);
              },
            ),
          ),

          // default page
          ListTile(
            title: const Text(
              "TAF Page as start page",
            ),
            subtitle: Text(
              "${settingsStore.startPage ? "Disable" : "Enable"} TAF page as start page",
            ),
            onTap: () {
              settingsStore.setStartPage(!settingsStore.startPage);
            },
            trailing: Switch(
              value: settingsStore.startPage,
              onChanged: (bool value) {
                settingsStore.setStartPage(value);
              },
            ),
          ),
        ],
      );
    });
  }
}

class WeatherSection extends StatefulWidget {
  const WeatherSection({super.key});

  @override
  State<WeatherSection> createState() => _WeatherSectionState();
}

class _WeatherSectionState extends State<WeatherSection> {
  SettingsStore settingsStore = SettingsStore();

  TextEditingController metarController = TextEditingController();
  TextEditingController tafController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return SettingsSection(
        title: "Features",
        children: [
          // fetch metar on startup
          ListTile(
            title: const Text(
              "Fetch Metar on Startup",
            ),
            subtitle: Text(
              "${settingsStore.fetchMetarOnStartup ? "Disable" : "Enable"} fetching Metar for a specific airport on startup",
            ),
            onTap: () {
              settingsStore.setFetchMetarOnStartup(!settingsStore.fetchMetarOnStartup);
            },
            trailing: Switch(
              value: settingsStore.fetchMetarOnStartup,
              onChanged: (bool value) {
                settingsStore.setFetchMetarOnStartup(value);
              },
            ),
          ),

          if (settingsStore.fetchMetarOnStartup) ...[
            ListTile(
              title: const Text("Default Metar Airport"),
              subtitle: const Text("Airport for which to fetch Metar on startup"),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Text(settingsStore.defaultMetarAirport ?? "Tap to enter a default airport"),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Default Metar Airport"),
                      content: TextField(
                        controller: metarController,
                        autocorrect: false,
                        onChanged: (String newVal) {
                          settingsStore.setDefaultMetarAirport(newVal);
                        },
                        onSubmitted: (String newVal) {
                          settingsStore.setDefaultMetarAirport(newVal);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Set default metar airport to ${settingsStore.defaultMetarAirport}"),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Default Airport",
                          hintText: "Enter a default airport",
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cancel"),
                        ),
                        FilledButton(
                          onPressed: () {
                            settingsStore.setDefaultMetarAirport(metarController.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Set default metar airport to ${settingsStore.defaultMetarAirport}"),
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],

          // fetch taf on startup
          ListTile(
            title: const Text(
              "Fetch Taf on Startup",
            ),
            subtitle: Text(
              "${settingsStore.fetchTafOnStartup ? "Disable" : "Enable"} fetching Taf for a specific airport on startup",
            ),
            onTap: () {
              settingsStore.setFetchTafOnStartup(!settingsStore.fetchTafOnStartup);
            },
            trailing: Switch(
              value: settingsStore.fetchTafOnStartup,
              onChanged: (bool value) {
                settingsStore.setFetchTafOnStartup(value);
              },
            ),
          ),

          if (settingsStore.fetchTafOnStartup) ...[
            ListTile(
              title: const Text("Default Taf Airport"),
              subtitle: const Text("Airport for which to fetch Taf on startup"),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Text(settingsStore.defaultTafAirport ?? "Tap to enter a default airport"),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Default Taf Airport"),
                      content: TextField(
                        controller: tafController,
                        autocorrect: false,
                        onChanged: (String newVal) {
                          settingsStore.setDefaultTafAirport(newVal);
                        },
                        onSubmitted: (String newVal) {
                          settingsStore.setDefaultTafAirport(newVal);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Set default taf airport to ${settingsStore.defaultTafAirport}"),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Default Airport",
                          hintText: "Enter a default airport",
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cancel"),
                        ),
                        FilledButton(
                          onPressed: () {
                            settingsStore.setDefaultTafAirport(tafController.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Set default taf airport to ${settingsStore.defaultTafAirport}"),
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ],
      );
    });
  }
}

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return const Text("Error loading package info");
          }
          return SettingsSection(
            title: "About",
            children: [
              ListTile(
                title: const Text(
                  "Metar Viewer",
                ),
                subtitle: Text("Version: ${snapshot.data?.version}\nBuild: ${snapshot.data?.buildNumber}"),
              ),
              ListTile(
                title: const Text(
                  "Source Code",
                ),
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("You can find the source code at "),
                    Text("github.com/zeykafx/metar_viewer_3", style: TextStyle(color: Colors.blue)),
                  ],
                ),
                onTap: () {
                  // open the paypal link
                  launchUrlString("https://github.com/zeykafx/metar_viewer_3");
                },
                trailing: const Icon(Icons.open_in_new),
              ),
              ListTile(
                title: const Text(
                  "Made by Corentin Detry",
                ),
                subtitle: const Row(
                  children: [
                    Text("If you like this app, you can support me at "),
                    Text("paypal.me/zeykafx", style: TextStyle(color: Colors.blue)),
                  ],
                ),
                onTap: () {
                  // open the paypal link
                  launchUrlString("https://paypal.me/zeykafx");
                },
                trailing: const Icon(Icons.open_in_new),
              ),
            ],
          );
        });
  }
}
