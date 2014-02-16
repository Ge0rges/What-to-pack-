//
//  ViewController.m
//  What to pack?
//
//  Created by Georges Kanaan on 10/15/13.
//  Copyright (c) 2013 Georges Kanaan. All rights reserved.
//

#import "ViewController.h"

#define systemSoundID    1028

extern NSInteger forecast_count;

//clothes (extern variables so we can use them to populate tableView in WhatToPackViewController)
//Basics (max value 7)
extern NSInteger underwear;
extern NSInteger socks;
extern NSInteger undershirt;
extern NSInteger bras;
extern NSInteger sleepwear;
extern NSInteger tights;

//dressy (max value 3)
extern NSInteger dressShirts;
extern NSInteger sweaters;
extern NSInteger blazers;
extern NSInteger slacks;
extern NSInteger womenPants;
extern NSInteger skirts;
extern NSInteger dresses;
extern NSInteger suits;
extern NSInteger womenSuits;
extern NSInteger tuxedo;
extern NSInteger ties;

//outerwear (max value 2)
extern NSInteger jackets;
extern NSInteger coats;
extern NSInteger raincoats;
extern NSInteger hats;
extern NSInteger gloves;
extern NSInteger scarves;

//casual (max value 5)
extern NSInteger t_shirt;
extern NSInteger tankTops;
extern NSInteger sweatshirts;
extern NSInteger jeans;
extern NSInteger shorts;
extern NSInteger exercise_clothing;
extern NSInteger swimsuit;

//footwear (max value 2)
extern NSInteger athleticShoes;
extern NSInteger leisureShoes;
extern NSInteger dressShoes;
extern NSInteger sandals__flip_flops;
extern NSInteger boots;

//accesories (max value 2)
extern NSInteger belt;
extern NSInteger wristwatch;
extern NSInteger jewelry;
extern NSInteger glasses;
extern NSInteger sunglasses;
extern NSInteger reading_glasses;
extern NSInteger glasses_cases;
extern NSInteger umbrella;
//thermals (max value 2)
extern NSInteger topThermal;
extern NSInteger bottomThermal;

@interface ViewController ()

@end

@implementation ViewController

@synthesize unitSC, destinationTF, activityIndicator, timeTF, goButton, sexeSC, typeSC, whatToPackBTN;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //set activity indicator
    [activityIndicator stopAnimating];
    
    //no data yet!
    //goButton
    goButton.hidden = YES;
    [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(hideGoButton) userInfo:nil repeats:YES];
    
    //what to pack hutton
    whatToPackBTN.hidden = YES;
    
    //setup date format and init forecast array
    NSString *dateComponents = @"MMMddyyyy H:m";
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale systemLocale]];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    
    forecast = @[];
    
    
    // Setup weather api
    weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"49dfbf0711418f5cd182e3b0cc4641ee"];
    
    // We want localized strings according to the prefered system language
    [weatherAPI setLangWithPreferedLanguage];
    
    //setup unitsSC
    int unit = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"unit"];
    if (unit == 1) {
        
        unitSC.selectedSegmentIndex = 0;
        [weatherAPI setTemperatureFormat:kOWMTempCelcius];

    
    } else if (unit == 2) {
        
        unitSC.selectedSegmentIndex = 1;
        [weatherAPI setTemperatureFormat:kOWMTempFahrenheit];

    
    } else if (unit == 3) {
       
        unitSC.selectedSegmentIndex = 2;
        [weatherAPI setTemperatureFormat:kOWMTempKelvin];
        
    }
    
    BOOL type = [[NSUserDefaults standardUserDefaults] boolForKey:@"casual"];
    if (type == YES) {
        
        typeSC.selectedSegmentIndex = 0;
        
        
    } else if (type == NO) {
        
        typeSC.selectedSegmentIndex = 1;
        
    }
    
    BOOL sexe = [[NSUserDefaults standardUserDefaults] boolForKey:@"female"];
    if (sexe == NO) {
        
        sexeSC.selectedSegmentIndex = 0;
        
        
    } else if (sexe == YES) {
        
        sexeSC.selectedSegmentIndex = 1;
        
    }
}

