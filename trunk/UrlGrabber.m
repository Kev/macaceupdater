/*
 * UrlGrabber.m - Implementation file for URL grabbing helpers.
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

#import "UrlGrabber.h"

@implementation UrlGrabber

+ (NSString*) getPageAsString:(NSURL*) url
{
	NSLog(@"loading URL");
	NSLog([url absoluteString]);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url 
                                    cachePolicy: NSURLRequestReloadIgnoringCacheData
                                    timeoutInterval: 60];
									
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest: request
                                    returningResponse: &response
                                    error: &error];
	
	NSString *output = [NSString stringWithCString:[data bytes] length:[data length]];
	if (error) { 
		NSLog(@"%@", error);
	}

	return [output autorelease];
}

+ (BOOL) getPage:(NSURL*) url toFile:(NSString*) file
{
	NSData *urlContents = [url resourceDataUsingCache:YES];

	if ([urlContents writeToFile:[file
                 stringByExpandingTildeInPath]
                 atomically:YES])
	{
		return YES;
	} else {
		return NO;
	}
}
@end
