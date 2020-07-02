/*
 PareizrakstibaDelegate.mm
 
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

#import "PareizrakstibaDelegate.h"

@implementation PareizrakstibaDelegate

- (id)init
{
  self = [super init];
  if (self) {
    mySC = [[PareizrakstibaSpellChecker alloc] init];
  }
  return self;
}

- (void) dealloc
{
  [mySC release];
  [super dealloc];
}

// Search for a misspelled word in a given string
- (NSRange)               spellServer:(NSSpellServer *)sender
           findMisspelledWordInString:(NSString *)stringToCheck
                             language:(NSString *)language
                            wordCount:(NSInteger *)wordCount
                            countOnly:(BOOL)countOnly
{
  return [mySC spellServer:sender findMisspelledWordInString:stringToCheck language:language wordCount:wordCount countOnly:countOnly];
}

// Suggest guesses for the correct spelling of the given misspelled word
- (NSArray<NSString *> *) spellServer:(NSSpellServer *)sender
                suggestGuessesForWord:(NSString *)word
                           inLanguage:(NSString *)language
{
  return [mySC spellServer:sender suggestGuessesForWord:word inLanguage:language];
}

// Possible word completions, based on a partially completed string
- (NSArray *)spellServer:(NSSpellServer *)sender suggestCompletionsForPartialWordRange:(NSRange)range inString:(NSString *)string language:(NSString *)language
{
  return [mySC spellServer:sender suggestCompletionsForPartialWordRange:range inString:string language:language];
}


// User has removed the specified word from the user’s list of acceptable words in the specified language
- (void)                  spellServer:(NSSpellServer *)sender
                        didForgetWord:(NSString *)word
                           inLanguage:(NSString *)language
{
  return [mySC spellServer:sender didForgetWord:word inLanguage:language];
}

// User has added the specified word to the user’s list of acceptable words in the specified language.
- (void)                  spellServer:(NSSpellServer *)sender
                         didLearnWord:(NSString *)word
                           inLanguage:(NSString *)language
{
  return [mySC spellServer:sender didLearnWord:word inLanguage:language];
}

// Notifies the spell checker of the users’s response to a correction. (required)
- (void)                  spellServer:(NSSpellServer *)sender
                       recordResponse:(NSUInteger)response
                         toCorrection:(NSString *)correction
                              forWord:(NSString *)word
                             language:(NSString *)language;
{
  return [mySC spellServer:sender recordResponse:response toCorrection:correction forWord:word language:language];
}

@end