-(void)viewDidAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstTimeMainView"]) {
        //how to use app
        [[[UIAlertView alloc] initWithTitle:@"What to pack? Tutorial" message:@"This is the main window, here you configure various settings like if you are packing for a man or women, is this a formal occasion like a wedding and what's your favorite unit for temperature. Then you enter your destination and how many days you will be traveling and press Go! We will automaticaly get a forecast for you and so you can look at that while we generate what you have to pack. Once we're doen doing that Just click the What to Pack? button that appeared on the bottom of the screen along with that 'ping' sound!" delegate:nil cancelButtonTitle:@"Awesome!" otherButtonTitles:nil, nil] show];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTimeMainView"];
    }
}

#pragma mark - controls, buttons

- (IBAction)segmentedControls:(id)sender {
    
    if (sender ==  unitSC) {
        if (unitSC.selectedSegmentIndex == 0) {
            
            [weatherAPI setTemperatureFormat:kOWMTempCelcius];
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"unit"];
            
        } else if (unitSC.selectedSegmentIndex == 1) {
            
            [weatherAPI setTemperatureFormat:kOWMTempFahrenheit];
            [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"unit"];
        
        }else if (unitSC.selectedSegmentIndex == 2) {
            
            [weatherAPI setTemperatureFormat:kOWMTempKelvin];
            [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"unit"];
            
        }
    } else if (sender == typeSC) {
        if (unitSC.selectedSegmentIndex == 0) {
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"casual"];
            
        } else if (unitSC.selectedSegmentIndex == 1) {
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"casual"];
            
        }
    } else if (sender == sexeSC) {
        if (unitSC.selectedSegmentIndex == 0) {
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"female"];
            
        } else if (unitSC.selectedSegmentIndex == 1) {
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"female"];
            
        }
    }
}

- (IBAction)getCityNameAndLaunchForecast:(id)sender {
    
    int value = [timeTF.text intValue];
    
    [self getWeatherWithDestination:destinationTF.text andTime:value];
    
    [activityIndicator startAnimating];
    activityIndicator.hidden = NO;
    goButton.hidden = YES;
    
    [destinationTF resignFirstResponder];
    [timeTF resignFirstResponder];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == destinationTF) {
        
        if (timeTF.text.length >0) {
        
            [self getCityNameAndLaunchForecast:nil];
        
        }
    }
    
    [destinationTF resignFirstResponder];
    [timeTF resignFirstResponder];
    
    return YES;
}

- (void)hideGoButton{
    
    if (activityIndicator.isAnimating == YES) {
        
        goButton.hidden = YES;
        
    } else {
    
        if (destinationTF.text.length >0 && timeTF.text.length >0) {
        
            goButton.hidden = NO;
    
        } else {
        
            goButton.hidden = YES;
        }
    }
}

#pragma mark - weather
- (void)getWeatherWithDestination:(NSString *)destination andTime:(int)time {
    
    if (time > 14) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forecast" message:@"We are only able to get the weather forecast for 14 days and less today is included in those 14 days, so we are loading 14 days of forecast for you!" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        timeTF.text = @"14";
        
        [alert show];

    }
    
    [weatherAPI dailyForecastWeatherByCityName:destination withCount:time andCallback:^(NSError *error, NSDictionary *result) {
        if (error) {

            [activityIndicator stopAnimating];
            goButton.hidden = NO;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please verify you have an internet connection and that the city name is spelled correclty with no spaces." delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        
        } else {
        
            // The data is ready
            forecast = result[@"list"];
            forecast_count = (NSInteger)forecast.count;
            temp = [result[@"temp"][@"day"]integerValue];

            [self.forecastTableView reloadData];
            
            [self whatToPack];
        }
    }];
}

