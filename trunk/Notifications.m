/*
 * Notifications.m - Implementation file event handlers.
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
#import "Notifications.h"
#import <Growl/Growl.h>

#define NotificationApplicationName  @"Mac Ace Updater"
#define NotificationInstalled @"Addon installation complete"

@implementation Notifications
- (void) announceMessageString:(NSString*) message
{
	NSLog(@"Trying to notify growl");
	[GrowlApplicationBridge notifyWithTitle:@"AddOn installation complete"
							description:message
                            notificationName:NotificationInstalled
                            iconData: nil
                            priority:0
							isSticky:NO
							clickContext:@"bob"];
}

- (id) init 
{
	if ((self = [super init])) {
		//register the growl interface
		NSLog(@"Registering Growl");
		[GrowlApplicationBridge setGrowlDelegate:self];
	}
	return self;
}
	
- (void) dealloc {
	[super dealloc];
}

- (NSDictionary *) registrationDictionaryForGrowl {
	        NSArray *notifications = [NSArray arrayWithObjects:
	                NotificationInstalled,
	                nil];
 	
	        NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
	                NotificationApplicationName, GROWL_APP_NAME,
	                notifications, GROWL_NOTIFICATIONS_ALL,
	                notifications, GROWL_NOTIFICATIONS_DEFAULT,
	                nil];
 	
	        return regDict;
}

- (void) growlNotificationWasClicked:(id)clickContext {
        NSLog(@"Hey - the user clicked one of my notifications - the context is: %@", clickContext);
}
 	
- (void) growlNotificationTimedOut:(id)clickContext {
        NSLog(@"Hey - nobody clicked one of my notifications - the context is: %@", clickContext);
}

- (NSString *) applicationNameForGrowl {
	return NotificationApplicationName;
}
@end
