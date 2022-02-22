import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmodinstaller/config.dart';
import 'package:tmodinstaller/src/models/models.dart';
import 'package:tmodinstaller/src/screens/modlist.dart';
import 'package:tmodinstaller/src/screens/settings.dart';
import 'package:tmodinstaller/src/utils.dart';
import 'package:tmodinstaller/theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();
  await Config.initializePreference();
  await Future.wait([
    flutter_acrylic.Window.initialize(),
    _TModInstallerPageState.fetchData(),
    WindowManager.instance.ensureInitialized()
  ]);

  // await WindowManager.instance.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    // await windowManager.setTitleBarStyle('hidden');
    // await windowManager.setSize(const Size(755, 545));
    // await windowManager.setMinimumSize(const Size(755, 545));
    await windowManager.center();
    await windowManager.show();
    await windowManager.setSkipTaskbar(false);
  });

  runApp(const TModInstallerApp());
}

class TModInstallerApp extends StatelessWidget {
  const TModInstallerApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AppTheme(),
        builder: (context, _) {
          final appTheme = context.watch<AppTheme>();
          //Quick and dirty way to set the color!
          var theme = Config.preferences?.getInt("color");
          if (theme != null) {
            if (theme == -1) {
              appTheme.rawColor = systemAccentColor;
            } else {
              appTheme.rawColor = Colors.accentColors[theme];
            }
          }

          return FluentApp(
            title: 'Tricked mod Installer',
            debugShowCheckedModeBanner: false,
            color: appTheme.color,
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              accentColor: appTheme.color,
              visualDensity: VisualDensity.standard,
              focusTheme: FocusThemeData(
                glowFactor: is10footScreen() ? 2.0 : 0.0,
              ),
            ),
            theme: ThemeData(
              accentColor: appTheme.color,
              visualDensity: VisualDensity.standard,
              focusTheme: FocusThemeData(
                glowFactor: is10footScreen() ? 2.0 : 0.0,
              ),
            ),
            builder: (context, child) {
              return Directionality(
                textDirection: appTheme.textDirection,
                child: child!,
              );
            },
            home: const TModInstallerPage(title: 'Tricked mod Installer'),
          );
        });
  }
}

class TModInstallerPage extends StatefulWidget {
  const TModInstallerPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<TModInstallerPage> createState() => _TModInstallerPageState();
}

class _TModInstallerPageState extends State<TModInstallerPage> {
  @override
  void initState() {
    super.initState();
  }

  int index = 0;

  final settingsController = ScrollController();

  @override
  void dispose() {
    settingsController.dispose();
    super.dispose();
  }

