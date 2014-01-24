//
//  BLScrollView.h
//  BlurTest
//
//  Created by Bennett Lee on 1/22/14.
//  Copyright (c) 2014 Tapiture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLContainerView.h"

@interface BLScrollView : UIScrollView

@property (nonatomic,strong) BLContainerView *containerView;

- (id)initWithImage:(UIImage *)image;

@end
