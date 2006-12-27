/*
 * PluginManagerController.h - Header file for the application controller.
 * Copyright (C) 2006  Kevin Smith.
 *
 * This file is part of the MacAceUpdater program.
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License,
 * as published by the Free Software Foundation, version 2.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */
#import <Cocoa/Cocoa.h>
#import "PluginManager.h"

@interface PluginManagerController : NSObject
{
    IBOutlet NSTextField *markedCount;
    IBOutlet NSTableView *pluginList;
    IBOutlet NSTextView *progressText;
    IBOutlet NSTextField *statusText;
	PluginManager *pluginManager_;
}
- (IBAction)InstallPlugins:(id)sender;
- (IBAction)initialiseGUI:(id)sender;
- (IBAction)selectOutdated:(id)sender;
- (void) doInit;
- (void) markedUpdate;
- (void) statusUpdate:(NSString*)status;
@end
