/// Safe TTS preprocessing. Strips presentation metadata without damaging
/// legitimate target-language words and phrases.
abstract final class SpeechTextNormalizer {
  static final RegExp _ipaOnly = RegExp(r'^/.+/$');
  static final RegExp _isolatedLatinLetter = RegExp(r'^[A-Za-z]$');
  static final RegExp _casePrefix = RegExp(
    r'^(?:uppercase|lowercase|upper[\s-]?case|lower[\s-]?case|capital(?:\s+letter)?|small(?:\s+letter)?)\s+',
    caseSensitive: false,
  );
  static final RegExp _caseSuffix = RegExp(
    r'\s*[\(\[]\s*(?:uppercase|lowercase|upper[\s-]?case|lower[\s-]?case|capital|small letter)\s*[\)\]]\s*$',
    caseSensitive: false,
  );
  static final RegExp _letterPrefix = RegExp(
    r'^(?:letter|glyph|character)\s+',
    caseSensitive: false,
  );
  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _unicodeApostrophe = RegExp(
    r'[\u2018\u2019\u02BC\u2032\u00B4]',
  );
  static final RegExp _hasLetterOrNumber = RegExp(
    r'\p{L}|\p{N}',
    unicode: true,
  );

  static const Set<String> _metadataLabels = <String>{
    'punctuation',
    'ipa',
    'romanization',
    'pronunciation',
    'uppercase',
    'lowercase',
    'glyph',
    'translation',
  };

  /// Educational spoken form for clips and tests.
  ///
  /// Returns null when [raw] is empty, IPA-only, punctuation-only, or a
  /// technical label. Terminal punctuation inside real phrases is kept.
  static String? clean(String? raw) {
    String? value = raw?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    value = value.replaceAll(_unicodeApostrophe, "'");
    value = value.replaceAll(_whitespace, ' ').trim();
    if (value.isEmpty || _ipaOnly.hasMatch(value)) {
      return null;
    }

    value = value.replaceFirst(_casePrefix, '').trim();
    value = value.replaceFirst(_caseSuffix, '').trim();
    if (_isolatedLatinLetter.hasMatch(value) == false &&
        _letterPrefix.hasMatch(value)) {
      final String stripped = value.replaceFirst(_letterPrefix, '').trim();
      if (_isolatedLatinLetter.hasMatch(stripped)) {
        value = stripped;
      }
    }
    if (value.isEmpty || _ipaOnly.hasMatch(value)) {
      return null;
    }

    final String label = value.toLowerCase();
    if (_metadataLabels.contains(label)) {
      return null;
    }
    if (!_hasLetterOrNumber.hasMatch(value)) {
      return null;
    }
    if (_isolatedLatinLetter.hasMatch(value)) {
      return value.toUpperCase();
    }
    return value;
  }

  /// Native-engine string. Isolated Latin letters stay a single letter.
  ///
  /// Apple voices announce "capital A" / "uppercase A" when the utterance is
  /// one uppercase letter. Lowercase keeps the letter name without case labels.
  /// Educational [speechText] remains "A"; this shaping is engine-only.
  static String utterance(String cleaned) {
    if (_isolatedLatinLetter.hasMatch(cleaned)) {
      return cleaned.toLowerCase();
    }
    return cleaned;
  }
}
