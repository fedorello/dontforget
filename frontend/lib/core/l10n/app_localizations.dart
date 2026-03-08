import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n? of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n);
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'DontForget'**
  String get appName;

  /// No description provided for @nav_today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get nav_today;

  /// No description provided for @nav_medicines.
  ///
  /// In ru, this message translates to:
  /// **'Лекарства'**
  String get nav_medicines;

  /// No description provided for @nav_shopping.
  ///
  /// In ru, this message translates to:
  /// **'Покупки'**
  String get nav_shopping;

  /// No description provided for @nav_todos.
  ///
  /// In ru, this message translates to:
  /// **'Задачи'**
  String get nav_todos;

  /// No description provided for @greeting_morning.
  ///
  /// In ru, this message translates to:
  /// **'Доброе утро, {name}!'**
  String greeting_morning(String name);

  /// No description provided for @greeting_afternoon.
  ///
  /// In ru, this message translates to:
  /// **'Добрый день, {name}!'**
  String greeting_afternoon(String name);

  /// No description provided for @greeting_evening.
  ///
  /// In ru, this message translates to:
  /// **'Добрый вечер, {name}!'**
  String greeting_evening(String name);

  /// No description provided for @take_now.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас принять'**
  String get take_now;

  /// No description provided for @taken.
  ///
  /// In ru, this message translates to:
  /// **'Принял'**
  String get taken;

  /// No description provided for @snooze_15.
  ///
  /// In ru, this message translates to:
  /// **'Отложить на 15 мин'**
  String get snooze_15;

  /// No description provided for @skip_today.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить сегодня'**
  String get skip_today;

  /// No description provided for @no_medicines_today.
  ///
  /// In ru, this message translates to:
  /// **'На сегодня всё принято'**
  String get no_medicines_today;

  /// No description provided for @add_medicine.
  ///
  /// In ru, this message translates to:
  /// **'Добавить лекарство'**
  String get add_medicine;

  /// No description provided for @add_medicine_by_name.
  ///
  /// In ru, this message translates to:
  /// **'Ввести название'**
  String get add_medicine_by_name;

  /// No description provided for @add_medicine_by_photo.
  ///
  /// In ru, this message translates to:
  /// **'Сфотографировать'**
  String get add_medicine_by_photo;

  /// No description provided for @medicine_name_hint.
  ///
  /// In ru, this message translates to:
  /// **'Название лекарства или БАД'**
  String get medicine_name_hint;

  /// No description provided for @analyzing.
  ///
  /// In ru, this message translates to:
  /// **'Анализирую...'**
  String get analyzing;

  /// No description provided for @analyzing_photo.
  ///
  /// In ru, this message translates to:
  /// **'Анализирую фото...'**
  String get analyzing_photo;

  /// No description provided for @medicine_what_it_does.
  ///
  /// In ru, this message translates to:
  /// **'Что делает'**
  String get medicine_what_it_does;

  /// No description provided for @medicine_dose.
  ///
  /// In ru, this message translates to:
  /// **'Доза'**
  String get medicine_dose;

  /// No description provided for @medicine_frequency.
  ///
  /// In ru, this message translates to:
  /// **'Как часто'**
  String get medicine_frequency;

  /// No description provided for @medicine_timing.
  ///
  /// In ru, this message translates to:
  /// **'Когда принимать'**
  String get medicine_timing;

  /// No description provided for @medicine_course.
  ///
  /// In ru, this message translates to:
  /// **'Курс'**
  String get medicine_course;

  /// No description provided for @medicine_side_effects.
  ///
  /// In ru, this message translates to:
  /// **'Побочные эффекты'**
  String get medicine_side_effects;

  /// No description provided for @medicine_compatibility.
  ///
  /// In ru, this message translates to:
  /// **'Совместимость'**
  String get medicine_compatibility;

  /// No description provided for @compatibility_ok.
  ///
  /// In ru, this message translates to:
  /// **'Совместим'**
  String get compatibility_ok;

  /// No description provided for @compatibility_caution.
  ///
  /// In ru, this message translates to:
  /// **'С осторожностью'**
  String get compatibility_caution;

  /// No description provided for @compatibility_danger.
  ///
  /// In ru, this message translates to:
  /// **'Несовместим'**
  String get compatibility_danger;

  /// No description provided for @start_reminders.
  ///
  /// In ru, this message translates to:
  /// **'Запустить напоминания'**
  String get start_reminders;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @active.
  ///
  /// In ru, this message translates to:
  /// **'Активные'**
  String get active;

  /// No description provided for @archive.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get archive;

  /// No description provided for @profile_title.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile_title;

  /// No description provided for @profiles_title.
  ///
  /// In ru, this message translates to:
  /// **'Профили'**
  String get profiles_title;

  /// No description provided for @add_profile.
  ///
  /// In ru, this message translates to:
  /// **'Добавить профиль'**
  String get add_profile;

  /// No description provided for @profile_name.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get profile_name;

  /// No description provided for @profile_birth_date.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения'**
  String get profile_birth_date;

  /// No description provided for @profile_gender.
  ///
  /// In ru, this message translates to:
  /// **'Пол'**
  String get profile_gender;

  /// No description provided for @profile_gender_male.
  ///
  /// In ru, this message translates to:
  /// **'Мужской'**
  String get profile_gender_male;

  /// No description provided for @profile_gender_female.
  ///
  /// In ru, this message translates to:
  /// **'Женский'**
  String get profile_gender_female;

  /// No description provided for @profile_weight.
  ///
  /// In ru, this message translates to:
  /// **'Вес (кг)'**
  String get profile_weight;

  /// No description provided for @profile_health_notes.
  ///
  /// In ru, this message translates to:
  /// **'Особенности здоровья'**
  String get profile_health_notes;

  /// No description provided for @profile_allergies.
  ///
  /// In ru, this message translates to:
  /// **'Аллергии'**
  String get profile_allergies;

  /// No description provided for @shopping_title.
  ///
  /// In ru, this message translates to:
  /// **'Покупки'**
  String get shopping_title;

  /// No description provided for @shopping_new_list.
  ///
  /// In ru, this message translates to:
  /// **'Новый список'**
  String get shopping_new_list;

  /// No description provided for @shopping_list_name.
  ///
  /// In ru, this message translates to:
  /// **'Название списка'**
  String get shopping_list_name;

  /// No description provided for @shopping_add_item.
  ///
  /// In ru, this message translates to:
  /// **'Добавить товар...'**
  String get shopping_add_item;

  /// No description provided for @shopping_clear_done.
  ///
  /// In ru, this message translates to:
  /// **'Очистить купленное'**
  String get shopping_clear_done;

  /// No description provided for @shopping_empty.
  ///
  /// In ru, this message translates to:
  /// **'Список пуст'**
  String get shopping_empty;

  /// No description provided for @shopping_all_done.
  ///
  /// In ru, this message translates to:
  /// **'Всё куплено!'**
  String get shopping_all_done;

  /// No description provided for @todos_title.
  ///
  /// In ru, this message translates to:
  /// **'Задачи'**
  String get todos_title;

  /// No description provided for @todo_add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить задачу...'**
  String get todo_add;

  /// No description provided for @todo_filter_all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get todo_filter_all;

  /// No description provided for @todo_filter_today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get todo_filter_today;

  /// No description provided for @todo_filter_week.
  ///
  /// In ru, this message translates to:
  /// **'На неделе'**
  String get todo_filter_week;

  /// No description provided for @todo_filter_done.
  ///
  /// In ru, this message translates to:
  /// **'Выполненные'**
  String get todo_filter_done;

  /// No description provided for @todo_empty.
  ///
  /// In ru, this message translates to:
  /// **'Задач нет'**
  String get todo_empty;

  /// No description provided for @todo_priority_high.
  ///
  /// In ru, this message translates to:
  /// **'Важная'**
  String get todo_priority_high;

  /// No description provided for @todo_set_reminder.
  ///
  /// In ru, this message translates to:
  /// **'Установить напоминание'**
  String get todo_set_reminder;

  /// No description provided for @todo_repeat.
  ///
  /// In ru, this message translates to:
  /// **'Повтор'**
  String get todo_repeat;

  /// No description provided for @error_generic.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так'**
  String get error_generic;

  /// No description provided for @error_no_connection.
  ///
  /// In ru, this message translates to:
  /// **'Нет соединения с сервером'**
  String get error_no_connection;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get loading;

  /// No description provided for @empty_state_medicines.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте первое лекарство или БАД'**
  String get empty_state_medicines;

  /// No description provided for @empty_state_todos.
  ///
  /// In ru, this message translates to:
  /// **'Здесь будут ваши задачи'**
  String get empty_state_todos;

  /// No description provided for @settings_language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settings_language;

  /// No description provided for @settings_language_ru.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get settings_language_ru;

  /// No description provided for @settings_language_en.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get settings_language_en;

  /// No description provided for @days_short.
  ///
  /// In ru, this message translates to:
  /// **'{count} дн.'**
  String days_short(int count);

  /// No description provided for @per_day.
  ///
  /// In ru, this message translates to:
  /// **'{count} раз в день'**
  String per_day(int count);

  /// No description provided for @confirm_delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить?'**
  String get confirm_delete;

  /// No description provided for @confirm_delete_message.
  ///
  /// In ru, this message translates to:
  /// **'Это действие нельзя отменить'**
  String get confirm_delete_message;

  /// No description provided for @units_remaining.
  ///
  /// In ru, this message translates to:
  /// **'Осталось {count} шт.'**
  String units_remaining(int count);

  /// No description provided for @recommendation_title.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендации'**
  String get recommendation_title;

  /// No description provided for @for_profile.
  ///
  /// In ru, this message translates to:
  /// **'Для {name}'**
  String for_profile(String name);

  /// No description provided for @accept_recommendation.
  ///
  /// In ru, this message translates to:
  /// **'Принять рекомендации'**
  String get accept_recommendation;

  /// No description provided for @adjust_recommendation.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get adjust_recommendation;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'ru':
      return AppL10nRu();
  }

  throw FlutterError(
      'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
