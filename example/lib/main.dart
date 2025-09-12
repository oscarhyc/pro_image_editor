import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/example_constants.dart';
import 'core/mixin/example_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Necessary initialization for package:media_kit.
  MediaKit.ensureInitialized();

  await Supabase.initialize(
    url: 'SUPABASE_URL',
    anonKey: 'SUPABASE_ANON_KEY',
    debug: false,
  );

  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  /// Creates a new [MyApp] widget.
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro-Image-Editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      home: const NetworkEditorPage(),
    );
  }
}

class NetworkEditorPage extends StatefulWidget {
  const NetworkEditorPage({super.key});

  @override
  State<NetworkEditorPage> createState() => _NetworkEditorPageState();
}

class _NetworkEditorPageState extends State<NetworkEditorPage>
    with ExampleHelperState<NetworkEditorPage> {
  late final _configs = ProImageEditorConfigs(
    designMode: ImageEditorDesignMode.material,
  );
  late final _callbacks = ProImageEditorCallbacks(
    onImageEditingStarted: onImageEditingStarted,
    onImageEditingComplete: onImageEditingComplete,
    onCloseEditor: (editorMode) => onCloseEditor(editorMode: editorMode),
    mainEditorCallbacks: MainEditorCallbacks(
      helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.network(
      kImageEditorExampleNetworkUrl,
      callbacks: _callbacks,
      configs: _configs,
    );
  }
}

/// It's handy to then extract the Supabase client in a variable for later uses
final supabase = Supabase.instance.client;
