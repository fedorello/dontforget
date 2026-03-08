// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DontForget';

  @override
  String get nav_today => 'Today';

  @override
  String get nav_medicines => 'Medicines';

  @override
  String get nav_shopping => 'Shopping';

  @override
  String get nav_todos => 'Tasks';

  @override
  String greeting_morning(String name) {
    return 'Good morning, $name!';
  }

  @override
  String greeting_afternoon(String name) {
    return 'Good afternoon, $name!';
  }

  @override
  String greeting_evening(String name) {
    return 'Good evening, $name!';
  }

  @override
  String get take_now => 'Take now';

  @override
  String get taken => 'Taken';

  @override
  String get snooze_15 => 'Snooze 15 min';

  @override
  String get skip_today => 'Skip today';

  @override
  String get no_medicines_today => 'All done for today';

  @override
  String get add_medicine => 'Add medicine';

  @override
  String get add_medicine_by_name => 'Enter name';

  @override
  String get add_medicine_by_photo => 'Take a photo';

  @override
  String get medicine_name_hint => 'Medicine or supplement name';

  @override
  String get analyzing => 'Analyzing...';

  @override
  String get analyzing_photo => 'Analyzing photo...';

  @override
  String get medicine_what_it_does => 'What it does';

  @override
  String get medicine_dose => 'Dose';

  @override
  String get medicine_frequency => 'Frequency';

  @override
  String get medicine_timing => 'When to take';

  @override
  String get medicine_course => 'Course';

  @override
  String get medicine_side_effects => 'Side effects';

  @override
  String get medicine_compatibility => 'Compatibility';

  @override
  String get compatibility_ok => 'Compatible';

  @override
  String get compatibility_caution => 'Use with caution';

  @override
  String get compatibility_danger => 'Incompatible';

  @override
  String get start_reminders => 'Start reminders';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get done => 'Done';

  @override
  String get active => 'Active';

  @override
  String get archive => 'Archive';

  @override
  String get profile_title => 'Profile';

  @override
  String get profiles_title => 'Profiles';

  @override
  String get add_profile => 'Add profile';

  @override
  String get profile_name => 'Name';

  @override
  String get profile_birth_date => 'Date of birth';

  @override
  String get profile_gender => 'Gender';

  @override
  String get profile_gender_male => 'Male';

  @override
  String get profile_gender_female => 'Female';

  @override
  String get profile_weight => 'Weight (kg)';

  @override
  String get profile_health_notes => 'Health notes';

  @override
  String get profile_allergies => 'Allergies';

  @override
  String get shopping_title => 'Shopping';

  @override
  String get shopping_new_list => 'New list';

  @override
  String get shopping_list_name => 'List name';

  @override
  String get shopping_add_item => 'Add item...';

  @override
  String get shopping_clear_done => 'Clear done';

  @override
  String get shopping_empty => 'List is empty';

  @override
  String get shopping_all_done => 'All done!';

  @override
  String get todos_title => 'Tasks';

  @override
  String get todo_add => 'Add task...';

  @override
  String get todo_filter_all => 'All';

  @override
  String get todo_filter_today => 'Today';

  @override
  String get todo_filter_week => 'This week';

  @override
  String get todo_filter_done => 'Done';

  @override
  String get todo_empty => 'No tasks';

  @override
  String get todo_priority_high => 'Important';

  @override
  String get todo_set_reminder => 'Set reminder';

  @override
  String get todo_repeat => 'Repeat';

  @override
  String get error_generic => 'Something went wrong';

  @override
  String get error_no_connection => 'Cannot connect to server';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get empty_state_medicines => 'Add your first medicine or supplement';

  @override
  String get empty_state_todos => 'Your tasks will appear here';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_ru => 'Русский';

  @override
  String get settings_language_en => 'English';

  @override
  String days_short(int count) {
    return '$count days';
  }

  @override
  String per_day(int count) {
    return '${count}x per day';
  }

  @override
  String get confirm_delete => 'Delete?';

  @override
  String get confirm_delete_message => 'This action cannot be undone';

  @override
  String units_remaining(int count) {
    return '$count units left';
  }

  @override
  String get recommendation_title => 'Recommendations';

  @override
  String for_profile(String name) {
    return 'For $name';
  }

  @override
  String get accept_recommendation => 'Accept recommendations';

  @override
  String get adjust_recommendation => 'Adjust';
}
