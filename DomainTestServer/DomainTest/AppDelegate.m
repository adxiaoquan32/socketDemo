//
//  AppDelegate.m
//  DomainTest
//
//  Created by Jonathan Diehl on 06.10.12.
//  Copyright (c) 2012 Jonathan Diehl. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize server = _server;
@synthesize clients = _clients;

- (IBAction)addClient:(id)sender;
{
 
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_clients = [NSMutableArray new];
	
	NSError *error = nil;
	_server = [[DomainServer alloc] initWithWindowNibName:@"DomainServer"];
	//self.server.url = [NSURL fileURLWithPath:@"/tmp/socket"];
    // 10.1.153.92:59289
    self.server.url = [NSURL URLWithString:@"http://localhost:59289"];
    
    [_server showWindow:nil];
	if (![self.server start:&error]) {
		[self.window presentError:error];
	}
	
	//[self addClient:nil];
}

@end
