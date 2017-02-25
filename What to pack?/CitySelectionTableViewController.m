//
//  CitySelectionTableViewController.m
//  What to Pack?
//
//  Created by Georges Kanaan on 25/02/2017.
//  Copyright © 2017 Georges Kanaan. All rights reserved.
//

#import "CitySelectionTableViewController.h"

// Controllers
#import "ViewController.h"

@interface CitySelectionTableViewController () <UISearchResultsUpdating, UISearchBarDelegate> {
  NSArray <NSDictionary*> *cityList;// The static list of all cities
  NSArray <NSDictionary*> *loadedList;// Can be filtered or not, used to load the table view.
}

@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation CitySelectionTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Show navigation bar
  [self.navigationController setNavigationBarHidden:NO animated:YES];
  
  // Get the list of cities
  NSURL *urlToCityListJson = [[NSBundle mainBundle] URLForResource:@"cityList" withExtension:@"json"];
  
  NSError *error;
  NSData *cityListData = [NSData dataWithContentsOfURL:urlToCityListJson options:NSDataReadingUncached error:&error];
  NSLog(@"%@", error);
  
  cityList = [NSJSONSerialization JSONObjectWithData:cityListData options:0 error:nil];
  loadedList = cityList;
  
  // Setup search
  self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
  self.searchController.searchResultsUpdater = self;
  self.searchController.dimsBackgroundDuringPresentation = NO;
  self.searchController.searchBar.delegate = self;
  
  self.tableView.tableHeaderView = self.searchController.searchBar;
  self.definesPresentationContext = YES;

  
  // Reload the table view
  [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return loadedList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
  
  // Configure the cell...
  NSDictionary *cityDict = loadedList[indexPath.row];
  cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", cityDict[@"name"], cityDict[@"country"]];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  // Get the city ID
  NSDictionary *cityDict = loadedList[indexPath.row];
  self.viewController.selectedCity = cityDict;
  
  [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma  mark - Search
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
  NSString *searchString = searchController.searchBar.text;
  [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
  [self.tableView reloadData];
}

- (void)searchForText:(NSString * _Nonnull)searchString scope:(NSInteger)scope {
  if (![searchString isEqualToString:@""]) {
    searchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    loadedList = [cityList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name contains[cd] %@)", searchString]];
  
  } else {
    loadedList = cityList;
  }
}


@end
