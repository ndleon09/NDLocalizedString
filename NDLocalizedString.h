//
//  NDLocalizedString.h
//
//  Created by Nelson on 11/03/16.
//  Copyright © 2016 Nelson Domínguez León. All rights reserved.
//

#import <Foundation/Foundation.h>

// Replace NSLocalizedString calls
#undef NSLocalizedString
#define NSLocalizedString(key, comment) \
[[NDLocalizedString sharedInstance] localizedStringForKey:(key) value:@""]

@interface NDLocalizedString : NSObject

/**
 *  Default language
 */
@property (nonatomic, copy) NSString *defaultLanguage;

/**
 *  Languages to use
 */
@property (nonatomic, strong) NSArray *languages;

/**
 *  ApiKey to download files
 */
@property (nonatomic, copy) NSString *apiKey;

/**
 *  Singleton
 *
 *  @return NDLocalizedString
 */
+(instancetype)sharedInstance;

/**
 *  Call this function after to set languages property
 */
-(void)downloadLocalizableStringsFromServer;

/**
 *  Function to localize strings
 *
 *  @param key          Key
 *  @param defaultValue Default value
 *
 *  @return NSString
 */
-(NSString*)localizedStringForKey:(NSString*)key value:(NSString*)defaultValue;

@end
