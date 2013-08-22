//
//  ASMImageCropView.m
//  ASMCropViewController
//
//  Created by The Molloys on 8/22/13.
//  Copyright (c) 2013 Andy Molloy. All rights reserved.
//

#import "ASMImageCropView.h"

static const NSInteger sHandleTolerance = 22;

@interface ASMImageCropView ()
@property (assign, nonatomic) BOOL draggingTop;
@property (assign, nonatomic) BOOL draggingBottom;
@property (assign, nonatomic) BOOL draggingLeft;
@property (assign, nonatomic) BOOL draggingRight;
@property (assign, nonatomic) BOOL draggingFrame;
@property (assign, nonatomic) CGRect initialCropFrame;
@end

@implementation ASMImageCropView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		self.backgroundColor = [UIColor clearColor];
		self.cropFrame = CGRectZero;
		self.cropFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		// For testing
		self.cropFrame = CGRectInset(self.cropFrame, 100, 100);
		
		UIPanGestureRecognizer* gr = [[UIPanGestureRecognizer alloc] initWithTarget:self
																			 action:@selector(didPan:)];
		[self addGestureRecognizer:gr];
	}
	return self;
}

- (void)didPan:(UIGestureRecognizer*)gr
{
	if ((UIGestureRecognizerStateCancelled == gr.state ||
			  UIGestureRecognizerStateEnded == gr.state ||
			  UIGestureRecognizerStateFailed == gr.state))
	{
		self.draggingTop = NO;
		self.draggingBottom = NO;
		self.draggingRight = NO;
		self.draggingLeft = NO;
		self.draggingFrame = NO;
	}
	else
	{
		CGPoint offset = [(UIPanGestureRecognizer*)gr translationInView:self];
		
		CGAffineTransform cropBoxTransform = [self cropBoxTransform];
		CGRect transformedBox = CGRectApplyAffineTransform(self.initialCropFrame, cropBoxTransform);
		
		if (self.draggingFrame)
		{
			transformedBox = CGRectOffset(transformedBox, offset.x, offset.y);

			transformedBox = CGRectApplyAffineTransform(transformedBox, CGAffineTransformInvert(cropBoxTransform));
			transformedBox = CGRectStandardize(transformedBox);
			
			if (CGRectGetMinX(transformedBox) < 0)
			{
				transformedBox.origin.x = 0;
			}
			if (CGRectGetMaxX(transformedBox) > self.imageSize.width)
			{
				transformedBox.origin.x = self.imageSize.width - CGRectGetWidth(transformedBox);
			}
			if (CGRectGetMinY(transformedBox) < 0)
			{
				transformedBox.origin.y = 0;
			}
			if (CGRectGetMaxY(transformedBox) > self.imageSize.height)
			{
				transformedBox.origin.y = self.imageSize.height - CGRectGetHeight(transformedBox);
			}
		}
		else
		{
			UIEdgeInsets insets = UIEdgeInsetsZero;

			if (self.draggingTop)
			{
				insets.top = offset.y;
			}
			else if (self.draggingBottom)
			{
				insets.bottom = -offset.y;
			}
			
			if (self.draggingLeft)
			{
				insets.left = offset.x;
			}
			else if (self.draggingRight)
			{
				insets.right = -offset.x;
			}
			
			transformedBox = UIEdgeInsetsInsetRect(transformedBox, insets);
			transformedBox = CGRectApplyAffineTransform(transformedBox, CGAffineTransformInvert(cropBoxTransform));
			
			insets = UIEdgeInsetsZero;
			
			if (CGRectGetMinX(transformedBox) < 0)
			{
				insets.left = -CGRectGetMinX(transformedBox);
			}
			if (CGRectGetMaxX(transformedBox) > self.imageSize.width)
			{
				insets.right = CGRectGetMaxX(transformedBox) - self.imageSize.width;
			}
			if (CGRectGetMinY(transformedBox) < 0)
			{
				insets.top = -CGRectGetMinY(transformedBox);
			}
			if (CGRectGetMaxY(transformedBox) > self.imageSize.height)
			{
				insets.bottom = CGRectGetMaxY(transformedBox) - self.imageSize.height;
			}
			
			transformedBox = UIEdgeInsetsInsetRect(transformedBox, insets);
		}
		
		self.cropFrame = transformedBox;
	}

	[self setNeedsDisplay];
}

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView == self)
	{
		hitView = nil;
		
		CGAffineTransform cropBoxTransform = [self cropBoxTransform];
		CGRect transformedBox = CGRectApplyAffineTransform(self.cropFrame, cropBoxTransform);
		
		CGRect outerBox = CGRectInset(transformedBox, -sHandleTolerance / 2, -sHandleTolerance / 2);
		
		if (CGRectContainsPoint(outerBox, point))
		{
			self.initialCropFrame = self.cropFrame;
			
			CGRect innerBox = CGRectInset(transformedBox, sHandleTolerance / 2, sHandleTolerance / 2);
			
			if (!CGRectContainsPoint(innerBox, point))
			{
				if (fabsf(point.y - CGRectGetMinY(transformedBox)) < sHandleTolerance)
				{
					self.draggingTop = YES;
				}
				else if (fabsf(point.y - CGRectGetMaxY(transformedBox)) < sHandleTolerance)
				{
					self.draggingBottom = YES;
				}
				
				if (fabsf(point.x - CGRectGetMaxX(transformedBox)) < sHandleTolerance)
				{
					self.draggingRight = YES;
				}
				else if (fabsf(point.x - CGRectGetMinX(transformedBox)) < sHandleTolerance)
				{
					self.draggingLeft = YES;
				}
				
				hitView = self;
			}
			else
			{
				UIEdgeInsets insets = UIEdgeInsetsMake(CGRectGetHeight(outerBox) / 3,
													   CGRectGetWidth(outerBox) / 3,
													   CGRectGetHeight(outerBox) / 3,
													   CGRectGetWidth(outerBox) / 3);
				CGRect dragBox = UIEdgeInsetsInsetRect(outerBox, insets);
				
				if (CGRectContainsPoint(dragBox, point))
				{
					self.draggingFrame = YES;
					hitView = self;
				}
			}
		}
    }

	return hitView;
}

