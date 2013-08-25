//
//  ASMImageCropView.h
//  ASMCropViewController
//
//  Created by The Molloys on 8/22/13.
//  Copyright (c) 2013 Andy Molloy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASMImageCropView : UIView

@property (assign, nonatomic) CGSize imageSize;
@property (assign, nonatomic) CGRect cropFrame;
@property (assign, nonatomic) CGFloat zoomScale;
@property (assign, nonatomic) CGSize offset;
@property (assign, nonatomic) CGSize aspectRatio;

@end
