/**
 * Social.Common.People
 */

#import <Foundation/Foundation.h>
#import "MBGUser.h"
#import "MBGError.h"
#import "MBGOption.h"
#import "MBGResult.h"

/*!
 * @abstract The social API for returning user objects with their social graphs. 
 * @discussion The user object retrieved varies from platform to platform. US platform required fields are <code>id</code>, 
 * <code>displayName</code>, <code>hasApp</code> and <code>thumbnailUrl</code> of the <code>Person</code> data type.
 */
@interface MBGSocialPeople : NSObject
{
}

/*!
 * @abstract Retrieves the current user.
 * @discussion Retrieves the <code>id</code>, <code>displayName</code>, <code>hasApp</code>
 * and <code>thumbnailUrl</code> fields of the <code>Person</code> data type.
 * To retrieve non-required fields of the <code>Person</code> data type, specify the non-required fields desired
 * in the <code>fields</code> parameter.
 * @param fields Takes an array of non-required fields (as NSString) to include in the response to the callback function. 
 * <br/>If <code>null</code> or an empty array, it retrieves only the required fields.
 * @param successCB Retrieves the current user.
 * @param errorCB The callback interface that handles errors.
 */
+ (void) getCurrentUser: (NSArray *)fields 
			  onSuccess:( void (^)( MBGUser* user ) )successCB 
				onError:( void (^)( MBGError* error ) )errorCB;

/*!
 * @abstract Retrieves the friends of a given user.
 * @discussion Retrieves the <code>id</code>, <code>displayName</code>, <code>hasApp</code> 
 * and <code>thumbnailUrl</code> fields of the <code>Person</code> data type.
 * To retrieve non-required fields of the <code>Person</code> data type, specify the non-required fields 
 * desired in the <code>fields</code> parameter.
 * Takes an optional <code>fields</code> parameter to retrieve non-required fields 
 * of the <code>Person</code> data type, and an optional <code>opt</code> parameter for pagination.
 * @param userId Takes a user ID of the user whose friends will be retrieved with the callback function. 
 * @param fields Takes an array of non-required fields (as NSString) to include in the response to the callback function. 
 * <br/> If <code>null</code>, undefined or an empty array, it retrieves only the required fields.
 * @param opt Takes a PagingOption structure containing the start index and count for pagination. <br/>E.g., <code>{start=1; count=100;}</code> 
 * @param successCB Retrieves the friends of the given user .
 * @param errorCB The callback interface that handles errors.
 *
 */
+ (void) getFriends: (NSString *)userId 
			 fields: (NSArray *)fields 
			options: (MBGOption *)opt
		  onSuccess:( void (^)( NSArray* users, MBGResult* result ) )successCB 
			onError:( void (^)( MBGError* error ) )errorCB;

/*!
 * @abstract Retrieves the user's friends playing the current game.
 * @discussion Takes an optional <code>fields</code> parameter to retrieve non-required fields of the 
 * <code>Person</code> data type, and an optional <code>opt</code> parameter for pagination. 
 * @param userId Takes a user ID of the user whose friends will be retrieved with the callback function. 
 * @param fields Takes an array of non-required fields (as NSString) to include in the response to the callback function. 
 * <br/> If <code>null</code>, undefined or an empty array, it retrieves only the required fields.
 * @param opt Takes a PagingOption structure containing the start index and count for pagination. <br/>E.g., <code>{start=1; count=100;}</code> 
 * @param successCB Retrieves the friends of the given user.
 * @param errorCB The callback interface that handles errors.
 *
 */
+ (void) getFriendsWithGame: (NSString *)userId
					 fields: (NSArray *)fields
					options: (MBGOption *)opt
	   onSuccess:( void (^)( NSArray* users, MBGResult* result ) )successCB 
		 onError:( void (^)( MBGError* error ) )errorCB;


/*!
 * @abstract Retrieves the user corresponding to the user ID parameter.
 * @discussion Takes a user ID parameter and retrieves the corresponding user. 
 * Retrieves the <code>id</code>, <code>displayName</code>, <code>hasApp</code> 
 * and <code>thumbnailUrl</code> fields of the <code>Person</code> data type.
 * To retrieve non-required fields of the <code>Person</code> data type, specify the non-required fields 
 * desired in the <code>fields</code> parameter.
 * @param userId Takes the user ID of the user to retrieve.
 * @param fields Takes an array of non-required fields (as NSString) to include in the response to the callback function. 
 * <br/>If <code>null</code> or an empty array, it retrieves only the required fields.
 * @param successCB Retrieves the user specified by the userId parameter.
 * @param errorCB The callback interface that handles errors.
 *
 */
+ (void) getUser:(NSString *)userId
		  fields:(NSArray *)fields 
	   onSuccess:( void (^)( MBGUser* user ) )successCB 
		 onError:( void (^)( MBGError* error ) )errorCB;

/*!
 * @abstract Retrieves an array of users.
 * @discussion Takes one or more user IDs and retrieves an array of users with the callback function. 
 * Retrieves up to 100 users, with no guarantee of retrieving the user array 
 * in the order specified in the <code>fields</code> parameter.
 * Retrieves the <code>id</code>, <code>displayName</code>, <code>hasApp</code> 
 * and <code>thumbnailUrl</code> fields of the <code>Person</code> data type for each user.
 * To retrieve non-required fields of the <code>Person</code> data type, specify the non-required fields 
 * desired in the <code>fields</code> parameter.
 * @param userIds Takes an array of user IDs of the users to retrieve. Minimum array size is 1, and maximum is 100.
 * @param fields Takes an array of non-required fields (as NSString) to include in the response to the callback function. 
 * <br/>If <code>null</code> or an empty array, it retrieves only the required fields.
 * @param successCB Retrieves an array of users specified by the <code>userIds</code> parameter.
 * @param errorCB The callback interface that handles errors.
 *
 */
+ (void) getUsers: (NSArray *)userIds 
		   fields: (NSArray *)fields 
	   onSuccess:( void (^)( NSArray* users, MBGResult* result ) )successCB 
		 onError:( void (^)( MBGError* error ) )errorCB;

@end

