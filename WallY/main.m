//
//  main.m
//  WallY
//
//  Created by Johan Lindskogen on 2013-12-13.
//  Copyright (c) 2013 Johan Lindskogen. All rights reserved.
//

#import "WYDesktopController.h"
#import "WYLogging.h"
#import "WYOptions.h"

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		WYDesktopController *con = [[WYDesktopController alloc] init];
		WYOptions *options = [[WYOptions alloc] initWithArguments:[[NSProcessInfo processInfo] arguments]];
		[con setWallpaperWithOptions:options];
	}
    return 0;
}

