//
//  CropView.m
//  BlurTest
//
//  Created by Bennett Lee on 1/17/14.
//  Copyright (c) 2014 Tapiture. All rights reserved.
//

#import "BLCropView.h"

@implementation BLCropView

@synthesize scrollView = _scrollView;

// Forward scroll events to scorllView
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return _scrollView;
    }
    return view;
}

@end
