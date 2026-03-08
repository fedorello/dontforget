// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'DontForget';

  @override
  String get nav_today => 'Сегодня';

  @override
  String get nav_medicines => 'Лекарства';

  @override
  String get nav_shopping => 'Покупки';

  @override
  String get nav_todos => 'Задачи';

  @override
  String greeting_morning(String name) {
    return 'Доброе утро, $name!';
  }

  @override
  String greeting_afternoon(String name) {
    return 'Добрый день, $name!';
  }

  @override
  String greeting_evening(String name) {
    return 'Добрый вечер, $name!';
  }

  @override
  String get take_now => 'Сейчас принять';

  @override
  String get taken => 'Принял';

  @override
  String get snooze_15 => 'Отложить на 15 мин';

  @override
  String get skip_today => 'Пропустить сегодня';

  @override
  String get no_medicines_today => 'На сегодня всё принято';

  @override
  String get add_medicine => 'Добавить лекарство';

  @override
  String get add_medicine_by_name => 'Ввести название';

  @override
  String get add_medicine_by_photo => 'Сфотографировать';

  @override
  String get medicine_name_hint => 'Название лекарства или БАД';

  @override
  String get analyzing => 'Анализирую...';

  @override
  String get analyzing_photo => 'Анализирую фото...';

  @override
  String get medicine_what_it_does => 'Что делает';

  @override
  String get medicine_dose => 'Доза';

  @override
  String get medicine_frequency => 'Как часто';

  @override
  String get medicine_timing => 'Когда принимать';

  @override
  String get medicine_course => 'Курс';

  @override
  String get medicine_side_effects => 'Побочные эффекты';

  @override
  String get medicine_compatibility => 'Совместимость';

  @override
  String get compatibility_ok => 'Совместим';

  @override
  String get compatibility_caution => 'С осторожностью';

  @override
  String get compatibility_danger => 'Несовместим';

  @override
  String get start_reminders => 'Запустить напоминания';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get add => 'Добавить';

  @override
  String get done => 'Готово';

  @override
  String get active => 'Активные';

  @override
  String get archive => 'Архив';

  @override
  String get profile_title => 'Профиль';

  @override
  String get profiles_title => 'Профили';

  @override
  String get add_profile => 'Добавить профиль';

  @override
  String get profile_name => 'Имя';

  @override
  String get profile_birth_date => 'Дата рождения';

  @override
  String get profile_gender => 'Пол';

  @override
  String get profile_gender_male => 'Мужской';

  @override
  String get profile_gender_female => 'Женский';

  @override
  String get profile_weight => 'Вес (кг)';

  @override
  String get profile_health_notes => 'Особенности здоровья';

  @override
  String get profile_allergies => 'Аллергии';

  @override
  String get shopping_title => 'Покупки';

  @override
  String get shopping_new_list => 'Новый список';

  @override
  String get shopping_list_name => 'Название списка';

  @override
  String get shopping_add_item => 'Добавить товар...';

  @override
  String get shopping_clear_done => 'Очистить купленное';

  @override
  String get shopping_empty => 'Список пуст';

  @override
  String get shopping_all_done => 'Всё куплено!';

  @override
  String get todos_title => 'Задачи';

  @override
  String get todo_add => 'Добавить задачу...';

  @override
  String get todo_filter_all => 'Все';

  @override
  String get todo_filter_today => 'Сегодня';

  @override
  String get todo_filter_week => 'На неделе';

  @override
  String get todo_filter_done => 'Выполненные';

  @override
  String get todo_empty => 'Задач нет';

  @override
  String get todo_priority_high => 'Важная';

  @override
  String get todo_set_reminder => 'Установить напоминание';

  @override
  String get todo_repeat => 'Повтор';

  @override
  String get error_generic => 'Что-то пошло не так';

  @override
  String get error_no_connection => 'Нет соединения с сервером';

  @override
  String get retry => 'Повторить';

  @override
  String get loading => 'Загрузка...';

  @override
  String get empty_state_medicines => 'Добавьте первое лекарство или БАД';

  @override
  String get empty_state_todos => 'Здесь будут ваши задачи';

  @override
  String get settings_language => 'Язык';

  @override
  String get settings_language_ru => 'Русский';

  @override
  String get settings_language_en => 'English';

  @override
  String days_short(int count) {
    return '$count дн.';
  }

  @override
  String per_day(int count) {
    return '$count раз в день';
  }

  @override
  String get confirm_delete => 'Удалить?';

  @override
  String get confirm_delete_message => 'Это действие нельзя отменить';

  @override
  String units_remaining(int count) {
    return 'Осталось $count шт.';
  }

  @override
  String get recommendation_title => 'Рекомендации';

  @override
  String for_profile(String name) {
    return 'Для $name';
  }

  @override
  String get accept_recommendation => 'Принять рекомендации';

  @override
  String get adjust_recommendation => 'Изменить';
}
