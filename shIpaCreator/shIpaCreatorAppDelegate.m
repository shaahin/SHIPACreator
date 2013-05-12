//
//  shIpaCreatorAppDelegate.m
//  shIpaCreator
//
//  Created by Shahin on 7/6/90.
//  Copyright 1390 __MyCompanyName__. All rights reserved.
//

#import "shIpaCreatorAppDelegate.h"

@implementation shIpaCreatorAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}
- (void) awakeFromNib
{
    [window registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]]; 
    [shImage setHidden:NO];
    [shImage setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Drop" ofType:@"png"]]];
}
-(NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    return NSDragOperationGeneric;
}
-(BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    return YES;
}
- (void)windowWillClose:(NSNotification *)aNotification {
	[NSApp terminate:self];
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard* pbrd = [sender draggingPasteboard];
    NSArray *files = [pbrd propertyListForType:NSFilenamesPboardType];
    long cnt = [files count];
    // Do something here.
    
    bool idx = NO;
    NSString *AppUrl = @"";
    NSString *IcnUrl = @"";
    if (((idx = [[[files objectAtIndex:0] pathExtension] isEqualToString:@"app"]) || [[[files objectAtIndex:1] pathExtension] isEqualToString:@"app"]) && cnt == 2) 
    {
        if(idx)
        {
            // means that the .app is the first item in the list.
            AppUrl = [files objectAtIndex:0];
            IcnUrl = [files objectAtIndex:1];
            
        }
        else
        {
            AppUrl = [files objectAtIndex:1];
            IcnUrl = [files objectAtIndex:0];
        }
        [shProgress startAnimation:self];
        [shImage setHidden:YES];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[@"~/_shIpaCreator_temp/Payload/" stringByExpandingTildeInPath] withIntermediateDirectories:true attributes:NULL error:NULL];

        NSString *tempAppUrl = [[NSString stringWithFormat:@"~/_shIpaCreator_temp/Payload/%@", [[AppUrl pathComponents] lastObject]] stringByExpandingTildeInPath];
        NSString *tempIconUrl = [@"~/_shIpaCreator_temp/iTunesArtwork" stringByExpandingTildeInPath];
        

        // modify Plist
        NSDictionary *atts =  [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat: @"%@/Info.plist",[AppUrl stringByExpandingTildeInPath]] error:NULL];
        NSMutableDictionary  *videoDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat: @"%@/Info.plist",[AppUrl stringByExpandingTildeInPath]]];
        BOOL alreadyThere;
        alreadyThere = FALSE;
        for(NSString* key in videoDictionary){
            if ([key isEqualToString:@"SignerIdentity"]) {
                alreadyThere = TRUE; // If the key is already there.
            }
        }
        if (!alreadyThere) {
            NSLog(@"alreadynotthere");
            // If the key is already not there, then add the value for key to the mutable dictionary.
            [videoDictionary setObject:@"Apple iPhone OS Application Signing" forKey:@"SignerIdentity"];
            
        }
        else {
            NSLog(@"alreadythere");
            // If the key is already there.
            [videoDictionary removeObjectForKey:@"SignerIdentity"]; // Removing the existing key and value from the mutable dictionary
            [videoDictionary setObject:@"Apple iPhone OS Application Signing" forKey:@"SignerIdentity"]; // Adding the new value with the key
        }
        
        // Writing the dictionary to plist
        [videoDictionary writeToFile:[NSString stringWithFormat: @"%@/Info.plist",[AppUrl stringByExpandingTildeInPath]] atomically:YES];
        
        
        [[NSFileManager defaultManager] setAttributes:atts ofItemAtPath:[NSString stringWithFormat: @"%@/Info.plist",[AppUrl stringByExpandingTildeInPath]] error:NULL];
        
        
        // end: modify Plist
        NSDictionary *attributes;
		NSNumber *permissions;
		permissions = [NSNumber numberWithUnsignedLong: 0775];
		attributes = [NSDictionary dictionaryWithObject:permissions forKey:NSFilePosixPermissions];
        
        [[NSFileManager defaultManager] copyItemAtPath:AppUrl toPath: tempAppUrl error:NULL];
        [[NSFileManager defaultManager] copyItemAtPath:IcnUrl toPath: tempIconUrl error:NULL];
        [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:[@"~/_shIpaCreator_temp/Payload/" stringByExpandingTildeInPath] error:NULL];
        
        // begin making ipa file
        // ditto -c -k --sequesterRsrc  ~/_shIpaCreator_temp ~/archive.zip
        NSArray *arguments;
        arguments = [NSArray arrayWithObjects: @"-c",@"-k",@"--sequesterRsrc", [@"~/_shIpaCreator_temp" stringByExpandingTildeInPath],[[NSString stringWithFormat:@"~/desktop/%@-shIpaCreator.zip",[[[AppUrl pathComponents] lastObject] stringByDeletingPathExtension]] stringByExpandingTildeInPath]  , nil];
        //
        NSTask *task;
        task = [[NSTask alloc] init];
        
        [task setLaunchPath: @"/usr/bin/ditto" ];
        [task setArguments: arguments];
        
        NSPipe *pipe;
        pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        
        NSFileHandle *file;
        file = [pipe fileHandleForReading];
        
        [task launch];
        
        NSData *data;
        data = [file readDataToEndOfFile];
        
        NSString *string;
        string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        NSLog(@"%@",string);
        [[NSFileManager defaultManager] moveItemAtPath:[[NSString stringWithFormat:@"~/desktop/%@-shIpaCreator.zip",[[[AppUrl pathComponents] lastObject] stringByDeletingPathExtension]] stringByExpandingTildeInPath] toPath:[[NSString stringWithFormat:@"~/desktop/%@-shIpaCreator.ipa",[[[AppUrl pathComponents] lastObject] stringByDeletingPathExtension]] stringByExpandingTildeInPath] error:NULL];
        
        [shProgress stopAnimation:self];
        [shImage setHidden:NO];
        
        NSAlert *theAlert = [[[NSAlert alloc] init] autorelease];
        [theAlert addButtonWithTitle:@"OK"];
        [theAlert setMessageText:@"Voila!"];
        [theAlert setInformativeText:@"Your IPA file is ready! you can find it on your desktop!"];
        [theAlert setAlertStyle:1];
        [theAlert runModal];          

        [[NSFileManager defaultManager] removeItemAtPath:[@"~/_shIpaCreator_temp" stringByExpandingTildeInPath] error:NULL];
    }
else
    {
        NSAlert *theAlert = [[[NSAlert alloc] init] autorelease];
        [theAlert addButtonWithTitle:@"OK"];
        [theAlert setMessageText:@"Invalid files"];
        [theAlert setInformativeText:@"Please select BOTH .app file and jpg/png artwork files and drop it in this application."];
        [theAlert setAlertStyle:0];
        [theAlert runModal];              
    }
    
    return YES;
}
@end
