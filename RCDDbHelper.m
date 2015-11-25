//
//  RCDDbHelper.m
//  DatabaseHelper
//
//  Created by Razib Chandra Deb on 11/23/15.
//  Copyright © 2015 Razib Chandra Deb. All rights reserved.
//

#import "RCDDbHelper.h"

@implementation RCDDbHelper


//https://www.sqlite.org/datatype3.html
NSString * const SQLITE_TABLE_COLUMN_TYPES[] = { @"INTEGER", @"TEXT", @"BLOB", @"REAL",@"NUMERIC" };
int const SQLITE_TABLE_COLUMN_TYPES_SIZE = 5;

+(RCDDbHelper *)getInstance
{
    static RCDDbHelper *instance;
    @synchronized(self) {
        if(instance==nil)
            instance = [[RCDDbHelper alloc] init];
    }
    return instance;
}


-(bool) Close
{
    return sqlite3_close(database);
}

-(id)init
{
    if ((self = [super init])) {
        NSString *cacheDir = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbPath = [cacheDir stringByAppendingPathComponent:DB_NAME];
        NSLog(@"DBPATH: %@",dbPath);
        
        if (sqlite3_open([dbPath UTF8String], &database) != SQLITE_OK) {
            NSLog(@"RCDDBHelper Failed to open database!");
        }
        else
        {
            NSLog(@"RCDDBHelper Database Opened");
        }
    }
    return self;
}




-(bool)executeQuery:(NSString *)sql statement:(sqlite3_stmt **)statement
{
    const char *sql_stmt = [sql UTF8String];
    return sqlite3_prepare_v2(database, sql_stmt,-1, statement, NULL) == SQLITE_OK;
}


-(bool)executeCommand:(NSString *)sql
{
    sqlite3_stmt *statement;
    const char *sql_stmt = [sql UTF8String];
    if(sqlite3_prepare_v2(database, sql_stmt,-1, &statement, NULL) == SQLITE_OK) {
        bool done = sqlite3_step(statement) == SQLITE_DONE;
        sqlite3_finalize(statement);
        return done;
    }
    return false;
}


-(db_result) createTableWithTableName:(NSString* )tableName WithColumnName:(NSArray *)columnNameArray withColumnType:(NSArray *) columnTypeArray withColVerifyEnabled:(bool) shouldVerifyColumnName
{
    
    if ([columnNameArray count] != [columnTypeArray count] && [columnTypeArray count] > 0) {
        NSLog(@"RCDDBHelper Number of Column & Array elements does not match");
        return INVALID_PARAMETER;
    }
    
    //if verification is enabled
    if (shouldVerifyColumnName) {
        for (int i = 0; i < [columnTypeArray count]; i++) {
            NSString * columnType = [columnTypeArray objectAtIndex:i];
            
            bool matchFound = false;
            for (int j = 0; j < SQLITE_TABLE_COLUMN_TYPES_SIZE; j++) {
                if ([columnType isEqualToString: SQLITE_TABLE_COLUMN_TYPES[j]]) {
                    matchFound = true;
                    break;
                }
            }
            if (matchFound == false) {
                NSLog(@"RCDDBHelper ERROR: Invalid Column Type");
                return INVALID_COMUMN_TYPE;
            }
        }
    }
    
    NSString * createTableCommand = [NSString stringWithFormat:@"CREATE TABLE %@ ( ", tableName];
    
    createTableCommand = [NSString stringWithFormat:@"%@%@ %@",createTableCommand,columnNameArray[0],columnTypeArray[0]];
    for (int i = 1; i < [columnNameArray count]; i++) {
        
        createTableCommand = [NSString stringWithFormat:@"%@, %@ %@",createTableCommand,columnNameArray[i],columnTypeArray[i]];
    }
    createTableCommand = [NSString stringWithFormat:@"%@);",createTableCommand];
    
    NSLog(@"RCDDBHelper Final Command: %@", createTableCommand);
    
    bool res = [self executeCommand:createTableCommand];
    if (res == true) {
        NSLog(@"RCDDBHelper Table creation successful");
        return TABLE_CREATION_SUCCESS;
    }
    else
    {
        NSLog(@"RCDDBHelper ERROR: Table creation failed");
        return  TABLE_CREATION_FAILED;
    }
    return ERROR;
}


-(db_result) insertDataIntoTable:(NSString *) tableName WithDataDictionary:(NSDictionary *) dict
{
    
    NSString *insertCommand = [NSString stringWithFormat:@"INSERT INTO %@ ( ",tableName];
    NSArray *columnArray = [dict allKeys];
    NSArray *dataArray = [dict allValues];
    
    if ([columnArray count] == 0) {
        return INVALID_PARAMETER;
    }
    
    insertCommand = [NSString stringWithFormat:@"%@ %@",insertCommand, [columnArray objectAtIndex:0]];
    
    for (int i = 1; i < [columnArray count]; i++) {
        NSString * colName = [columnArray objectAtIndex:i];
        insertCommand = [NSString stringWithFormat:@"%@ ,%@",insertCommand, colName];
        
    }
    
    insertCommand = [NSString stringWithFormat:@"%@ ) VALUES ( ",insertCommand];
    
    
    if([[ dataArray objectAtIndex:0] isKindOfClass:[NSString class]])
        insertCommand = [NSString stringWithFormat:@"%@ '%@'",insertCommand, [dataArray objectAtIndex:0]];
    else
        insertCommand = [NSString stringWithFormat:@"%@ %@",insertCommand, [dataArray objectAtIndex:0]];
    
    for (int i = 1; i < [columnArray count]; i++) {
        
        id  data = [dataArray objectAtIndex:i];
        
        if ([data isKindOfClass:[NSString class]]) {
            insertCommand = [NSString stringWithFormat:@"%@ ,'%@'",insertCommand, data];
        }
        else
        {
            insertCommand = [NSString stringWithFormat:@"%@ ,%@",insertCommand, data];
        }
    }
    
    insertCommand = [NSString stringWithFormat:@"%@ );",insertCommand];
    
    
    NSLog(@"QUERY: %@", insertCommand);
    
    
    bool res = [self executeCommand:insertCommand];
    if (res == true) {
        NSLog(@"RCDDBHelper Data insertion successful");
        return SUCCESS;
    }
    else
    {
        NSLog(@"RCDDBHelper ERROR: Data insertion failed");
        return  ERROR;
    }
    return ERROR;
}

@end
