/*
 * PareizrakstibaSpellChecker.mm
 *
 * Pareizrakstība
 * Latvian spellcheck for macOS.
 *
 * Copyright (C) 2008-2026 kroko (Reinis Adovičs)
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "PareizrakstibaSpellChecker.h"

@interface PareizrakstibaSpellChecker ()
- (BOOL)isWordSpelledCorrectly:(NSString *)word;
- (NSString *)wordByTrimmingTrailingDots:(NSString *)word;
@end

@implementation PareizrakstibaSpellChecker

- (id)init
{
  self = [super init];
  if (self != nil) {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *affPath = [bundle pathForResource:@"lv_LV" ofType:@"aff" inDirectory:@"lv_LV"];
    NSString *dicPath = [bundle pathForResource:@"lv_LV" ofType:@"dic" inDirectory:@"lv_LV"];

    if (affPath == nil || dicPath == nil) {
      NSLog(@"Pareizrakstiba - missing dictionary resource in bundle:%@%@\n",
            (affPath == nil) ? @" lv_LV.aff" : @"", (dicPath == nil) ? @" lv_LV.dic" : @"");
      [self release];
      self = nil;
    }
    else {
      myHS = new Hunspell([affPath UTF8String], [dicPath UTF8String]);

      // Word charset: alphanumerics and '.'.
      // See engineering/spelling/decisions/0001-word-charset.md

      wordCharSet = [[NSMutableCharacterSet alphanumericCharacterSet] retain];
      [wordCharSet addCharactersInString:@"."];

      // Memoization of hunspell spell() verdicts
      spellCache = [[NSCache alloc] init];
      // soft bound
      [spellCache setCountLimit:4096];
    }
  }
  return self;
}

- (void)dealloc
{
  delete myHS;
  myHS = NULL;
  [wordCharSet release];
  wordCharSet = NULL;
  [spellCache release];
  spellCache = NULL;
  [super dealloc];
}

// Hunspell spell() verdict for a word.
// Spell-as-you-type re-checks every word of the string on each keystroke
// hunspell has no result cache, thus repeated verdicts are served from here
- (BOOL)isWordSpelledCorrectly:(NSString *)word
{
  // The dictionary stores precomposed (NFC) characters only, so a
  // decomposed (NFD) form of the same word would fail
  // Normalise first so both forms share the verdict
  NSString *normalizedWord = [word precomposedStringWithCanonicalMapping];

  NSNumber *cachedVerdict = [spellCache objectForKey:normalizedWord];
  if (cachedVerdict != nil) {
    return [cachedVerdict boolValue];
  }

  const char *utf8Word = [normalizedWord UTF8String];
  if (utf8Word == NULL) {
    return NO;
  }

  BOOL spelledCorrectly = myHS->spell(std::string(utf8Word));
  [spellCache setObject:[NSNumber numberWithBool:spelledCorrectly] forKey:normalizedWord];
  return spelledCorrectly;
}

// Copy of the token without its trailing dots
// Mirroring what hunspell cleanword2() does, i.e., it strips before looking in dic
- (NSString *)wordByTrimmingTrailingDots:(NSString *)word
{
  NSUInteger length = [word length];
  while (length > 0 && [word characterAtIndex:length - 1] == '.') {
    --length;
  }
  return length == [word length] ? word : [word substringToIndex:length];
}

// Suggest guesses for the correct spelling of the given misspelled word
- (NSArray<NSString *> *)spellServer:(NSSpellServer *)sender
               suggestGuessesForWord:(NSString *)word
                          inLanguage:(NSString *)language
{
  NSMutableArray *guessesForWord = [NSMutableArray array];

  // Dictionary stores precomposed (NFC), normalise first
  NSString *normalizedWord = [word precomposedStringWithCanonicalMapping];

#if DEBUG
  NSLog(@"Trying to get suggestions for string: %s", [normalizedWord UTF8String]);
#endif

  const char *utf8Word = [normalizedWord UTF8String];
  if (utf8Word == NULL) {
    return guessesForWord;
  }

  std::vector<std::string> hsSuggestList = myHS->suggest(utf8Word);

  for (const std::string &suggestion : hsSuggestList) {
    NSString *suggestionString = [NSString stringWithUTF8String:suggestion.c_str()];
    if (suggestionString != nil) {
      [guessesForWord addObject:suggestionString];
    }
  }

  return guessesForWord;
}

// Search for a misspelled word in a given string
- (NSRange)spellServer:(NSSpellServer *)sender
    findMisspelledWordInString:(NSString *)stringToCheck
                      language:(NSString *)language
                     wordCount:(NSInteger *)wordCount
                     countOnly:(BOOL)countOnly
{

  NSScanner *stringToCheckScanner = [NSScanner scannerWithString:stringToCheck];

  // If the method only counts the words in the string object
  if (countOnly) {
    NSInteger wordCountTotal = 0;
    while (![stringToCheckScanner isAtEnd]) {
      [stringToCheckScanner scanUpToCharactersFromSet:wordCharSet intoString:nil];
      if (![stringToCheckScanner isAtEnd]) {
        ++wordCountTotal;
        [stringToCheckScanner scanCharactersFromSet:wordCharSet intoString:nil];
      }
    }
    if (wordCount) *wordCount = wordCountTotal;
  }
  else {
    NSInteger wordCountUntill = 0;
    while (![stringToCheckScanner isAtEnd]) {
      // scans the string until a char from wordCharSet encountered
      // send accumulating characters into nil
      [stringToCheckScanner scanUpToCharactersFromSet:wordCharSet intoString:nil];
      // if scanner at this point is not at end
      // (or characters from the set to be skipped remaining != TRUE)
      // we have found a word
      if (![stringToCheckScanner isAtEnd]) {
        NSString *wordToCheck;
        // scan the stringToCheck as long as chars from wordCharSet encountered
        // and accumulate characters into wordToCheck
        [stringToCheckScanner scanCharactersFromSet:wordCharSet intoString:&wordToCheck];

        // A learned word is stored without the trailing dot
        // Hunspell keeps the original token, its single-dot retry is
        // what makes abbreviations such as "u.c.", "u.tml." pass
        NSString *userWord = [self wordByTrimmingTrailingDots:wordToCheck];
        if (([sender isWordInUserDictionaries:userWord caseSensitive:YES]) ||
            [self isWordSpelledCorrectly:wordToCheck]) {
          ++wordCountUntill;
          continue;
        }
        else {
          if (wordCount) *wordCount = wordCountUntill;

          // Check for .
          // See engineering/spelling/decisions/0001-word-charset.md
          if ([wordToCheck length] > 0 &&
              ([wordToCheck characterAtIndex:[wordToCheck length] - 1] == '.')) {
            return NSMakeRange([stringToCheckScanner scanLocation] - [wordToCheck length],
                               [wordToCheck length] - 1);
          }
          else {
            return NSMakeRange([stringToCheckScanner scanLocation] - [wordToCheck length],
                               [wordToCheck length]);
          }
        }
      }
    }
    // pass number of words till misspelled word
    if (wordCount) *wordCount = wordCountUntill;
  }
  // No misspelling found: INT_MAX, not NSNotFound
  // See engineering/spelling/decisions/0006-no-misspelling-found.md
  return NSMakeRange(INT_MAX, 0);
}

// User has removed the specified word from the user’s list of acceptable words
// in the specified language
- (void)spellServer:(NSSpellServer *)sender
      didForgetWord:(NSString *)word
         inLanguage:(NSString *)language
{

  // Not involving run-time hunspell dictionary
  // "Unlearn Spelling" adds the word to the user dic (OS) a second time
  // See engineering/spelling/decisions/0002-unlearn-spelling.md

#if DEBUG
  NSLog(@"User unlearned word \"%@\" in language %@.\n", word, language);
#endif
}

// User has added the specified word to the user’s list of acceptable words
// in the specified language
- (void)spellServer:(NSSpellServer *)sender
       didLearnWord:(NSString *)word
         inLanguage:(NSString *)language
{

  // Not involving run-time hunspell dictionary
  // See engineering/spelling/decisions/0003-learn-spelling.md

#if DEBUG
  NSLog(@"User learned word \"%@\" in language %@.\n", word, language);
#endif
}

// Possible word completions, based on a partially completed string
- (NSArray<NSString *> *)spellServer:(NSSpellServer *)sender
    suggestCompletionsForPartialWordRange:(NSRange)range
                                 inString:(NSString *)string
                                 language:(NSString *)language
{

  // I will use array that's returned by suggestGuessesForWord
  // See engineering/spelling/decisions/0004-suggest-completions.md

  // Suggestions come back in NFC
  NSString *rangeString = [[string substringWithRange:range] precomposedStringWithCanonicalMapping];

  NSMutableArray *completionsList =
      [NSMutableArray arrayWithArray:[self spellServer:sender suggestGuessesForWord:rangeString
                                                    inLanguage:language]];

  for (NSUInteger i = 0; i < [completionsList count];) {
    if (([[completionsList objectAtIndex:i] length] < [rangeString length]) ||
        ([[completionsList objectAtIndex:i] compare:rangeString options:(NSLiteralSearch)range
                                                   :NSMakeRange(0, [rangeString length])] !=
         NSOrderedSame)) {
      [completionsList removeObjectAtIndex:i];
    }
    else {
      ++i;
    }
  }

  return completionsList;
}

// Notifies the spell checker of the users’s response to a correction
// Required
- (void)spellServer:(NSSpellServer *)sender
     recordResponse:(NSUInteger)response
       toCorrection:(NSString *)correction
            forWord:(NSString *)word
           language:(NSString *)language
{

  // Required by API, but sent to /dev/null
  // See engineering/spelling/decisions/0005-record-response.md
}

@end
