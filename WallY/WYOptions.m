//
//  WYOptions.m
//  WallY
//
//  Created by Johan Lindskogen on 2013-12-14.
//  Copyright (c) 2013 Johan Lindskogen. All rights reserved.
//

#import "WYOptions.h"
#import "WYLogging.h"

#import <Appkit/NSWorkspace.h>

#import <FSArgumentParser/FSArgumentParser.h>
#import <FSArgumentParser/FSArgumentPackage.h>
#import <FSArgumentParser/FSArgumentSignature.h>


typedef NS_ENUM(NSUInteger, ScreenMode) {
	FIT,
	FILL,
	STRETCH,
	CENTER // ,
	// TILE
};

@interface WYOptions ()

@property (nonatomic) ScreenMode screenMode;
@property (nonatomic, strong) NSColor *fillColor;

@end


@implementation WYOptions

-(NSDictionary*)wallpaperOptions {
	NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
	
	if (self.screenMode) {
		NSImageScaling scaling = NSImageScaleProportionallyDown;
		BOOL clipping = NO;
		switch (self.screenMode) {
			case FIT:
				clipping = NO;
				scaling = NSImageScaleProportionallyUpOrDown;
				break;
			case FILL:
				clipping = YES;
				scaling = NSImageScaleProportionallyUpOrDown;
				break;
			case STRETCH:
				scaling = NSImageScaleAxesIndependently;
				break;
			case CENTER:
				scaling = NSImageScaleNone;
				break;
			// case TILE:
			//  	break;
			default:
				NSLog(@"Invalid screenmode: %u", (unsigned int) self.screenMode);
				break;
		}
		[options setObject:[NSNumber numberWithUnsignedInteger:scaling] forKey:NSWorkspaceDesktopImageScalingKey];
		[options setObject:[NSNumber numberWithBool:clipping] forKey:NSWorkspaceDesktopImageAllowClippingKey];
	}
	if (self.fillColor) {
		[options setObject:self.fillColor forKey:NSWorkspaceDesktopImageFillColorKey];
	}
	return options;
}

-(ScreenMode)screenModeFromString:(NSString*)string {
	
	NSDictionary *modes = @{@"fill": [NSNumber numberWithUnsignedInteger:FILL],
							@"fit": [NSNumber numberWithUnsignedInteger:FIT],
							@"stretch": [NSNumber numberWithUnsignedInteger:STRETCH],
							@"center": [NSNumber numberWithUnsignedInteger:CENTER]};
							// @"tile": [NSNumber numberWithUnsignedInteger:TILE]};
	if (![[modes allKeys] containsObject:string]) {
		[WYLogging writeError:[NSString stringWithFormat:@"Invalid mode: \"%@\"", string]];
		exit(EXIT_FAILURE);
		return -1;
	}
	return [[modes objectForKey:string] unsignedIntegerValue];
}

-(void)showHelp {
	NSArray *helpTexts = @[
						   @"Usage: wally [options] path\n",
						   @"OPTIONS:",
						   @"-h --help\t\t\tShow this message.",
						   @"   --version\t\tShow version and application info.",
						   @"-s --screen i\t\tIndex of the screen to set wallpaper.",
						   @"-a --all\t\t\tSet wallpaper for all screens (ignores -s).",
						   @"-m --mode mode\t\tSet display mode. (fill, fit, stretch, center", // , tile)",
						   @"-c --color color\tSet fill color (in hex; 000000, 333333, ffffff etc)."
						   ];
	for (NSString *str in helpTexts) {
		[WYLogging writeStandard:str];
	}
}

-(NSColor*)colorFromString:(NSString*)string {
	NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
	
    if (nil != string)
    {
		NSScanner* scanner = [NSScanner scannerWithString:string];
		(void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits
	
    result = [NSColor
			  colorWithCalibratedRed:(CGFloat)redByte / 0xff
			  green:(CGFloat)greenByte / 0xff
			  blue:(CGFloat)blueByte / 0xff
			  alpha:1.0];
    return result;
}


-(void)showVersion {
	[WYLogging writeStandard:[NSString stringWithFormat:@"Wally, version %@", APP_VERSION]];
}

-(id)initWithArguments:(NSArray *)arguments {
	self = [super init];
	
	FSArgumentSignature
	// all signatures follow
	
	// help, show usage
	*help = [FSArgumentSignature argumentSignatureWithFormat:@"[-h --help]"],
	
	*version = [FSArgumentSignature argumentSignatureWithFormat:@"[--version]"],
	
	// screen is a number from 0 to the number of screens
	*screen = [FSArgumentSignature argumentSignatureWithFormat:@"[-s --screen]="],
	
	// if specified will set wallpaper of all screens, disregards -s
	*all = [FSArgumentSignature argumentSignatureWithFormat:@"[-a --all]"],
	
	// how the image is applied: can be `fill`, `fit`, `stretch`, `center` or `tile`
	*mode = [FSArgumentSignature argumentSignatureWithFormat:@"[-m --mode]="],
	
	// set the background color if the image doesn't fill all the screen
	*color = [FSArgumentSignature argumentSignatureWithFormat:@"[-c --color]="];
	
	
	FSArgumentParser *argumentParser = [[FSArgumentParser alloc] initWithArguments:arguments signatures:@[help, version, screen, all, mode, color]];
	FSArgumentPackage *package = [argumentParser parse];
	
	
	// If invalid argument was detected
	for (NSString *arg in [package unknownSwitches]) {
		[WYLogging writeError:[NSString
							   stringWithFormat:@"Unknown option: \"%@\" use -h or --help for help.", arg]];
		exit(EXIT_FAILURE);
	}
	
	if ([package booleanValueForSignature:version] || [package booleanValueForSignature:help]) {
		[self showVersion];
		if ([package booleanValueForSignature:help]) {
			[WYLogging writeStandard:@"A tool for setting a wallpaper in OS X.\n"];
			[self showHelp];
		}
		exit(EXIT_SUCCESS);
	}
	
	self.setAll = [package booleanValueForSignature:all];
	
	if ([package countOfSignature:screen] > 0) {
		self.screen = [[package firstObjectForSignature:screen] intValue];
	} else {
		self.screen = -1;
	}
	
	if ([package countOfSignature:color] > 0) {
		self.fillColor = [self colorFromString:[package firstObjectForSignature:color]];
	}
	
	if ([package countOfSignature:mode] > 0) {
		self.screenMode = [self screenModeFromString:[package firstObjectForSignature:mode]];
	} else {
		self.screenMode = [self screenModeFromString:@"fill"];
	}
	
	self.imagePath = [[NSURL fileURLWithPath:arguments.lastObject] URLByResolvingSymlinksInPath];
	
	if (! [[NSFileManager defaultManager] fileExistsAtPath:[self.imagePath path]]) {
		[WYLogging writeError:[NSString stringWithFormat:@"File not found: \"%@\"", [self.imagePath path]]];
		exit(EXIT_FAILURE);
	}
	return self;
}

@end
