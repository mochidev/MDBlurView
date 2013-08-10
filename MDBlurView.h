//
//  MDBlurView.h
//  MDBlurView
//
//  Created by Dimitri Bouniol on 7/25/13.
//  Copyright (c) 2013 Mochi Development, Inc. All rights reserved.
//
//  Copyright (c) 2013 Dimitri Bouniol, Mochi Development, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software, associated artwork, and documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  1. The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//  2. Neither the name of Mochi Development, Inc. nor the names of its
//     contributors or products may be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  Mochi Dev, and the Mochi Development logo are copyright Mochi Development, Inc.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MDBlurView : UIView {
@private
    UIView *bar;
    UIView *overlay;
    
    UIImageView *maskViewA;
    UIImageView *maskViewB;
    
    UIView *lastMaskView;
    UIView *lastOverlayMaskView;
    
    UIView *_maskView;
    UIView *_overlayMaskView;
    
    UIView *cachedBarBackground;
    CALayer *cachedLayer;
}

@property (nonatomic, strong) UIColor *backgroundTintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat blurRadius UI_APPEARANCE_SELECTOR __attribute__((deprecated("Use blurFraction instead.")));
@property (nonatomic) CGFloat blurFraction UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIImage *maskImage; // use this! Supports expandable images.

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *overlayMaskView; // needs to be different from maskView!;

@end
