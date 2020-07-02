/*
 PareizrakstibaSpellChecker.mm
 
 Pareizrakstība - Latviešu valodas pareizrakstības pārbaude macOS operētājsistēmai
 Pareizrakstiba - Latvian spellcheck for macOS operating system
 Copyright (C) 2008-2015 Reinis Adovičs a.k.a. kroko

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "PareizrakstibaSpellChecker.h"

struct EncodingMapping {
  const char* name;
  CFStringEncoding encoding;
};

@implementation PareizrakstibaSpellChecker

- (id)init
{
  self = [super init] ;
  if (self != nil) {
    myHS = new Hunspell ([[ [ NSBundle bundleForClass:[self class] ] pathForResource:@"lv_LV" ofType:@"aff" inDirectory:@"Dictionaries/lv_LV-1.4.0"] UTF8String],
                         [[ [ NSBundle bundleForClass:[self class] ] pathForResource:@"lv_LV" ofType:@"dic" inDirectory:@"Dictionaries/lv_LV-1.4.0"] UTF8String]);


    // Charset for words (alphanumerical and .)
    //
    // This leaves out misspellings like "garumz;ime", which is common for those who type diacritical marks w/ '(apostrophe) and miss the key sometimes. As now - the misspelled word is divided in two.
    // We "could" allow all characters except for whitespace (and \n,\t,\v,\r,\f). Then at word scanning we would look at data between whitespaces. If data ends with n count of nonalphanumerical characters, substract them, then spell word.
    // For exaple, a word that ends sentence and has ellipsis afterwards " garumz;ime... "
    // After substarcting last nonalphanumerical characters, we get "garumz;ime", spell that.
    // Although haven't tested, it seems expensive for me.

#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
    // for 10.4 // There was a bug I discovered back then, don't remeber what it was
    wordCharSet = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
#else
    wordCharSet = [NSMutableCharacterSet alphanumericCharacterSet];
#endif
    [wordCharSet addCharactersInString:@"."];
  }
  return self;
}

- (void) dealloc
{
  delete myHS;
  myHS = NULL;
  [super dealloc];
}

// Suggest guesses for the correct spelling of the given misspelled word
- (NSArray<NSString *> *) spellServer:(NSSpellServer *)sender
                suggestGuessesForWord:(NSString *)word
                           inLanguage:(NSString *)language
{
  NSMutableArray *guessesForWord = [NSMutableArray array]; // create a dynamic array
  char ** hsSuggestList = 0;

#if DEBUG
  NSLog(@"Trying to get suggestions for string: %s", [word UTF8String]);
#endif

#if DICTENCODE
  NSInteger hsSuggestListCount = myHS -> suggest (&hsSuggestList, [word cStringUsingEncoding:(NSStringEncoding)[self hunspellDictEncodingToNSEncoding:myHS->get_dic_encoding()]]); // returns number of suggestions and write them into hsSuggestList array
#else
  NSInteger hsSuggestListCount = myHS -> suggest (&hsSuggestList, [word UTF8String]); // returns number of suggestions and write them into hsSuggestList array
#endif

  for (NSInteger i = 0; i < hsSuggestListCount; ++i) { // for all suggestions
#if DICTENCODE
    [guessesForWord addObject:[NSString stringWithCString: hsSuggestList[i] encoding:(NSStringEncoding)[self hunspellDictEncodingToNSEncoding:myHS->get_dic_encoding()]]];
#else
    [guessesForWord addObject:[NSString stringWithUTF8String:hsSuggestList[i]]]; // add suggestion to suggestions array from sugList array
#endif
  }
  if(hsSuggestList) myHS->free_list(&hsSuggestList, hsSuggestListCount); // clean suggest list

  return guessesForWord; // return our array
}

// Search for a misspelled word in a given string
- (NSRange)               spellServer:(NSSpellServer *)sender
           findMisspelledWordInString:(NSString *)stringToCheck
                             language:(NSString *)language
                            wordCount:(NSInteger *)wordCount
                            countOnly:(BOOL)countOnly
{

  NSScanner *stringToCheckScanner = [NSScanner scannerWithString:stringToCheck]; // create NSScanner object to scan stringToCheck

  // If the method only counts the words in the string object and does not spell checking
  if (countOnly)
  {
    if (*wordCount) *wordCount = [[stringToCheck componentsSeparatedByString:@" "] count]; // get number of words in stringToCheck
  }
  else { // if countOnly==NO, then we check spelling
    NSInteger wordCountUntill = 0;
    while (![stringToCheckScanner isAtEnd]) // while scanner is not at end
    {
      [stringToCheckScanner scanUpToCharactersFromSet:wordCharSet intoString:nil]; // scans the string until a character from wordCharSet character set is encountered, send accumulating characters into nil
      if (![stringToCheckScanner isAtEnd]) // if scanner at this point is not at end (or characters from the set to be skipped remaining != TRUE), we have found a word
      {
        NSString *wordToCheck; //create string object for word
        [stringToCheckScanner scanCharactersFromSet:wordCharSet intoString:&wordToCheck];	// scan the stringToCheck as long as characters from wordCharSet are encountered
        // and accumulate characters into wordToCheck
        // if word is in dictionary or or word is in user dictionary

#if DICTENCODE
        if ((myHS -> spell ([wordToCheck cStringUsingEncoding:(NSStringEncoding)[self hunspellDictEncodingToNSEncoding:myHS->get_dic_encoding()]])) || ([sender isWordInUserDictionaries:wordToCheck caseSensitive:YES]))
#else
          if ((myHS -> spell ([wordToCheck UTF8String])) || ([sender isWordInUserDictionaries:wordToCheck caseSensitive:YES]))
#endif
          {
            ++wordCountUntill;
            continue;
          }
          else
          {
            if (*wordCount) *wordCount = wordCountUntill; // pass number of words till misspelled word
            if ([wordToCheck length]>0 && ([wordToCheck characterAtIndex:[wordToCheck length]-1] == '.')) {
              return NSMakeRange ([stringToCheckScanner scanLocation] - [wordToCheck length], [wordToCheck length]-1);
            }
            else
            {
              return NSMakeRange ([stringToCheckScanner scanLocation] - [wordToCheck length], [wordToCheck length]);
            }
          }
      }
    }
    if (*wordCount) *wordCount = wordCountUntill; // pass number of words till misspelled word
  }
#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
  return NSMakeRange (NSNotFound, 0); // for 10.4 // if our scanner failed to return range, then simply return {0x7fffffff,0} range
#else
  // In OS 10.5 and up NSNotFound is defined as NSIntegerMax (prior it was 0x7fffffff). So basically need for this arises whether user's running 32 or 64 bit environment.
  // Thus- compiling Pareizrakstība as 64-bit, will give NSNotFound==LONG_MAX, however apps utilising OSX spell server CAN expect
  // INT_MAX. Therefore a warning is rised
  // Pareizrakstiba[xxxx] Warning - conversion from 64 bit to 32 bit integral value requested within NSPortCoder, but the 64 bit value 9223372036854775807 cannot be represented by a 32 bit value
  // So just return INT_MAX in 64 bit case (or maybe 0x7fffffff ? )
#if __LP64__ || NS_BUILD_32_LIKE_64
  return NSMakeRange (INT_MAX, 0);
#else
  return NSMakeRange (NSNotFound, 0);
#endif
#endif  // MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
}

// User has removed the specified word from the user’s list of acceptable words in the specified language
- (void)                  spellServer:(NSSpellServer *)sender
                        didForgetWord:(NSString *)word
                           inLanguage:(NSString *)language
{

  //   When user chooses to "Unlearn Spelling" for a word OSX does it, using the same user dictionary, located at ~/Library/Spelling/<languageid>
  //   The way it's done, is adding the word one more time to the dic.
  //   It works and word isn't spelled any more.
  //
  //   However, as user dictionary at ~/Library/Spelling/<languageid> will be used to contribute/submit new words to HunSpell aff&dic developer,
  //   there's a problem to solve. In the situation described above user would contribute word list with an incorrect word repeated twice, instead of not sending it at all.
  //   We have to change this OSX behavior, and on "Unlearn Spelling" actually delete the word from user dic.
  //
  //   BUT - this methods description is incorrect - it's not "didForgetWord", burt "WILL!ForgetWord".
  //   "Notifies the delegate that the sender has removed the specified word from the user’s list of acceptable words in the specified language."
  //   actually is
  //   "Notifies the delegate that the sender IS GOING TO REMOVE (add second copy) the specified word from the user’s list of acceptable words in the specified language."
  //   Thus I cannot delete a word, that hasn't been written to user's dic yet.
  //
  //   That means that on contribute process the code will have to check for any duplicate words (which accordingly are unlearned (incorrect) words).
  //
  //   Note: I see no need to use Hunspell method of removing word from the run-time dictionary.
  //   myHS->remove([word UTF8String]);

#if DEBUG
  NSLog(@"User unlearned word \"%@\" in language %@.\n", word, language);
#endif
}

// User has added the specified word to the user’s list of acceptable words in the specified language.
- (void)                  spellServer:(NSSpellServer *)sender
                         didLearnWord:(NSString *)word
                           inLanguage:(NSString *)language
{

  // When user chooses to "Learn Spelling" for a word OSX automatically adds it to user dictionary, located at ~/Library/Spelling/<langid>
  // It works and word isn't spelled any more.
  //
  // When user chooses to "Ignore Spelling" no word is added to user dictionary, the word is kept in "memory" and
  // only while document containing the word is loaded.
  //
  // I see no need to use Hunspell method of adding word to the run-time dictionary, as it is managed in OS level and won't be passed here anyways
  // myHS->add([word UTF8String]);

#if DEBUG
  NSLog(@"User learned word \"%@\" in language %@.\n", word, language);
#endif
}

// Possible word completions, based on a partially completed string
- (NSArray<NSString *> *) spellServer:(NSSpellServer *)sender
suggestCompletionsForPartialWordRange:(NSRange)range
                             inString:(NSString *)string
                             language:(NSString *)language
{

  // I will use array that's returned by suggestGuessesForWord. However it is a suggestion list for the right spelling of the current partialy completed world,
  // not a suggstion for competion! There's a difference!
  // return [self spellServer:sender suggestGuessesForWord:string inLanguage:language]; // reuse suggestGuessesForWord which returns an array of words

  // Get the partial range
  NSString *rangeString = [NSString stringWithString:[string substringWithRange:range]]; // keep an autoreleased copy around

  // Therefore we will make string comparisons, to remove those words from suggestGuessesForWord returned array, which don't appear to be completions
  NSMutableArray *completionsList = [NSMutableArray arrayWithArray:[self spellServer:sender suggestGuessesForWord:rangeString inLanguage:language]];

  // make or completionsList to hold all suggestGuessesForWord array values
  for(NSUInteger i=0;i<[completionsList count]; ) { //check all completionsList array
    // if a word in completionsList at position i does not start with the same characters (and also that the characters are ordered the same)
    // as the current range for inString, then this isn't going to be a completion, thus remove it from the array

    // accordingly to apple docs this should be faster than hasPrefix (quote: "can speed some operations dramatically"), but wee need extra range check. whatever.
    // if (![[completionsList objectAtIndex:i] hasPrefix:rangeString])
    if (
        ( [[completionsList objectAtIndex:i] length] < [rangeString length] ) ||
        ( [[completionsList objectAtIndex:i] compare:rangeString options:(NSLiteralSearch) range:NSMakeRange(0,[rangeString length])] != NSOrderedSame )
        )
    {
      [completionsList removeObjectAtIndex:i];
    }
    else {
      ++i;
    }
  }

  return completionsList;
}

// Notifies the spell checker of the users’s response to a correction. (required)
- (void)                  spellServer:(NSSpellServer *)sender
                       recordResponse:(NSUInteger)response
                         toCorrection:(NSString *)correction
                              forWord:(NSString *)word
                             language:(NSString *)language
{

  // When the user accepts, rejects, or edits an autocorrection, the view notifies the NSSpellChecker class of what happened
  // in the client application, and NSSpellChecker then invokes this method, so that it can record that and modify future autocorrection
  // behavior based on what it has learned from the user's actions.
  //
  // This is introduced in 10.7 and is required method.
  // /dev/null this one
}

- (NSStringEncoding) hunspellDictEncodingToNSEncoding:(const char*)encoding
{
  EncodingMapping mappings[] = {
    {"UTF-8",kCFStringEncodingUTF8}, // Arabic, Az, Turkish
    {"ISO8859-1",kCFStringEncodingISOLatin1}, // Catalan, Danish, German, English, Spanish, Basque, gl, Italian, la, Dutch, Portuguese, Swedish
    {"ISO8859-2",kCFStringEncodingISOLatin2}, // Czech, Croatian, Polish
    {"ISO8859-3",kCFStringEncodingISOLatin3},
    {"ISO8859-4",kCFStringEncodingISOLatin4},
    {"ISO8859-5",kCFStringEncodingISOLatinCyrillic},
    {"ISO8859-6",kCFStringEncodingISOLatinArabic},
    {"ISO8859-7",kCFStringEncodingISOLatinGreek},
    {"ISO8859-8",kCFStringEncodingISOLatinHebrew},
    {"ISO8859-9",kCFStringEncodingISOLatin5},
    {"ISO8859-10",kCFStringEncodingISOLatin6},
    {"ISO8859-11",kCFStringEncodingISOLatinThai},
    {"ISO8859-13",kCFStringEncodingISOLatin7}, // Greek, Latvian
    {"ISO8859-14",kCFStringEncodingISOLatin8},
    {"ISO8859-15",kCFStringEncodingISOLatin9}, // French
    {"ISO8859-16",kCFStringEncodingISOLatin10},
    {"RFC2319",kCFStringEncodingKOI8_U},
    {"KOI8-U",kCFStringEncodingKOI8_U}, // Ukrainian
    {"KOI8-R",kCFStringEncodingKOI8_R},						// Russian
    {"microsoft-cp1251",kCFStringEncodingWindowsCyrillic},
    {"ISCII-DEVANAGARI",kCFStringEncodingMacDevanagari},
    {"microsoft-cp437",kCFStringEncodingDOSLatinUS},
    {"microsoft-cp437",kCFStringEncodingDOSGreek},
    {"microsoft-cp775",kCFStringEncodingDOSBalticRim},
    {"microsoft-cp850",kCFStringEncodingDOSLatin1},
    {"microsoft-cp851",kCFStringEncodingDOSGreek1},
    {"microsoft-cp852",kCFStringEncodingDOSLatin2},
    {"microsoft-cp855",kCFStringEncodingDOSCyrillic},
    {"microsoft-cp857",kCFStringEncodingDOSTurkish},
    {"microsoft-cp860",kCFStringEncodingDOSPortuguese},
    {"microsoft-cp861",kCFStringEncodingDOSIcelandic},
    {"microsoft-cp862",kCFStringEncodingDOSHebrew},
    {"microsoft-cp863",kCFStringEncodingDOSCanadianFrench},
    {"microsoft-cp864",kCFStringEncodingDOSArabic},
    {"microsoft-cp865",kCFStringEncodingDOSNordic},
    {"microsoft-cp866",kCFStringEncodingDOSRussian},
    {"microsoft-cp869",kCFStringEncodingDOSGreek2},
    {"microsoft-cp874",kCFStringEncodingDOSThai},
    {"microsoft-cp932",kCFStringEncodingDOSJapanese},
    {"microsoft-cp936",kCFStringEncodingDOSChineseSimplif},
    {"microsoft-cp949",kCFStringEncodingDOSKorean},
    {"microsoft-cp950",kCFStringEncodingDOSChineseTrad},
    {"microsoft-cp1250",kCFStringEncodingWindowsLatin2},
    {"microsoft-cp1251",kCFStringEncodingWindowsCyrillic},
    {"microsoft-cp1253",kCFStringEncodingWindowsGreek},
    {"microsoft-cp1254",kCFStringEncodingWindowsLatin5},
    {"microsoft-cp1255",kCFStringEncodingWindowsHebrew},
    {"microsoft-cp1256",kCFStringEncodingWindowsArabic},
    {"microsoft-cp1257",kCFStringEncodingWindowsBalticRim},
    {"microsoft-cp1258",kCFStringEncodingWindowsVietnamese},
    {"microsoft-cp1361",kCFStringEncodingWindowsKoreanJohab},
  };

  for (unsigned int i = 0; i < sizeof(mappings)/sizeof(EncodingMapping); ++i) {
    if (strcmp(encoding,mappings[i].name) == 0)
      // unsigned long
      return CFStringConvertEncodingToNSStringEncoding(mappings[i].encoding);
  }

  CFStringEncoding result = CFStringConvertIANACharSetNameToEncoding(CFStringRef([NSString stringWithCString:encoding encoding:NSUTF8StringEncoding]));
  if (result != kCFStringEncodingInvalidId) {
    return CFStringConvertEncodingToNSStringEncoding(result);
  }

  const NSStringEncoding* encodings = [NSString availableStringEncodings];
  while (*encodings){
    NSString* encodingName = [NSString localizedNameOfStringEncoding:*encodings];
    if (strstr ([encodingName UTF8String], encoding) != 0) {
      return *encodings;
    }
    ++encodings;
  }

  //    fprintf(stderr, "Pareizrakstiba error: unrecognized encoding: %s. Setting to ASCII.\n",encoding);
  NSLog(@"WARPDEBUG Pareizrakstiba Pareizrakstiba error: unrecognized encoding: Setting to ASCII.\n");
  return NSASCIIStringEncoding;
}

@end
