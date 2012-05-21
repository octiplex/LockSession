//
//  NSURL+LockSession.m
//  LockSession
//
//  Copyright (c) 2012 Octiplex - http://www.octiplex.com
//  
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//

#import "NSURL+LockSession.h"
#import "OXLSPreferencePane.h"

@implementation NSURL (LockSession)

+ (NSURL*)URLForLockSessionAgentApp
{
    return [[NSBundle bundleForClass:[OXLSPreferencePane class]] URLForResource:@"LockSessionAgent" withExtension:@"app"];
}

+ (NSURL*)URLForLockSessionAgentExecutable
{
    return [[NSBundle bundleWithURL:[self URLForLockSessionAgentExecutable]] executableURL];
}

@end
