//
//  InsertVC.m
//  DatabaseHelper
//
//  Created by Razib Chandra Deb on 11/26/15.
//  Copyright © 2015 Razib Chandra Deb. All rights reserved.
//

#import "InsertVC.h"

@interface InsertVC ()

@end

@implementation InsertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)insertTouched:(id)sender {
    
    //NSArray *columnArray = @[@"name",@"age",@"marks"];
    //NSArray *dataArray = @[self.nameTextField.text, self.ageTextField.text,self.marksTextField.text];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    int  age = (int)[self.ageTextField.text integerValue];
    float marks = [self.marksTextField.text floatValue ];
    
    [dictionary setObject:self.nameTextField.text forKey:@"name"];
    [dictionary setObject: [NSNumber numberWithInt:age] forKey:@"age"];
    [dictionary setObject: [NSNumber numberWithFloat:marks] forKey:@"marks"];
    
    [self.helper insertDataIntoTable:@"students" WithDataDictionary: dictionary];
}
@end
