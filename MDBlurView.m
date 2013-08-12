//
//  MDBlurView.m
//  MDBlurView
//
//  Created by Dimitri Bouniol on 7/25/13.
//  Copyright 2013 Mochi Development Inc. All rights reserved.
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

#import "MDBlurView.h"

//const CGFloat rY = 0.212655;
//const CGFloat gY = 0.715158;
//const CGFloat bY = 0.072187;
//
//// Inverse of sRGB "gamma" function. (approx 2.2)
//CGFloat inv_gam_sRGB(CGFloat c) {
//    if (c <= 0.04045)
//        return c/12.92;
//    else
//        return pow(((c+0.055)/(1.055)), 2.2);
//}
//
//// sRGB "gamma" function (approx 2.2)
//CGFloat gam_sRGB(CGFloat v) {
//    if (v <= 0.0031308)
//        v *= 12.92;
//    else
//        v = 1.055*pow(v, 1.0/2.2) - 0.055;
//    return v;
//}
//
//// luminance value
//CGFloat luminance(CGFloat r, CGFloat g, CGFloat b) {
//    return gam_sRGB(rY*inv_gam_sRGB(r) + gY*inv_gam_sRGB(g) + bY*inv_gam_sRGB(b));
//}

@implementation MDBlurView

#pragma mark - AboutController

+ (NSDictionary *)MDAboutControllerTextCreditDictionary
{
    if (self == [MDBlurView class]) {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Blurred views powered by MDBlurView, available free on GitHub!", @"Text", @"https://github.com/mochidev/MDBlurViewDemo", @"Link", nil];
    }
    return nil;
}

#pragma mark - Initializers

+ (void)initialize
{
    if (self != [MDBlurView class]) return;
    
    MDBlurView *appearanceProxy = [self appearance];
    appearanceProxy.backgroundTintColor = [UIColor colorWithWhite:1 alpha:0];
    appearanceProxy.blurFraction = 1;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _performInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _performInit];
    }
    return self;
}

- (void)_performInit
{
    self.userInteractionEnabled = NO;
    
    self.opaque = NO;
    self.backgroundColor = nil;
    bar = [[UINavigationBar alloc] initWithFrame:self.bounds];
    
    if (![bar respondsToSelector:NSSelectorFromString(@"barTintColor")]) {
        bar = [[UIView alloc] initWithFrame:self.bounds];
        bar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        bar.opaque = NO;
        cachedLayer = self.layer;
    }
//    bar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:bar];
    [self fixNavigationBar:bar];
    
    _tintView = [[UIImageView alloc] initWithFrame:self.bounds];
    _tintView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tintView.backgroundColor = nil;
    _tintView.userInteractionEnabled = NO;
    [self addSubview:_tintView];
    
    alpha = 1.;
}

#pragma mark - Voodoo

- (void)fixNavigationBar:(UIView *)navBar
{
    navBar.userInteractionEnabled = NO;
    if (navBar.subviews.count == 0) return;
    
    [cachedBarBackground.layer removeObserver:self forKeyPath:@"sublayers"];
    [cachedLayer removeObserver:self forKeyPath:@"mask"];
    
    UIView *barBackground = [navBar.subviews objectAtIndex:0];
    NSMutableArray *itemsToRemove = [[NSMutableArray alloc] init];
    
    for (UIView *subview in barBackground.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [itemsToRemove addObject:subview];
        }
    }
    for (UIView *view in itemsToRemove) {
        [view removeFromSuperview];
    }
    
    if (barBackground.subviews.count == 0) {
        cachedBarBackground = barBackground;
        [cachedBarBackground.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:NULL];
        
        return;
    }
    
    UIView *backdrop = [[barBackground subviews] objectAtIndex:0];
    
    if (backdrop.subviews.count == 0 || [NSStringFromClass(backdrop.class) rangeOfString:@"BackdropView"].location == NSNotFound) return;
    
    UIView *backdropEffectView = [[backdrop subviews] objectAtIndex:0];
    
    cachedLayer = backdropEffectView.layer;
    cachedLayer.mask = lastMaskView.layer;
    
    [cachedLayer addObserver:self forKeyPath:@"mask" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == cachedBarBackground.layer && [keyPath isEqualToString:@"sublayers"]) {
        if (cachedBarBackground.subviews.count > 0) {
            UIView *backdrop = [cachedBarBackground.subviews objectAtIndex:0];
            
            if (backdrop.subviews.count == 0 || [NSStringFromClass(backdrop.class) rangeOfString:@"BackdropView"].location == NSNotFound) return;
            
            UIView *backdropEffectView = [[backdrop subviews] objectAtIndex:0];
            
            cachedLayer = backdropEffectView.layer;
            cachedLayer.mask = lastMaskView.layer;
            
            [cachedLayer addObserver:self forKeyPath:@"mask" options:NSKeyValueObservingOptionNew context:NULL];
        }
        
        [cachedBarBackground.layer removeObserver:self forKeyPath:@"sublayers"];
        cachedBarBackground = nil;
        return;
    } else if (object == cachedLayer && [keyPath isEqual:@"mask"]) {
        CALayer *newMask = [change objectForKey:NSKeyValueChangeNewKey];
        if (newMask != lastMaskView.layer) {
            cachedLayer.mask = lastMaskView.layer;
        }
        return;
    }
    
    if ([super respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)])
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)dealloc
{
    [cachedBarBackground.layer removeObserver:self forKeyPath:@"sublayers"];
    [cachedLayer removeObserver:self forKeyPath:@"mask"];
}

