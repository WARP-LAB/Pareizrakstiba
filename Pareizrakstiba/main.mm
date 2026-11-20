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

int main(int argc, const char *argv[])
{
  NSLog(@"Pareizrakstiba - 4.2.1 (c) 2008-2026 kroko\n");
  @autoreleasepool {
    PareizrakstibaSpellServer *pareizrakstibaSpellServer = [[PareizrakstibaSpellServer alloc] init];
    // vendor @"Apple" or @"Pareizrakstiba"
    // check NSSpellChecker key in NSServices
    if ([pareizrakstibaSpellServer registerLanguage:@"lv" byVendor:@"Pareizrakstiba"]) {

      NSLog(@"Pareizrakstiba - Spell server registred\n");
      PareizrakstibaDelegate *delegate = [[PareizrakstibaDelegate alloc] init];
      if (delegate != nil) {
        [pareizrakstibaSpellServer setDelegate:delegate];

        NSLog(@"Pareizrakstiba - Spell checker delegated\n");

        [pareizrakstibaSpellServer run];
        [delegate release];
      }
      else {
        NSLog(@"Pareizrakstiba - Spell checker delegate could not be created\n");
      }
    }
    else {
      NSLog(@"Pareizrakstiba - Spell server could not be registred\n");
    }
    [pareizrakstibaSpellServer release];
    NSLog(@"Pareizrakstiba - Shutting down\n");
  }
  return 0;
}
