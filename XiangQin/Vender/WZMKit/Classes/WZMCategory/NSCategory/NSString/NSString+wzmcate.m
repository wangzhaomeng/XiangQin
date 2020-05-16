//
//  NSString+wzmcate.m
//  test
//
//  Created by wangzhaomeng on 16/7/26.
//  Copyright © 2016年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "NSString+wzmcate.h"
#import "NSDateFormatter+wzmcate.h"
#import "WZMLogPrinter.h"
#import "WZMDefined.h"
//MD5加密
#import <CommonCrypto/CommonCrypto.h>

NSString *const CHINA_MOBILE  = @"China Mobile";  //中国移动
NSString *const CHINA_TELECOM = @"China Telecom"; //中国电信
NSString *const CHINA_UNICOM  = @"China Unicom";  //中国联通
NSString *const UNKNOW        = @"Unknow";        //未识别
@implementation NSString (wzmcate)

#pragma mark - 进制转换
+ (NSString *)wzm_getHexByDecimal:(NSString *)decimal {
    return [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1lx",(long)[decimal integerValue]]];
}

+ (NSString *)wzm_getDecimalByHex:(NSString *)hex {
    return [NSString stringWithFormat:@"%lu",strtoul([hex UTF8String],0,16)];
}

+ (NSString *)wzm_getBinaryByDecimal:(NSInteger)decimal {
    NSString *binary = @"";
    while (decimal) {
        binary = [[NSString stringWithFormat:@"%ld", (long)(decimal%2)] stringByAppendingString:binary];
        if (decimal / 2 < 1) {
            break;
        }
        decimal = decimal / 2 ;
    }
    if (binary.length % 4 != 0) {
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    return binary;
}

+ (NSInteger)wzm_getDecimalByBinary:(NSString *)binary {
    
    NSInteger decimal = 0;
    for (int i=0; i<binary.length; i++) {
        
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"]) {
            
            decimal += pow(2, i);
        }
    }
    return decimal;
}

+ (NSString *)wzm_getHexByBinary:(NSString *)binary {
    NSMutableDictionary *binaryDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [binaryDic setObject:@"0" forKey:@"0000"];
    [binaryDic setObject:@"1" forKey:@"0001"];
    [binaryDic setObject:@"2" forKey:@"0010"];
    [binaryDic setObject:@"3" forKey:@"0011"];
    [binaryDic setObject:@"4" forKey:@"0100"];
    [binaryDic setObject:@"5" forKey:@"0101"];
    [binaryDic setObject:@"6" forKey:@"0110"];
    [binaryDic setObject:@"7" forKey:@"0111"];
    [binaryDic setObject:@"8" forKey:@"1000"];
    [binaryDic setObject:@"9" forKey:@"1001"];
    [binaryDic setObject:@"A" forKey:@"1010"];
    [binaryDic setObject:@"B" forKey:@"1011"];
    [binaryDic setObject:@"C" forKey:@"1100"];
    [binaryDic setObject:@"D" forKey:@"1101"];
    [binaryDic setObject:@"E" forKey:@"1110"];
    [binaryDic setObject:@"F" forKey:@"1111"];
    
    if (binary.length % 4 != 0) {
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    NSString *hex = @"";
    for (int i=0; i<binary.length; i+=4) {
        NSString *key = [binary substringWithRange:NSMakeRange(i, 4)];
        NSString *value = [binaryDic objectForKey:key];
        if (value) {
            hex = [hex stringByAppendingString:value];
        }
    }
    return hex;
}

+ (NSString *)wzm_getBinaryByHex:(NSString *)hex {
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binary = @"";
    for (int i=0; i<[hex length]; i++) {
        NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            binary = [binary stringByAppendingString:value];
        }
    }
    return binary;
}

+ (NSString *)wzm_getHexByData:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

#pragma mark - 时间、日期
+ (NSString *)wzm_getAstroByBirthday:(NSDate *)birthday {
    NSArray *dateArray = [self wzm_dateArrayFromDate:birthday];
    NSInteger m = [dateArray[1] integerValue];
    NSInteger d = [dateArray[2] integerValue];
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    if (m<1||m>12||d<1||d>31){
        return @"错误日期格式!";
    }
    if(m==2 && d>29){
        return @"错误日期格式!!";
    }else if(m==4 || m==6 || m==9 || m==11) {
        if (d>30) {
            return @"错误日期格式!!!";
        }
    }
    result = [NSString stringWithFormat:@"%@座",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
    return result;
}

+ (NSString *)wzm_getAgeByBirthday:(NSDate *)birthday {
    //出生日期转换 年月日
    NSArray *birthDay = [self wzm_dateArrayFromDate:birthday];
    NSInteger brithDateYear  = [birthDay[0] integerValue];
    NSInteger brithDateMonth = [birthDay[1] integerValue];
    NSInteger brithDateDay   = [birthDay[2] integerValue];
    
    //获取系统当前 年月日
    NSArray *currentDate = [self wzm_dateArrayFromDate:[NSDate date]];
    NSInteger currentDateYear  = [currentDate[0] integerValue];
    NSInteger currentDateMonth = [currentDate[1] integerValue];
    NSInteger currentDateDay   = [currentDate[2] integerValue];
    
    //计算年龄
    NSInteger iAge = currentDateYear - brithDateYear - 1;
    if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)){
        iAge++;
    }
    NSString *ageStr = [NSString stringWithFormat:@"%ld",(long)iAge];
    return ageStr;
}

