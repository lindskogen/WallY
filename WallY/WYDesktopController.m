//
//  WYDesktopController.m
//  WallY
//
//  Created by Johan Lindskogen on 2013-12-13.
//  Copyright (c) 2013 Johan Lindskogen. All rights reserved.
//

#import <Appkit/NSScreen.h>

#import "WYDesktopController.h"
#import "WYLogging.h"

@interface WYDesktopController ()
	@property (nonatomic, strong) NSWorkspace *workspace;

@end


@implementation WYDesktopController

- (id)init
{
    self = [super init];
    if (self) {
        self.workspace = [NSWorkspace sharedWorkspace];
    }
    return self;
}

-(void)setWallpaperWithOptions:(WYOptions*)options {
	if (options.setAll) {
		[self setWallpaperToAllScreensWithPath:options.imagePath andOptions:options.wallpaperOptions];
	} else {
		if (options.screen == -1) {
			options.screen = 0;
		}
		if (options.screen >= [[NSScreen screens] count]) {
			[WYLogging writeError:[NSString stringWithFormat:@"There's no screen with index %d.", options.screen]];
			exit(EXIT_FAILURE);
		}
		NSScreen *screen = [[NSScreen screens] objectAtIndex:options.screen];
		[self setWallpaperWithPath:options.imagePath screen:screen andOptions:options.wallpaperOptions];
	}
}

-(void)setWallpaperToAllScreensWithPath:(NSURL *)path andOptions:(NSDictionary*)options {
	for (NSScreen *screen in [NSScreen screens]) {
		[self setWallpaperWithPath:path screen:screen andOptions:options];
	}
}

-(BOOL)setWallpaperWithPath:(NSURL *)imagePath screen:(NSScreen *)screen andOptions:(NSDictionary*)options {
	return [self.workspace setDesktopImageURL:imagePath forScreen:screen options:options error:nil];
}

@end
