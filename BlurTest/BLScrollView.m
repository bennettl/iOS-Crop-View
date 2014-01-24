//
//  BLScrollView.m
//  BlurTest
//
//  Created by Bennett Lee on 1/22/14.
//  Copyright (c) 2014 Tapiture. All rights reserved.
//

#import "BLScrollView.h"
@interface BLScrollView()
@end

@implementation BLScrollView

- (id)initWithImage:(UIImage *)image{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 568)];
    if (self) {
        self.bounces            = NO;
        self.decelerationRate   = 0.2f;
        self.containerView      = [[BLContainerView alloc] initWithImage:image];
        self.contentSize = self.containerView.frame.size;
        [self addSubview:self.containerView];
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    // Disable existing recognizer
    for (UIGestureRecognizer* recognizer in [self gestureRecognizers]) {
        if ([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
       //   [recognizer setEnabled:NO];
        }
    }
}
@end
