/**
 * Social.Common.Blacklist
 */
#import <Foundation/Foundation.h>
#import "MBGError.h"
#import "MBGOption.h"
#import "MBGResult.h"

//#import "MBGType.h"

/*!
 * @abstract Provides an interface for checking the user's blacklist. 
 */
@interface MBGSocialBlacklist : NSObject

/*!
 * @abstract Determines if a target user ID is in the given user's blacklist.
 * @discussion Takes a user ID and a target user ID to determine if a target user is in the blacklist.
 * If the target user ID parameter is <code>null</code>, it checks the entire blacklist. It retrives
 * an array of target user IDs in the blacklist, or an empty array if none are found. The callback function also receives the total number of
 * target user IDs, the starting index and the number of target IDs returned for paging results.
 *
 * @param userId The user ID for the user corresponding to the blacklist.
 * @param targetUserId The target user ID to check in the blacklist. <br/>If <code>null</code>, it checks the entire blacklist.
 * @param option Takes a PagingOption structure containing the start index and count for pagination. <br/>E.g., <code>{start=1, count=100}</code>
 * Requires start index and count. The minimum start index is 1. If <code>null</code>, undefined or an empty array, the start index is 1 and the count is 50.
 * @param successCB Retrieves an array of user IDs (as NSString) found in the blacklist; otherwise, it retrieves an empty array.
 * @param errorCB The callback interface that handles errors.
 */
+ (void) checkBlacklist :(NSString*) userId 
				  target:(NSString*) targetUserId 
					 opt:(MBGOption*) option 
			   onSuccess:(void (^)( NSArray* listedUserIds, MBGResult* result )) successCB 
				 onError:(void (^)( MBGError* error )) errorCB;


@end
