//
//  WhatToPackViewController.m
//  What to pack?
//
//  Created by Georges Kanaan on 2/10/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "WhatToPackViewController.h"

NSInteger forecast_count;

//clothes
//Basics (max value 7)
NSInteger underwear;
NSInteger socks;
NSInteger undershirt;
NSInteger bras;
NSInteger sleepwear;
NSInteger tights;

//dressy (max value 3)
NSInteger dressShirts;
NSInteger sweaters;
NSInteger blazers;
NSInteger slacks;
NSInteger womenPants;
NSInteger skirts;
NSInteger dresses;
NSInteger suits;
NSInteger womenSuits;
NSInteger tuxedo;
NSInteger ties;

//outerwear (max value 2)
NSInteger jackets;
NSInteger coats;
NSInteger raincoats;
NSInteger hats;
NSInteger gloves;
NSInteger scarves;

//casual (max value 5)
NSInteger t_shirt;
NSInteger tankTops;
NSInteger sweatshirts;
NSInteger jeans;
NSInteger shorts;
NSInteger exercise_clothing;
NSInteger swimsuit;

//footwear (max value 2)
NSInteger athleticShoes;
NSInteger leisureShoes;
NSInteger dressShoes;
NSInteger sandals__flip_flops;
NSInteger boots;

//accesories (max value 2)
NSInteger belt;
NSInteger wristwatch;
NSInteger jewelry;
NSInteger glasses;
NSInteger sunglasses;
NSInteger reading_glasses;
NSInteger glasses_cases;
NSInteger umbrella;
//thermals (max value 2)
NSInteger topThermal;
NSInteger bottomThermal;


@interface WhatToPackViewController ()

@end

@implementation WhatToPackViewController

@synthesize mainTableView, underwearCell, undershirtCell, socksCell, brasCell, sleepwearCell, tightsCell;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //configure the tableview
    //auto layout
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    //cells
    //section 1
    underwearCell.textLabel.text = [NSString stringWithFormat:@"%i",underwear];
    undershirtCell.textLabel.text = [NSString stringWithFormat:@"%i",undershirt];
    socksCell.textLabel.text = [NSString stringWithFormat:@"%i",socks];
    brasCell.textLabel.text = [NSString stringWithFormat:@"%i",bras];
    sleepwearCell.textLabel.text = [NSString stringWithFormat:@"%i",sleepwear];
    tightsCell.textLabel.text = [NSString stringWithFormat:@"%i",tights];

    //reloadData
    [mainTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstTimeWhatToPack"]) {
        //how to use app
        [[[UIAlertView alloc] initWithTitle:@"What to pack? Tutorial" message:@"This window shows you what to pack, you can also tap on a cell to put a small checkmark to remind you that you already packed this. To go back to the main window swipe right with one finger." delegate:nil cancelButtonTitle:@"Awesome!" otherButtonTitles:nil, nil] show];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTimeWhatToPack"];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (currentCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        currentCell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    currentCell = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
