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


#pragma mark -
#pragma mark Initialization
+(RCDDbHelper *)getInstance
{
    static RCDDbHelper *instance;
    @synchronized(self) {
        if(instance==nil)
            instance = [[RCDDbHelper alloc] init];
    }
    return instance;
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

-(bool) Close
{
    return sqlite3_close(database);
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

//Data definition language
#pragma mark DDL Functions

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


-(db_result) dropTable:(NSString *) tableName
{
    return ERROR;
}

-(db_result) alterTable:(NSString *) tableName
{
    return ERROR;
}

-(db_result) renameTable:(NSString *) tableName
{
    return ERROR;
}

//Data Manipulation Lanuguage
#pragma mark DML Functions
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

-(NSArray *)getRowsFromTable:(NSString *) tableName withWhere:(NSString *) whereStatement
{
    NSString  * query = [NSString stringWithFormat:@"SELECT * from %@",tableName];
    if (whereStatement) {
        query = [query stringByAppendingFormat:@" WHERE %@",whereStatement];
    }
    NSMutableArray * dataArray =[[NSMutableArray alloc] init];
    sqlite3_stmt* statement =NULL;
    
    int rc =sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
    if(rc == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) //get each row in loop
        {
            
            NSString * name =[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
            NSInteger age =  sqlite3_column_int(statement, 1);
            NSInteger marks =  sqlite3_column_int(statement, 2);
            
            NSDictionary *row =[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",
                                [NSNumber numberWithInteger:age],@"age",[NSNumber numberWithInteger:marks], @"marks",nil];
            
            [dataArray addObject:row];
            NSLog(@"name: %@, age=%ld , marks =%ld",name,(long)age,(long)marks);
            
        }
        NSLog(@"Done");
        sqlite3_finalize(statement);
    }
    else
    {
        NSLog(@"Failed to prepare statement with rc:%d",rc);
    }
    //sqlite3_close(db);
    return dataArray;
}


-(NSArray *) getColumnNamesForStatement:(sqlite3_stmt*) statement
{
    NSMutableArray *columnArray = [[NSMutableArray alloc]init];
    char *colname = NULL;
    int counter = 0;
    do
    {
        colname = (char *) sqlite3_column_name(statement, counter);
        counter++;
        if (colname == NULL) {
            break;
        }
        else
        {
            [columnArray addObject:[NSString stringWithUTF8String:colname]];
        }
    }while (true);
    
    if([columnArray count] == 0)
        return nil;
    
    return columnArray;
}

- (NSArray*)getColumnNamesOfTable:( NSString* _Nonnull  ) tableName {
    char* errMsg = NULL ;
    int result ;
    NSMutableArray* columnNames = nil ;
    NSString* statement ;
    statement = [NSString stringWithFormat:@"pragma table_info(%@)", tableName] ;
    char** results ;
    int nRows ;
    int nColumns ;
    result = sqlite3_get_table(
                               database,        /* An open database */
                               [statement UTF8String], /* SQL to be
                                                        executed */
                               &results,  /* Result is in char *[]
                                           that this points to */
                               &nRows,    /* Number of result rows
                                           written here */
                               &nColumns, /* Number of result columns
                                           written here */
                               &errMsg    /* Error msg written here */
                               ) ;
    
    
    
    
    if (!(result == SQLITE_OK)) {
        NSLog(@"ERROR: %s",errMsg);
        sqlite3_free(errMsg) ;
    }
    else {
        int j ;
        if (j<nColumns) {
            int i ;
            columnNames = [[NSMutableArray alloc] init] ;
            for (i=0; i<nRows; i++) {
                [columnNames addObject:[NSString stringWithFormat:@"%s",results[(i+1)*nColumns + 1] ]] ;
            }
        }
    }
    sqlite3_free_table(results) ;
    
    return columnNames ;
}

-(NSArray *) getRecordsOfTable:(NSString*) tableName where:(NSString *)whereStmt
{
    NSMutableArray * rowArray =[[NSMutableArray alloc] init];
    //    sqlite3* database = NULL;
    sqlite3_stmt* stmt =NULL;
    int rc=0;
    //    rc = sqlite3_open_v2([filePath UTF8String], &db, SQLITE_OPEN_READONLY , NULL);
    //    if (SQLITE_OK != rc)
    //    {
    //        sqlite3_close(db);
    //        NSLog(@"Failed to open db connection");
    //    }
    //    else
    //    {
    NSString  * query = [NSString stringWithFormat:@"SELECT * from %@",tableName];
    if(whereStmt)
    {
        query = [query stringByAppendingFormat:@" WHERE %@",whereStmt];
    }
    
    rc =sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, NULL);
    if(rc == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) //get each row in loop
        {
            NSMutableDictionary *rowDictionary = [[NSMutableDictionary alloc] init];
            NSArray *columnNames = [ self getColumnNamesOfTable:tableName];
            int columnCount = 0;
            for (NSString *columnName in columnNames) {
                //get column name
                const char * ch = (const char *)sqlite3_column_text(stmt, columnCount);
                if(ch != NULL){
                    NSString * columnData =[NSString stringWithUTF8String:ch];
                    if (columnData != NULL) {
                        [rowDictionary setObject:columnData forKey:columnName];
                    }
                }
                
                columnCount++;
            }
            // NSString * name =[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
            // NSInteger age =  sqlite3_column_int(stmt, 2);
            // NSInteger marks =  sqlite3_column_int(stmt, 3);
            
            //                NSDictionary *rowData =[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",
            //                                        [NSNumber numberWithInteger:age],@"age",[NSNumber numberWithInteger:marks], @"marks",nil];
            if([rowDictionary count] > 0)
                [rowArray addObject:rowDictionary];
            //  NSLog(@"name: %@, age=%ld , marks =%ld",name,(long)age,(long)marks);
            
        }
        NSLog(@"Done  %@", rowArray);
        sqlite3_finalize(stmt);
    }
    else
    {
        NSLog(@"Failed to prepare statement with rc:%d",rc);
    }
    sqlite3_close(database);
    //    }
    
    return rowArray;
    
}


#pragma mark Utilities

-(NSString *) getDbFilePath
{
    NSString * docsPath= NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    return [docsPath stringByAppendingPathComponent:DB_NAME];
}




@end