#pragma mark - Overrides

- (void)setAlpha:(CGFloat)newAlpha // animating the alpha usually explodes, so manually do it to our two subviews.
{
    alpha = newAlpha;
    bar.alpha = newAlpha*_blurFraction;
    _tintView.alpha = newAlpha;
}

- (CGFloat)alpha
{
    return alpha;
}

- (void)setFrame:(CGRect)frame
{
    CGRect oldBounds = self.bounds;
    
    [super setFrame:frame];
    
    CGRect newBounds = self.bounds;
    
    if (lastMaskView) {
        [CATransaction begin];
        [CATransaction disableActions];
        oldBounds.origin = CGPointZero;
        if (newBounds.size.width > oldBounds.size.width) oldBounds.size.width = newBounds.size.width;
        if (newBounds.size.height > oldBounds.size.height) oldBounds.size.height = newBounds.size.height;
        bar.frame = oldBounds;
        [CATransaction commit];
    } else {
        bar.frame = newBounds;
    }
    
    lastMaskView.frame = newBounds;
    lastTintMaskView.frame = newBounds;
}

#pragma mark - Accessors

- (void)setBlurLuminosity:(MDBlurLuminosity)blurLuminosity
{
    _blurLuminosity = blurLuminosity;
    
    if (_blurLuminosity == MDBlurLuminosityAutomatic) {
        blurLuminosity = calculatedLuminosity;
    }
    
    if ([bar respondsToSelector:@selector(setBarStyle:)]) {
        UIBarStyle oldStyle = [(UINavigationBar *)bar barStyle];
        if (blurLuminosity == MDBlurLuminosityDark) {
            [(UINavigationBar *)bar setBarStyle:UIBarStyleBlack];
        } else {
            [(UINavigationBar *)bar setBarStyle:UIBarStyleDefault];
        }
        
        if (oldStyle != [(UINavigationBar *)bar barStyle])
            [self fixNavigationBar:bar];
    } else {
        if (blurLuminosity == MDBlurLuminosityDark) {
            bar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        } else {
            bar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        }
    }
}

- (void)setBlurRadius:(CGFloat)blurRadius
{
    self.blurFraction = blurRadius;
}

- (CGFloat)blurRadius
{
    return self.blurFraction;
}

- (void)setBlurFraction:(CGFloat)blurFraction
{
    _blurFraction = blurFraction;
    bar.alpha = blurFraction*alpha;
}

- (void)setBackgroundTintColor:(UIColor *)backgroundTintColor
{
    CGFloat r = 0;
    CGFloat g = 0;
    CGFloat b = 0;
    CGFloat a = 0;
    
    [backgroundTintColor getRed:&r green:&g blue:&b alpha:&a];
    
    CGFloat l = 0.212655*r + 0.715158*g + 0.072187*b;
    
    if (fabsf(r-l) < 0.05 && fabsf(g-l) < 0.05 && fabsf(b-l) < 0.05) {
        l *= 1.25; // boost greys
    }
    
    if (a < 0.05 || l > 0.5) {
        calculatedLuminosity = MDBlurLuminosityBright;
    } else {
        calculatedLuminosity = MDBlurLuminosityDark;
    }
    
    self.blurLuminosity = self.blurLuminosity;
    
    _tintView.backgroundColor = backgroundTintColor;
}

- (UIColor *)backgroundTintColor
{
    return _tintView.backgroundColor;
}

- (void)setMaskView:(UIView *)aMaskView
{
    bar.frame = self.bounds;
    if (_maskView != aMaskView) {
        [aMaskView removeFromSuperview];
        aMaskView.frame = self.bounds;
        
        _maskView = aMaskView;
    }
    lastMaskView = _maskView;
    cachedLayer.mask = _maskView.layer;
}

- (void)setOverlayMaskView:(UIView *)overlayMaskView
{
    self.tintMaskView = overlayMaskView;
}

- (UIView *)overlayMaskView
{
    return self.tintMaskView;
}

- (void)setTintMaskView:(UIView *)tintMaskView
{
    bar.frame = self.bounds;
    
    NSAssert(!tintMaskView || _maskView != tintMaskView, @"tintMaskView <%@: 0x%p> must be different from maskView <%@: 0x%p>!", NSStringFromClass(_maskView.class), _maskView, NSStringFromClass(tintMaskView.class), tintMaskView);
    if (_tintMaskView != tintMaskView) {
        [tintMaskView removeFromSuperview];
        tintMaskView.frame = self.bounds;
        
        _tintMaskView = tintMaskView;
    }
    lastTintMaskView = _tintMaskView;
    _tintView.layer.mask = tintMaskView.layer;
}

- (void)setMaskImage:(UIImage *)maskImage
{
    bar.frame = self.bounds;
    
    _maskImage = maskImage;
    
    if (!maskImage) {
        lastMaskView = nil;
        cachedLayer.mask = nil;
        lastTintMaskView = nil;
        _tintView.layer.mask = nil;
        
        return;
    }
    
    if (!maskViewA) {
        maskViewA = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    
    lastMaskView = maskViewA;
    maskViewA.frame = self.bounds;
    maskViewA.image = _maskImage;
    cachedLayer.mask = maskViewA.layer;
    
    if (!maskViewB) {
        maskViewB = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    
    lastTintMaskView = maskViewB;
    maskViewB.frame = self.bounds;
    maskViewB.image = _maskImage;
    _tintView.layer.mask = maskViewB.layer;
}

@end
