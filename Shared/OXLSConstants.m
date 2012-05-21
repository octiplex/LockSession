//
//  OXLSConstants.m
//  LockSession
//
//  Copyright (c) 2012 Octiplex - http://www.octiplex.com
//  
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//

#import "OXLSConstants.h"

NSString * const OXLSNotification_StopAgent         = @"com.octiplex.LockSession.stopAgent";
NSString * const OXLSNotification_HotKeyChanged     = @"com.octiplex.LockSession.hotKeyChanged";
NSString * const OXLSNotification_PingAgent         = @"com.octiplex.LockSession.pingAgent";
NSString * const OXLSNotification_AgentStopped      = @"com.octiplex.LockSession.AgentStopped";
NSString * const OXLSNotification_AgentStarted      = @"com.octiplex.LockSession.AgentStarted";

BOOL        const OXLSHotKey_DefaultCommandValue    = YES;
BOOL        const OXLSHotKey_DefaultOptionValue     = YES;
BOOL        const OXLSHotKey_DefaultControlValue    = YES;
BOOL        const OXLSHotKey_DefaultShiftValue      = NO;
NSInteger   const OXLSHotKey_DefaultKeyCodeValue    = 37;

NSString * const OXLSUserDefaults_CommandKey    = @"command";
NSString * const OXLSUserDefaults_OptionKey     = @"option";
NSString * const OXLSUserDefaults_ControlKey    = @"control";
NSString * const OXLSUserDefaults_ShiftKey      = @"shift";
NSString * const OXLSUserDefaults_KeyCodeKey    = @"keycode";
