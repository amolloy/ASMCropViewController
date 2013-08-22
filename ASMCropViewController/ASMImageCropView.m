//
//  ASMImageCropView.m
//  ASMCropViewController
//
//  Created by The Molloys on 8/22/13.
//  Copyright (c) 2013 Andy Molloy. All rights reserved.
//

#import "ASMImageCropView.h"

@interface ASMImageCropView ()
@property (strong, nonatomic) UIImage* fullImage;
@end

@implementation ASMImageCropView

- (void)setImage:(UIImage*)image
{
	self.fullImage = image;
	[self setNeedsDisplay];
}

- (void)sizeToFit
{
	CGRect newFrame = self.frame;
	newFrame.size = self.fullImage.size;
	self.frame = newFrame;
}

- (void)drawRect:(CGRect)rect
{
	[self.fullImage drawAtPoint:CGPointZero];
}

@end
