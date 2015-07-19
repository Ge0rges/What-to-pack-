//
//  MTAnimatedLabel.m
//  
//
//  Created by Michael Turner on 8/3/12.
//  Copyright (c) 2012 Michael Turner. All rights reserved.
//

/*
 Copyright (c) 2012 Michael Turner. All rights reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MTAnimatedLabel.h"

#define kGradientSize           0.45f
#define kAnimationDuration      2.25f
#define kGradientTint           [UIColor whiteColor]

#define kAnimationKey           @"gradientAnimation"
#define kGradientStartPointKey  @"startPoint"
#define kGradientEndPointKey    @"endPoint"

@interface MTAnimatedLabel () 
    
@property (strong, nonatomic) CATextLayer *textLayer;

- (void)setStartAndEndPoints:(CAGradientLayer *)layer;
- (NSValue *)calculateEndPointToValue;
- (NSValue *)calculateStartPointToValue;

@end

@implementation MTAnimatedLabel

@synthesize animationDirection;

#pragma mark - Initialization

- (void)initializeLayers
{
    /* set Defaults */
    self.gradientColor      = kGradientTint;
    self.animationDuration  = kAnimationDuration;
    self.gradientWidth      = kGradientSize;
    self.animationDirection = AnimationDirectionLeftToRight;
    
    CAGradientLayer *gradientLayer  = (CAGradientLayer *)self.layer;
    gradientLayer.backgroundColor   = [super.textColor CGColor];
    gradientLayer.colors            = @[(id)[self.textColor CGColor],(id)[_gradientColor CGColor], (id)[self.textColor CGColor]];
    
    [self setStartAndEndPoints:gradientLayer];
    
    self.textLayer                      = [CATextLayer layer];
    self.textLayer.backgroundColor      = [[UIColor clearColor] CGColor];
    self.textLayer.contentsScale        = [[UIScreen mainScreen] scale];
    self.textLayer.rasterizationScale   = [[UIScreen mainScreen] scale];
    self.textLayer.bounds               = self.bounds;
    self.textLayer.anchorPoint          = CGPointZero;
    
    /* set initial values for the textLayer because they may have been loaded from a nib */
    [self setFont:          super.font];
    [self setTextAlignment: super.textAlignment];
    [self setText:          super.text];
    [self setTextColor:     super.textColor];

    /*
        finally set the textLayer as the mask of the gradientLayer, this requires offscreen rendering
        and therefore this label subclass should ONLY BE USED if animation is required
     */
    gradientLayer.mask = self.textLayer;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeLayers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeLayers];
    }
    return self;
}

- (void)setAnimationDirection:(AnimationDirection)lclAnimationDirection {
    animationDirection = lclAnimationDirection;
    [self setStartAndEndPoints:(CAGradientLayer *)self.layer];
}

- (void)setStartAndEndPoints:(CAGradientLayer *)layer {
    if(self.animationDirection == AnimationDirectionLeftToRight) {
        layer.startPoint        = CGPointMake(-self.gradientWidth, 0.);
        layer.endPoint          = CGPointMake(0., 0.);
    } else {
        layer.startPoint        = CGPointMake(1, 0.);
        layer.endPoint          = CGPointMake(1+self.gradientWidth, 0.);
    }
    
}

