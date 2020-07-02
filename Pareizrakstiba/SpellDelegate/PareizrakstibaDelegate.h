/*
 PareizrakstibaDelegate.h
 
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

#import <Foundation/Foundation.h>
#import <Foundation/NSSpellServer.h>
#import "PareizrakstibaSpellChecker.h"

// As I had the idea of introducing some basic grammar checking, made this a forwarding class.
// Separate class for spelling, rather than putting code right here into instance methods.
// So grammar could be easily "modally" added later.

@class	PareizrakstibaSpellChecker; // Spelling checker class

// Since 10.6 this is informal protocol
@interface PareizrakstibaDelegate : NSObject <NSSpellServerDelegate> {
  PareizrakstibaSpellChecker*		mySC;
}
// construct/deconstruct
- (id) init;
- (void) dealloc;

////////////////////////////////////
// IMPLEMENTED

// Check Spelling in Strings
// macOS 10.0+
- (NSArray<NSString *> *) spellServer:(NSSpellServer *)sender
                suggestGuessesForWord:(NSString *)word
                           inLanguage:(NSString *)language;


// macOS 10.0+
- (NSRange)               spellServer:(NSSpellServer *)sender
           findMisspelledWordInString:(NSString *)stringToCheck
                             language:(NSString *)language
                            wordCount:(NSInteger *)wordCount
                            countOnly:(BOOL)countOnly;

// Managing the Spelling Dictionary
// macOS 10.0+
- (void)                  spellServer:(NSSpellServer *)sender
                        didForgetWord:(NSString *)word
                           inLanguage:(NSString *)language;

// macOS 10.0+
- (void)                  spellServer:(NSSpellServer *)sender
                         didLearnWord:(NSString *)word
                           inLanguage:(NSString *)language;

// macOS 10.3+
- (NSArray<NSString *> *) spellServer:(NSSpellServer *)sender
suggestCompletionsForPartialWordRange:(NSRange)range
                             inString:(NSString *)string
                             language:(NSString *)language;

// macOS 10.7+
- (void)                  spellServer:(NSSpellServer *)sender
                       recordResponse:(NSUInteger)response
                         toCorrection:(NSString *)correction
                              forWord:(NSString *)word
                             language:(NSString *)language;

////////////////////////////////////
// NOT IMPLEMENTED

// macOS 10.6+
//- (NSArray<NSTextCheckingResult *> *)spellServer:(NSSpellServer *)sender
//                                     checkString:(NSString *)stringToCheck
//                                          offset:(NSUInteger)offset
//                                           types:(NSTextCheckingTypes)checkingTypes
//                                         options:(NSDictionary<NSString *,id> *)options
//                                     orthography:(NSOrthography *)orthography
//                                       wordCount:(NSInteger *)wordCount;
//
// macOS 10.5+
//- (NSRange)spellServer:(NSSpellServer *)sender
//  checkGrammarInString:(NSString *)stringToCheck
//              language:(NSString *)language
//               details:(NSArray<NSDictionary<NSString *,id> *> * _Nullable *)details;

@end
