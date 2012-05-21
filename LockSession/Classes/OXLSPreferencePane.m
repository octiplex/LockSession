//
//  OXLSPreferencePane.m
//  LockSession
//
//  Copyright (c) 2012 Octiplex - http://www.octiplex.com
//  
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//

#import "OXLSPreferencePane.h"
#import "OXLSConstants.h"
#import "NSUserDefaults+LockSession.h"
#import "NSDictionary+LockSession.h"
#import "NSURL+LockSession.h"

#define NSLocalizedStringPrefPane(key, comment) [[self bundle] localizedStringForKey:(key) value:@"" table:nil]


@implementation OXLSPreferencePane

@synthesize shortcutControl = _shortcutControl;
@synthesize installButton = _installButton;
@synthesize startButton = _startButton;
@synthesize installTextField = _installTextField;
@synthesize startTextField = _startTextField;
@synthesize aboutTextView = _aboutTextView;
@synthesize shortcutBox = _shortcutBox;
@synthesize installBox = _installBox;


#pragma mark - Object lifetime

- (void)dealloc
{
    [_shortcutControl release];
    [_installButton release];
    [_startButton release];
    [_installTextField release];
    [_startTextField release];
    [_aboutTextView release];
    [_shortcutBox release];
    [_installBox release];
    [super dealloc];
}


#pragma mark - Interface

- (void)mainViewDidLoad
{
    // Configure shortcut control
    [self.shortcutControl setCanCaptureGlobalHotKeys:YES];
    
    // An hotkey is a combination of at least one key modifier (cmd, opt, ctrl or shift) and another key.
    // In NSUserDefaults, there is a boolean value for each key modifier and the code of the other key.
    
    BOOL cmd = NO, opt = NO, ctrl = NO, shift = NO;
    KeyCombo combo;	
    combo.code=0;
    combo.flags=0;
    
    NSDictionary *preferences = [NSUserDefaults persistentDomainForOXLSPreferencePane];
    
    cmd         = [[preferences objectForKey:OXLSUserDefaults_CommandKey]   boolValue];
    opt         = [[preferences objectForKey:OXLSUserDefaults_OptionKey]    boolValue];
    ctrl        = [[preferences objectForKey:OXLSUserDefaults_ControlKey]   boolValue];
    shift       = [[preferences objectForKey:OXLSUserDefaults_ShiftKey]     boolValue];
    combo.code  = [[preferences objectForKey:OXLSUserDefaults_KeyCodeKey]   intValue];
	
	// Default: cmd+crtl+alt+L
    if( !cmd && !opt && !ctrl && !shift && !combo.code )
    {
        cmd         = OXLSHotKey_DefaultCommandValue;
        opt         = OXLSHotKey_DefaultOptionValue;
        ctrl        = OXLSHotKey_DefaultControlValue;
        shift       = OXLSHotKey_DefaultShiftValue;
        combo.code  = OXLSHotKey_DefaultKeyCodeValue;
    }
    
    if (cmd)    combo.flags += NSCommandKeyMask;
    if (opt)    combo.flags += NSAlternateKeyMask;
    if (ctrl)   combo.flags += NSControlKeyMask;
    if (shift)  combo.flags += NSShiftKeyMask;
    
    [self.shortcutControl setKeyCombo:combo];
	
    
    // Updating interface
    [self.aboutTextView readRTFDFromFile:[[self bundle] pathForResource:@"about" ofType:@"rtfd"]];
    [self.installBox    setTitle:NSLocalizedStringPrefPane(@"installation", nil)];	
    [self.shortcutBox   setTitle:NSLocalizedStringPrefPane(@"shortcut", nil)];
    [self updateInterface];
    
    
    // Observing agent start/stop notifications
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(agentStarted:)
                                                            name:OXLSNotification_AgentStarted object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(agentStopped:) 
                                                            name:OXLSNotification_AgentStopped object:nil];
    
    // Ping agent (if agent is running, it responds by OXLSNotification_AgentStarted)
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:OXLSNotification_PingAgent object:nil];
}

- (void)updateInterface
{
    NSUInteger agentInstalled = [self agentInstallationStatus];
    
    [self.startButton setTitle:NSLocalizedStringPrefPane((_agentIsRunning ? @"stop" : @"start"), nil)];
    [self.startTextField setStringValue:NSLocalizedStringPrefPane((_agentIsRunning ? @"locksession_started" : @"locksession_stopped"), nil)];
    [self.startTextField setTextColor:_agentIsRunning ? [NSColor blackColor] : [NSColor redColor]];
    
    
    NSString *installButtonText = nil;
    NSString *installTextFieldText = nil;
    NSColor *installTextFieldColor = [NSColor redColor];
    BOOL startButtonEnabled = YES;
    
    switch (agentInstalled)
    {
        case OXLSAgentInstallationCorrupted:
            installButtonText = @"reinstall";
            installTextFieldText = @"locksession_not_properly";
            break;
        case OXLSAgentInstallationInstalled:
            installButtonText = @"remove";
            installTextFieldText = @"locksession_installed";
            installTextFieldColor = [NSColor blackColor];
            break;
        default:
            installButtonText = @"install";
            installTextFieldText = @"locksession_not_installed";
            if( !_agentIsRunning ) startButtonEnabled=NO;
            break;
    }
    
    [self.installButton     setTitle:NSLocalizedStringPrefPane(installButtonText, nil)];
    [self.installTextField  setStringValue:NSLocalizedStringPrefPane(installTextFieldText, nil)];
    [self.installTextField  setTextColor:installTextFieldColor];
    [self.startButton       setEnabled:startButtonEnabled];
}