//private
+ (NSArray *)wzm_dateArrayFromDate:(NSDate *)date {
    NSDateFormatter *selectDateFormatter = [NSDateFormatter wzm_dateFormatter:@"yyyy-MM-dd"];
    NSString *dateAndTime = [selectDateFormatter stringFromDate:date];
    NSArray *dateArray = [dateAndTime componentsSeparatedByString:@"-"];
    return dateArray;
}

+ (NSString *)wzm_getTimeStampByDate:(NSDate *)date {
    NSTimeInterval interval = [date timeIntervalSince1970]*1000;
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)interval];
    return timeStamp;
}

+ (NSString *)wzm_getTimeStringByDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [NSDateFormatter wzm_defaultDateFormatter];
    NSString *timeString = [dateFormatter stringFromDate:date];
    return timeString;
}

+ (NSString *)wzm_getDTimeByDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    // 1.获得当前时间的年月日
    NSDate *nowDate = [NSDate date];
    NSDateComponents *nowCmps = [calendar components:unit fromDate:nowDate];
    // 2.获得指定日期的年月日
    NSDateComponents *sinceCmps = [calendar components:unit fromDate:date];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter wzm_dateFormatter:@"yyyy年MM月dd日 HH:mm"];
    NSString *time = [dateFormatter stringFromDate:date];
    if ((sinceCmps.year == nowCmps.year) && (sinceCmps.month == nowCmps.month)) {
        if (nowCmps.day - sinceCmps.day == 0) {
            //今天
            return [NSString stringWithFormat:@"今天 %@",[time componentsSeparatedByString:@" "].lastObject];
        }
        else if (nowCmps.day - sinceCmps.day == 1) {
            //昨天
            return [NSString stringWithFormat:@"昨天 %@",[time componentsSeparatedByString:@" "].lastObject];
        }
    }
    return time;
}

#pragma mark - 类方法
+ (BOOL)wzm_isBlankString:(NSString *)str {
    if ([str isKindOfClass:[NSString class]] == NO) {
        return YES;
    }
    if ([str isEqualToString:@""] ||
        [str isEqualToString:@"(null)"] ||
        [str isEqualToString:@"<null>"]) {
        return YES;
    }
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+ (BOOL)wzm_isContainChinese:(NSString *)str {
    for(int i = 0; i < [str length];i ++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
            return YES;
    }
    return NO;
}

+ (NSString *)wzm_getJsonByObj:(id)obj {
    if ([obj isKindOfClass:[NSString class]]) {
        return (NSString *)obj;
    }
    if ([obj isKindOfClass:[NSArray class]] ||
        [obj isKindOfClass:[NSDictionary class]]) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:kNilOptions error:&error];
        NSString *json = @"";
        if (data) {
            json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        return json;
    }
    return @"";
}

+ (id)wzm_getObjByJson:(NSString *)json {
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
}

