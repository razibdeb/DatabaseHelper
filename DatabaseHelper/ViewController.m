//
//  ViewController.m
//  DatabaseHelper
//
//  Created by Razib Chandra Deb on 11/23/15.
//  Copyright © 2015 Razib Chandra Deb. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RCDDbHelper *helper = [RCDDbHelper getInstance];
    NSArray *columnNameArray = @[@"a",@"b",@"c"];
    NSArray *columnTypeArray = @[@"TEXT",@"NUMERIC",@"INTEGER"];
    [helper createTableWithTableName:@"tableName" WithColumnName:columnNameArray withColumnType:columnTypeArray withColVerifyEnabled:YES];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"TEXT" forKey:@"a"];
    [dict setObject:@(10.50) forKey:@"b"];
    [dict setObject:@(50) forKey:@"c"];
    [helper insertDataIntoTable:@"tableName" WithDataDictionary:dict];
    
    //[helper getRowsFromTable:@"tableName" withWhere:nil];
    
    NSArray *colName = [helper getRecordsOfTable:@"tableName" where:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
