import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// No description provided for @certificateDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do certificado'**
  String get certificateDetails;

  /// No description provided for @issuer.
  ///
  /// In pt, this message translates to:
  /// **'Emissor'**
  String get issuer;

  /// No description provided for @issueDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de emissão'**
  String get issueDate;

  /// No description provided for @description.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get description;

  /// No description provided for @files.
  ///
  /// In pt, this message translates to:
  /// **'Arquivos'**
  String get files;

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @openFile.
  ///
  /// In pt, this message translates to:
  /// **'Abrir arquivo'**
  String get openFile;

  /// No description provided for @attachFiles.
  ///
  /// In pt, this message translates to:
  /// **'Anexar arquivos'**
  String get attachFiles;

  /// No description provided for @deleteCertificateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir certificado?'**
  String get deleteCertificateTitle;

  /// No description provided for @deleteCertificateMessage.
  ///
  /// In pt, this message translates to:
  /// **'Isso também excluirá os arquivos armazenados.'**
  String get deleteCertificateMessage;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @newCertificate.
  ///
  /// In pt, this message translates to:
  /// **'Novo certificado'**
  String get newCertificate;

  /// No description provided for @editCertificate.
  ///
  /// In pt, this message translates to:
  /// **'Editar certificado'**
  String get editCertificate;

  /// No description provided for @title.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get title;

  /// No description provided for @selectFiles.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar arquivos ({count}/5)'**
  String selectFiles(Object count);

  /// No description provided for @createCertificate.
  ///
  /// In pt, this message translates to:
  /// **'Criar certificado'**
  String get createCertificate;

  /// No description provided for @saveChanges.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get saveChanges;

  /// No description provided for @onlyAllowedFiles.
  ///
  /// In pt, this message translates to:
  /// **'Apenas JPG, PNG e PDF de até 1 MB são permitidos.'**
  String get onlyAllowedFiles;

  /// No description provided for @selectAtLeastOneFile.
  ///
  /// In pt, this message translates to:
  /// **'Selecione pelo menos um arquivo.'**
  String get selectAtLeastOneFile;

  /// No description provided for @enterTitle.
  ///
  /// In pt, this message translates to:
  /// **'Informe um título'**
  String get enterTitle;

  /// No description provided for @enterIssuer.
  ///
  /// In pt, this message translates to:
  /// **'Informe um emissor'**
  String get enterIssuer;

  /// No description provided for @unableToLoadCertificate.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o certificado.'**
  String get unableToLoadCertificate;

  /// No description provided for @certificateDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Certificado excluído.'**
  String get certificateDeleted;

  /// No description provided for @fileAttached.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo anexado.'**
  String get fileAttached;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
