//
//  OXLSAgentController.m
//  LockSession
//
//  Copyright (c) 2012 Octiplex - http://www.octiplex.com
//  
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//

#import "OXLSAgentController.h"
#import "OXLSConstants.h"


@implementation OXLSAgentController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Register hotkey
    [self registerHotKey];
    
    // observe notifications from prefPane
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAgent:) 
                                                            name:OXLSNotification_StopAgent object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(hotKeyChanged:) 
                                                            name:OXLSNotification_HotKeyChanged object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(pingAgent:) 
                                                            name:OXLSNotification_PingAgent object:nil];
    
    // inform that agent is started
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:OXLSNotification_AgentStarted object:nil];
}


#pragma mark - Hotkey

OSStatus HotKeyPressed(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
    // HotKey pressed: lock session
    NSTask* lock = [[NSTask alloc] init];
    [lock setLaunchPath:@"/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession"];
    [lock setArguments:[NSArray arrayWithObjects:@"-suspend", nil]];
    [lock launch];
    [lock release];
    
    return noErr;
}

- (void)registerHotKey
{
    // unregister previous hotkey
    if (_hotKeyRef)
        [self unregisterHotKey];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    
    // An hotkey is a combination of at least one key modifier (cmd, opt, ctrl or shift) and another key.
    // In NSUserDefaults, there is a boolean value for each key modifier and the code of the other key.
    
    BOOL cmd = NO, opt = NO, ctrl = NO, shift = NO;
    signed short code = 0;
    
    
    // reading values
    cmd     = [defaults boolForKey:OXLSUserDefaults_CommandKey];
    opt     = [defaults boolForKey:OXLSUserDefaults_OptionKey];
    ctrl    = [defaults boolForKey:OXLSUserDefaults_ControlKey];
    shift   = [defaults boolForKey:OXLSUserDefaults_ShiftKey];
    code    = [defaults integerForKey:OXLSUserDefaults_KeyCodeKey];
    
    
    // If there is no key modifier and no key code, using default value: cmd+crtl+opt+L
    if( !cmd && !opt && !ctrl && !shift && !code )
    {
        cmd     = OXLSHotKey_DefaultCommandValue;
        opt     = OXLSHotKey_DefaultOptionValue;
        ctrl    = OXLSHotKey_DefaultControlValue;
        shift   = OXLSHotKey_DefaultShiftValue;
        code    = OXLSHotKey_DefaultKeyCodeValue;
    }
    
    
    // Register HotKeyPressed() function for keyboard event
    EventTypeSpec typeSpec;
    typeSpec.eventClass = kEventClassKeyboard;
    typeSpec.eventKind  = kEventHotKeyPressed;
    InstallApplicationEventHandler(&HotKeyPressed,1,&typeSpec,NULL,NULL);
    
    
    // Creating hotkey identifier
    EventHotKeyID hotKeyID;
    hotKeyID.signature = 'lcks'; // signature must have 4 characters
    hotKeyID.id = 1;
    
    UInt32 hotKeyModifiers = 0;
    if(cmd)     hotKeyModifiers += cmdKey;
    if(opt)     hotKeyModifiers += optionKey;
    if(ctrl)    hotKeyModifiers += controlKey;
    if(shift)   hotKeyModifiers += shiftKey;
    
    // Registering and retrieving hotkey
    if (noErr != RegisterEventHotKey(code,
                                     hotKeyModifiers,
                                     hotKeyID,
                                     GetApplicationEventTarget(),
                                     0,
                                     &_hotKeyRef))
    {
        // stop agent if enable to register hotkey
        [self stopAgent:nil];
    }
}

- (void)unregisterHotKey
{
    // unregister hotkey
    UnregisterEventHotKey(_hotKeyRef);
    _hotKeyRef = nil;
}


#pragma mark - Notifications

- (void)stopAgent:(NSNotification *)notification
{
    // Post notification before terminating application
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:OXLSNotification_AgentStopped object:nil];
    [[NSApplication sharedApplication] terminate:self];
}

- (void)hotKeyChanged:(NSNotification *)notification
{
    // unregister old hotkey and register new one
    [self unregisterHotKey];
    [self registerHotKey];
}

- (void)pingAgent:(NSNotification *)notification
{
    // answer to ping by notify that agent is started
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:OXLSNotification_AgentStarted object:nil];
}

@end
