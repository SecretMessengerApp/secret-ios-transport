// 
// 


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMKeychain : NSObject
+ (nullable NSData *)dataForAccount:(NSString *)accountName;
+ (nullable NSData *)dataForAccount:(NSString *)accountName fallbackToDefaultGroup:(BOOL)fallback;
+ (nullable NSString *)stringForAccount:(NSString *)accountName;
+ (nullable NSString *)stringForAccount:(NSString *)accountName fallbackToDefaultGroup:(BOOL)fallback;
+ (BOOL)hasAccessibleAccountData;

+ (BOOL)setData:(NSData *)data forAccount:(NSString *)accountName;

/// Deletes items of the specified account name
+ (void)deleteAllKeychainItemsWithAccountName:(NSString *)accountName;

/// Deletes all items of all account names
+ (void)deleteAllKeychainItems;

+ (nullable NSString *)defaultAccessGroup;

@end

NS_ASSUME_NONNULL_END
