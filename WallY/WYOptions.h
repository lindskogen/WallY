//
//  WYOptions.h
//  WallY
//
//  Created by Johan Lindskogen on 2013-12-14.
//  Copyright (c) 2013 Johan Lindskogen. All rights reserved.
//

#include <Appkit/NSColor.h>

@interface WYOptions : NSObject

@property (nonatomic, strong) NSURL *imagePath;
@property (nonatomic) BOOL setAll;
@property (nonatomic) unsigned int screen;

-(id)initWithArguments:(NSArray*)arguments;

-(NSDictionary*)wallpaperOptions;

@end
