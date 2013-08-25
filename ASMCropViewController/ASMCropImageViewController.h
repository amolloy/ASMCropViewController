//
//  ASMCropImageViewController.h
//  ASMCropViewController
//
//  Created by The Molloys on 8/22/13.
//  Copyright (c) 2013 Andy Molloy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASMCropImageViewController : UIViewController

@property (strong, nonatomic) UIImage* image;

- (UIImage*)croppedImage;

@end