#pragma mark - forecast tableview datasource

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
        
        cell.textLabel.text = [NSString stringWithFormat:@"%.1f°C - %@", [forecastData[@"temp"][@"day"]floatValue], forecastData[@"weather"][0][@"main"]];
        
        
    } else if (unit == 2) {

        cell.textLabel.text = [NSString stringWithFormat:@"%.1f°F - %@", [forecastData[@"temp"][@"day"]floatValue] , forecastData[@"weather"][0][@"main"]];
    
    } else if (unit == 3) {
        
        cell.textLabel.text = [NSString stringWithFormat:@"%.1f°K - %@", [forecastData[@"temp"][@"day"]floatValue], forecastData[@"weather"][0][@"main"]];
    }

    
    cell.detailTextLabel.text = [dateFormatter stringFromDate:forecastData[@"dt"]];
    
    [activityIndicator stopAnimating];
    goButton.hidden = NO;
    
    return cell;
}

- (void)whatToPack{
    
    for (int i=(int)forecast.count; i<=forecast.count; i++) {
        NSDictionary *forecastData = [forecast objectAtIndex:i-1];

        NSString *weather = forecastData[@"weather"][0][@"main"];

        //basic
        underwear ++;
        socks ++;
        undershirt ++;
        sleepwear ++;
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
            
            bras ++;
            tights ++;
        }
        
        //convert the temperature into °C for if statements
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"unit"] == 2) {
            temp = (temp  -  32)/1.8;
            
        } else  if ([[NSUserDefaults standardUserDefaults] integerForKey:@"unit"] == 2) {
            temp = temp- 273.15;
        }
        
        if (temp >= -10 && temp < 0) {
            if ([weather isEqualToString:@"Clear"] || [weather isEqualToString:@"Sunny"] || [weather isEqualToString:@"Clouds"]) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"casual"]) {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        leisureShoes ++;
                        boots ++;
                        belt ++;
                        if ([weather isEqualToString:@"Sunny"]) {
                            sunglasses ++;
                        }
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        
                    } else {
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        leisureShoes ++;
                        boots ++;
                        if ([weather isEqualToString:@"Sunny"]) {
                            sunglasses ++;
                        }
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        jewelry ++;

                    }
                } else {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        dressShoes ++;
                        boots ++;
                        belt ++;
                        if ([weather isEqualToString:@"Sunny"]) {
                            sunglasses ++;
                        }
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        ties ++;
                        dressShirts ++;
                        slacks ++;
                        blazers ++;
                        suits ++;
                        
                    } else {

                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        dressShoes ++;
                        boots ++;
                        if ([weather isEqualToString:@"Sunny"]) {
                            sunglasses ++;
                        }
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        jewelry ++;
                        dressShirts ++;
                        womenPants ++;
                        skirts ++;
                        womenSuits ++;
                    }
                }
            } else if ([weather isEqualToString:@"Snow"] || [weather isEqualToString:@"Rain"]) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"casual"]) {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        leisureShoes ++;
                        boots ++;
                        belt ++;
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        raincoats ++;
                        umbrella ++;
                        
                    } else {
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        leisureShoes ++;
                        boots ++;
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        jewelry ++;
                        raincoats ++;
                        umbrella ++;
                    }
                } else {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        dressShoes ++;
                        boots ++;
                        belt ++;
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        ties ++;
                        dressShirts ++;
                        slacks ++;
                        blazers ++;
                        suits ++;
                        raincoats ++;
                        umbrella ++;
                        
                    } else {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        dressShoes ++;
                        boots ++;
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        jewelry ++;
                        dressShirts ++;
                        womenPants ++;
                        skirts ++;
                        womenSuits ++;
                        raincoats ++;
                        umbrella ++;
                    }
                
                }
            } else {
                
                [[[UIAlertView alloc] initWithTitle:@"Could not calculate what to pack" message:@"Oops seems like the weather condition is too extreme for us to handle sorry! " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
            }
        } else if (temp >= 0 && temp < 10) {
            if ([weather isEqualToString:@"Clear"] || [weather isEqualToString:@"Sunny"] || [weather isEqualToString:@"Clouds"]) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"casual"]) {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        leisureShoes ++;
                        boots ++;
                        belt ++;
                        if ([weather isEqualToString:@"Sunny"]) {
                            sunglasses ++;
                        }
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        
                    } else {
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        leisureShoes ++;
                        boots ++;
                        if ([weather isEqualToString:@"Sunny"]) {
                            sunglasses ++;
                        }
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        jewelry ++;
                        
                    }
                } else {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        dressShoes ++;
                        boots ++;
                        belt ++;
                        if ([weather isEqualToString:@"Sunny"]) {
                            sunglasses ++;
                        }
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        ties ++;
                        dressShirts ++;
                        slacks ++;
                        blazers ++;
                        suits ++;
                        
                    } else {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        dressShoes ++;
                        boots ++;
                        if ([weather isEqualToString:@"Sunny"]) {
                            sunglasses ++;
                        }
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        jewelry ++;
                        dressShirts ++;
                        womenPants ++;
                        skirts ++;
                        womenSuits ++;
                    }
                }
            } else if ([weather isEqualToString:@"Snow"] || [weather isEqualToString:@"Rain"]) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"casual"]) {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        leisureShoes ++;
                        boots ++;
                        belt ++;
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        raincoats ++;
                        umbrella ++;
                        
                    } else {
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        leisureShoes ++;
                        boots ++;
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        jewelry ++;
                        raincoats ++;
                        umbrella ++;
                    }
                } else {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        dressShoes ++;
                        boots ++;
                        belt ++;
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        ties ++;
                        dressShirts ++;
                        slacks ++;
                        blazers ++;
                        suits ++;
                        raincoats ++;
                        umbrella ++;
                        
                    } else {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        dressShoes ++;
                        boots ++;
                        topThermal ++;
                        bottomThermal ++;
                        wristwatch ++;
                        jewelry ++;
                        dressShirts ++;
                        womenPants ++;
                        skirts ++;
                        womenSuits ++;
                        raincoats ++;
                        umbrella ++;
                    }
                
                }
            } else {
                
                [[[UIAlertView alloc] initWithTitle:@"Could not calculate what to pack" message:@"Oops seems like the weather condition is too extreme for us to handle sorry! " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
            }
        }  else if (temp >= 10 && temp < 16) {
            if ([weather isEqualToString:@"Clear"] || [weather isEqualToString:@"Sunny"] || [weather isEqualToString:@"Clouds"]) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"casual"]) {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweatshirts ++;
                        jeans ++;
                        leisureShoes ++;
                        boots ++;
                        belt ++;
                        if ([weather isEqualToString:@"Sunny"]) {
                            sunglasses ++;
                        }
                        wristwatch ++;
                        
                    } else {
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweatshirts ++;
                        jeans ++;
                        leisureShoes ++;
                        boots ++;
                        if ([weather isEqualToString:@"Sunny"]) {
                            sunglasses ++;
                        }
                        wristwatch ++;
                        jewelry ++;
                        
                    }
                } else {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        dressShoes ++;
                        boots ++;
                        belt ++;
                        if ([weather isEqualToString:@"Sunny"]) {
                            sunglasses ++;
                        }
                        wristwatch ++;
                        ties ++;
                        dressShirts ++;
                        slacks ++;
                        blazers ++;
                        suits ++;
                        
                    } else {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        dressShoes ++;
                        boots ++;
                        if ([weather isEqualToString:@"Sunny"]) {
                            sunglasses ++;
                        }
                        wristwatch ++;
                        jewelry ++;
                        dressShirts ++;
                        womenPants ++;
                        skirts ++;
                        womenSuits ++;
                    }
                }
            } else if ([weather isEqualToString:@"Snow"] || [weather isEqualToString:@"Rain"]) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"casual"]) {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        leisureShoes ++;
                        boots ++;
                        belt ++;
                        wristwatch ++;
                        raincoats ++;
                        umbrella ++;
                        
                    } else {
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        leisureShoes ++;
                        boots ++;
                        wristwatch ++;
                        jewelry ++;
                        raincoats ++;
                        umbrella ++;
                    }
                } else {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"female"]) {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        dressShoes ++;
                        boots ++;
                        belt ++;
                        wristwatch ++;
                        ties ++;
                        dressShirts ++;
                        slacks ++;
                        blazers ++;
                        suits ++;
                        raincoats ++;
                        umbrella ++;
                        
                    } else {
                        
                        coats ++;
                        hats++;
                        gloves ++;
                        scarves++;
                        t_shirt ++;
                        sweaters ++;
                        jeans ++;
                        dressShoes ++;
                        boots ++;
                        wristwatch ++;
                        jewelry ++;
                        dressShirts ++;
                        womenPants ++;
                        skirts ++;
                        womenSuits ++;
                        raincoats ++;
                        umbrella ++;
                    }
                
                }
            } else {
                
                [[[UIAlertView alloc] initWithTitle:@"Could not calculate what to pack" message:@"Oops seems like the weather condition is too extreme for us to handle sorry! " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
            }
        }
    }
    
    if (temp < -10 || temp > 40) {
        [[[UIAlertView alloc] initWithTitle:@"Could not calculate what to pack" message:@"Oops seems like the temperature is too extreme for us to handle sorry! " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
    } else {
       //round all variables to their maxvalue
        if (underwear > 7) {
            underwear = 7;
        }
        if (socks > 7) {
            socks = 7;
        }
        if (undershirt > 7) {
            undershirt = 7;
        }
        if (bras > 7) {
            bras = 7;
        }
        if (sleepwear > 7) {
            sleepwear = 7;
        }
        if (tights > 7) {
            tights = 7;
        }
        if (underwear > 7) {
            underwear = 7;
        }
        if (dressShirts > 3) {
            dressShirts = 3;
        }
        if (sweaters > 3) {
            sweaters = 3;
        }
        if (blazers > 3) {
            blazers = 3;
        }
        if (slacks > 3) {
            slacks = 3;
        }
        if (womenPants > 3) {
            womenPants = 3;
        }
        if (skirts > 3) {
            skirts = 3;
        }
        if (dresses > 3) {
            dresses = 3;
        }
        if (womenSuits > 3) {
            womenSuits = 3;
        }
        if (tuxedo > 3) {
            tuxedo = 3;
        }
        if (ties > 3) {
            ties = 3;
        }
        if (jackets > 2) {
            jackets = 2;
        }
        if (coats > 2) {
            coats = 2;
        }
        if (raincoats > 2) {
            raincoats = 2;
        }
        if (hats > 2) {
            hats = 2;
        }
        if (gloves > 2) {
            gloves = 2;
        }
        if (scarves > 2) {
            scarves = 2;
        }
        if (t_shirt > 5) {
            t_shirt = 5;
        }
        if (tankTops > 5) {
            tankTops = 5;
        }
        if (sweatshirts > 5) {
            sweatshirts = 5;
        }
        if (jeans > 5) {
            jeans = 5;
        }
        if (shorts > 5) {
            shorts = 5;
        }
        if (exercise_clothing > 5) {
            exercise_clothing = 5;
        }
        if (swimsuit > 5) {
            swimsuit = 5;
        }
        if (athleticShoes > 2) {
            athleticShoes = 2;
        }
        if (leisureShoes > 2) {
            leisureShoes = 2;
        }
        if (dressShoes > 2) {
            dressShoes = 2;
        }
        if (sandals__flip_flops > 2) {
            sandals__flip_flops = 2;
        }
        if (boots > 2) {
            boots = 2;
        }
        if (belt > 2) {
            belt = 2;
        }
        if (wristwatch > 2) {
            wristwatch = 2;
        }
        if (jewelry > 2) {
            jewelry = 2;
        }
        if (glasses > 2) {
            glasses = 2;
        }
        if (sunglasses > 2) {
            sunglasses = 2;
        }
        if (reading_glasses > 2) {
            reading_glasses = 2;
        }
        glasses_cases = reading_glasses + sunglasses + glasses;
        
        if (umbrella > 2) {
            umbrella = 2;
        }
        if (topThermal > 2) {
            topThermal = 2;
        }
        if (bottomThermal > 2) {
            bottomThermal = 2;
        }
        
        AudioServicesPlaySystemSound (systemSoundID);
        whatToPackBTN.hidden = NO;
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
