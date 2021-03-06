//
//  ViewController.m
//  What to pack?
//
//  Created by Georges Kanaan on 10/15/13.
//  Copyright (c) 2013 Georges Kanaan. All rights reserved.
//

#import "ViewController.h"

// Frameworks
#import <AudioToolbox/AudioToolbox.h>

// Controllers
#import "WhatToPackViewController.h"
#import "CitySelectionTableViewController.h"

// Classes
#import "OWMWeatherAPI.h"

extern NSInteger forecastCount;

@interface ViewController () <UITextFieldDelegate, UITableViewDataSource> {
  NSArray *clothes;
  
  OWMWeatherAPI *weatherAPI;
  
  NSMutableArray *forecast;
  
  NSDateFormatter *dateFormatter;
}

@property (strong, nonatomic) IBOutlet UIButton *goButton;
@property (strong, nonatomic) IBOutlet UIButton *whatToPackBTN;

@property (weak, nonatomic) IBOutlet UITableView *forecastTableView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UITextField *timeTF;
@property (strong, nonatomic) IBOutlet UITextField *destinationTF;

@property (strong, nonatomic) IBOutlet UISegmentedControl *unitSC;
@property (strong, nonatomic) IBOutlet UISegmentedControl *typeSC;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sexeSC;

@end

@implementation ViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  //update status bar
  [self setNeedsStatusBarAppearanceUpdate];
  
  // Setup weather api
  weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"49dfbf0711418f5cd182e3b0cc4641ee"];
  
  // We want localized strings according to the prefered system language
  [weatherAPI setLangWithPreferedLanguage];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Hide navigation bar
  [self.navigationController setNavigationBarHidden:YES animated:YES];
  
  //get clothes data
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{clothes = [self getClothingData];});
  
  // Populate the destination TF
  if (self.selectedCity) {
    self.destinationTF.text = [NSString stringWithFormat:@"%@, %@", self.selectedCity[@"name"],  self.selectedCity[@"country"]];
  }
  
  //set activity indicator
  [self.activityIndicator stopAnimating];
  self.activityIndicator.alpha = 0.0;
  
  //prepare view for no data
  //goButton
  [self checkHideGoButton];
  
  //what to pack hutton
  if (!forecast) {
    self.whatToPackBTN.hidden = YES;
    self.whatToPackBTN.alpha = 0.0;
  }
  
  //setup date format and init forecast array
  NSString *dateComponents = @"MMMddyyyy H:m";
  NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale systemLocale]];
  dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:dateFormat];
  
  if (!forecast) {
    forecast = [NSMutableArray new];
  }
  
  //setup unitsSC
  int unit = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"unit"];
  
  switch (unit) {
    case 1:
    self.unitSC.selectedSegmentIndex = 0;
    [weatherAPI setTemperatureFormat:kOWMTempCelcius];
    break;
    
    case 2:
    self.unitSC.selectedSegmentIndex = 1;
    [weatherAPI setTemperatureFormat:kOWMTempFahrenheit];
    break;
    
    case 3:
    self.unitSC.selectedSegmentIndex = 2;
    [weatherAPI setTemperatureFormat:kOWMTempKelvin];
    break;
    
    default:
    self.unitSC.selectedSegmentIndex = 0;
    [weatherAPI setTemperatureFormat:kOWMTempCelcius];
    break;
  }
  
  BOOL type = [[NSUserDefaults standardUserDefaults] boolForKey:@"casual"];
  if (type == YES) {
    self.typeSC.selectedSegmentIndex = 0;
  } else if (type == NO) {
    self.typeSC.selectedSegmentIndex = 1;
  }
  
  BOOL sexe = [[NSUserDefaults standardUserDefaults] boolForKey:@"female"];
  if (sexe == NO) {
    self.sexeSC.selectedSegmentIndex = 0;
  } else if (sexe == YES) {
    self.sexeSC.selectedSegmentIndex = 1;
  }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleDefault;
}

#pragma mark - Buttons

- (IBAction)segmentedControls:(id)sender {
  if (sender ==  self.unitSC) {
    if (self.unitSC.selectedSegmentIndex == 0) {
      
      [weatherAPI setTemperatureFormat:kOWMTempCelcius];
      [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"unit"];
      
    } else if (self.unitSC.selectedSegmentIndex == 1) {
      
      [weatherAPI setTemperatureFormat:kOWMTempFahrenheit];
      [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"unit"];
      
    }else if (self.unitSC.selectedSegmentIndex == 2) {
      
      [weatherAPI setTemperatureFormat:kOWMTempKelvin];
      [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"unit"];
      
    }
  } else if (sender == self.typeSC) {
    if (self.typeSC.selectedSegmentIndex == 0) {
      
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"casual"];
      
    } else if (self.typeSC.selectedSegmentIndex == 1) {
      
      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"casual"];
      
    }
  } else if (sender == self.sexeSC) {
    if (self.sexeSC.selectedSegmentIndex == 0) {
      
      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"female"];
      
    } else if (self.sexeSC.selectedSegmentIndex == 1) {
      
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"female"];
      
    }
  }
}

