import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/src/widgets_localizations.dart';

class _OmWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _OmWidgetsLocalizationsDelegate();

  @override
  bool isSupported(final Locale locale) => locale.languageCode == 'om';

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    return SynchronousFuture<WidgetsLocalizations>(const OmWidgetsLocalization());
  }

  @override
  bool shouldReload(_OmWidgetsLocalizationsDelegate old) => false;
}

class OmWidgetsLocalization extends GlobalWidgetsLocalizations {
  /// Create an instance of the translation bundle for Afar.
  ///
  /// For details on the meaning of the arguments, see [GlobalWidgetsLocalizations].
  const OmWidgetsLocalization() : super(TextDirection.ltr);

  @override
  String get reorderItemDown => 'ወደ ታች ውሰድ';

  @override
  String get reorderItemLeft => 'ወደ ግራ ውሰድ';

  @override
  String get reorderItemRight => 'ወደ ቀኝ ውሰድ';

  @override
  String get reorderItemToEnd => 'ወደ መጨረሻ ውሰድ';

  @override
  String get reorderItemToStart => 'ወደ መጀመሪያ ውሰድ';

  @override
  String get reorderItemUp => 'ወደ ላይ ውሰድ';

  static const LocalizationsDelegate<WidgetsLocalizations> delegate =
      _OmWidgetsLocalizationsDelegate();
      
        @override
        // TODO: implement copyButtonLabel
        String get copyButtonLabel => throw UnimplementedError();
      
        @override
        // TODO: implement cutButtonLabel
        String get cutButtonLabel => throw UnimplementedError();
      
        @override
        // TODO: implement lookUpButtonLabel
        String get lookUpButtonLabel => throw UnimplementedError();
      
        @override
        // TODO: implement pasteButtonLabel
        String get pasteButtonLabel => throw UnimplementedError();
      
        @override
        // TODO: implement searchWebButtonLabel
        String get searchWebButtonLabel => throw UnimplementedError();
      
        @override
        // TODO: implement selectAllButtonLabel
        String get selectAllButtonLabel => throw UnimplementedError();
      
        @override
        // TODO: implement shareButtonLabel
        String get shareButtonLabel => throw UnimplementedError();
}
