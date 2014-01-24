//
//  BLContainerView.h
//  BlurTest
//
//  Created by Bennett Lee on 1/23/14.
//  Copyright (c) 2014 Tapiture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLBlurView.h"
#import "BLImageView.h"
@interface BLContainerView : UIView

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) BLImageView *imageView;
@property (strong, nonatomic) BLBlurView *blurView;

- (id)initWithImage:(UIImage *)image;

@end
