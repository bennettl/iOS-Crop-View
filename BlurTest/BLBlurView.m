//
//  BlurView.m
//  BlurTest
//
//  Created by Bennett Lee on 1/17/13.
//  Copyright (c) 2013 Tapiture. All rights reserved.
//

#import "BLBlurView.h"


@implementation BLBlurView

// Child of container view
- (id)initWithImage:(UIImage *)image{
    self = [super initWithImage:image];

    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setContentMode:UIViewContentModeScaleAspectFill];
    }
    return self;
}



// Custom setter. Creates a blured version of image
-(void) setImage:(UIImage *) image{
    CIImage *inputImage     = [[CIImage alloc] initWithImage:image] ;
//       CIFilter *blurFilter    = [CIFilter filterWithName:@"CISepiaTone"] ;
    CIFilter *blurFilter    = [CIFilter filterWithName:@"CIGaussianBlur"] ;
    [blurFilter setDefaults];
    
    [blurFilter setValue:inputImage forKey:@"inputImage"] ;
    [blurFilter setValue: [NSNumber numberWithFloat:4.0f] forKey:@"inputRadius"];
    
    CIImage *outputImage    = [blurFilter valueForKey: @"outputImage"];
    CIContext *context      = [CIContext contextWithOptions:nil];
    struct CGImage *cgImage = [context createCGImage:outputImage fromRect:outputImage.extent];
    UIImage *blurred        = [UIImage imageWithCGImage:cgImage];
    [super setImage:blurred];
    CFRelease(cgImage);
}

@end
