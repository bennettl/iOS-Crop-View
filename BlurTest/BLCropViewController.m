//
//  ViewController.m
//  BlurTest
//
//  Created by jbauer on 12/19/13.
//  Copyright (c) 2013 Tapiture. All rights reserved.
//

#import "BLCropViewController.h"
#import "BLBlurView.h"
#import "BLCropView.h"
#import <QuartzCore/QuartzCore.h>

#define IMAGE_NAME @"portrait"
#define CROP_VIEW_WIDTH 100
#define CROP_VIEW_HEIGHT 100

@interface BLCropViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) BLCropView *cropView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) BLBlurView *blurView;

@end

@implementation BLCropViewController

- (void)viewDidLoad
{
//    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Sibings
    [self setupCropView];
    [self setupScrollView];
    [self adjustContainerView];
    [self adjustImageViewMaskLayer];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self centerScrollView];
}

#pragma mark Setup Views

- (void)setupScrollView{
    UIImage *image = [UIImage imageNamed:IMAGE_NAME];
    [self setupContainerViewWithImage:image]; // Child
    [self addGestureRecgonizers];
    [self setZoomScales];
}

// Note, this changes the width/height of containerView
- (void)setZoomScales{
    self.scrollView.contentSize         = self.imageView.frame.size;
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
    CGSize size = [[UIScreen mainScreen] bounds].size;     // Screen bounds
    // Configure size of cropview as you like
    self.cropView = [[BLCropView alloc] initWithFrame:CGRectMake(0,0,
                                                             size.width / 2.0f,
                                                             size.height / 2.0f)];
    NSLog(@"WIDTH: %f, %f", size.width/2.0f, size.height/2.0f);
    self.cropView.backgroundColor       = [UIColor clearColor];
    self.cropView.layer.borderWidth     = 1.0f;
    self.cropView.layer.borderColor     = [UIColor blackColor].CGColor;
    self.cropView.layer.cornerRadius    = 6.0f;
    self.cropView.center                = self.view.center;
    // Forward scroll events to scrollView
    self.cropView.scrollView            = self.scrollView;
    [self.view addSubview:self.cropView]; // view (parent of) scrollView
//    NSLog(@"crop view %@", NSStringFromCGRect(self.cropView.frame));
}

// Childen of scrollView
- (void)setupContainerViewWithImage:(UIImage *)image{
    // Create a containerView (UIView) with image size/width
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    // Setup children
    [self setupBlurViewWithImage:image];
    [self setupImageViewWithImage:image];
    
    [self.scrollView addSubview:self.containerView]; // scrollView (parent of) containerView
//    NSLog(@"container view %@", NSStringFromCGRect(self.containerView.frame));
}

// Child of container view
- (void)setupImageViewWithImage:(UIImage *)image{
    // Create imageView (UIView) and set it's image to the same image as blurView
    self.imageView                      = [[UIImageView alloc] initWithImage:image];
    [self.imageView setImage:image];
    self.imageView.center               = self.containerView.center;
    [self.containerView addSubview:self.imageView]; // containerView (parent of) imageView
//    NSLog(@"image view %@", NSStringFromCGRect(self.imageView.frame));
}

// Child of container view
- (void)setupBlurViewWithImage:(UIImage *)image{
    // Create blurView (UIView) and set it's image
    self.blurView                       = [[BLBlurView alloc] initWithImage:image];
    [self.blurView setImage:image];
    self.blurView.center                = self.containerView.center;
    [self.containerView addSubview:self.blurView]; // containerView (parent of) blurView
//    NSLog(@"blur view %@", NSStringFromCGRect(self.blurView.frame));
}

#pragma mark Adjustments

