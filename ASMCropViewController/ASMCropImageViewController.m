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

@property (strong, nonatomic) UIImageView* imageView;
@property (strong, nonatomic) ASMImageCropView* cropView;
@end

@implementation ASMCropImageViewController

- (void)setAspectRatio:(CGSize)aspectRatio
{
	_aspectRatio = aspectRatio;
	self.cropView.aspectRatio = aspectRatio;
}

- (void)viewDidLoad
{
	self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	self.scrollView.delegate = self;
	[self.view addSubview:self.scrollView];
	
	self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
	[self.scrollView addSubview:self.imageView];

	self.cropView = [[ASMImageCropView alloc] initWithFrame:self.scrollView.bounds];
	[self.view addSubview:self.cropView];
	self.cropView.aspectRatio = self.aspectRatio;
	
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
	self.cropView.imageSize = self.image.size;
	self.cropView.zoomScale = self.scrollView.zoomScale;
}

- (void)setImage:(UIImage *)image
{
	_image = image;
	[self setupImageView];
}

- (CGSize)offsetForScrollView:(UIScrollView*)scrollView
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
	
	return CGSizeMake(offsetX, offsetY);
}

- (UIImage*)croppedImage
{
	CGImageRef subImage = CGImageCreateWithImageInRect(self.image.CGImage,
													   self.cropView.cropFrame);
	UIImage* croppedImage = [UIImage imageWithCGImage:subImage];
	CGImageRelease(subImage);
	
	return croppedImage;
}

#pragma mark Scroll View Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	CGSize offset = [self offsetForScrollView:scrollView];
	
	self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5f + offset.width,
										scrollView.contentSize.height * 0.5f + offset.height);

	
	self.cropView.zoomScale = scrollView.zoomScale;
	self.cropView.offset = CGSizeMake(offset.width - self.scrollView.contentOffset.x,
									  offset.height - self.scrollView.contentOffset.y);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGSize offset = [self offsetForScrollView:scrollView];
	self.cropView.offset = CGSizeMake(offset.width - self.scrollView.contentOffset.x,
									  offset.height - self.scrollView.contentOffset.y);
}

@end
