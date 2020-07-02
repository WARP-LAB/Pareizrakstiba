/*
 PareizrakstibaSpellChecker.h
 
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
#import <CoreFoundation/CoreFoundation.h>
#import "hunspell.hxx"

#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4 // for 10.4
// NSInteger/NSUInteger and Max/Mins (for 10.4 we care only about 32-bit arch here)
#ifndef NSINTEGER_DEFINED
typedef int NSInteger;
typedef unsigned int NSUInteger;
#define NSIntegerMax    INT_MAX
#define NSIntegerMin    INT_MIN
#define NSUIntegerMax   UINT_MAX
#define NSINTEGER_DEFINED 1
#endif  // NSINTEGER_DEFINED
#endif  // MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4

class	Hunspell;

@interface PareizrakstibaSpellChecker : NSObject {
	Hunspell* myHS;
    NSMutableCharacterSet *wordCharSet;
}
- (id)init;
- (void) dealloc;
- (NSRange)spellServer:(NSSpellServer *)sender findMisspelledWordInString:(NSString *)stringToCheck language:(NSString *)language wordCount:(NSInteger *)wordCount countOnly:(BOOL)countOnly;
- (NSArray *)spellServer:(NSSpellServer *)sender suggestGuessesForWord:(NSString *)word inLanguage:(NSString *)language;
- (NSArray *)spellServer:(NSSpellServer *)sender suggestCompletionsForPartialWordRange:(NSRange)range inString:(NSString *)string language:(NSString *)language;
- (void)spellServer:(NSSpellServer *)sender recordResponse:(NSUInteger)response toCorrection:(NSString *)correction forWord:(NSString *)word language:(NSString *)language;
- (void)spellServer:(NSSpellServer *)sender didLearnWord:(NSString *)word inLanguage:(NSString *)language;
- (void)spellServer:(NSSpellServer *)sender didForgetWord:(NSString *)word inLanguage:(NSString *)language;


@end
