//
//  WYLogging.h
//  WallY
//
//  Created by Johan Lindskogen on 2013-12-13.
//  Copyright (c) 2013 Johan Lindskogen. All rights reserved.
//

@interface WYLogging : NSObject

+(BOOL)writeLog:(NSString*)string toFile:(NSString*)target;
+(BOOL)writeError:(NSString*)string;
+(BOOL)writeStandard:(NSString*)string;

@end
