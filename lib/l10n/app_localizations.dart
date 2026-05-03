import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
    Locale('uk')
  ];

  /// No description provided for @enterPhoneNumber.
  ///
  /// In uk, this message translates to:
  /// **'Введіть номер телефону'**
  String get enterPhoneNumber;

  /// No description provided for @phoneNumber.
  ///
  /// In uk, this message translates to:
  /// **'Номер телефону'**
  String get phoneNumber;

  /// No description provided for @getCode.
  ///
  /// In uk, this message translates to:
  /// **'Отримати код'**
  String get getCode;

  /// No description provided for @needHelpSupport.
  ///
  /// In uk, this message translates to:
  /// **'Потрібна допомога? Звертайтесь до\nнашої служби підтримки!'**
  String get needHelpSupport;

  /// No description provided for @enterCode.
  ///
  /// In uk, this message translates to:
  /// **'Введіть код'**
  String get enterCode;

  /// No description provided for @codeWasSent.
  ///
  /// In uk, this message translates to:
  /// **'Код було відправлено на ваш номер'**
  String get codeWasSent;

  /// No description provided for @continue_.
  ///
  /// In uk, this message translates to:
  /// **'Продовжити'**
  String get continue_;

  /// No description provided for @changeNumber.
  ///
  /// In uk, this message translates to:
  /// **'Змінити номер?'**
  String get changeNumber;

  /// No description provided for @save.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти'**
  String get save;

  /// No description provided for @profile.
  ///
  /// In uk, this message translates to:
  /// **'Профіль'**
  String get profile;

  /// No description provided for @ourSite.
  ///
  /// In uk, this message translates to:
  /// **'Наш сайт'**
  String get ourSite;

  /// No description provided for @support.
  ///
  /// In uk, this message translates to:
  /// **'Підтримка'**
  String get support;

  /// No description provided for @privacyPolicy.
  ///
  /// In uk, this message translates to:
  /// **'Політика конфіденційності'**
  String get privacyPolicy;

  /// No description provided for @deleteProfile.
  ///
  /// In uk, this message translates to:
  /// **'Видалити профіль'**
  String get deleteProfile;

  /// No description provided for @logOutOfProfile.
  ///
  /// In uk, this message translates to:
  /// **'Вийти з профілю'**
  String get logOutOfProfile;

  /// No description provided for @thanksForRegistration.
  ///
  /// In uk, this message translates to:
  /// **'Дякуємо за реєстрацію'**
  String get thanksForRegistration;

  /// No description provided for @application.
  ///
  /// In uk, this message translates to:
  /// **'Заявки'**
  String get application;

  /// No description provided for @supportService.
  ///
  /// In uk, this message translates to:
  /// **'Служба підтримки'**
  String get supportService;

  /// No description provided for @supportTeamTextEnd.
  ///
  /// In uk, this message translates to:
  /// **'Не соромтеся звертатися до нас з будь-якими запитаннями, коментарями або проблемами, які ви маєте. Наша команда завжди тут, щоб допомогти вам і забезпечити вас якісною підтримкою.\n\nДякуємо, що вибрали наш додаток!\n\nЗ повагою, \nКоманда служби підтримки.'**
  String get supportTeamTextEnd;

  /// No description provided for @supportTeamText.
  ///
  /// In uk, this message translates to:
  /// **'Дякуємо за звернення до нашої служби підтримки! Ми готові допомогти вам у вирішенні будь-яких питань чи проблем, з якими ви зіткнулися.\n\nЗверніться до нас через наші канали зв\'язку у телеграмі або вайбері.\nНаші експерти швидко відповідатимуть на ваші повідомлення та надаватимуть професійну допомогу у найкоротші терміни.\n'**
  String get supportTeamText;

  /// No description provided for @read.
  ///
  /// In uk, this message translates to:
  /// **'Прочитати'**
  String get read;

  /// No description provided for @applicationNo.
  ///
  /// In uk, this message translates to:
  /// **'Заявка №'**
  String get applicationNo;

  /// No description provided for @from.
  ///
  /// In uk, this message translates to:
  /// **'від:'**
  String get from;

  /// No description provided for @expired.
  ///
  /// In uk, this message translates to:
  /// **'Термін дії закінчився'**
  String get expired;

  /// No description provided for @copiedToClipboard.
  ///
  /// In uk, this message translates to:
  /// **'Дані про замовлення скопійовані в буфер обміну'**
  String get copiedToClipboard;

  /// No description provided for @region.
  ///
  /// In uk, this message translates to:
  /// **'Область'**
  String get region;

  /// No description provided for @name.
  ///
  /// In uk, this message translates to:
  /// **'Назва'**
  String get name;

  /// No description provided for @crop.
  ///
  /// In uk, this message translates to:
  /// **'Культура'**
  String get crop;

  /// No description provided for @harvestYear.
  ///
  /// In uk, this message translates to:
  /// **'Рік врожаю'**
  String get harvestYear;

  /// No description provided for @paymentNonCash.
  ///
  /// In uk, this message translates to:
  /// **'1ф. (б/г)'**
  String get paymentNonCash;

  /// No description provided for @paymentCash.
  ///
  /// In uk, this message translates to:
  /// **'2ф. (гот.)'**
  String get paymentCash;

  /// No description provided for @product.
  ///
  /// In uk, this message translates to:
  /// **'Продукт'**
  String get product;

  /// No description provided for @volume.
  ///
  /// In uk, this message translates to:
  /// **'Об\'єм'**
  String get volume;

  /// No description provided for @formOfPayment.
  ///
  /// In uk, this message translates to:
  /// **'Форма оплати'**
  String get formOfPayment;

  /// No description provided for @typeOfDelivery.
  ///
  /// In uk, this message translates to:
  /// **'Тип доставки'**
  String get typeOfDelivery;

  /// No description provided for @comment.
  ///
  /// In uk, this message translates to:
  /// **'Коментар'**
  String get comment;

  /// No description provided for @notInstalled.
  ///
  /// In uk, this message translates to:
  /// **'Не встановлено'**
  String get notInstalled;

  /// No description provided for @contacts.
  ///
  /// In uk, this message translates to:
  /// **'Контакти'**
  String get contacts;

  /// No description provided for @additionally.
  ///
  /// In uk, this message translates to:
  /// **'Додатково'**
  String get additionally;

  /// No description provided for @agreement.
  ///
  /// In uk, this message translates to:
  /// **'Угода'**
  String get agreement;

  /// No description provided for @applications.
  ///
  /// In uk, this message translates to:
  /// **'Заявки'**
  String get applications;

  /// No description provided for @applicationSent.
  ///
  /// In uk, this message translates to:
  /// **'Заявка відправлена. Скоро з вами зв’яжеться оператор.'**
  String get applicationSent;

  /// No description provided for @errorTariffMail.
  ///
  /// In uk, this message translates to:
  /// **'Ви не можете відкрити ці контакти. Перевірте кількість контактів в тарифі.'**
  String get errorTariffMail;

  /// No description provided for @errorAgreement.
  ///
  /// In uk, this message translates to:
  /// **'Трапилась помилка при угоді'**
  String get errorAgreement;

  /// No description provided for @waitAddress.
  ///
  /// In uk, this message translates to:
  /// **'Почекайте 5 хв, відкоригуємо адресу'**
  String get waitAddress;

  /// No description provided for @bids.
  ///
  /// In uk, this message translates to:
  /// **'Заявок'**
  String get bids;

  /// No description provided for @encounters.
  ///
  /// In uk, this message translates to:
  /// **'Контактів'**
  String get encounters;

  /// No description provided for @sms.
  ///
  /// In uk, this message translates to:
  /// **'SMS'**
  String get sms;

  /// No description provided for @tariffDuration.
  ///
  /// In uk, this message translates to:
  /// **'Термін дії тарифу'**
  String get tariffDuration;

  /// No description provided for @establish.
  ///
  /// In uk, this message translates to:
  /// **'Встановити'**
  String get establish;

  /// No description provided for @sendQuote.
  ///
  /// In uk, this message translates to:
  /// **'Відправити пропозицію'**
  String get sendQuote;

  /// No description provided for @applicationDemand.
  ///
  /// In uk, this message translates to:
  /// **'Попит на заявку'**
  String get applicationDemand;

  /// No description provided for @interestedInBuying.
  ///
  /// In uk, this message translates to:
  /// **'Зацікавлені купити'**
  String get interestedInBuying;

  /// No description provided for @viewedContact.
  ///
  /// In uk, this message translates to:
  /// **'Переглянули контакт'**
  String get viewedContact;

  /// No description provided for @suggestedPrices.
  ///
  /// In uk, this message translates to:
  /// **'Запропоновані ціни'**
  String get suggestedPrices;

  /// No description provided for @hide.
  ///
  /// In uk, this message translates to:
  /// **'Сховати'**
  String get hide;

  /// No description provided for @reviews.
  ///
  /// In uk, this message translates to:
  /// **'Відгуки'**
  String get reviews;

  /// No description provided for @addPrice.
  ///
  /// In uk, this message translates to:
  /// **'Додати ціну'**
  String get addPrice;

  /// No description provided for @sold.
  ///
  /// In uk, this message translates to:
  /// **'Продано'**
  String get sold;

  /// No description provided for @sell.
  ///
  /// In uk, this message translates to:
  /// **'Продав'**
  String get sell;

  /// No description provided for @price.
  ///
  /// In uk, this message translates to:
  /// **'Ціна'**
  String get price;

  /// No description provided for @currencyUsd.
  ///
  /// In uk, this message translates to:
  /// **'Долар'**
  String get currencyUsd;

  /// No description provided for @currencyEuro.
  ///
  /// In uk, this message translates to:
  /// **'Євро'**
  String get currencyEuro;

  /// No description provided for @currencyUah.
  ///
  /// In uk, this message translates to:
  /// **'Гривня'**
  String get currencyUah;

  /// No description provided for @fertilizerPriceOffers.
  ///
  /// In uk, this message translates to:
  /// **'Пропозиції цін на добрива'**
  String get fertilizerPriceOffers;

  /// No description provided for @uaht.
  ///
  /// In uk, this message translates to:
  /// **'грн/т.'**
  String get uaht;

  /// No description provided for @yourPrice.
  ///
  /// In uk, this message translates to:
  /// **'Ваша ціна'**
  String get yourPrice;

  /// No description provided for @fullName.
  ///
  /// In uk, this message translates to:
  /// **'ПІБ'**
  String get fullName;

  /// No description provided for @callResult.
  ///
  /// In uk, this message translates to:
  /// **'Результат дзвінка'**
  String get callResult;

  /// No description provided for @phone.
  ///
  /// In uk, this message translates to:
  /// **'Телефон'**
  String get phone;

  /// No description provided for @farmerContacts.
  ///
  /// In uk, this message translates to:
  /// **'Контакти фермера'**
  String get farmerContacts;

  /// No description provided for @district.
  ///
  /// In uk, this message translates to:
  /// **'Район'**
  String get district;

  /// No description provided for @town.
  ///
  /// In uk, this message translates to:
  /// **'Місто'**
  String get town;

  /// No description provided for @address.
  ///
  /// In uk, this message translates to:
  /// **'Адреса'**
  String get address;

  /// No description provided for @eMail.
  ///
  /// In uk, this message translates to:
  /// **'Е-mail'**
  String get eMail;

  /// No description provided for @errorTelegram.
  ///
  /// In uk, this message translates to:
  /// **'Ми не знайшли «Telegram» на Вашому телефоні. Будь ласка, встановіть додаток та спробуйте знову.'**
  String get errorTelegram;

  /// No description provided for @errorViber.
  ///
  /// In uk, this message translates to:
  /// **'Ми не знайшли «Viber» на Вашому телефоні. Будь ласка, встановіть додаток та спробуйте знову.'**
  String get errorViber;

  /// No description provided for @close.
  ///
  /// In uk, this message translates to:
  /// **'Закрити'**
  String get close;

  /// No description provided for @download.
  ///
  /// In uk, this message translates to:
  /// **'Завантажити'**
  String get download;

  /// No description provided for @setTicketSettings.
  ///
  /// In uk, this message translates to:
  /// **'Встановіть налаштування заявок у вашому кабінеті та завантажте прайс'**
  String get setTicketSettings;

  /// No description provided for @yourProposalSent.
  ///
  /// In uk, this message translates to:
  /// **'Вашу пропозицію буде відправлено '**
  String get yourProposalSent;

  /// No description provided for @clickOk.
  ///
  /// In uk, this message translates to:
  /// **' абонентам. Якщо впевнені в цій дії натисніть ОК.'**
  String get clickOk;

  /// No description provided for @areYouSure.
  ///
  /// In uk, this message translates to:
  /// **'Чи впевнені ви?'**
  String get areYouSure;

  /// No description provided for @wth.
  ///
  /// In uk, this message translates to:
  /// **'з'**
  String get wth;

  /// No description provided for @notEnoughMessages.
  ///
  /// In uk, this message translates to:
  /// **'Через те що кількість доступних Вам sms менша за кількість абонентів, Вашу пропозицію буде відправлено '**
  String get notEnoughMessages;

  /// No description provided for @offerSent.
  ///
  /// In uk, this message translates to:
  /// **'Ваша пропозиція була надіслана '**
  String get offerSent;

  /// No description provided for @abonen.
  ///
  /// In uk, this message translates to:
  /// **'-м абонентам.'**
  String get abonen;

  /// No description provided for @errorAddPrice.
  ///
  /// In uk, this message translates to:
  /// **'Трапилась помилка при додаванні ціни, перевірте ваші дані'**
  String get errorAddPrice;

  /// No description provided for @unspecified.
  ///
  /// In uk, this message translates to:
  /// **'Не вказано'**
  String get unspecified;

  /// No description provided for @thisCapabilityPaid.
  ///
  /// In uk, this message translates to:
  /// **'Ця можливість для платних користувачів. Деталі в телеграм t.me/uagro_oper'**
  String get thisCapabilityPaid;

  /// No description provided for @openedByTraders.
  ///
  /// In uk, this message translates to:
  /// **'Відкривали номер 4 трейдери:'**
  String get openedByTraders;

  /// No description provided for @needWriteReview.
  ///
  /// In uk, this message translates to:
  /// **'Потрібно написати відгук'**
  String get needWriteReview;

  /// No description provided for @feedbackAdded.
  ///
  /// In uk, this message translates to:
  /// **'Відгук додано'**
  String get feedbackAdded;

  /// No description provided for @errorAddingReview.
  ///
  /// In uk, this message translates to:
  /// **'Трапилась помилка при додаванні відгуку, перевірте ваші дані'**
  String get errorAddingReview;

  /// No description provided for @addReview.
  ///
  /// In uk, this message translates to:
  /// **'Додати відгук'**
  String get addReview;

  /// No description provided for @startWriting.
  ///
  /// In uk, this message translates to:
  /// **'Почніть писати...'**
  String get startWriting;

  /// No description provided for @add.
  ///
  /// In uk, this message translates to:
  /// **'Додати'**
  String get add;

  /// No description provided for @yourApplications.
  ///
  /// In uk, this message translates to:
  /// **'Ваші заявки'**
  String get yourApplications;

  /// No description provided for @search.
  ///
  /// In uk, this message translates to:
  /// **'Пошук'**
  String get search;

  /// No description provided for @updateComplete.
  ///
  /// In uk, this message translates to:
  /// **'Оновлення завершено'**
  String get updateComplete;

  /// No description provided for @dataWillBeDeleted.
  ///
  /// In uk, this message translates to:
  /// **'Всі ваші дані будуть видалені'**
  String get dataWillBeDeleted;

  /// No description provided for @profileCancelActionLog.
  ///
  /// In uk, this message translates to:
  /// **'Ваш профіль буде видалено через 90 днів, щоб скасувати дію, зайдіть в свій аккаунт'**
  String get profileCancelActionLog;

  /// No description provided for @yes.
  ///
  /// In uk, this message translates to:
  /// **'Так'**
  String get yes;

  /// No description provided for @cancel.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get cancel;

  /// No description provided for @dataDeviceDeleted.
  ///
  /// In uk, this message translates to:
  /// **'Всі ваші дані на даному девайсі буде видалено'**
  String get dataDeviceDeleted;

  /// No description provided for @tariffs.
  ///
  /// In uk, this message translates to:
  /// **'Тарифи'**
  String get tariffs;

  /// No description provided for @managersContactYou.
  ///
  /// In uk, this message translates to:
  /// **'Наші менеджери скоро зв’яжуться із вами.'**
  String get managersContactYou;

  /// No description provided for @numberNoRegistered.
  ///
  /// In uk, this message translates to:
  /// **'Цей номер не зареєстрований, перевірте дані та повторіть спробу'**
  String get numberNoRegistered;

  /// No description provided for @agreementKey.
  ///
  /// In uk, this message translates to:
  /// **'Угода'**
  String get agreementKey;

  /// No description provided for @noAnswerKey.
  ///
  /// In uk, this message translates to:
  /// **'Не підняв слухавку'**
  String get noAnswerKey;

  /// No description provided for @noConnectionKey.
  ///
  /// In uk, this message translates to:
  /// **'Не має зв’язку'**
  String get noConnectionKey;

  /// No description provided for @wrongPriceKey.
  ///
  /// In uk, this message translates to:
  /// **'Ціна не підійшла'**
  String get wrongPriceKey;

  /// No description provided for @notActualKey.
  ///
  /// In uk, this message translates to:
  /// **'Заявка не актуальна'**
  String get notActualKey;

  /// No description provided for @paymentFormF1.
  ///
  /// In uk, this message translates to:
  /// **'1ф. (по перерахунку)'**
  String get paymentFormF1;

  /// No description provided for @paymentFormF2.
  ///
  /// In uk, this message translates to:
  /// **'2ф. (готівка)'**
  String get paymentFormF2;

  /// No description provided for @scanQrCode.
  ///
  /// In uk, this message translates to:
  /// **'Cканувати QR-код'**
  String get scanQrCode;

  /// No description provided for @failedScan.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося сканувати QR-код'**
  String get failedScan;

  /// No description provided for @loginSuccess.
  ///
  /// In uk, this message translates to:
  /// **'Вхід yспішний'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося увійти'**
  String get loginFailed;

  /// No description provided for @qrNotValidForLogin.
  ///
  /// In uk, this message translates to:
  /// **'QR код не дійсний для входу.'**
  String get qrNotValidForLogin;

  /// No description provided for @error.
  ///
  /// In uk, this message translates to:
  /// **'Помилка'**
  String get error;

  /// No description provided for @buyPackage.
  ///
  /// In uk, this message translates to:
  /// **'Придбати пакет'**
  String get buyPackage;

  /// No description provided for @mapForPaid.
  ///
  /// In uk, this message translates to:
  /// **'Сервіс доступний для платних тарифів'**
  String get mapForPaid;

  /// No description provided for @allApplications.
  ///
  /// In uk, this message translates to:
  /// **'Всі заявки'**
  String get allApplications;

  /// No description provided for @nomber.
  ///
  /// In uk, this message translates to:
  /// **'Номер'**
  String get nomber;

  /// No description provided for @requestingAddress.
  ///
  /// In uk, this message translates to:
  /// **'запросив адресу фермера'**
  String get requestingAddress;

  /// No description provided for @correctAddress.
  ///
  /// In uk, this message translates to:
  /// **'. Відкоригуйте адресу'**
  String get correctAddress;

  /// No description provided for @somethingWentWrong.
  ///
  /// In uk, this message translates to:
  /// **'Щось пішло не так (. Спробуйте пізніше.'**
  String get somethingWentWrong;

  /// No description provided for @myTariff.
  ///
  /// In uk, this message translates to:
  /// **'Мій тариф'**
  String get myTariff;

  /// No description provided for @allPaymentForm.
  ///
  /// In uk, this message translates to:
  /// **'1ф/2ф'**
  String get allPaymentForm;

  /// No description provided for @youBalance.
  ///
  /// In uk, this message translates to:
  /// **'Ваш баланс'**
  String get youBalance;

  /// No description provided for @topUp.
  ///
  /// In uk, this message translates to:
  /// **'Поповнити'**
  String get topUp;

  /// No description provided for @errorPaymant.
  ///
  /// In uk, this message translates to:
  /// **'Мінімальна сума поповнення 10 грн'**
  String get errorPaymant;

  /// No description provided for @orInputSum.
  ///
  /// In uk, this message translates to:
  /// **'Або введіть суму (грн):'**
  String get orInputSum;

  /// No description provided for @onPay.
  ///
  /// In uk, this message translates to:
  /// **'Оплатити'**
  String get onPay;

  /// No description provided for @sum.
  ///
  /// In uk, this message translates to:
  /// **'Сума'**
  String get sum;

  /// No description provided for @topUpBalance.
  ///
  /// In uk, this message translates to:
  /// **'Поповнити рахунок'**
  String get topUpBalance;
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
      <String>['en', 'kk', 'ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
