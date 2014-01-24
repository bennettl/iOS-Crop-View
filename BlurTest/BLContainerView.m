//
//  BLContainerView.m
//  BlurTest
//
//  Created by Bennett Lee on 1/23/14.
//  Copyright (c) 2014 Tapiture. All rights reserved.
//

#import "BLContainerView.h"

@implementation BLContainerView

- (id)initWithImage:(UIImage *)image{
    
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        
        // Create children and reposition them  to center
        self.blurView   = [[BLBlurView alloc] initWithImage:image];
        self.imageView  = [[BLImageView alloc] initWithImage:image];
        [self addSubview:self.blurView];
        [self addSubview:self.imageView];
    }
    return self;
}

@end
