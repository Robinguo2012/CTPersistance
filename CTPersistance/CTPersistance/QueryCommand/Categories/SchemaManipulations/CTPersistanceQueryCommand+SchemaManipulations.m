//
//  CTPersistanceQueryCommand+SchemaManipulations.m
//  CTPersistance
//
//  Created by casa on 15/10/5.
//  Copyright © 2015年 casa. All rights reserved.
//

#import "CTPersistanceQueryCommand+SchemaManipulations.h"

#import "CTPersistanceMarcos.h"

#import "NSMutableArray+CTPersistanceBindValue.h"
#import "NSString+Where.h"

@implementation CTPersistanceQueryCommand (SchemaManipulations)

- (CTPersistanceSqlStatement *)createTable:(NSString *)tableName columnInfo:(NSDictionary *)columnInfo
{
    if (CTPersistance_isEmptyString(tableName)) {
        return nil;
    }
    
    NSMutableArray *columnList = [[NSMutableArray alloc] init];
    
    [columnInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull columnName, NSString * _Nonnull columnDescription, BOOL * _Nonnull stop) {
        if (CTPersistance_isEmptyString(columnDescription)) {
            [columnList addObject:[NSString stringWithFormat:@"`%@`", columnName]];
        } else {
            [columnList addObject:[NSString stringWithFormat:@"`%@` %@", columnName, columnDescription]];
        }
    }];

    NSString *columns = [columnList componentsJoinedByString:@","];

    NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS `%@` (%@);", tableName, columns];

    return [self compileSqlString:sqlString bindValueList:nil error:NULL];
}

- (CTPersistanceSqlStatement *)dropTable:(NSString *)tableName
{
    if (CTPersistance_isEmptyString(tableName)) {
        return nil;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DROP TABLE IF EXISTS `%@`;", tableName];

    return [self compileSqlString:sqlString bindValueList:nil error:NULL];
}

- (CTPersistanceSqlStatement *)createIndex:(NSString *)indexName
                                 tableName:(NSString *)tableName
                         indexedColumnList:(NSArray *)indexedColumnList
                                 condition:(NSString *)condition
                           conditionParams:(NSDictionary *)conditionParams
                                  isUnique:(BOOL)isUnique
{
    if (CTPersistance_isEmptyString(tableName) || CTPersistance_isEmptyString(indexName) || indexedColumnList == nil) {
        return nil;
    }
    
    NSMutableArray <NSInvocation *> *bindValueList = [[NSMutableArray alloc] init];

    NSString *whereString = [condition whereStringWithConditionParams:conditionParams bindValueList:bindValueList];

    NSMutableString *sqlString = nil;
    if (isUnique) {
        sqlString = [NSMutableString stringWithFormat:@"CREATE UNIQUE INDEX IF NOT EXISTS "];
    } else {
        sqlString = [NSMutableString stringWithFormat:@"CREATE INDEX IF NOT EXISTS "];
    }

    NSString *indexedColumnListString = [indexedColumnList componentsJoinedByString:@","];
    [sqlString appendFormat:@"`%@` ON `%@` (%@) ", indexName, tableName, indexedColumnListString];

    if (whereString.length > 0) {
        [sqlString appendFormat:@"WHERE %@;", whereString];
    }

    return [self compileSqlString:sqlString bindValueList:bindValueList error:NULL];
}

- (CTPersistanceSqlStatement *)dropIndex:(NSString *)indexName
{
    NSString *sqlString = [NSString stringWithFormat:@"DROP INDEX IF EXISTS `%@`;", indexName];

    return [self compileSqlString:sqlString bindValueList:nil error:NULL];
}

- (CTPersistanceSqlStatement *)addColumn:(NSString *)columnName columnInfo:(NSString *)columnInfo tableName:(NSString *)tableName
{
    if (CTPersistance_isEmptyString(tableName) || CTPersistance_isEmptyString(columnInfo) || CTPersistance_isEmptyString(columnName)) {
        return nil;
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE `%@` ADD COLUMN `%@` %@;", tableName, columnName, columnInfo];

    return [self compileSqlString:sqlString bindValueList:nil error:NULL];
}

- (CTPersistanceSqlStatement *)columnInfoWithTableName:(NSString *)tableName
{
    NSString *sqlString = [NSString stringWithFormat:@"PRAGMA table_info(`%@`);", tableName];
    return [self compileSqlString:sqlString bindValueList:nil error:NULL];
}

@end
