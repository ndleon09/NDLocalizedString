//
//  NDLocalizedString.m
//
//  Created by Nelson on 11/03/16.
//  Copyright © 2016 Nelson Domínguez León. All rights reserved.
//

#import "NDLocalizedString.h"

NSString *const CUSTOM_BUNDLE_NAME = @"NDLocalizedString.bundle";

@interface NDLocalizedString()

@property (nonatomic, strong) NSBundle *customBundle;

@end

@implementation NDLocalizedString

+(instancetype)sharedInstance
{
    static NDLocalizedString *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NDLocalizedString alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init
{
    if (self = [super init]) {
        [self createCustomBundle];
    }
    return self;
}

-(NSString*)customBundlePath
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    NSString *bundlePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@/", applicationName]];
    return bundlePath;
}

-(void)createCustomBundle
{
    NSString *bundleFilePath = [[self customBundlePath] stringByAppendingString:CUSTOM_BUNDLE_NAME];
    self.customBundle = [NSBundle bundleWithPath:bundleFilePath];
}

-(NSString*)localizedStringForKey:(NSString *)key value:(NSString *)defaultValue
{
    NSString *localizedString = [self.customBundle localizedStringForKey:key value:defaultValue table:nil];
    if (localizedString == nil) {
        return key;
    }
    return localizedString;
}

-(void)downloadLocalizableStringsFromServer
{
    if (self.apiKey == nil || self.defaultLanguage == nil) {
        return;
    }
    
    // Add default language to download list
    if (![self.languages containsObject:self.defaultLanguage]) {
        NSMutableArray *languages = [NSMutableArray arrayWithArray:self.languages];
        [languages insertObject:self.defaultLanguage atIndex:0];
        self.languages = languages;
    }

    // Download strings
    for (NSString *language in self.languages) {

        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://localise.biz/api/export/locale/%@.strings?key=%@", language, self.apiKey]];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error == nil) {
                NSString *folderName = [NSString stringWithFormat:@"%@/%@", CUSTOM_BUNDLE_NAME, [NSString stringWithFormat:@"%@.lproj", [language isEqualToString:self.defaultLanguage] ? @"Base" : language]];
                if(![self saveData:data toFolder:folderName usingFilename:@"Localizable.strings"]) {
                    NSLog(@"Error to save strings file for language: %@", language);
                }
            }
        }];
        [task resume];
    }
}

-(BOOL)saveData:(NSData *)dataToSave toFolder:(NSString *)folder usingFilename:(NSString *)filename
{
    NSString *dataPath = [[self customBundlePath] stringByAppendingPathComponent:folder];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", dataPath, filename];
    if(![dataToSave writeToFile:filePath atomically:YES]) {
        return NO;
    }
    else {
        // DON'T forget to call the next function.
        // Since we do not want the downloaded data to be saved through iCloud
        // Otherwise App would be rejected by Apple. You can only save data in the
        // iCloud if it is created by the user (not downloaded...)
        NSURL *backUrl = [NSURL fileURLWithPath:filePath];
        [self addSkipBackupAttributeToItemAtURL:backUrl];
        NSLog(@"DOWNLOADED AND SAVED: %@ to %@", filename, filePath);
    }
    return YES;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
