import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/l10n/app_localizations.dart';
import 'features/profiles/presentation/cubit/profiles_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI();
  runApp(const DontForgetApp());
}

class DontForgetApp extends StatefulWidget {
  const DontForgetApp({super.key});

  @override
  State<DontForgetApp> createState() => _DontForgetAppState();
}

class _DontForgetAppState extends State<DontForgetApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    final prefs = getIt<SharedPreferences>();
    final lang = prefs.getString(AppConstants.keyLocale) ?? 'ru';
    _locale = Locale(lang);
  }

  void _changeLocale(String languageCode) {
    setState(() => _locale = Locale(languageCode));
    getIt<SharedPreferences>().setString(AppConstants.keyLocale, languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return LocaleNotifier(
      onLocaleChange: _changeLocale,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<ProfilesCubit>()..loadProfiles()),
        ],
        child: MaterialApp.router(
          title: 'DontForget',
          theme: AppTheme.light,
          locale: _locale,
          localizationsDelegates: const [
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ru'),
            Locale('en'),
          ],
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class LocaleNotifier extends InheritedWidget {
  final void Function(String) onLocaleChange;

  const LocaleNotifier({
    super.key,
    required this.onLocaleChange,
    required super.child,
  });

  static LocaleNotifier? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LocaleNotifier>();

  @override
  bool updateShouldNotify(LocaleNotifier oldWidget) => false;
}