- (NSValue *)calculateEndPointToValue {
    if(self.animationDirection == AnimationDirectionLeftToRight) {
        return [NSValue valueWithCGPoint:CGPointMake(1+self.gradientWidth, 0)];
    } else {
        return [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    }
}

- (NSValue *)calculateStartPointToValue {
    if(self.animationDirection == AnimationDirectionLeftToRight) {
        return [NSValue valueWithCGPoint:CGPointMake(1.0, 0)];
    } else {
        return [NSValue valueWithCGPoint:CGPointMake(-self.gradientWidth, 0)];
    }
}

#pragma mark - UILabel Accessor overrides

- (UIColor *)textColor
{
    UIColor *textColor = [UIColor colorWithCGColor:self.layer.backgroundColor];
    if (!textColor) {
        textColor = [super textColor];
    }
    return textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    CAGradientLayer *gradientLayer  = (CAGradientLayer *)self.layer;
    gradientLayer.backgroundColor   = [textColor CGColor];
    gradientLayer.colors            = @[(id)[textColor CGColor],(id)[self.gradientColor CGColor], (id)[textColor CGColor]];
    
    [self setNeedsDisplay];
}

- (NSString *)text
{
    return self.textLayer.string;
}

- (void)setText:(NSString *)text
{
    self.textLayer.string = text;
    [self setNeedsDisplay];
}

- (UIFont *)font
{
    CTFontRef ctFont    = self.textLayer.font;
    NSString *fontName  = (__bridge_transfer NSString *)CTFontCopyName(ctFont, kCTFontPostScriptNameKey);
    CGFloat fontSize    = CTFontGetSize(ctFont);
    return [UIFont fontWithName:fontName size:fontSize];
}

- (void)setFont:(UIFont *)font
{
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)(font.fontName), font.pointSize, &CGAffineTransformIdentity);
    self.textLayer.font = fontRef;
    self.textLayer.fontSize = font.pointSize;
    CFRelease(fontRef);
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (NSTextAlignment)textAlignment
{
    return [MTAnimatedLabel UITextAlignmentFromCAAlignment:self.textLayer.alignmentMode];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    self.textLayer.alignmentMode = [MTAnimatedLabel CAAlignmentFromNSTextAlignment:textAlignment];
}

#pragma mark - UILabel Layer override

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

/* Stop UILabel from drawing because we are using a CATextLayer for that! */
- (void)drawRect:(CGRect)rect {}

#pragma mark - Utility Methods

+ (NSString *)CAAlignmentFromNSTextAlignment:(NSTextAlignment)textAlignment
{    
    switch (textAlignment) {
        case NSTextAlignmentLeft:   return kCAAlignmentLeft;
        case NSTextAlignmentCenter: return kCAAlignmentCenter;
        case NSTextAlignmentRight:  return kCAAlignmentRight;
        default:                    return kCAAlignmentNatural;
    }
}

+ (NSTextAlignment)UITextAlignmentFromCAAlignment:(NSString *)alignment
{
    if ([alignment isEqualToString:kCAAlignmentLeft])       return NSTextAlignmentLeft;
    if ([alignment isEqualToString:kCAAlignmentCenter])     return NSTextAlignmentCenter;
    if ([alignment isEqualToString:kCAAlignmentRight])      return NSTextAlignmentRight;
    if ([alignment isEqualToString:kCAAlignmentNatural])    return NSTextAlignmentLeft;
    return NSTextAlignmentLeft;
}

#pragma mark - LayoutSublayers

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    self.textLayer.frame = self.layer.bounds;
}

#pragma mark - MTAnimated Label Public Methods

- (void)setGradientColor:(UIColor *)gradientColor
{
    _gradientColor = gradientColor;
    
    CAGradientLayer *gradientLayer  = (CAGradientLayer *)self.layer;
    gradientLayer.colors            = @[(id)[self.textColor CGColor],(id)[_gradientColor CGColor], (id)[self.textColor CGColor]];
    [self setNeedsDisplay];
}

- (void)startAnimating
{
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    
    if([gradientLayer animationForKey:kAnimationKey] == nil) {
        CABasicAnimation *startPointAnimation = [CABasicAnimation animationWithKeyPath:kGradientStartPointKey];
        startPointAnimation.toValue = [self calculateStartPointToValue];
        startPointAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        CABasicAnimation *endPointAnimation = [CABasicAnimation animationWithKeyPath:kGradientEndPointKey];
        endPointAnimation.toValue = [self calculateEndPointToValue];
        endPointAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[startPointAnimation, endPointAnimation];
        group.duration = self.animationDuration;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        group.repeatCount = FLT_MAX;
        
        [gradientLayer addAnimation:group forKey:kAnimationKey];
    }
}

- (void)stopAnimating
{
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    if([gradientLayer animationForKey:kAnimationKey])
        [gradientLayer removeAnimationForKey:kAnimationKey];
}

@end
