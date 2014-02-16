//
//  WhatToPackViewController.h
//  What to pack?
//
//  Created by Georges Kanaan on 2/10/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WhatToPackViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

//tableView cells
@property (strong, nonatomic) IBOutlet UITableViewCell *underwearCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *socksCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *undershirtCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *brasCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *sleepwearCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *tightsCell;

@end
