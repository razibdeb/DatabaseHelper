//
//  ViewController.h
//  DatabaseHelper
//
//  Created by Razib Chandra Deb on 11/23/15.
//  Copyright © 2015 Razib Chandra Deb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDDbHelper.h"
#import "InsertVC.h"
@interface ViewController : UIViewController
{
    RCDDbHelper *helper;
}
- (IBAction)createTableButtonTouched:(id)sender;

@end

