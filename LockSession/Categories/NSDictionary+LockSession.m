//
//  NSDictionary+LockSession.m
//  LockSession
//
//  Copyright (c) 2012 Octiplex - http://www.octiplex.com
//  
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//

#import "NSDictionary+LockSession.h"
#import "OXLSPreferencePane.h"
#import "NSURL+LockSession.h"

NSString * const OXLSLaunchAgent_LabelKey               = @"Label";
NSString * const OXLSLaunchAgent_LabelValue             = @"com.octiplex.LockSession";
NSString * const OXLSLaunchAgent_RunAtLoadKey           = @"RunAtLoad";
NSString * const OXLSLaunchAgent_DisabledKey            = @"Disabled";
NSString * const OXLSLaunchAgent_ProgramArgumentsKey    = @"ProgramArguments";

@implementation NSDictionary (LockSession)

+ (NSDictionary*)dictionaryForLockSessionLaunchAgent
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    [dictionary setObject:OXLSLaunchAgent_LabelValue forKey:OXLSLaunchAgent_LabelKey];
    [dictionary setObject:[NSNumber numberWithBool:YES] forKey:OXLSLaunchAgent_RunAtLoadKey];
    [dictionary setObject:[NSNumber numberWithBool:NO] forKey:OXLSLaunchAgent_DisabledKey];
    [dictionary setObject:[NSArray arrayWithObject:[[NSURL URLForLockSessionAgentExecutable] path]] forKey:OXLSLaunchAgent_ProgramArgumentsKey];
    return dictionary;
}

- (BOOL)isValidLockSessionLaunchAgent
{
    BOOL label = [[self objectForKey:OXLSLaunchAgent_LabelKey] isEqualToString:OXLSLaunchAgent_LabelValue];
    BOOL runAtLoad = [[self objectForKey:OXLSLaunchAgent_RunAtLoadKey] boolValue];
    BOOL disabled = [[self objectForKey:OXLSLaunchAgent_DisabledKey] boolValue];
    NSArray *programArguments = [self objectForKey:OXLSLaunchAgent_ProgramArgumentsKey];
    BOOL programArgumentsSize = ([programArguments count] == 1);
    BOOL programArgumentsValue = [[programArguments lastObject] isEqualToString:[[NSURL URLForLockSessionAgentExecutable] path]];
    
    if( !label || !runAtLoad || disabled || !programArgumentsSize || !programArgumentsValue )
        return NO;
    return YES;
}

@end