- (IBAction)getCityNameAndLaunchForecast:(id)sender {
  
  if (!clothes) {
    clothes = [self getClothingData];
    if (!clothes) {
      return;
    }
  }
  
  //clear the amounts of clothes
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    for (NSArray *clotheItem in clothes) {//for each clothing items in clothes list
      //get the properties
      NSString *name = [clotheItem objectAtIndex:NAME_STRING_INDEX_CLOTHES_ARRAY];
      [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:name];
    }
  });
  
  int time = [self.timeTF.text intValue];
  
  [self getWeatherWithTime:time+1];
  
  [self.activityIndicator startAnimating];
  
  self.activityIndicator.hidden = NO;

  [UIView animateWithDuration:0.3 animations:^{
    self.goButton.alpha = 0.0;
    self.activityIndicator.alpha = 1.0;
  } completion:^(BOOL finished) {
    self.goButton.hidden = YES;
  }];
  
  
  [self.destinationTF resignFirstResponder];
  [self.timeTF resignFirstResponder];
  
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (self.timeTF.text.length > 0 && self.selectedCity) {
    [self getCityNameAndLaunchForecast:nil];
    
    [self.destinationTF resignFirstResponder];
    [self.timeTF resignFirstResponder];
    
  }
  
  [self checkHideGoButton];
  
  return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (textField == self.destinationTF) {
    [self.view endEditing:YES];
    
    [self performSegueWithIdentifier:@"citySelection" sender:textField];
    
    return NO;
  }
  
  return  YES;
}

- (void)checkHideGoButton {
  //check if we should hide the go button depending on text entered
  if (self.activityIndicator.isAnimating == YES || self.activityIndicator.hidden == NO) {
    [UIView animateWithDuration:0.3 animations:^{self.goButton.alpha = 0.0;} completion:^(BOOL finished) {self.goButton.hidden = YES;}];
    
  } else {
    if (self.selectedCity && self.timeTF.text.length > 0) {
      self.goButton.hidden = NO;
      [UIView animateWithDuration:0.3 animations:^{self.goButton.alpha = 1.0;}];
      
      
    } else {
      [UIView animateWithDuration:0.3 animations:^{self.goButton.alpha = 0.0;} completion:^(BOOL finished) {self.goButton.hidden = YES;}];
    }
  }
}

#pragma mark - Weather
- (void)getWeatherWithTime:(int)time {
  if (time > 15) {//make sure it is possible to get a  forecast for those days
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forecast" message:@"We are only able to get the weather forecast for 14 days excluding today. We are generating a packing list for 14 days (+ today)." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    self.timeTF.text = @"14";
    time = 15;
    [alert show];
  }
  
  [weatherAPI dailyForecastWeatherByCityId:self.selectedCity[@"_id"] withCount:time andCallback:^(NSError *error, NSDictionary *result) {
  //[weatherAPI dailyForecastWeatherByCityName:@"Beirut" withCount:time andCallback:^(NSError *error, NSDictionary *result) {
    if (error) {
      
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error getting the forecast. Please try again in a few moments as the servers might be overloaded or under maintenance." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
      [alert show];
      
    } else {
      
      // The data is ready
      NSArray *forecastArray = [result objectForKey:@"list"];//get the result into a array
      [forecast removeAllObjects];//make sure the forecast mutable array is empty
      [forecast addObjectsFromArray:forecastArray];//populate the mutable array from the forecastArray
      [forecast removeObjectAtIndex:0];//delete the forecast for today
      forecastCount = (NSInteger)forecast.count;
      
      [self.forecastTableView reloadData];//reload the tableView
      
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//create a background thread to generate what to pack
        [self whatToPack];//generate what to pack
      });
    }
  }];
  
  [UIView animateWithDuration:0.3 animations:^{self.activityIndicator.alpha = 0.0;} completion:^(BOOL finished) {
    [self checkHideGoButton];
  }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return forecast.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
  }
  
  NSDictionary *forecastData = [forecast objectAtIndex:indexPath.row];
  
  int unit = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"unit"];
  if (unit == 1) {
    cell.textLabel.text = [NSString stringWithFormat:@"%i°C - %@", [forecastData[@"main"][@"temp"] intValue], forecastData[@"weather"][0][@"main"]];
    
  } else if (unit == 2) {
    cell.textLabel.text = [NSString stringWithFormat:@"%i°F - %@", [forecastData[@"main"][@"temp"] intValue] , forecastData[@"weather"][0][@"main"]];
    
  } else if (unit == 3) {
    cell.textLabel.text = [NSString stringWithFormat:@"%i°K - %@", [forecastData[@"main"][@"temp"] intValue], forecastData[@"weather"][0][@"main"]];
  }
  
  
  cell.detailTextLabel.text = [dateFormatter stringFromDate:forecastData[@"dt"]];
  
  [UIView animateWithDuration:0.3 animations:^{self.activityIndicator.alpha = 0.0;} completion:^(BOOL finished) {
    [self.activityIndicator stopAnimating];
    self.goButton.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{self.goButton.alpha = 1.0;}];
  }];
  
  return cell;
}

