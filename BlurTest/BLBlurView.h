//
//  BlurView.h
//  BlurTest
//
//  Created by Bennett Lee on 1/17/13.
//  Copyright (c) 2013 Tapiture. All rights reserved.

#import <UIKit/UIKit.h>

@interface BLBlurView : UIView
{
    UIImageView *blurImageView;
    
}

@property (nonatomic, strong) UIImageView *blurImageView;

-(void) setImage:(UIImage *) image;
- (id)initWithImage:(UIImage *)image;

@end
