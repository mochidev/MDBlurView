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
    appearanceProxy.blurRadius = 1;
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
    bar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:bar];
    [self fixNavigationBar:bar];
    
    overlay = [[UIView alloc] initWithFrame:self.bounds];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    overlay.backgroundColor = nil;
    overlay.userInteractionEnabled = NO;
    [self addSubview:overlay];
}

#pragma mark - Voodoo

- (void)fixNavigationBar:(UIView *)navBar
{
    navBar.userInteractionEnabled = NO;
    if (navBar.subviews.count == 0) return;
    
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

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    lastMaskView.frame = self.bounds;
    lastOverlayMaskView.frame = self.bounds;
    cachedLayer.frame = self.bounds;
}

#pragma mark - Accessors

- (void)setBlurRadius:(CGFloat)blurRadius
{
    _blurRadius = blurRadius;
    bar.alpha = blurRadius;
}

- (void)setBackgroundTintColor:(UIColor *)backgroundTintColor
{
    _backgroundTintColor = backgroundTintColor;
    overlay.backgroundColor = backgroundTintColor;
}

- (void)setMaskView:(UIView *)aMaskView
{
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
    NSAssert(!overlayMaskView || _maskView != overlayMaskView, @"overlayMaskView <%@: 0x%p> must be different from maskView <%@: 0x%p>!", NSStringFromClass(_maskView.class), _maskView, NSStringFromClass(overlayMaskView.class), overlayMaskView);
    if (_overlayMaskView != overlayMaskView) {
        [overlayMaskView removeFromSuperview];
        overlayMaskView.frame = self.bounds;
        
        _overlayMaskView = overlayMaskView;
    }
    lastOverlayMaskView = _overlayMaskView;
    overlay.layer.mask = overlayMaskView.layer;
}

- (void)setMaskImage:(UIImage *)maskImage
{
    _maskImage = maskImage;
    
    if (!maskImage) {
        lastMaskView = nil;
        cachedLayer.mask = nil;
        lastOverlayMaskView = nil;
        overlay.layer.mask = nil;
        
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
    
    lastOverlayMaskView = maskViewB;
    maskViewB.frame = self.bounds;
    maskViewB.image = _maskImage;
    overlay.layer.mask = maskViewB.layer;
}

@end
