//
//  RCDDbHelper.h
//  DatabaseHelper
//
//  Created by Razib Chandra Deb on 11/23/15.
//  Copyright © 2015 Razib Chandra Deb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


#define DB_NAME @"mydb.sqlite"
extern NSString * const SQLITE_TABLE_COLUMN_TYPES[];
extern int const SQLITE_TABLE_COLUMN_TYPES_SIZE;
typedef enum
{
    SUCCESS,
    ERROR,
    TABLE_NOT_EXISTS,
    INVALID_PARAMETER,
    INVALID_COMUMN_TYPE,
    TABLE_CREATION_FAILED,
    TABLE_CREATION_SUCCESS
}result;

@interface RCDDbHelper : NSObject
{
    sqlite3 *database;
    //NSArray *COLUMN_TYPES = @[@"",@""];
}
-(bool)executeCommand:(NSString *)sql;
-(bool)executeQuery:(NSString *)sql statement:(sqlite3_stmt **)statement;
+(RCDDbHelper *)getInstance;
-(result) createTableWithTableName:(NSString* )tableName WithColumnName:(NSArray *)columnNameArray withColumnType:(NSArray *) columnTypeArray withColVerifyEnabled:(bool) shouldVerifyColumnName;
@end


//libsqlite3.dylib