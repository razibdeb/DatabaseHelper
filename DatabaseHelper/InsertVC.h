//
//  InsertVC.h
//  DatabaseHelper
//
//  Created by Razib Chandra Deb on 11/26/15.
//  Copyright © 2015 Razib Chandra Deb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDDbHelper.h"
@interface InsertVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *marksTextField;
- (IBAction)insertTouched:(id)sender;

@property (weak) RCDDbHelper * helper;
@end