#pragma mark - Notifications

- (void)agentStarted:(NSNotification *)notification
{
    _agentIsRunning = YES;
    [self updateInterface];
}

- (void)agentStopped:(NSNotification *)notification
{
    _agentIsRunning = NO;
    [self updateInterface];
}


#pragma mark - Agent management

- (NSURL *)launchAgentURL
{
    NSURL *libraryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"LaunchAgents/com.octiplex.LockSession.plist"];
}

- (OXLSAgentInstallationStatus)agentInstallationStatus
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:[self launchAgentURL]];
    if( !dict ) return OXLSAgentInstallationNone;
    return [dict isValidLockSessionLaunchAgent] ? OXLSAgentInstallationInstalled : OXLSAgentInstallationCorrupted;
}

- (void)startAgent
{
    if(!_agentIsRunning)
    {
        // Use launch services API to start the agent
        LSLaunchURLSpec launchSpec;
		launchSpec.appURL = (CFURLRef)[NSURL URLForLockSessionAgentApp];
        launchSpec.itemURLs = NULL;
        launchSpec.passThruParams = NULL;
        launchSpec.launchFlags = kLSLaunchDefaults | kLSLaunchDontAddToRecents | kLSLaunchDontSwitch | kLSLaunchNoParams;
        launchSpec.asyncRefCon = NULL;
        LSOpenFromURLSpec(&launchSpec,NULL);
    }
}

- (void)stopAgent
{
    // Ask agent to stop by itself
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:OXLSNotification_StopAgent object:nil];
}

- (void)installAgent {
	if([self agentInstallationStatus] == OXLSAgentInstallationNone)
    {
		NSDictionary *dictionary = [NSDictionary dictionaryForLockSessionLaunchAgent];
        NSString *error = nil;
		NSData *data = [NSPropertyListSerialization dataFromPropertyList:dictionary
                                                                  format:NSPropertyListXMLFormat_v1_0
                                                        errorDescription:&error];
        NSLog(@"data = %@", data);
        NSLog(@"error = %@", error);
		if(data) [data writeToURL:[self launchAgentURL] atomically:YES];
	}
}

- (void)uninstallAgent
{
    [[NSFileManager defaultManager] removeItemAtURL:[self launchAgentURL] error:nil];
}

- (IBAction)startAction:(id)sender
{
    if(_agentIsRunning)
        [self stopAgent];
    else
        [self startAgent];
    
    [self updateInterface];
}

- (IBAction)installAction:(id)sender
{
    NSUInteger agentInstalled = [self agentInstallationStatus];
    
    switch (agentInstalled)
    {
        case OXLSAgentInstallationCorrupted:
            [self uninstallAgent];
            [self installAgent];
            break;
        case OXLSAgentInstallationInstalled:
            [self uninstallAgent];
            [self stopAgent];
            break;
        default:
            [self installAgent];
            [self startAgent];
            break;
    }
    [self updateInterface];
}


- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    unsigned int flags = [aRecorder keyCombo].flags;
    signed short code = [aRecorder keyCombo].code;
    
    BOOL cmd = NO, opt = NO, ctrl = NO, shift = NO;
    
    if (flags & NSCommandKeyMask)   cmd=YES;
    if (flags & NSAlternateKeyMask) opt=YES;
    if (flags & NSControlKeyMask)   ctrl=YES;
    if (flags & NSShiftKeyMask)     shift=YES;
    
    // get old preferences
    NSMutableDictionary *preferences = [[[NSUserDefaults persistentDomainForOXLSPreferencePane] mutableCopy] autorelease];
    if ( !preferences ) preferences = [NSMutableDictionary dictionary];
    
    // setting new preferences
    [preferences setObject:[NSNumber numberWithBool:cmd]    forKey:OXLSUserDefaults_CommandKey];
    [preferences setObject:[NSNumber numberWithBool:opt]    forKey:OXLSUserDefaults_OptionKey];
    [preferences setObject:[NSNumber numberWithBool:ctrl]   forKey:OXLSUserDefaults_ControlKey];
    [preferences setObject:[NSNumber numberWithBool:shift]  forKey:OXLSUserDefaults_ShiftKey];
    [preferences setObject:[NSNumber numberWithShort:code]  forKey:OXLSUserDefaults_KeyCodeKey];
    
    // applying new preferences
    [defaults setPersistentDomain:preferences forName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
    [defaults synchronize];
    
    // notify agent
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:OXLSNotification_HotKeyChanged object:nil];
}

@end
