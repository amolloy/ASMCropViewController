//
//  ASMCropImageViewController.m
//  ASMCropViewController
//
//  Created by The Molloys on 8/22/13.
//  Copyright (c) 2013 Andy Molloy. All rights reserved.
//

#import "ASMCropImageViewController.h"
#import "ASMImageCropView.h"

@interface ASMCropImageViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView* scrollView;
@property (strong, nonatomic) ASMImageCropView* imageView;
@end

@implementation ASMCropImageViewController

- (void)viewDidLoad
{
	self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	self.scrollView.delegate = self;
	[self.view addSubview:self.scrollView];
	
	self.imageView = [[ASMImageCropView alloc] initWithFrame:self.scrollView.bounds];
	[self.scrollView addSubview:self.imageView];
	
	[self setupImageView];
}

- (void)setupImageView
{
	[self.imageView setImage:self.image];
	[self.imageView sizeToFit];

	self.scrollView.contentSize = self.imageView.frame.size;
	
	CGFloat zoomScale = MIN(CGRectGetWidth(self.scrollView.frame) / self.scrollView.contentSize.width,
							CGRectGetHeight(self.scrollView.frame) / self.scrollView.contentSize.height);
	
	self.scrollView.minimumZoomScale = zoomScale;
	self.scrollView.zoomScale = zoomScale;
}

- (void)setImage:(UIImage *)image
{
	_image = image;
	[self setupImageView];
}

#pragma mark Scroll View Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	CGFloat offsetX = 0.0f;
	if ( scrollView.bounds.size.width > scrollView.contentSize.width )
	{
		offsetX = (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5f;
	}

	CGFloat offsetY = 0.0f;
	if ( scrollView.bounds.size.height > scrollView.contentSize.height )
	{
		offsetY = (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5f;
	}

    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5f + offsetX,
										scrollView.contentSize.height * 0.5f + offsetY);
}

@end