  static Future<void> fetchData() async {
    try {
      var repos = Config.preferences?.getStringList("repos");
      if (repos != null) {
        for (var repo in repos) {
          final res = await http.get(Uri.parse(repo.trim()));
          var data = json.decode(res.body);

          mods = [
            ...mods,
            ...data["mods"].map((x) {
              x["repo"] = data["id"];
              return Mod.fromJson(x);
            })
          ];
        }
      } else {
        final response =
            await http.get(Uri.parse('https://tmod.deno.dev/skyclient.json'));
        var data = json.decode(response.body);

        mods = [
          ...mods,
          ...data["mods"].map((x) {
            x["repo"] = data["id"];
            return Mod.fromJson(x);
          })
        ];
      }
    } catch (_) {
      mods = [
        Mod(
            categories: [],
            repo: "INVALID",
            display: "INVALID REPO DETECTED",
            description:
                "PLEASE ENSURE THAT ALL REPOS ARE VALID AND WORKING BEFORE ADDING THEM",
            id: "INVALID",
            downloads: [
              DownloadMod(
                  filename: "INVALID",
                  id: "INVALID",
                  mcversion: "0.0.0",
                  version: "0.0.0",
                  hash: "sha1;null",
                  url: "")
            ],
            nicknames: [],
            conflicts: [],
            forgeid: "INVALID",
            meta: {},
            icon:
                "https://cdn-images-1.medium.com/max/1200/1*5-aoK8IBmXve5whBQM90GA.png")
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();

    List<String> versions = Set.of(mods
        .map((x) => x.downloads.map((x) => x.mcversion))
        .expand((i) => i)).toList();

    // snapshot.data.
    // // print(mods);
    // // print(versions);
    return NavigationView(
      appBar: NavigationAppBar(
        title: () {
          // return const DragToMoveArea(
          //   child: Align(
          //     alignment: AlignmentDirectional.centerStart,
          //     child: Text("a"),
          //   ),
          // );
        }(),
        // actions: DragToMoveArea(
        //   child: Row(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     // children: const [Spacer(), WindowButtons()],
        //   ),
        // ),
      ),
      pane: NavigationPane(
        selected: index,
        onChanged: (i) => setState(() => index = i),
        size: const NavigationPaneSize(
          openMinWidth: 250,
          openMaxWidth: 320,
        ),
        header: Container(
          height: kOneLineTileHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: const FlutterLogo(
            style: FlutterLogoStyle.horizontal,
            size: 100,
          ),
        ),
        // displayMode: appTheme.displayMode,
        // indicatorBuilder: () {
        //   switch (appTheme.indicator) {
        //     case NavigationIndicators.end:
        //       return NavigationIndicator.end;
        //     case NavigationIndicators.sticky:
        //     default:
        //       return NavigationIndicator.sticky;
        //   }
        // }(),
        items: [
          ...versions.map(
            (e) => PaneItem(
              icon: const Icon(FluentIcons.game),
              title: Text(e),
            ),
          )
          // It doesn't look good when resizing from compact to open
          // PaneItemHeader(header: Text('User Interaction')),
          // PaneItem(
          //   icon: const Icon(FluentIcons.checkbox_composite),
          //   title: const Text('Inputs'),
          // ),
          // PaneItem(
          //   icon: const Icon(FluentIcons.text_field),
          //   title: const Text('Forms'),
          // ),
          // PaneItemSeparator(),
          // PaneItem(
          //   icon: const Icon(FluentIcons.color),
          //   title: const Text('Colors'),
          // ),
          // PaneItem(
          //   icon: const Icon(FluentIcons.icon_sets_flag),
          //   title: const Text('Icons'),
          // ),
          // PaneItem(
          //   icon: const Icon(FluentIcons.plain_text),
          //   title: const Text('Typography'),
          // ),
          // PaneItem(
          //   icon: const Icon(FluentIcons.cell_phone),
          //   title: const Text('Mobile'),
          // ),
          // PaneItem(
          //   icon: Icon(
          //     appTheme.displayMode == PaneDisplayMode.top
          //         ? FluentIcons.more
          //         : FluentIcons.more_vertical,
          //   ),
          //   title: const Text('Others'),
          //   infoBadge: const InfoBadge(
          //     source: Text('9'),
          //   ),
          // ),
        ],
        // autoSuggestBox: AutoSuggestBox(
        //   controller: TextEditingController(),
        //   items: const ['Item 1', 'Item 2', 'Item 3', 'Item 4'],
        // ),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
          ),
          // _LinkPaneItemAction(
          //   icon: const Icon(FluentIcons.open_source),
          //   title: const Text('Source code'),
          //   link: 'https://github.com/bdlukaa/fluent_ui',
          // ),
        ],
      ),

      // appBar: NavigationAppBar(title: Text("Fluent Design App Bar")),
      // content: comp,
      content: NavigationBody(index: index, children: [
        ...versions.map((version) => ModListsPage(
              mods: [
                ...mods.where((x) =>
                    x.downloads.where((x) => x.mcversion == version).isNotEmpty)
              ],
              version: version,
            )),
        // const InputsPage(),
        // const Forms(),
        // const ColorsPage(),
        // const IconsPage(),
        // const TypographyPage(),
        // const Mobile(),
        // const Others(),
        Settings(controller: settingsController),
      ]),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
