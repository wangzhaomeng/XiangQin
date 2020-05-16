//
//  WZMSqliteManager.m
//  WZMFoundation
//
//  Created by Mr.Wang on 16/12/30.
//  Copyright © 2016年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "WZMSqliteManager.h"
#import <objc/runtime.h>
#import <sqlite3.h>
#import "WZMLogPrinter.h"

@interface WZMSqliteManager (){
    NSString *_dataBasePath;
    sqlite3 *_sql3;
}
@end

@implementation WZMSqliteManager

/**
 数据库操纵单例
 */
+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static WZMSqliteManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[WZMSqliteManager alloc] init];
    });
    return manager;
}

//创建自定义数据库
- (instancetype)initWithDBPath:(NSString *)dataBasePath {
    self = [super init];
    if (self) {
        _dataBasePath = dataBasePath;
    }
    return self;
}

/**
 根据-模型类-创建表
 */
- (BOOL)createTableName:(NSString *)tableName modelClass:(Class)modelClass{
    if ([self openDataBase]) {
        if ([self isTableExist:tableName]) {//数据库中该表存在
            [self closeDataBase];
            return YES;
        }
        else{//CREATE TABLE if not exists
            NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@(id integer primary key autoincrement",tableName];
            NSArray *propertys = [self allPropertyNameInClass:modelClass];
            
            for (NSDictionary *dic in propertys) {
                sql = [NSString stringWithFormat:@"%@,%@ %@",sql,dic[@"name"],dic[@"type"]];
            }
            sql = [sql stringByAppendingString:@")"];
            
            int result = sqlite3_exec(_sql3, sql.UTF8String, NULL, NULL, NULL);
            if (result != SQLITE_OK) {
                //NSAssert(NO, @"数据库-创建-失败");
                WZMLog(@"数据库-创建-失败");
            }
            [self closeDataBase];
            return (result == SQLITE_OK);
        }
    }
    return NO;
}

//查询表的所有字段
- (NSArray *)tableInfo:(NSString *)tableName {
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)",tableName];
    if ([self openDataBase]) {
        sqlite3_stmt *stmt = nil;
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        int res = sqlite3_prepare(_sql3, sql.UTF8String, -1, &stmt, NULL);
        if (res == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                char *nameData = (char *)sqlite3_column_text(stmt, 1);
                NSString *columnName = [[NSString alloc] initWithUTF8String:nameData];
                [array addObject:columnName];
            }
        }
        sqlite3_finalize(stmt);
        [self closeDataBase];
        return [array copy];
    }
    return nil;
}

/**
 插入数据-模型
 */
- (BOOL)insertModel:(id)model tableName:(NSString *)tableName{
    NSDictionary *dic = [self DictionaryFromModel:model];
    return [self insertDic:dic tableName:tableName];
}

- (BOOL)insertDic:(NSDictionary *)dic tableName:(NSString *)tableName{
    NSMutableString *keys = [NSMutableString string];
    NSMutableString *values = [NSMutableString string];
    for (int i = 0; i < dic.count; i++) {
        NSString *key = dic.allKeys[i];
        NSString *value = dic.allValues[i];
        if (value == nil) {
            value = @"";
        }
        [keys appendFormat:@"`%@`,",key];
        [values appendFormat:@"'%@',",value];
    }
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) values(%@)",tableName,[keys substringToIndex:keys.length-1],[values substringToIndex:values.length-1]];
    return ![self execute:sql];
}

/**
 删除
 */
- (BOOL)deleteModel:(id)model tableName:(NSString *)tableName primkey:(NSString *)primkey{
    NSDictionary *dic = [self DictionaryFromModel:model];
    return [self deleteDic:dic tableName:tableName primkey:primkey];
}