- (void)setZoomScale:(CGFloat)zoomScale
{
	_zoomScale = zoomScale;
	[self setNeedsDisplay];
}

- (void)setOffset:(CGSize)offset
{
	_offset = offset;
	[self setNeedsDisplay];
}

- (CGAffineTransform)cropBoxTransform
{
	CGAffineTransform cropBoxTransform = CGAffineTransformMake(self.zoomScale,
															   0,
															   0,
															   self.zoomScale,
															   self.offset.width,
															   self.offset.height);
	return cropBoxTransform;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);

	CGAffineTransform cropBoxTransform = [self cropBoxTransform];

	// Darken the outside of the crop box
	{
		CGMutablePathRef cropBoxPath = CGPathCreateMutable();
		CGPathAddRect(cropBoxPath, NULL, self.bounds);
		CGPathAddRect(cropBoxPath, &cropBoxTransform, self.cropFrame);
		CGContextAddPath(ctx, cropBoxPath);
		CGPathRelease(cropBoxPath);
		CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:0.75f].CGColor);
		CGContextEOFillPath(ctx);
	}

	CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);

	CGFloat outlineStrokeWidth = 2;
	
	// Draw the outline of the crop box
	{
		CGMutablePathRef cropBoxPath = CGPathCreateMutable();
		CGPathAddRect(cropBoxPath, &cropBoxTransform, self.cropFrame);
		CGContextAddPath(ctx, cropBoxPath);
		CGPathRelease(cropBoxPath);
		CGContextSetLineWidth(ctx, outlineStrokeWidth);
		CGContextStrokePath(ctx);
	}
	
	// Draw the corner handles
	{
		CGFloat handleOffset = outlineStrokeWidth / self.zoomScale;
		
		CGMutablePathRef cornerPath = CGPathCreateMutable();
		const NSInteger handleSize = 20 / self.zoomScale;

		NSInteger horizHandleSize = MIN(handleSize, CGRectGetWidth(self.cropFrame));
		NSInteger vertHandleSize = MIN(handleSize, CGRectGetHeight(self.cropFrame));
		
		CGPathMoveToPoint(cornerPath,
						  &cropBoxTransform,
						  CGRectGetMinX(self.cropFrame) + handleOffset,
						  CGRectGetMinY(self.cropFrame) + handleOffset + vertHandleSize);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMinX(self.cropFrame) + handleOffset,
							 CGRectGetMinY(self.cropFrame) + handleOffset);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMinX(self.cropFrame) + handleOffset + horizHandleSize,
							 CGRectGetMinY(self.cropFrame) + handleOffset);

		CGPathMoveToPoint(cornerPath,
						  &cropBoxTransform,
						  CGRectGetMaxX(self.cropFrame) - handleOffset,
						  CGRectGetMinY(self.cropFrame) + handleOffset + vertHandleSize);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMaxX(self.cropFrame) - handleOffset,
							 CGRectGetMinY(self.cropFrame) + handleOffset);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMaxX(self.cropFrame) - handleOffset - horizHandleSize,
							 CGRectGetMinY(self.cropFrame) + handleOffset);

		CGPathMoveToPoint(cornerPath,
						  &cropBoxTransform,
						  CGRectGetMinX(self.cropFrame) + handleOffset,
						  CGRectGetMaxY(self.cropFrame) - handleOffset - vertHandleSize);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMinX(self.cropFrame) + handleOffset,
							 CGRectGetMaxY(self.cropFrame) - handleOffset);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMinX(self.cropFrame) + handleOffset + horizHandleSize,
							 CGRectGetMaxY(self.cropFrame) - handleOffset);
		
		CGPathMoveToPoint(cornerPath,
						  &cropBoxTransform,
						  CGRectGetMaxX(self.cropFrame) - handleOffset,
						  CGRectGetMaxY(self.cropFrame) - handleOffset - vertHandleSize);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMaxX(self.cropFrame) - handleOffset,
							 CGRectGetMaxY(self.cropFrame) - handleOffset);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMaxX(self.cropFrame) - handleOffset - horizHandleSize,
							 CGRectGetMaxY(self.cropFrame) - handleOffset);
		
		CGContextAddPath(ctx, cornerPath);
		CGPathRelease(cornerPath);
		CGContextSetLineWidth(ctx, 4);
		CGContextStrokePath(ctx);
	}
	
	// Draw the grid
	{
		CGMutablePathRef gridPath = CGPathCreateMutable();

		CGFloat oneThirdHeight = CGRectGetHeight(self.cropFrame) / 3;
		
		CGPathMoveToPoint(gridPath,
						  &cropBoxTransform,
						  CGRectGetMinX(self.cropFrame),
						  CGRectGetMinY(self.cropFrame) + oneThirdHeight);
		CGPathAddLineToPoint(gridPath,
							 &cropBoxTransform,
							 CGRectGetMaxX(self.cropFrame),
							 CGRectGetMinY(self.cropFrame) + oneThirdHeight);

		CGPathMoveToPoint(gridPath,
						  &cropBoxTransform,
						  CGRectGetMinX(self.cropFrame),
						  CGRectGetMinY(self.cropFrame) + oneThirdHeight * 2);
		CGPathAddLineToPoint(gridPath,
							 &cropBoxTransform,
							 CGRectGetMaxX(self.cropFrame),
							 CGRectGetMinY(self.cropFrame) + oneThirdHeight * 2);

		CGFloat oneThirdWidth = CGRectGetWidth(self.cropFrame) / 3;
		
		CGPathMoveToPoint(gridPath,
						  &cropBoxTransform,
						  CGRectGetMinX(self.cropFrame) + oneThirdWidth,
						  CGRectGetMinY(self.cropFrame));
		CGPathAddLineToPoint(gridPath,
							 &cropBoxTransform,
							 CGRectGetMinX(self.cropFrame) + oneThirdWidth,
							 CGRectGetMaxY(self.cropFrame));
		
		CGPathMoveToPoint(gridPath,
						  &cropBoxTransform,
						  CGRectGetMinX(self.cropFrame) + oneThirdWidth * 2,
						  CGRectGetMinY(self.cropFrame));
		CGPathAddLineToPoint(gridPath,
							 &cropBoxTransform,
							 CGRectGetMinX(self.cropFrame) + oneThirdWidth * 2,
							 CGRectGetMaxY(self.cropFrame));
		
		CGContextAddPath(ctx, gridPath);
		CGPathRelease(gridPath);
		CGContextSetLineWidth(ctx, outlineStrokeWidth / 2);
		CGContextStrokePath(ctx);
	}

	CGContextRestoreGState(ctx);
}

@end