#pragma mark - What To Pack
- (void)whatToPack {
  //get the clothes
  NSMutableSet *namesOfClothesToPack = [NSMutableSet set];
  
  for (int i = 0; i < forecastCount; i++) {//for each vacation day
    for (NSArray *clotheItem in clothes) {//for each clothing items in clothes list
      
      //get the properties
      NSString *name = [clotheItem objectAtIndex:NAME_STRING_INDEX_CLOTHES_ARRAY];
      NSString *gender = [clotheItem objectAtIndex:GENDER_STRING_INDEX_CLOTHES_ARRAY];
      int minimumTemperature = -400, maximumTemperature = 400;//if we don't have  a range then it shoudl always be in the list
      if (clotheItem.count == 7) {//we have a range of temperatures
        minimumTemperature = [[clotheItem objectAtIndex:MINIMUM_TEMPERATURE_INDEX_CLOTHES_ARRAY] intValue];
        maximumTemperature = [[clotheItem objectAtIndex:MAXIMUM_TEMPERATURE_INDEX_CLOTHES_ARRAY] intValue];
      }
      int maximumNumber = [[clotheItem objectAtIndex:MAXIMUM_NUMBER_INDEX__CLOTHES_ARRAY] intValue];
      NSArray *weatherStates = [clotheItem objectAtIndex:WEATHER_TYPE_INDEX_CLOTHES_ARRAY];
      BOOL formal = [[clotheItem objectAtIndex:FORMAL_BOOL_INDEX_CLOTHES_ARRAY] boolValue];
      
      
      //get the current weather
      NSDictionary *forecastData = [forecast objectAtIndex:i];
      NSString *weather = forecastData[@"weather"][0][@"main"];
      int temperetaure = [forecastData[@"temp"][@"day"] intValue];
      
      //get variables to use in if statement
      //gender
      //check if we need gender first of all
      int genderInt;
      if ([gender isEqualToString:@"both"]) {
        genderInt = 3;
      } else if ([gender isEqualToString:@"men"]) {
        genderInt = 2;
      } else if ([gender isEqualToString:@"women"]) {
        genderInt = 1;
      }
      
      //get the user gender
      int userGenderInt;
      if ([[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
        userGenderInt = 1;
      } else {
        userGenderInt = 2;
      }
      
      //formal or leisure
      BOOL leisure = [[NSUserDefaults standardUserDefaults] boolForKey:@"casual"];
      
      //mx number
      NSInteger previousNumber = [[NSUserDefaults standardUserDefaults] integerForKey:name];
      
      for (NSString *weatherState in weatherStates) {//for each weather states avaible
        if ([weather isEqualToString:weatherState] && temperetaure >= minimumTemperature && temperetaure <= maximumTemperature && (userGenderInt == genderInt || genderInt == 3) && leisure != formal && previousNumber < maximumNumber) {//check all properties
          [[NSUserDefaults standardUserDefaults] setInteger:previousNumber+1 forKey:name];//increment previous number by one and save it
          //add the key to the clothes to pack
          [namesOfClothesToPack addObject:name];
        }
      }
    }
  }
  
  // Save the set
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSSet setWithSet:namesOfClothesToPack]];
  [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"namesOfClothesToPack"];
  
  
  // Sync defaults
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  //We're done. Update UI and play a sound.
  dispatch_async(dispatch_get_main_queue(), ^{
    AudioServicesPlaySystemSound(1057);
    self.whatToPackBTN.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{self.whatToPackBTN.alpha = 1.0;}];
  });
}

#pragma mark -- Retrieving Data
- (NSArray *)getClothingData {
  //declare the json dict
  __block NSArray *clothingItems = nil;
  
  //get json data
  //get the url
  NSURL *url = [[NSURL alloc] initWithString:@"https://appdata.ge0rges.com/WhatToPack%3F/ClothingItems.plist"];
  
  //variables to store reposne and error
  NSURLResponse *response;
  NSError *error;
  
  //send the request
  NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&response error:&error];
  
  if (error || !response) {//if we got an error or the response is empty
    //show a alert view
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"It seems the current data isn't valid. Please verify your internet connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
    
    return nil;
    
  } else if (response) {//otherwise if we got a response
    clothingItems = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:&error];
    
    if (error || !clothingItems || clothingItems.count == 0) {//if we got an error parsing or list is empty
      //show a alert view
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Not able to fetch latest data. Please verify your internet connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
      [alertView show];
      
      return nil;
      
    } else {//otherwise everything is fine
      
      return clothingItems;
    }
  } else {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Not able to fetch latest data. Please verify your internet connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
  }
  
  return nil;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"citySelection"]) {
    CitySelectionTableViewController *citySelectionTVC = [segue destinationViewController];
    citySelectionTVC.viewController = self;
  }
}

@end
