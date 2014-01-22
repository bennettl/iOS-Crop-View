//
//  BlurView.m
//  BlurTest
//
//  Created by Bennett Lee on 1/17/13.
//  Copyright (c) 2013 Tapiture. All rights reserved.
//

#import "BLBlurView.h"

@implementation BLBlurView

@synthesize blurImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.blurImageView = [[UIImageView alloc] initWithFrame:frame];
        self.blurImageView.layer.borderColor = [UIColor greenColor].CGColor;
        self.blurImageView.layer.borderWidth = 10.0f;
        [self addSubview:self.blurImageView];
        [self.blurImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    self.blurImageView  = [[UIImageView alloc] initWithImage:image];
    self                = [super initWithFrame:self.blurImageView.frame];
    
    if (self) {
        [self addSubview:self.blurImageView];
      //  [self.blurImageView setContentMode:UIViewContentModeCenter];
    }
    return self;
}

// Custom setter. Creates a blured version of image
-(void) setImage:(UIImage *) image
{
    CIImage *inputImage     = [[CIImage alloc] initWithImage:image] ;
    CIFilter *blurFilter    = [CIFilter filterWithName:@"CISepiaTone"] ;
//    CIGaussianBlur
    [blurFilter setDefaults];
    
    [blurFilter setValue:inputImage forKey:@"inputImage"] ;
//     [blurFilter setValue:[NSNumber numberWithFloat:0.2f] forKey:@"inputintensity"];
//    [blurFilter setValue: [NSNumber numberWithFloat:4.0f] forKey:@"inputRadius"];
    
    CIImage *outputImage    = [blurFilter valueForKey: @"outputImage"];
    CIContext *context      = [CIContext contextWithOptions:nil];
    UIImage *blurred        = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]];
    self.blurImageView.image = blurred;
}

@end