- (BOOL)deleteDic:(NSDictionary *)dic tableName:(NSString *)tableName primkey:(NSString *)primkey{
    NSString *keySql = nil;
    for (int i = 0; i < dic.count; i++) {
        NSString *key = dic.allKeys[i];
        NSString *value = dic.allValues[i];
        
        if ([primkey isEqualToString:key]) {
            keySql = [NSString stringWithFormat:@"`%@`='%@'", primkey, value];
            break;
        }
    }
    if (keySql == nil) {
        WZMLog(@"数据库删除失败:字段[%@]不存在",primkey);
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",tableName,keySql];
    WZMLog(@"%@",sql);
    return ![self execute:sql];
}

/**
 更新
 */
- (BOOL)updateModel:(id)model tableName:(NSString *)tableName primkey:(NSString *)primkey{
    NSDictionary *dic = [self DictionaryFromModel:model];
    return [self updateDic:dic tableName:tableName primkey:primkey];
}

- (BOOL)updateDic:(NSDictionary *)dic tableName:(NSString *)tableName primkey:(NSString *)primkey{
    NSString *keySql = nil;
    NSMutableString *values = [NSMutableString string];
    for (int i = 0; i < dic.count; i++) {
        NSString *key = dic.allKeys[i];
        NSString *value = dic.allValues[i];
        
        if ([primkey isEqualToString:key]) {
            keySql = [NSString stringWithFormat:@"`%@`='%@'", primkey, value];
            continue;
        }
        [values appendFormat:@"`%@`='%@',", key, value];
    }
    if (keySql == nil) {
        WZMLog(@"数据库更新失败:字段[%@]不存在",primkey);
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where %@",tableName,[values substringToIndex:values.length - 1], keySql];
    WZMLog(@"%@",sql);
    return ![self execute:sql];
}

- (long)insertColumns:(NSArray *)columnNames tableName:(NSString *)tableName {
    NSArray *exColumns = [self insertValidColumns:columnNames tableName:tableName];
    //拼接查询语句
    NSMutableArray *sqls = [[NSMutableArray alloc] init];
    for (NSString *column in exColumns) {
        NSString *sql = [NSString stringWithFormat:@"alter table %@ add %@ text default ''",tableName,column];
        [sqls addObject:sql];
    }
    return [self executes:sqls];
}

- (NSArray *)insertValidColumns:(NSArray *)columnNames tableName:(NSString *)tableName {
    NSMutableArray *exColumns = [columnNames mutableCopy];
    //查询数据库现有字段
    NSArray *columns = [self tableInfo:tableName];
    //遍历数据库现有字段
    for (NSString *column in columns) {
        //判断新增字段是否存在
        if ([exColumns containsObject:column]) {
            [exColumns removeObject:column];
        }
    }
    return [exColumns copy];
}

- (long)deleteColumns:(NSArray *)columnNames tableName:(NSString *)tableName {
    NSArray *exColumns = [self deleteValidColumns:columnNames tableName:tableName];
    //拼接查询语句
    NSMutableArray *sqls = [[NSMutableArray alloc] init];
    for (NSString *column in exColumns) {
        NSString *sql = [NSString stringWithFormat:@"alter table %@ drop column %@",tableName,column];
        [sqls addObject:sql];
    }
    return [self executes:sqls];
}

- (NSArray *)deleteValidColumns:(NSArray *)columnNames tableName:(NSString *)tableName {
    NSMutableArray *exColumns = [columnNames mutableCopy];
    //查询数据库现有字段
    NSArray *columns = [self tableInfo:tableName];
    //遍历将要删除的字段
    for (NSString *columnName in columnNames) {
        //判断数据库是否存在该字段
        if ([columns containsObject:columnName] == NO) {
            [exColumns removeObject:columnName];
        }
    }
    return [exColumns copy];
}

- (long)execute:(NSString *)sql{
    long insertId = 0;
    if ([self openDataBase]) {
        int res = sqlite3_exec(_sql3, sql.UTF8String, NULL, NULL, NULL);
        if (res == SQLITE_OK){
            insertId = (long)sqlite3_last_insert_rowid(_sql3);
        }
        [self closeDataBase];
    }
    return insertId;
}

- (long)executes:(NSArray *)sqls{
    if (sqls.count == 0) return SQLITE_OK;
    long insertId = 0;
    if ([self openDataBase]) {
        for (NSString *sql in sqls) {
            int res = sqlite3_exec(_sql3, sql.UTF8String, NULL, NULL, NULL);
            if (res == SQLITE_OK){
                insertId = (long)sqlite3_last_insert_rowid(_sql3);
            }
        }
        [self closeDataBase];
    }
    return insertId;
}

/**
 查询
 */
- (NSMutableArray *)selectWithSql:(NSString *)sql{
    if ([self openDataBase]) {
        sqlite3_stmt *stmt = nil;
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        int res = sqlite3_prepare(_sql3, sql.UTF8String, -1, &stmt, NULL);
        if (res == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                int count = sqlite3_column_count(stmt);
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
                for (int i = 0; i < count; i++) {
                    const char *columName = sqlite3_column_name(stmt, i);
                    const char *value = (const char*)sqlite3_column_text(stmt, i);
                    if (value != NULL) {
                        NSString *columValue = [NSString stringWithUTF8String:value];
                        [dic setValue:columValue forKey:[NSString stringWithUTF8String:columName]];
                    }else{
                        [dic setValue:@"" forKey:[NSString stringWithUTF8String:columName]];
                    }
                }
                [array addObject:dic];
            }
        }
        sqlite3_finalize(stmt);
        [self closeDataBase];
        return array;
    }
    return nil;
}

/*
 删除数据库
 */
- (BOOL)deleteDataBase:(NSError **)error {
    NSString *filePath = [self dataBasePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [[NSFileManager defaultManager] removeItemAtPath:filePath error:error];
    }
    return YES;
}

/**
 删除表
 */
- (BOOL)deleteTableName:(NSString *)tableName {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
    return ![self execute:sql];
}

#pragma mark - private
/*
 创建存储数据库的路径
 */
- (NSString *)dataBasePath{
    if (!_dataBasePath) {
        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _dataBasePath = [document stringByAppendingPathComponent:@"LLDataBase.sqlite"];
    }
    return _dataBasePath;
}

/*
 打开数据库
 */
- (BOOL)openDataBase{
    const char *filePath = [[self dataBasePath] UTF8String];
    int result = sqlite3_open(filePath, &_sql3);
    if (result == SQLITE_OK) {
        return YES;
    }
    else{
        sqlite3_close(_sql3);
        //NSAssert(NO, @"数据库-打开-失败");
        WZMLog(@"数据库-打开-失败");
        return NO;
    }
}

/*
 关闭数据库
 */
-(BOOL)closeDataBase{
    return !sqlite3_close(_sql3);
}

/*
 判断表是否存在
 */
- (BOOL)isTableExist:(NSString *)tableName{
    BOOL exist = NO;
    sqlite3_stmt *stmt;
    NSString *sql = [NSString stringWithFormat:@"SELECT name FROM sqlite_master where type='table' and name='%@'",tableName];
    if (sqlite3_prepare_v2(_sql3, sql.UTF8String, -1, &stmt, nil) == SQLITE_OK){
        int temp = sqlite3_step(stmt);
        if (temp == SQLITE_ROW){
            exist = YES;
        }
    }
    sqlite3_finalize(stmt);
    return exist; 
}

#pragma merk - runtime
/*
 获取类的所有属性名称与类型
 */
- (NSArray *)allPropertyNameInClass:(Class)cls{
    NSMutableArray *arr = [NSMutableArray array];
    unsigned int count;
    objc_property_t *pros = class_copyPropertyList(cls, &count);
    for (int i = 0; i < count; i++) {
        objc_property_t pro = pros[i];
//        NSString *attributes = [NSString stringWithFormat:@"%s", property_getAttributes(pro)];
//        if ([attributes containsString:@",R,"]) {
//            continue;
//        }
        NSString *name =[NSString stringWithFormat:@"%s",property_getName(pro)];
        NSString *type = [self attrValueWithName:@"T" InProperty:pros[i]];
        //类型转换
        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]||[type isEqualToString:@"I"]) {
            type = @"integer";
        }else if([type isEqualToString:@"f"] || [type isEqualToString:@"d"]){
            type = @"real";
        }else if([type isEqualToString:@"B"]){
            type = @"boolean";
        }else{
            type = @"text";
        }
        NSDictionary *dic = @{@"name":name,@"type":type};
        [arr addObject:dic];
    }
    free(pros);
    return arr;
}

/*
 获取属性的特征值
 */
- (NSString*)attrValueWithName:(NSString*)name InProperty:(objc_property_t)pro{
    unsigned int count = 0;
    objc_property_attribute_t *attrs = property_copyAttributeList(pro, &count);
    for (int i = 0; i < count; i++) {
        objc_property_attribute_t attr = attrs[i];
        if (strcmp(attr.name, name.UTF8String) == 0) {
            return [NSString stringWithUTF8String:attr.value];
        }
    }
    free(attrs);
    return nil;
}

/*
 对象转换为字典
 */
- (NSDictionary *)DictionaryFromModel:(id)model{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    Class modelClass = object_getClass(model);
    unsigned int count = 0;
    objc_property_t *pros = class_copyPropertyList(modelClass, &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t pro = pros[i];
//        NSString *attributes = [NSString stringWithFormat:@"%s", property_getAttributes(pro)];
//        if ([attributes containsString:@",R,"]) {
//            continue;
//        }
        NSString *name = [NSString stringWithFormat:@"%s", property_getName(pro)];
        id value = [model valueForKey:name];
        if (value != nil) {
            [dic setValue:value forKey:name];
        }
    }
    free(pros);
    return dic;
}

@end
