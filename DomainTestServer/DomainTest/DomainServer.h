//
//  DomainServer.h
//  DomainTest
//
//  Created by Jonathan Diehl on 06.10.12.
//  Copyright (c) 2012 Jonathan Diehl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"

@interface DomainServer : NSWindowController <GCDAsyncSocketDelegate>

@property (readonly) GCDAsyncSocket *socket;
@property (readonly) NSMutableSet *connectedSockets;
@property (readonly) NSMutableSet *totalconnectedSockets;
@property (strong) NSURL *url;

@property (strong) IBOutlet NSTextView *outputView;
@property (strong) IBOutlet NSTextField *inputView;


@property (unsafe_unretained) IBOutlet NSTextView *userTextView;


- (IBAction)send:(id)sender;

- (BOOL)start:(NSError **)error;
- (void)stop;

@end
