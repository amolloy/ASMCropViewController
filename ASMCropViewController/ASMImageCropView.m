//
//  ASMImageCropView.m
//  ASMCropViewController
//
//  Created by The Molloys on 8/22/13.
//  Copyright (c) 2013 Andy Molloy. All rights reserved.
//

#import "ASMImageCropView.h"

@interface ASMImageCropView ()
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
	}
	return self;
}

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView == self)
	{
		// TODO Look for hits on the cropping frame edit handles
		return nil;
    }
    else
	{
        return hitView;
    }
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

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);

	CGAffineTransform cropBoxTransform = CGAffineTransformMake(self.zoomScale,
															   0,
															   0,
															   self.zoomScale,
															   self.offset.width,
															   self.offset.height);

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

		CGPathMoveToPoint(cornerPath,
						  &cropBoxTransform,
						  CGRectGetMinX(self.cropFrame) + handleOffset,
						  CGRectGetMinY(self.cropFrame) + handleOffset + handleSize);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMinX(self.cropFrame) + handleOffset,
							 CGRectGetMinY(self.cropFrame) + handleOffset);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMinX(self.cropFrame) + handleOffset + handleSize,
							 CGRectGetMinY(self.cropFrame) + handleOffset);

		CGPathMoveToPoint(cornerPath,
						  &cropBoxTransform,
						  CGRectGetMaxX(self.cropFrame) - handleOffset,
						  CGRectGetMinY(self.cropFrame) + handleOffset + handleSize);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMaxX(self.cropFrame) - handleOffset,
							 CGRectGetMinY(self.cropFrame) + handleOffset);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMaxX(self.cropFrame) - handleOffset - handleSize,
							 CGRectGetMinY(self.cropFrame) + handleOffset);

		CGPathMoveToPoint(cornerPath,
						  &cropBoxTransform,
						  CGRectGetMinX(self.cropFrame) + handleOffset,
						  CGRectGetMaxY(self.cropFrame) - handleOffset - handleSize);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMinX(self.cropFrame) + handleOffset,
							 CGRectGetMaxY(self.cropFrame) - handleOffset);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMinX(self.cropFrame) + handleOffset + handleSize,
							 CGRectGetMaxY(self.cropFrame) - handleOffset);
		
		CGPathMoveToPoint(cornerPath,
						  &cropBoxTransform,
						  CGRectGetMaxX(self.cropFrame) - handleOffset,
						  CGRectGetMaxY(self.cropFrame) - handleOffset - handleSize);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMaxX(self.cropFrame) - handleOffset,
							 CGRectGetMaxY(self.cropFrame) - handleOffset);
		CGPathAddLineToPoint(cornerPath,
							 &cropBoxTransform,
							 CGRectGetMaxX(self.cropFrame) - handleOffset - handleSize,
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
