import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

enum L10nKey {
  no,
  yes,
  offerCoffee,
  impossibleToOpenCoffeeLink,
  isDayValidated,
  isDayValidatedText,
  reconsiderTheDay,
  reconsiderTheDayText,
  goalTitle,
  titleRequired,
  moreInfos,
  renew,
  addAGoal,
  addTheGoal,
  accomplished,
  ignored,
  statsTitle,
  editGoalTitle,
  save,
  deleteTheGoal,
  warningDelete,
  cancel,
  delete,
  settingsTitle,
  dailyNotifications,
  monthlyNotifications,
  quarterlyNotifications,
  annualyNotifications,
  displayStats,
  morning,
  evening,
  startMonth,
  halfMonth,
  endMonth,
  firstDayOfMonth,

}

const Map<String, Map<L10nKey, String>> _kTranslations = {
  'fr': {
    L10nKey.no:'Non',
    L10nKey.yes:'Oui',
    L10nKey.offerCoffee: '☕ Offrez-moi un café',
    L10nKey.impossibleToOpenCoffeeLink: 'Impossible d\'ouvrir le lien de donation',
    L10nKey.isDayValidated: 'Valider la journée?',
    L10nKey.isDayValidatedText: 'Voulez-vous marquer cette journée comme accomplie?',
    L10nKey.reconsiderTheDay: 'Reconsidérer la journée?',
    L10nKey.reconsiderTheDayText: 'Voulez-vous marquer cette journée comme non accomplie ?',
    L10nKey.goalTitle: 'Titre de l\'objectif',
    L10nKey.titleRequired: 'Titre requis',
    L10nKey.moreInfos: 'Infos supplémentaires (optionnel)',
    L10nKey.renew: 'Reconduire',
    L10nKey.addAGoal: 'Ajouter un objectif',
    L10nKey.addTheGoal: 'Ajouter l\'objectif',
    L10nKey.accomplished: 'Accomplis',
    L10nKey.ignored: 'Ignorés',
    L10nKey.statsTitle: 'Statistiques d\'assiduité',
    L10nKey.editGoalTitle: 'Modifier l\'objectif',
    L10nKey.save: 'Sauvegarder',
    L10nKey.deleteTheGoal: 'Supprimer l\'objectif ?',
    L10nKey.warningDelete: 'Cette action est irréversible.',
    L10nKey.cancel: 'Annuler',
    L10nKey.delete: 'Supprimer',
    L10nKey.settingsTitle: 'Paramètres',
    L10nKey.dailyNotifications: 'Notifications journalières',
    L10nKey.monthlyNotifications: 'Notifications mensuelles',
    L10nKey.quarterlyNotifications: 'Notifications trimestrielles',
    L10nKey.annualyNotifications: 'Notifications annuelles',
    L10nKey.displayStats: 'Afficher les statistiques',
    L10nKey.morning: 'Matin',
    L10nKey.evening: 'Soir',
    L10nKey.startMonth: 'Début du mois',
    L10nKey.halfMonth: 'Moitié du mois',
    L10nKey.endMonth: 'Fin du mois',
    L10nKey.firstDayOfMonth: 'Chaque 1er du mois'

  },
  'en': {
    L10nKey.no:'No',
    L10nKey.yes:'Yes',
    L10nKey.offerCoffee: '☕ Buy me a coffee',
    L10nKey.impossibleToOpenCoffeeLink: 'Impossible to open the donation link',
    L10nKey.isDayValidated: 'Valid the day?',
    L10nKey.isDayValidatedText: 'Do you want to mark this day as accomplished?',
    L10nKey.reconsiderTheDay: 'Reconsider the day?',
    L10nKey.reconsiderTheDayText: 'Do you want to mark this day as unfulfilled?',
    L10nKey.goalTitle: 'Title',
    L10nKey.titleRequired: 'Title required',
    L10nKey.moreInfos: 'Additional information (optionnal)',
    L10nKey.renew: 'Renew',
    L10nKey.addAGoal: 'Add a goal',
    L10nKey.addTheGoal: 'Add the goal',
    L10nKey.accomplished: 'Accomplished',
    L10nKey.ignored: 'Ignored',
    L10nKey.statsTitle: 'Attendance statistics',
    L10nKey.editGoalTitle: 'Modify the goal',
    L10nKey.save: 'Save',
    L10nKey.deleteTheGoal: 'Delete the goal ?', 
    L10nKey.warningDelete: 'This action is irreversible',
    L10nKey.cancel: 'Cancel',
    L10nKey.delete: 'Delete',
    L10nKey.settingsTitle: 'Settings',
    L10nKey.displayStats: 'Display statistics',
    L10nKey.morning: 'Morning',
    L10nKey.evening: 'Evening',
    L10nKey.startMonth: 'Strat of the month',
    L10nKey.halfMonth: 'Half of the month',
    L10nKey.endMonth: 'End of the month',
    L10nKey.firstDayOfMonth: 'Every 1st of the month'


  },
};

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String t(L10nKey key) {
    final lang = locale.languageCode;
    final map = _kTranslations[lang] ?? _kTranslations['fr']!;
    return map[key] ?? '‹${describeEnum(key)}›';
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) =>
      ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
