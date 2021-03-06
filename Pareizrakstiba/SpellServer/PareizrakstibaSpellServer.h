/*
 PareizrakstibaSpellServer.h
 
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

// Subclass of NSSpellServer
// Currently an empty class
// It was not so empty as I used to play around w/ a companion preference pane to change spell server opts on fly

@interface PareizrakstibaSpellServer : NSSpellServer

@end
