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

typedef NS_ENUM(NSUInteger, MDBlurLuminosity) {
    MDBlurLuminosityAutomatic = 0,
    MDBlurLuminosityBright = 1,
    MDBlurLuminosityDark = 2
};

/**
 MDBlurView provides an easy way for your interfaces to incorporate auto-bluring views into your layouts. It provides a greate way to not only place one anywhere, but also to color it, control how much bluring you get, and best of all mask it accordingly.
 
 MDBlurView uses no private APIs, and uses a UINavigationBar internally to get the blur, after stripping it of it's decorations. If for any reason the internal blur views disapear in upcoming releases, the only change will be a lack of blur — your UI should otherwise stay unaffected.
 
 @warning Avoid setting the background color directly, and set the backgroundTintColor instead.
 @see -setBackgroundTintColor:
 
 */

@interface MDBlurView : UIView {
@private
    UIView *bar;
    
    UIImageView *maskViewA;
    UIImageView *maskViewB;
    
    UIView *lastMaskView;
    UIView *lastTintMaskView;
    
    UIView *_maskView;
    UIView *_tintMaskView;
    
    UIView *cachedBarBackground;
    CALayer *cachedLayer;
    
    CGFloat alpha;
}

/**
 @property backgroundTintColor
 @abstract The blur view's background tint color.
 
 @discussion The default value is nil, which results in the default white blur look. This property participates in the appearance proxy API.
 Changes to this property can be animated. Set this property instead of the backgroundColor.
 
 @note Setting an alpha value around 0.5 usually works for bright colors. For darker colors, this value can be set much higher to 0.6 or 0.7.
 @warning Setting the alpha value higher than 0.8 will make most blur effects unnoticeable.
 @link //apple_ref/occ/clm/UIAppearance/appearance +appearance @/link
 */

@property (nonatomic, copy) UIColor *backgroundTintColor UI_APPEARANCE_SELECTOR;


/**
 @property blurFraction
 @abstract The amount a blur view blurs.
 
 @discussion The default value is 1.0. The value of this property is a floating-point number in the range 0.0 to 1.0, where 0.0 represents totally transparent and 1.0 represents fairly blurred. This property participates in the appearance proxy API.
 Changes to this property can be animated.
 
 @note Interesting effects can be achieved by varying this value between 0.95 and 1.0.
 @link //apple_ref/occ/clm/UIAppearance/appearance +appearance @/link
 */

@property (nonatomic) CGFloat blurFraction UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat blurRadius UI_APPEARANCE_SELECTOR __attribute__((deprecated("Use blurFraction instead.")));


/**
 @property maskImage
 @abstract The mask for the blur view.
 
 @discussion The default value is nil. Setting the value of this property with a resizable image will cause it to fill the bounds of the blur view and animate when the bounds are changed. This is the prefered and easier way of setting a mask.
 @note If a mask is already set by setting tintMaskView, this property overrides that.
 */

@property (nonatomic, strong) UIImage *maskImage; // use this! Supports resizable images.

/// @name Advanced

@property (nonatomic) MDBlurLuminosity blurLuminosity;

/**
 @property tintView
 @abstract The blur view's underlying tint view.
 
 @discussion This is useful if you want to animate the tint alpha or set an overlay image
 */

@property (nonatomic, readonly) UIImageView *tintView;

/**
 @property maskView
 @abstract The mask for the blurred content of the blur view.
 
 @discussion The default value is nil. Setting the value of this property will remove the view from its superview and set it as a mask. Note the view will not have a superview nor a window from then out.
 @note If a mask is already set by setting maskImage, this property overrides that.
 @warning This property only sets the mask for blur view and not the background tint. Set tintMaskView to a *different* view (perhaps by implementing -copy on your custom view) to maks the color as well.
 @see tintMaskView
 @see maskImage
 */

@property (nonatomic, strong) UIView *maskView; // if you need more control, use this.


/**
 @property tintMaskView
 @abstract The mask for the background tint of the blur view.
 
 @discussion The default value is nil. Setting the value of this property will remove the view from its superview and set it as a mask. Note the view will not have a superview nor a window from then out.
 @note If a mask is already set by setting maskImage, this property overrides that.
 @warning This property only sets the mask for background tint and not the blur view. Set maskView to a *different* view (perhaps by implementing -copy on your custom view) to maks the color as well.
 @see maskView
 @see maskImage
 */

@property (nonatomic, strong) UIView *tintMaskView; // needs to be different from maskView!;
@property (nonatomic, strong) UIView *overlayMaskView __attribute__((deprecated("Use tintMaskView instead.")));

@end
