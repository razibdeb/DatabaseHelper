//
//  ShowDataVC.m
//  DatabaseHelper
//
//  Created by Razib Chandra Deb on 11/26/15.
//  Copyright © 2015 Razib Chandra Deb. All rights reserved.
//

#import "ShowDataVC.h"

@interface ShowDataVC ()

@end

NSArray * dataArray;

@implementation ShowDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark Data

-(void)loadData
{
    RCDDbHelper *helper = [RCDDbHelper getInstance];
    dataArray = [helper getRecordsOfTable:@"students" where:nil];
}

#pragma mark UITableViewDatasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"name"];
    return cell;
}
@end
