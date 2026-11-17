/*
 * PareizrakstibaSpellChecker.h
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
#import <CoreFoundation/CoreFoundation.h>
#import "hunspell.hxx"

class Hunspell;

@interface PareizrakstibaSpellChecker : NSObject {
  Hunspell *myHS;
  NSMutableCharacterSet *wordCharSet;
  NSCache *spellCache;
}
- (id)init;
- (void)dealloc;

// Check Spelling in Strings

- (NSArray<NSString *> *)spellServer:(NSSpellServer *)sender
               suggestGuessesForWord:(NSString *)word
                          inLanguage:(NSString *)language;

- (NSRange)spellServer:(NSSpellServer *)sender
    findMisspelledWordInString:(NSString *)stringToCheck
                      language:(NSString *)language
                     wordCount:(NSInteger *)wordCount
                     countOnly:(BOOL)countOnly;

// Managing the Spelling Dictionary

- (void)spellServer:(NSSpellServer *)sender
      didForgetWord:(NSString *)word
         inLanguage:(NSString *)language;

- (void)spellServer:(NSSpellServer *)sender
       didLearnWord:(NSString *)word
         inLanguage:(NSString *)language;

- (NSArray<NSString *> *)spellServer:(NSSpellServer *)sender
    suggestCompletionsForPartialWordRange:(NSRange)range
                                 inString:(NSString *)string
                                 language:(NSString *)language;

- (void)spellServer:(NSSpellServer *)sender
     recordResponse:(NSUInteger)response
       toCorrection:(NSString *)correction
            forWord:(NSString *)word
           language:(NSString *)language;

@end
