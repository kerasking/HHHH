//
//  MBGSocialNearBy.h
//  MyNativeTest
//
//  Created by panzaofeng on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBGError.h"
#import "MBGOption.h"
#import "MBGResult.h"

@interface MBGSocialNearBy : NSObject
/*!
 * @abstract Retrieves the nearby friends of current user.
 * @discussion Retrieves the <code>id</code>, <code>displayName</code>, <code>hasApp</code> 
 * and <code>thumbnailUrl</code> fields of the <code>Person</code> data type.
 * To retrieve non-required fields of the <code>Person</code> data type, specify the non-required fields 
 * desired in the <code>fields</code> parameter.
 * of the <code>Person</code> data type, and an optional <code>opt</code> parameter for pagination.
 * @param userId Takes a user ID of the user whose friends will be retrieved with the callback function. 
 * @param fields Takes an array of non-required fields (as NSString) to include in the response to the callback function. 
 * <br/> If <code>null</code>, undefined or an empty array, it retrieves only the required fields.
 * @param options Takes a PagingOption structure containing the start index and count for pagination. <br/>E.g., <code>{start=1; count=100;}</code> 
 * @param onSuccess Retrieves the friends of the given user .
 * @param onError The callback interface that handles errors.
 *
 */
+ (void) getNearbyFriends: (double)disatance 
                  options: (MBGOption *)opt
                onSuccess:( void (^)( NSArray* users, MBGResult* result ) )successCB 
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
 * @param options Takes a PagingOption structure containing the start index and count for pagination. <br/>E.g., <code>{start=1; count=100;}</code> 
 * @param onSuccess Retrieves the friends of the given user .
 * @param onError The callback interface that handles errors.
 *
 */
+ (void) getNearbyUsers: (double)disatance 
                options: (MBGOption *)opt
              onSuccess:( void (^)( NSArray* users, MBGResult* result ) )successCB 
                onError:( void (^)( MBGError* error ) )errorCB;
@end
