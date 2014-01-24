//
//  ViewController.m
//  BlurTest
//
//  Created by jbauer on 12/19/13.
//  Copyright (c) 2013 Tapiture. All rights reserved.
//

#import "BLCropViewController.h"
#import "BLScrollView.h"
#import "BLBlurView.h"
#import "BLCropView.h"
#import "BLContainerView.h"

#import <QuartzCore/QuartzCore.h>

//#define IMAGE_NAME @"portrait"
#define IMAGE_NAME @"landscape"
#define CROP_VIEW_WIDTH 240/2
#define CROP_VIEW_HEIGHT 382/2

@interface BLCropViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) BLCropView *cropView;
@property (strong, nonatomic) BLScrollView *scrollView;
@property (strong, nonatomic) UIImage *image;

@property CGPoint offsetPercentage;
@property CGSize prevSize;
@end

@implementation BLCropViewController

- (void)viewDidLoad
{
//    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Sibings
    [self setupScrollView];
    [self setupCropView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setZoomScales];
    CGSize padding                    = CGSizeMake(CGRectGetMaxX(self.cropView.frame), CGRectGetMaxY(self.cropView.frame));
    self.scrollView.contentInset      = UIEdgeInsetsMake(padding.height, padding.width, padding.height, padding.width);
    self.scrollView.contentSize        = self.scrollView.containerView.frame.size;
    [self adjustImageViewMaskLayer];
    [self centerScrollView];
    
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
   //[self.view addGestureRecognizer:pinchGesture];
    
}



-(void)handlePinch:(UIPinchGestureRecognizer*)pinch {
    UIView *view = self.scrollView.containerView; //pinch.view.

    // Cropfield center (0,0) means top left, acounts for increase image sie
    CGPoint cropCenter = CGPointMake(self.scrollView.contentOffset.x + self.cropView.center.x,
                                     self.scrollView.contentOffset.y + self.cropView.center.y);
    
    CGPoint anchorPoint = CGPointMake(MAX(cropCenter.x/self.scrollView.containerView.frame.size.width,0),
                                      MAX(cropCenter.y/self.scrollView.containerView.frame.size.height,0));
    
    // 0.5, 0.5
    CGPoint apb = CGPointMake(self.scrollView.containerView.layer.anchorPoint.x,
                              self.scrollView.containerView.layer.anchorPoint.y);
    
    
    self.scrollView.containerView.layer.anchorPoint = CGPointMake(1, 1);
    // 0 ,0
    CGPoint apa = CGPointMake(self.scrollView.containerView.layer.anchorPoint.x,
                              self.scrollView.containerView.layer.anchorPoint.y);
   // NSLog(@"anchor point %@", NSStringFromCGPoint(anchorPoint));
    
    view.frame = CGRectOffset(view.frame,
                              view.frame.size.width * (apa.x- apb.x),
                               view.frame.size.height * (apa.y- apb.y));
    
    self.scrollView.contentSize = view.frame.size;
    view.transform = CGAffineTransformScale(view.transform, pinch.scale, pinch.scale);
    
    [view sizeToFit];
    self.scrollView.contentSize = view.frame.size;
   

    pinch.scale = 1;
    
    
}

#pragma mark Setup Views

- (void)setupScrollView{
    // Init with image and padding
    self.image      = [UIImage imageNamed:IMAGE_NAME];
    self.scrollView = [[BLScrollView alloc] initWithImage:self.image];
    
    [self addGestureRecgonizers];
    
    self.scrollView.delegate = self;
   // self.scrollView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:self.scrollView];

}

// Note, this changes the width/height of containerView
- (void)setZoomScales{
    self.scrollView.contentSize         = self.scrollView.containerView.imageView.frame.size;
    CGRect scrollViewFrame              = self.scrollView.frame;
    CGFloat scaleWidth                  = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight                 = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale                    = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale   = 0.0006f;
    self.scrollView.maximumZoomScale   = 60.0f;
    self.scrollView.zoomScale          = minScale;
    [self centerScrollViewContents];
}

// Center white box
- (void)setupCropView{
    // Configure size of cropview as you like
    self.cropView = [[BLCropView alloc] initWithFrame:CGRectMake(0,0,
                                                            CROP_VIEW_WIDTH,
                                                            CROP_VIEW_HEIGHT)];
    self.cropView.backgroundColor       = [UIColor clearColor];
    self.cropView.layer.borderWidth     = 1.0f;
    self.cropView.layer.borderColor     = [UIColor blackColor].CGColor;
    self.cropView.layer.cornerRadius    = 6.0f;
    self.cropView.center                = self.view.center;
    // Forward scroll events to scrollView
    [self.view addSubview:self.cropView]; // view (parent of) scrollView
//    NSLog(@"crop view %@", NSStringFromCGRect(self.cropView.frame));
}


