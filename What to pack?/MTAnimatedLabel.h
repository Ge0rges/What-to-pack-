//
//  MTAnimatedLabel.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface MTAnimatedLabel : UILabel
    
@property (nonatomic)           CGFloat animationDuration;
@property (nonatomic)           CGFloat gradientWidth;
@property (strong, nonatomic)   UIColor *gradientColor;

- (void)startAnimating;
- (void)stopAnimating;

typedef enum
{
    AnimationDirectionLeftToRight = 0,
    AnimationDirectionRightToLeft = 1,
    
} AnimationDirection;

@property (nonatomic) AnimationDirection animationDirection;

@end
