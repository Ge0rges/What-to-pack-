//
//  ViewController.h
//  What to pack?
//
//  Created by Georges Kanaan on 10/15/13.
//  Copyright (c) 2013 Georges Kanaan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "OWMWeatherAPI.h"
#import "WhatToPackViewController.h"

@interface ViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource> {
    
    OWMWeatherAPI *weatherAPI;
    
    NSArray *forecast;
    NSDateFormatter *dateFormatter;
    
    float temp;
}

@property (strong, nonatomic) IBOutlet UIButton *goButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *unitSC;
@property (strong, nonatomic) IBOutlet UITextField *destinationTF;
@property (weak, nonatomic) IBOutlet UITableView *forecastTableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UITextField *timeTF;
@property (strong, nonatomic) IBOutlet UISegmentedControl *typeSC;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sexeSC;
@property (strong, nonatomic) IBOutlet UIButton *whatToPackBTN;

@end