+ (NSString *)wzm_getHexByColor:(UIColor *)color {
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    return [NSString stringWithFormat:@"#%x%x%x", (int)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}

+ (NSString *)wzm_getBase64ByImage:(UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}

+ (NSString *)wzm_getStringByFormat:(NSString *)value,... {
    va_list list;
    va_start(list, value);
    NSMutableString* string = [NSMutableString stringWithString: value];
    while (YES) {
        NSString *stringTemp = va_arg(list, NSString*);
        if (!stringTemp) { break; }
        [string appendString: stringTemp];
    }
    va_end(list);
    return string;
}

+ (NSString *)wzm_getRandomWithConut:(int)count {
    char data[count];
    for (int x=0;x<count;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:count encoding:NSUTF8StringEncoding];
}

+ (NSString *)wzm_getUniqueString {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uniqueId = (__bridge NSString *)uuidStringRef;
    CFRelease(uuidStringRef);
    return uniqueId;
}

+ (NSString *)wzm_getChineseByArebic:(NSString *)arebic {
    NSString *str = arebic;
    NSArray *arabic_numerals = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *chinese_numerals = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零"];
    NSArray *digits = @[@"个",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千",@"兆"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chinese_numerals forKeys:arabic_numerals];
    
    NSMutableArray *sums = [NSMutableArray array];
    for (int i = 0; i < str.length; i ++) {
        NSString *substr = [str substringWithRange:NSMakeRange(i, 1)];
        NSString *a = [dictionary objectForKey:substr];
        NSString *b = digits[str.length -i-1];
        NSString *sum = [a stringByAppendingString:b];
        if ([a isEqualToString:chinese_numerals[9]]) {
            if([b isEqualToString:digits[4]] || [b isEqualToString:digits[8]]) {
                sum = b;
                if ([[sums lastObject] isEqualToString:chinese_numerals[9]]) {
                    [sums removeLastObject];
                }
            }
            else {
                sum = chinese_numerals[9];
            }
            
            if ([[sums lastObject] isEqualToString:sum]) {
                continue;
            }
        }
        [sums addObject:sum];
    }
    NSString *sumStr = [sums componentsJoinedByString:@""];
    NSMutableString *chinese = [[sumStr substringToIndex:sumStr.length-1] mutableCopy];
    if ([chinese hasPrefix:@"一十"]) {
        [chinese deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    WZMLog(@"%@",str);
    WZMLog(@"%@",chinese);
    return [chinese copy];
}

+ (NSString *)wzm_getTimeBySecond:(NSInteger)second {
    NSString *time;
    if (second < 60) {
        time = [NSString stringWithFormat:@"00:%02ld",(long)second];
    }
    else {
        if (second < 3600) {
            time = [NSString stringWithFormat:@"%02ld:%02ld",(long)(second/60),(long)(second%60)];
        }
        else {
            time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)(second/3600),(long)((second-second/3600*3600)/60),(long)(second%60)];
        }
    }
    return time;
}

+ (NSString *)wzm_getLaunchImageName {
#if WZM_APP
    CGSize viewSize = [UIApplication sharedApplication].delegate.window.bounds.size;
    //竖屏
    NSString *viewOrientation = @"Portrait";
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return launchImageName;
#endif
    return @"";
}

+ (NSString *)wzm_getStringByData:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];;
}

+ (NSString *)wzm_getPasteboardString {
    return [[UIPasteboard generalPasteboard] string];
}

+ (void)wzm_setPasteboardString:(NSString *)string {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = string;
}

///pragma mark - emoji表情
+ (unsigned int)wzm_emojiCodeToSymbol:(unsigned int)c {
    return ((((0x808080F0|(c&0x3F000)>>4)|(c&0xFC0)<<10)|(c&0x1C000)<<18)|(c&0x3F)<<24);
}

+ (NSString *)wzm_getEmojiByIntCode:(unsigned int)intCode {
    unsigned int symbol = [self wzm_emojiCodeToSymbol:intCode];
    NSString *string = [[NSString alloc] initWithBytes:&symbol length:sizeof(symbol) encoding:NSUTF8StringEncoding];
    if (string == nil) {
        string = [NSString stringWithFormat:@"%C", (unichar)intCode];
    }
    return string;
}

+ (NSString *)wzm_getEmojiByStringCode:(NSString *)stringCode {
    NSScanner *scanner = [[NSScanner alloc] initWithString:stringCode];
    unsigned int intCode = 0;
    [scanner scanHexInt:&intCode];
    return [self wzm_getEmojiByIntCode:intCode];
}

+ (CGFloat)wzm_heightWithStr:(NSString *)string width:(CGFloat)width font:(UIFont *)font {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 1;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                    attributes:attributes context:nil].size;
    return ceilf(size.height);
}

#pragma mark - 实例方法
- (NSString *)wzm_getMD5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), digest ); //This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return [output copy];
}

