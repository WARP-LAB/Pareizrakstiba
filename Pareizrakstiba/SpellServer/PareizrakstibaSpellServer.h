/*
 * PareizrakstibaSpellServer.h
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

// Subclass of NSSpellServer
// Currently an empty class
// It was not so empty as I used to play around w/
// a companion preference pane to change spell server opts on fly

@interface PareizrakstibaSpellServer : NSSpellServer

@end
