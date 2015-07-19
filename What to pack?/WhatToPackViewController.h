//
//  WhatToPackViewController.h
//  What to pack?
//
//  Created by Georges Kanaan on 2/10/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "MTAnimatedLabel.h"

@interface WhatToPackViewController : UITableViewController {
    NSMutableArray *clothes;
}

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@end
