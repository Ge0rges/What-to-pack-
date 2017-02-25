//
//  WhatToPackViewController.m
//  What to pack?
//
//  Created by Georges Kanaan on 2/10/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "WhatToPackViewController.h"

// Controllers
#import "ViewController.h"

NSInteger forecastCount;// Extern from ViewController.h

@interface WhatToPackViewController () {
  NSMutableArray *clothes;
}

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation WhatToPackViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  clothes = [NSMutableArray new];
  
  // Update status bar
  [self setNeedsStatusBarAppearanceUpdate];
  
  // Make the footer label in the tableView have a smaller font
  [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont boldSystemFontOfSize:14]];
  
  // Populate cloth to pack array
  NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"namesOfClothesToPack"];
  NSSet *namesOfClothesToPack = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  
  for (NSString *name in namesOfClothesToPack) {
    NSInteger number = [[NSUserDefaults standardUserDefaults] integerForKey:name];
    
    NSArray *clothe = [NSArray arrayWithObjects:name, [NSNumber numberWithInteger:number], nil];
    [clothes addObject:clothe];
  }
  
  // Reload table data
  [self.mainTableView reloadData];
  
  // Show navigation bar
  [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated {
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
  if (currentCell.accessoryType == UITableViewCellAccessoryCheckmark) {
    currentCell.accessoryType = UITableViewCellAccessoryNone;
  } else {
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return clothes.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return @"* Depends on Activity Types.";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  return @"Pack important documents.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  
  //get the clothe and its name
  NSArray *clotheItem = [clothes objectAtIndex:indexPath.row];
  NSString *name = [clotheItem objectAtIndex:0];
  
  //set the labels
  [cell.textLabel setText:name];
  [cell.detailTextLabel setText:[NSString stringWithFormat:@"%i", [[clotheItem objectAtIndex:1] intValue]]];
  
  return cell;
}

@end
