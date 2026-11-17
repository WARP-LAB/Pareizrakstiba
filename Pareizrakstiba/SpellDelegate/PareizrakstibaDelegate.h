/*
 * PareizrakstibaDelegate.h
 *
 * Pareizrakstība
 * Latvian spellcheck for macOS.
 *
 * Copyright (C) 2008-2026 kroko (Reinis Adovičs)
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import <Foundation/Foundation.h>
#import <Foundation/NSSpellServer.h>
#import "PareizrakstibaSpellChecker.h"

// As I had the idea of introducing some basic grammar checking,
// made this a forwarding class.
// Separate class for spelling, rather than putting code right here
// into instance methods.

@class PareizrakstibaSpellChecker;
@interface PareizrakstibaDelegate : NSObject <NSSpellServerDelegate> {
  PareizrakstibaSpellChecker *mySC;
}

// construct/deconstruct
- (id)init;
- (void)dealloc;

////////////////////////////////////
// IMPLEMENTED

// Check Spelling in Strings
// macOS 10.0+
- (NSArray<NSString *> *)spellServer:(NSSpellServer *)sender
               suggestGuessesForWord:(NSString *)word
                          inLanguage:(NSString *)language;

// macOS 10.0+
- (NSRange)spellServer:(NSSpellServer *)sender
    findMisspelledWordInString:(NSString *)stringToCheck
                      language:(NSString *)language
                     wordCount:(NSInteger *)wordCount
                     countOnly:(BOOL)countOnly;

// Managing the Spelling Dictionary
// macOS 10.0+
- (void)spellServer:(NSSpellServer *)sender
      didForgetWord:(NSString *)word
         inLanguage:(NSString *)language;

// macOS 10.0+
- (void)spellServer:(NSSpellServer *)sender
       didLearnWord:(NSString *)word
         inLanguage:(NSString *)language;

// macOS 10.3+
- (NSArray<NSString *> *)spellServer:(NSSpellServer *)sender
    suggestCompletionsForPartialWordRange:(NSRange)range
                                 inString:(NSString *)string
                                 language:(NSString *)language;

// macOS 10.7+
- (void)spellServer:(NSSpellServer *)sender
     recordResponse:(NSUInteger)response
       toCorrection:(NSString *)correction
            forWord:(NSString *)word
           language:(NSString *)language;

////////////////////////////////////
// NOT IMPLEMENTED

// macOS 10.6+
//- (NSArray<NSTextCheckingResult *> *)spellServer:(NSSpellServer *)sender
//    checkString:(NSString *)stringToCheck
//         offset:(NSUInteger)offset
//          types:(NSTextCheckingTypes)checkingTypes
//        options:(NSDictionary<NSString *,id> *)options
//    orthography:(NSOrthography *)orthography
//      wordCount:(NSInteger *)wordCount;
//
// macOS 10.5+
//- (NSRange)spellServer:(NSSpellServer *)sender
//  checkGrammarInString:(NSString *)stringToCheck
//              language:(NSString *)language
//               details:(NSArray<NSDictionary<NSString *,id> *> * _Nullable *)details;

@end
