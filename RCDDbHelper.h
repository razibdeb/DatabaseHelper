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
}db_result;

@interface RCDDbHelper : NSObject
{
    sqlite3 *database;

}
/*!
 @description Initialize the database if it is not created yet
 @return return the instance of RCDDBHelper.
*/
+(RCDDbHelper *)getInstance;

-(db_result) createTableWithTableName:(NSString* )tableName WithColumnName:(NSArray *)columnNameArray withColumnType:(NSArray *) columnTypeArray withColVerifyEnabled:(bool) shouldVerifyColumnName;

-(db_result) insertDataIntoTable:(NSString *) tableName WithDataDictionary:(NSDictionary *) dict;

//-(NSArray *) getRowsFromTable:(NSString *) tableName withWhere:(NSString *) whereStatement;

/*!
 @description This function finds the rows of table with where statment
 @return return the rows in array with NSDictionary in every index of array.
 Dictionary will contain column names (as keys) and values of that column row as value.
 @param tableName Name of the table
 @param whereStmt Where statment of your query like name=yourname
 */
-(NSArray *) getRecordsOfTable:(NSString *) tableName where:(NSString *)whereStmt;


-(NSArray *) getColumnNamesOfTable:(NSString *)tableName;
-(NSArray *) getColumnNamesForStatement:(sqlite3_stmt *) statement;

-(bool)executeCommand:(NSString *)sql;
@end
