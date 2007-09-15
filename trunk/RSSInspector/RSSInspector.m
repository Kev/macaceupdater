/*

BSD License

Copyright (c) 2002, Brent Simmons
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

*	Redistributions of source code must retain the above copyright notice,
	this list of conditions and the following disclaimer.
*	Redistributions in binary form must reproduce the above copyright notice,
	this list of conditions and the following disclaimer in the documentation
	and/or other materials provided with the distribution.
*	Neither the name of ranchero.com or Brent Simmons nor the names of its
	contributors may be used to endorse or promote products derived
	from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


*/

/*
	RSSInspector.m
	RSSInspector
	
	A simple demo of using the RSS class.
	
	Created by Brent Simmons on Tue Jun 04 2002.
	Copyright (c) 2002 Brent Simmons. All rights reserved.
*/


#import "RSSInspector.h"


@implementation RSSInspector


- (void) awakeFromNib {
	
	/*Give user a default URL.*/
	
	[urlField setStringValue: @"http://ranchero.com/macnews/rss.xml"];	
	} /*awakeFromNib*/
	
	
- (void) appendDictionary: (NSDictionary *) dictionary to: (NSMutableString *) s {
	
	NSEnumerator *enumerator = [dictionary keyEnumerator];
	NSString *name, *value;
	
	while (name = [enumerator nextObject]) {
			
		value = [dictionary objectForKey: name];
		
		[s appendString: name];
		
		[s appendString: @" = "];
		
		[s appendString: value];
		
		[s appendString: @"\n"];
		} /*while*/
	} /*appendDictionary*/


- (void) appendHeaderItems: (NSMutableString *) s {
	
	[s appendString: @"---Header items---\n\n"];
	
	[self appendDictionary: [rssFeed headerItems] to: s];
	
	[s appendString: @"\n\n"];
	} /*appendHeaderItems*/


- (void) appendNewsItems: (NSMutableString *) s {
	
	NSEnumerator *enumerator = [[rssFeed newsItems] objectEnumerator];
	NSDictionary *item;
	int ix = 0;
	
	[s appendString: @"---News items---\n\n"];

	while (item = [enumerator nextObject]) {
	
		ix++;
		
		[s appendString: [NSString stringWithFormat: @"---Item #%d:\n", ix]];
			
		/*Each item is a dictionary.*/
	
		[self appendDictionary: item to: s];
		
		[s appendString: @"\n"];
		} /*while*/
	} /*appendNewsItems*/
	
	
- (IBAction) getRss: (id) sender {
	
	/*
	Create a new RSS object and display it as text
	in the text view.
	*/
	
	NSMutableString *rssString;
	NSAttributedString *rssStringAttributed;
		
	NS_DURING
	
		/*Creation of an RSS object may fail if:
		1. The file can't be read, or
		2. It can't be parsed.*/
	
		rssFeed = [[RSS alloc] initWithURL: [NSURL URLWithString: [urlField stringValue]] normalize: YES];
	
	NS_HANDLER
	
		/*Run a sheet.*/
		
		NSBeginAlertSheet (@"Error!", @"OK", nil, nil,
		window, self, nil, nil, nil,
		[NSString stringWithFormat: @"Error: %@", [localException reason]]);
		
		return;

	NS_ENDHANDLER

	rssString = [[NSMutableString alloc] init];

	[self appendHeaderItems: rssString];
	
	[self appendNewsItems: rssString];
	
	rssStringAttributed = [[NSAttributedString alloc] initWithString: rssString];

	[[rssText textStorage] setAttributedString: rssStringAttributed];

	[rssStringAttributed release];
	
	[rssString release];
	
	[rssFeed release];
	} /*getRss*/
	
@end
