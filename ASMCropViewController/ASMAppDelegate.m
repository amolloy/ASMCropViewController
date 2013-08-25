//
//  ASMAppDelegate.m
//  ASMCropViewController
//
//  Created by The Molloys on 8/22/13.
//  Copyright (c) 2013 Andy Molloy. All rights reserved.
//

#import "ASMAppDelegate.h"
#import "ASMCropImageViewController.h"

@interface ASMAppDelegate ()
@property (nonatomic, strong) ASMCropImageViewController* cropImageViewController;
@end

@implementation ASMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	self.cropImageViewController = [[ASMCropImageViewController alloc] init];
	self.cropImageViewController.image = [UIImage imageNamed:@"IMG_7999.jpg"];

	UINavigationController* navController = [[UINavigationController alloc]
											 initWithRootViewController:self.cropImageViewController];
	
	navController.topViewController.navigationItem.rightBarButtonItem =
	[[UIBarButtonItem alloc] initWithTitle:@"Crop"
									 style:UIBarButtonItemStyleBordered
									target:self
									action:@selector(doCrop:)];
	
	self.window.rootViewController = navController;
	
	[self.window makeKeyAndVisible];
	
    return YES;
}

- (void)doCrop:(id)sender
{
	UIImage* croppedImage = [self.cropImageViewController croppedImage];
	UIImageView* croppedImageView = [[UIImageView alloc] initWithImage:croppedImage];
	UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.window.bounds];
	[scrollView addSubview:croppedImageView];
	[scrollView setContentSize:croppedImage.size];
	[self.window addSubview:scrollView];
}

@end
