//
//  OXLSAgentController.h
//  LockSession
//
//  Copyright (c) 2012 Octiplex - http://www.octiplex.com
//  
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>


@interface OXLSAgentController : NSObject
{
    EventHotKeyRef _hotKeyRef; // Reference on the currently used hotkey
}

#pragma mark - HotKey
- (void)registerHotKey; // Register hotkey from values in NSUserDefaults
- (void)unregisterHotKey; // Unregister hotkey (if hotkey as changed)


#pragma mark - Notifications
- (void)stopAgent:(NSNotification *)notification; // Terminate the application
- (void)hotKeyChanged:(NSNotification *)notification; // Update registered hotkey
- (void)pingAgent:(NSNotification *)notification; // Answer a ping from prefPane


@end