- (void)centerScrollView{
    CGFloat zoomScale           = self.scrollView.zoomScale;
    CGSize boundsSize           = self.scrollView.bounds.size;
    CGRect scaledBlurViewRect   = CGRectMake(self.blurView.frame.origin.x * zoomScale,
                                             self.blurView.frame.origin.y * zoomScale,
                                             self.blurView.frame.size.width * zoomScale,
                                             self.blurView.frame.size.height * zoomScale);
    CGPoint contentOffset       = CGPointZero;
    
    if (scaledBlurViewRect.size.width < boundsSize.width) {
        // Height of image + half of the difference between blur and cropview
        contentOffset.x    = scaledBlurViewRect.size.width;
        contentOffset.x   += (CGRectGetWidth(self.cropView.frame) - scaledBlurViewRect.size.width)/2.0f;
    } else {
        contentOffset.x = scaledBlurViewRect.origin.x;
    }
    
    if (scaledBlurViewRect.size.height < boundsSize.height) {
        // Height of image + half of the difference between blur and cropview
        contentOffset.y   = scaledBlurViewRect.size.height ;
        contentOffset.y   += (CGRectGetHeight(self.cropView.frame) - scaledBlurViewRect.size.height)/2.0f;
    } else {
        contentOffset.y = scaledBlurViewRect.origin.y;
    }

    self.scrollView.contentOffset = contentOffset;
}

// Center scroll view contents
- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.containerView.frame;
    
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

// Adjust the containerView size base whenever the zoomScale changes to make sure there is appropriate padding surrounding
- (void)adjustContainerView{
    float scaleFactor               =  1/self.scrollView.zoomScale;
    
    float scaledCropViewWidth       = scaleFactor * CGRectGetMaxX(self.cropView.frame);
    float scaledCropViewHeight      = scaleFactor * CGRectGetMaxY(self.cropView.frame);
    float imageWidth                = self.blurView.blurImageView.frame.size.width ;
    float imageHeight               = self.blurView.blurImageView.frame.size.height;
    
    float widthPadding =  2 * scaledCropViewWidth ;
    float heightPadding =  2* scaledCropViewHeight ;
    
    // Reset container view frame and make sure imageView/blurView realigns with the new center
    CGRect rect                                 = CGRectMake(0, 0,
                                                             imageWidth + widthPadding,
                                                             imageHeight + heightPadding);
    CGSize inset                                = CGSizeMake(widthPadding/2 , heightPadding/2);
    
    self.containerView.frame                    = rect;
    self.blurView.frame                         = CGRectInset(rect, inset.width, inset.height); // shrink by inset
    self.blurView.blurImageView.frame           = CGRectMake(0, 0, self.blurView.frame.size.width, self.blurView.frame.size.height);
    self.blurView.backgroundColor               = [UIColor brownColor];
    self.blurView.blurImageView.backgroundColor = [UIColor greenColor];
    
    // aligns the imageView with blurView
    self.imageView.frame = CGRectInset(rect, inset.width, inset.height);
    
    // Update scrollView content size
    self.scrollView.contentSize = CGSizeMake(self.containerView.frame.size.width/scaleFactor, self.containerView.frame.size.height/scaleFactor);
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
    maskLayer.frame = CGRectOffset(maskLayer.frame, -self.imageView.frame.origin.x , -self.imageView.frame.origin.y);
    // Shift the mask to the lower right by contentOffset and cropView offset
    maskLayer.frame = CGRectOffset(maskLayer.frame, scaledXOffset + scaledCropViewX ,scaledYOffset + scaledCropViewY);
    
    self.imageView.layer.mask = maskLayer;
}

#pragma mark UIScrollViewDelegate

// Every time the user scrolls, adjust image mask position
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [CATransaction setDisableActions:YES];
    [self adjustImageViewMaskLayer];
   // [self adjustContainerView];
}

// Return the view that you want to zoom
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.containerView;
}

// The scroll view has zoomed, so you need to re-center the contents
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self adjustContainerView];
    [self centerScrollViewContents];
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
    CGPoint pointInView = [recognizer locationInView:self.containerView];
    
    // 2
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // 3
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

// Zoom out when user two finger taps
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

@end
