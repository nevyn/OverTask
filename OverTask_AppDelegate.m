//  Created by Joachim Bengtsson on 2010-07-16.

#import "OverTask_AppDelegate.h"
#import <Carbon/Carbon.h>

static EventHotKeyRef OTLeft, OTRight, OTUp, OTDown, OTReturn, OTAltUp, OTSpace;

@implementation OverTaskApp
enum {
	// NSEvent subtypes for hotkey events (undocumented).
	kEventHotKeyPressedSubtype = 6,
	kEventHotKeyReleasedSubtype = 9,
};

- (void)sendEvent:(NSEvent *)evt;
{
	if ([evt type] == NSSystemDefined && [evt subtype] ==kEventHotKeyPressedSubtype) {
		TaskView *tv = [(id)[self delegate] task];
		
		if(evt.data1 == (int)OTLeft) [tv moveLeft:self];
		if(evt.data1 == (int)OTRight) [tv moveRight:self];
		if(evt.data1 == (int)OTUp) [tv moveUp:self];
		if(evt.data1 == (int)OTDown) [tv moveDown:self];
		if(evt.data1 == (int)OTReturn) [tv completeSelected:self];
		if(evt.data1 == (int)OTAltUp) [tv addChild:self];
		if(evt.data1 == (int)OTSpace) [tv renameSelected:self];
	}
	
	[super sendEvent:evt];
}

@end



@implementation OverTask_AppDelegate

@synthesize window, task;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
#define test(x) if((s = (x)) != 0) { NSLog(@"Registration error: %d", s); return; }
	OSStatus s;
	EventHotKeyID nul;
	EventTargetRef t = GetApplicationEventTarget();
    test(RegisterEventHotKey(kVK_LeftArrow, cmdKey|controlKey, nul, t, 0, &OTLeft));
    test(RegisterEventHotKey(kVK_RightArrow, cmdKey|controlKey, nul, t, 0, &OTRight));
    test(RegisterEventHotKey(kVK_UpArrow, cmdKey|controlKey, nul, t, 0, &OTUp));
    test(RegisterEventHotKey(kVK_DownArrow, cmdKey|controlKey, nul, t, 0, &OTDown));
    test(RegisterEventHotKey(kVK_Return, cmdKey|controlKey, nul, t, 0, &OTReturn));
    test(RegisterEventHotKey(kVK_UpArrow, cmdKey|optionKey|controlKey, nul, t, 0, &OTAltUp));
    test(RegisterEventHotKey(kVK_Space, cmdKey|controlKey, nul, t, 0, &OTSpace));
#undef test
	
	
	__block NSPoint oldPoint;
	__block id mouseMonitor = nil;
	id modifierMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:^(NSEvent *evt) {
		NSUInteger newFlags = evt.modifierFlags & NSDeviceIndependentModifierFlagsMask;
		NSLog(@"New flags %d", newFlags);
		if(newFlags == (NSCommandKeyMask|NSControlKeyMask)) {
			oldPoint = NSEvent.mouseLocation;
			mouseMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMoved handler:^(NSEvent *mouseEvt) {
				NSLog(@"Mouse monitored");
				NSPoint newPoint = NSEvent.mouseLocation;
				
				float delta = newPoint.y - oldPoint.y;
				window.alphaValue += delta/100.;
				
				oldPoint = newPoint;
			}];
			NSLog(@"Starting mouse monitoring %@", mouseMonitor);
		} else if(mouseMonitor) {
			NSLog(@"Stopping mouse monitoring");
			[NSEvent removeMonitor:mouseMonitor];
			mouseMonitor = nil;
		}
	}];
	NSLog(@"Registered modifier monitor %@", modifierMonitor);
}


/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "OverTask" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"OverTask"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void)dealloc {

    [window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	
    [super dealloc];
}


@end