///unicode编码
- (NSString *)wzm_getUniEncode {
    NSUInteger length = [self length];
    NSMutableString *muStr = [NSMutableString stringWithCapacity:0];
    for (int i = 0;i < length; i++) {
        unichar _char = [self characterAtIndex:i];
        if ( _char < 0x9fff && _char > 0x4e00) {
            [muStr appendFormat:@"\\u%x",[self characterAtIndex:i]];
        }
        else {
            [muStr appendFormat:@"%@",[self substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    return [muStr copy];
}

///unicode解码
- (NSString *)wzm_getUniDecode {
    NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\%u" withString:@"\\U"];
    NSString *tempStr3 = [tempStr2 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr4 = [[@"\"" stringByAppendingString:tempStr3] stringByAppendingString:@"\""];
    NSData   *tempData = [tempStr4 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

///URLEnCode编码
- (NSString *)wzm_getURLEncoded {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)wzm_getURLEncoded2 {
    CFStringRef cfUrlEncodedString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                (CFStringRef)self,NULL,
                                                (CFStringRef)@"!#$%&'()*+,/:;=?@[]",
                                                kCFStringEncodingUTF8);
    NSString *str = (__bridge NSString *)cfUrlEncodedString;
    CFRelease(cfUrlEncodedString);
    return str;
}

- (NSString *)wzm_getURLDecoded {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        return [self stringByRemovingPercentEncoding];
    }
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)wzm_enumerateSubstrings:(void(^)(NSString *subStr, NSRange range))completion {
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (completion) completion(substring,substringRange);
    }];
}

- (NSString *)wzm_mstchStrWithRegular:(NSString *)regular {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:regular
                                  options:0
                                  error:&error];
    if (!error) {
        NSTextCheckingResult *match = [regex firstMatchInString:self
                                                        options:0
                                                          range:NSMakeRange(0, [self length])];
        if (match) {
            NSString *result = [self substringWithRange:match.range];
            return result;
        }
    }
    return nil;
}

- (NSString *)wzm_mstchStrBetweenStr1:(NSString *)str1 str2:(NSString *)str2 {
    NSError *error;
    NSString *regular = [NSString stringWithFormat:@"%@(.*)%@",str1,str2];
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:regular
                                  options:0
                                  error:&error];
    if (!error) {
        NSTextCheckingResult *match = [regex firstMatchInString:self
                                                        options:0
                                                          range:NSMakeRange(0, [self length])];
        if (match) {
            NSString* result = [self substringWithRange:[match rangeAtIndex:1]];
            return result;
        }
    }
    return self;
}

- (NSArray *)wzm_componentsByStringSet:(NSString *)stringSet {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:stringSet];
    return [self componentsSeparatedByCharactersInSet:characterSet];
}

- (NSArray *)wzm_specifiedWithStartASC:(int)start endASC:(int)end unnecessaries:(NSArray **)unnecessaries {
    NSString *result = @"";
    NSString *other = @"";
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *others = [NSMutableArray arrayWithCapacity:0];
    for(int i = 0; i < [self length];i ++){
        int a = [self characterAtIndex:i];
        
        if( a >= start && a <= end) {
            result = [result stringByAppendingString:[self substringWithRange:NSMakeRange(i, 1)]];
            if (other.length) {
                [others addObject:other];
                other = @"";
            }
            if (i == self.length-1) {
                if (result.length) {
                    [results addObject:result];
                    result = @"";
                }
            }
        }
        else {
            other = [other stringByAppendingString:[self substringWithRange:NSMakeRange(i, 1)]];
            if (result.length) {
                [results addObject:result];
                result = @"";
            }
            if (i == self.length-1) {
                if (other.length) {
                    [others addObject:other];
                    other = @"";
                }
            }
        }
    }
    *unnecessaries = [others copy];
    return [results copy];
}

- (NSString *)wzm_getPinyin {
    NSMutableString *pinyin = [self mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin,NULL,kCFStringTransformMandarinLatin,NO);//带音标的拼音
    CFStringTransform((__bridge CFMutableStringRef)pinyin,NULL,kCFStringTransformStripCombiningMarks,NO);//去除音标
    //return [pinyin uppercaseString];//全部大写
    return pinyin;
}

- (NSString *)wzm_getLowercase {
    return [self lowercaseString];
}

- (NSString *)wzm_getUppercase {
    return [self uppercaseString];
}

/*
 NSArray *ary = @[@"1a我",@"_b是",@"王",@"f照",@"D猛"];
 NSArray *myary = [ary sortedArrayUsingSelector:@selector(compareOtherString:)];
 WZMLog(@"array=%@",myary);
 */
- (NSComparisonResult)wzm_compareOtherString:(NSString *)otherString {
    return [[self wzm_getPinyin] localizedCompare:[otherString wzm_getPinyin]];
}

- (NSString *)wzm_deleteSpecialCharacter {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"[` ~!@#$%^&*()_\\-+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]"];
    return [[self componentsSeparatedByCharactersInSet:set] componentsJoinedByString: @""];
}

- (NSString *)wzm_deleteAllWhitespace {
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSString *)wzm_deleteHeadAndTailWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end

@implementation NSMutableString (wzmcate)


@end
