/**
 * Social.Common.Leaderboard
 */

#import <Foundation/Foundation.h>
#import "MBGError.h"
#import "MBGOption.h"
#import "MBGLeaderboardResponse.h"
#import "MBGLeaderboardTopScore.h"

/*!
 * @abstract
 * Mobage provides a Common API for updating and retrieving leaderboard information.
 * <br />
 * <code>Leaderboard</code> allows game to configure a collection of leaderboards through the
 * Developer Portal or via HTTP REST endpoints which are then subsequently accessed via this API.
 */
@interface MBGSocialLeaderboard : NSObject {
}

/*!
 * @abstract 
 * Retrieves information about the specified leaderboard. By default, only a limited amount of
 * information is retrieved. Use the <code>fields</code> parameter to retrieve additional
 * information.
 */
+(void)getLeaderboard:(NSString*)leaderboardId
               fields:(NSArray*)fields
            onSuccess:(void (^)(MBGLeaderboardResponse* response))successCB
              onError:(void (^)(MBGError* error))errorCB;
/*!
 * @abstract 
 * Retrieves information about the specified leaderboards. By default, only a limited amount of
 * information is retrieved about each leaderboard. Use the <code>fields</code> parameter to retrieve additional
 * information.
 */
+(void)getLeaderboards:(NSArray*)leaderboardIds
                fields:(NSArray*)fields
             onSuccess:(void (^)(NSArray* response))successCB
               onError:(void (^)(MBGError* error))errorCB;
/*!
 * @abstract 
 * Retrieves information about all of the current user's game leaderboards. By default, only a limited amount of
 * information about each leaderboard is retrieved. Use the <code>fields</code> parameter to retrieve additional
 * information.
 */
+(void)getAllLeaderboards:(NSArray*)fields
                onSuccess:(void (^)(NSArray* response))successCB
                  onError:(void (^)(MBGError* error))errorCB;
/*!
 * @abstract 
 * Retrieves information about the top users of a given leaderboard.  An array of <code>Score</code> objects
 * are returned. By default, only a limited amount of information about each user's <code>Score</code>
 * is retrieved. Use the <code>fields</code> parameter to retrieve additional information.
 */
+(void)getTopScoresList:(NSString*)leaderboardId
                 fields:(NSArray*)fields
                   opts:(MBGOption*)opts
              onSuccess:(void (^)(NSArray* response))successCB
                onError:(void (^)(MBGError* error))errorCB;
/*!
 * @abstract 
 * Retrieves information about the top scores for the specified user's leaderboards.  Said in another way, this API
 * gets the scores for the given user's specified leaderboard.  An array of <code>Score</code> objects
 * are returned. By default, only a limited amount of information about each user's <code>Score</code>
 * is retrieved. Use the <code>fields</code> parameter to retrieve additional information.
 */
+(void)getFriendsScoresList:(NSString*)leaderboardId
                     fields:(NSArray*)fields
                       opts:(MBGOption*)opts
                  onSuccess:(void (^)(NSArray* response))successCB
                    onError:(void (^)(MBGError* error))errorCB;
/*!
 * @abstract 
 * Retrieves top score for the specified user's specified leaderboard.  A single <code>Score</code> object
 * is returned. By default, only a limited amount of information the user's <code>Score</code>
 * is retrieved. Use the <code>fields</code> parameter to retrieve additional information.
 */
+(void)getScore:(NSString*)leaderboardId
         userId:(NSString*)userId   
         fields:(NSArray*)fields
      onSuccess:(void (^)(MBGLeaderboardTopScore* score))successCB
        onError:(void (^)(MBGError* error))errorCB;
/*!
 * @abstract
 * Updates the current user's score in the specified leaderboard.  No additional information is returned.
 */
+(void)updateCurrentUserScore:(NSString*)leaderboardId
                        value:(double)value
                    onSuccess:(void (^)(MBGLeaderboardTopScore* score))successCB
                      onError:(void (^)(MBGError* error))errorCB;
/*!
 * @abstract 
 * Deletes the current user's score in the specified leaderboard.
 */
+(void)deleteCurrentUserScore:(NSString*)leaderboardId
                    onSuccess:(void (^)())successCB
                      onError:(void (^)(MBGError* error))errorCB;

@end
