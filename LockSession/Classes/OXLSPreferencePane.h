//
//  OXLSPreferencePane.h
//  LockSession
//
//  Copyright (c) 2012 Octiplex - http://www.octiplex.com
//  
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//

#import <PreferencePanes/PreferencePanes.h>
#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/ShortcutRecorder.h>


typedef enum
{
    OXLSAgentInstallationNone,
    OXLSAgentInstallationCorrupted,
    OXLSAgentInstallationInstalled,
} OXLSAgentInstallationStatus;


@interface OXLSPreferencePane : NSPreferencePane 
{
    SRRecorderControl   *_shortcutControl;
    NSButton    *_installButton;
    NSButton    *_startButton;
    NSTextField *_installTextField;
    NSTextField *_startTextField;
    NSTextView  *_aboutTextView;
    NSBox       *_shortcutBox;
    NSBox       *_installBox;
    
    BOOL _agentIsRunning;
}

@property (nonatomic, retain) IBOutlet SRRecorderControl *shortcutControl;
@property (nonatomic, retain) IBOutlet NSButton *installButton;
@property (nonatomic, retain) IBOutlet NSButton *startButton;
@property (nonatomic, retain) IBOutlet NSTextField *installTextField;
@property (nonatomic, retain) IBOutlet NSTextField *startTextField;
@property (nonatomic, retain) IBOutlet NSTextView *aboutTextView;
@property (nonatomic, retain) IBOutlet NSBox *shortcutBox;
@property (nonatomic, retain) IBOutlet NSBox *installBox;

#pragma mark - Interface
- (void)updateInterface;

#pragma mark - Notifications
- (void)agentStarted:(NSNotification *)notification;
- (void)agentStopped:(NSNotification *)notification;

#pragma mark - User actions
- (IBAction)startAction:(id)sender;
- (IBAction)installAction:(id)sender;

#pragma mark - Agent management
- (NSURL*)launchAgentURL;
- (OXLSAgentInstallationStatus)agentInstallationStatus;
- (void)startAgent;
- (void)stopAgent;
- (void)installAgent;
- (void)uninstallAgent;

@end
