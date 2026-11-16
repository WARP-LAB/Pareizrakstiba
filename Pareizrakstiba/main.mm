/*
 * main.mm
 *
 * Pareizrakstība
 * Latvian spellcheck for macOS.
 *
 * Copyright (C) 2008-2026 kroko (Reinis Adovičs)
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import <Foundation/Foundation.h>
#import "PareizrakstibaSpellServer.h"
#import "PareizrakstibaDelegate.h"

int main(int argc, const char * argv[])
{
  NSLog(@"WARPDEBUG Pareizrakstiba - 4.2.0 (c) 2008-2026 kroko\n");
  @autoreleasepool {
    PareizrakstibaSpellServer *pareizrakstibaSpellServer = [[PareizrakstibaSpellServer alloc] init];
    // vendor @"Apple" or @"Pareizrakstiba"
    // ckeck NSSpellChecker key in NSServices
    if ([pareizrakstibaSpellServer registerLanguage:@"lv" byVendor:@"Pareizrakstiba"]) {

      NSLog(@"WARPDEBUG Pareizrakstiba - Spell server registred\n");
      [pareizrakstibaSpellServer setDelegate:[[[PareizrakstibaDelegate alloc] init] autorelease]];

      NSLog(@"WARPDEBUG Pareizrakstiba - Spell checker delegated\n");

      [pareizrakstibaSpellServer run];
    }
    else {
      NSLog(@"WARPDEBUG Pareizrakstiba - Spell server could not be registred\n");
    }
    [pareizrakstibaSpellServer release];
    NSLog(@"WARPDEBUG Pareizrakstiba - Shutting down\n");
  }
  return 0;
}
