//
//  ShowDataVC.h
//  DatabaseHelper
//
//  Created by Razib Chandra Deb on 11/26/15.
//  Copyright © 2015 Razib Chandra Deb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDDbHelper.h"
@interface ShowDataVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
