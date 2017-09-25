//
//  Gateway.m
//  viper
//
//  Created by vagrant on 9/24/17.
//  Copyright © 2017 vagrant. All rights reserved.
//

#import "Gateway.h"
#import "CityWeatherCloud.h"

@implementation Gateway{
    @private AFHTTPSessionManager* manager;
}

- (instancetype)initWithManager:(AFHTTPSessionManager*)amanager
{
    self = [super init];
    if (self) {
        manager = amanager;
    }
    return self;
}

-(Entity*)perform{
    NSError *error = nil;
    NSString* apiKey = @"9186b8e5715f961fed5d4482516bc296";
    NSString* query = @"ACoruna";
    NSString* url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@", query, apiKey];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager setRequestSerializer:requestSerializer];
    NSDictionary *result = [manager syncGET:url
                           parameters:@{}
                                 task:NULL
                                error:&error];
     if (!error) {
        CityWeatherCloud* city = [[CityWeatherCloud alloc] initWithDictionary:result error:&error];
         if ([city.cod intValue] == 200) {
             Entity* entity = [[Entity alloc]initWithCity:city.name withTemp:city.main.temp withPressure:city.main.pressure withHumidity:city.main.humidity withMaxTemp:city.main.temp_max withMinTemp:city.main.temp_min];
             return entity;
         }else{
             @throw([NSException exceptionWithName:@"Network exception" reason:city.message userInfo:nil]);
         }
     }
    @throw([NSException exceptionWithName:@"Network exception" reason:@"Network error" userInfo:nil]);
}

@end
