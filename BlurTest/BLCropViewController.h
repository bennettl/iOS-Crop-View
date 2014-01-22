//
//  ViewController.h
//  BlurTest
//
//  Created by jbauer on 12/19/13.
//  Copyright (c) 2013 Tapiture. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCropViewController : UIViewController

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;

@end
