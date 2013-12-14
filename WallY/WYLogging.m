//
//  WYLogging.m
//  WallY
//
//  Created by Johan Lindskogen on 2013-12-13.
//  Copyright (c) 2013 Johan Lindskogen. All rights reserved.
//

#import "WYLogging.h"

@implementation WYLogging

+(BOOL)writeLog:(NSString*)string toFile:(NSString*)target {
	string = [NSString stringWithFormat:@"%@\n", string];
	return [string writeToFile:target atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

+(BOOL)writeError:(NSString*)string {
	return [self writeLog:string toFile:@"/dev/stderr"];
}
+(BOOL)writeStandard:(NSString*)string {
	return [self writeLog:string toFile:@"/dev/stdout"];
}

@end
