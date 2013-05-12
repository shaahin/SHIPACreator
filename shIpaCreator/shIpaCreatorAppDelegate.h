//
//  shIpaCreatorAppDelegate.h
//  shIpaCreator
//
//  Created by Shahin on 7/6/90.
//  Copyright 1390 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <AppKit/AppKit.h>

@interface shIpaCreatorAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet NSProgressIndicator *shProgress;
    IBOutlet NSImageView *shImage;}

@property (assign) IBOutlet NSWindow *window;

@end