#pragma mark Adjustments

// Initially when the site inits, scroll view will be centered
- (void)centerScrollView{
    CGSize boundsSize               = self.scrollView.bounds.size;
    CGRect blurViewRect             = self.scrollView.containerView.blurView.frame;
    CGPoint contentOffset           = CGPointZero;
    

    if (blurViewRect.size.width * self.scrollView.zoomScale < boundsSize.width) {
        // Height of image + half of the difference between blur and cropview
       contentOffset.x     =  (boundsSize.width - (blurViewRect.size.width * self.scrollView.zoomScale))/2.0f;
       contentOffset.x     *= -1;

    } else {
        // Offset zoomed by pushing scrollView to top left
        contentOffset.x = blurViewRect.origin.x;
    }
    
    if (blurViewRect.size.height * self.scrollView.zoomScale  < boundsSize.height) {
        // Height of image + half of the difference between blur and cropview
        contentOffset.y     =  (boundsSize.height - (blurViewRect.size.height * self.scrollView.zoomScale))/2.0f;
        contentOffset.y     *= -1;

    } else {
        contentOffset.y = blurViewRect.origin.y;
    }

    self.scrollView.contentOffset = contentOffset;
    NSLog(@"%@", NSStringFromCGPoint(self.scrollView.contentOffset));
}

// Center scroll view contents
- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.scrollView.containerView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
}


// Adjust imageView layer mask to the same rect of the cropView everytime user scrolls
- (void)adjustImageViewMaskLayer{
    // Note: Everything needs to be converted to the containerView coordinates because that is where we are drawing the mask layer
    // When containerView is zoom out, there are actually more points packed into a smaller space. scaleFactor will convert that small space into how many points are in containerView
    
    // Scale factor will make the points beweteen cropView, scrollView to containerView coordinates
    float scaleFactor               =  1/self.scrollView.zoomScale;
    // Convert the cropViews size to containerView Coordiates
    float scaledWidth               = scaleFactor * self.cropView.frame.size.width;
    float scaledHeight              = scaleFactor * self.cropView.frame.size.height;
    
    // New masklayer
    CALayer *maskLayer              = [CALayer layer];
    maskLayer.frame                 = CGRectMake(0, 0, scaledWidth, scaledHeight);
    maskLayer.cornerRadius          = self.cropView.layer.cornerRadius;
    maskLayer.backgroundColor       = [UIColor blackColor].CGColor;
    
    // Content offset
    // Convert the scrollView offset to containerView Coordinaates
    float scaledXOffset             = scaleFactor * self.scrollView.contentOffset.x;
    float scaledYOffset             = scaleFactor * self.scrollView.contentOffset.y;
    // Convert the cropView offset to containerView Coordinaates
    float scaledCropViewX           = scaleFactor * CGRectGetMinX(self.cropView.frame);
    float scaledCropViewY           = scaleFactor * CGRectGetMinY(self.cropView.frame);
    
    // Position mask it to top left origion (0,0) relative to containreView
    maskLayer.frame = CGRectOffset(maskLayer.frame, -self.scrollView.containerView.imageView.frame.origin.x , -self.scrollView.containerView.imageView.frame.origin.y);
    // Shift the mask to the lower right by contentOffset and cropView offset
    maskLayer.frame = CGRectOffset(maskLayer.frame, scaledXOffset + scaledCropViewX ,scaledYOffset + scaledCropViewY);
    
    self.scrollView.containerView.imageView.layer.mask = maskLayer;
}

#pragma mark UIScrollViewDelegate

// Every time the user scrolls, adjust image mask position
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [CATransaction setDisableActions:YES];
    [self adjustImageViewMaskLayer];
}

// Return the view that you want to zoom
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scrollView.containerView;
}

// The scroll view has zoomed, so you need to re-center the contents
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [CATransaction setDisableActions:YES];
    [self adjustImageViewMaskLayer];
}

#pragma mark Gestures

// Add double/two finger tap gesture recognizers
- (void)addGestureRecgonizers{
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
}

// Zoom in when user double taps
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // 1
    CGPoint pointInView = [recognizer locationInView:self.scrollView.containerView];
    
    // 2
    CGFloat newZoomScale    = self.scrollView.zoomScale * 1.5f;
    newZoomScale            = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // 3
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
    [self adjustImageViewMaskLayer];

}

// Zoom out when user two finger taps
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

@end
