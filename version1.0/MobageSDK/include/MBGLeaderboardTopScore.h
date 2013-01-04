#import <Foundation/Foundation.h>

/*!
 * @abstract Information about the Score object.
 */
@interface MBGLeaderboardTopScore : NSObject {
    NSString *_displayValue;
    NSString *_userId;
    NSInteger _rank;
    double    _value;
}
/*!
 * @abstract Formatted score value based upon the formatting rules for the
 *      requested leaderboard.
 */
@property (nonatomic, retain) NSString *displayValue;
/*!
 * @abstract User ID for this score record.
 */
@property (nonatomic, retain) NSString *userId;
/*!
 * @abstract User's numerical rank for their placement in this leaderboard.
 */
@property (nonatomic, assign) NSInteger rank;
/*!
 * @abstract Raw score value for this user.
 */
@property (nonatomic, assign) double value;

// internal use
+(id)topScore;
+(id)topScoreWith:(NSString*)displayValue userId:(NSString*)userId rank:(NSInteger)rank value:(double)value;

-(void)toDebug;
@end
