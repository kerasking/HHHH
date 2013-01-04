#import <Foundation/Foundation.h>

/*!
 * @abstract Leaderboard Information about the requested object.
 */
@interface MBGLeaderboardResponse : NSObject {
    NSString *_id;
    NSString *_appId;
    NSString *_title;
    NSString *_scoreFormat;
    int      _scorePrecision;
    NSString *_iconUrl;
    BOOL     _allowLowerScore;
    BOOL     _reverse;
    BOOL     _archived;
    double   _defaultScore;
    NSString *_published;
    NSString *_updated;
}
/*!
 * @abstract Leaderboard identifier.
 */
@property (nonatomic, retain) NSString *respId;
/*!
 * @abstract The application ID associated with this Leaderboard.
 */
@property (nonatomic, retain) NSString *appId;
/*!
 * @abstract The title of the leaderboard.
 */
@property (nonatomic, retain) NSString *title;
/*!
 * @abstract The format of the <code>displayValue</code> in this leaderboard.
 */
@property (nonatomic, retain) NSString *scoreFormat;
/*!
 * @abstract The decimal place value for the <code>displayValue</code> in this leaderboard.
 */
@property (nonatomic, assign) int   scorePrecision;
/*!
 * @abstract The URL of the leaderboard icon.
 */
@property (nonatomic, retain) NSString *iconUrl;
/*!
 * @abstract If true, the leaderboard will allow a user to post
 *      a lower score to this leaderboard.  If false, a user's preexisting higher score will NOT be replaced
 *      by an attempt to post a lower score.  This flag allows the developer to avoid "get and set if lower" logic.
 */
@property (nonatomic, assign) BOOL     allowLowerScore;
/*!
 * @abstract If true, lower scores are treated as more desirable.
 *      For example, in golf a lower score is more desirable.
 */
@property (nonatomic, assign) BOOL     reverse;
/*!
 * @abstract Future enhancement field to archive a leaderboard.  Archived
 *      leaderboards will be readable but not writeable.  Currently this field always returns false.
 */
@property (nonatomic, assign) BOOL     archived;
/*!
 * @abstract Default score value given to a user if no score attribute is
 *      specified in previous calls to <code>updateCurrentUserScore</code>.
 */
@property (nonatomic, assign) double defaultScore;
/*!
 * @abstract The date and time when this leaderboard was created.
 *      Uses the date format YYYY-MM-DDThh:mm:ss.
 */
@property (nonatomic, retain) NSString *published;
/*!
 * @abstract The date and time when this leaderboard was updated.
 *      Uses the date format YYYY-MM-DDThh:mm:ss.
 */
@property (nonatomic, retain) NSString *updated;

// internal use
+(id)response;

+(id)responseWith:(NSString*)respId appId:(NSString*)appId title:(NSString*)title scoreFormat:(NSString*)scoreFormat scorePrecision:(int)scorePrecision iconUrl:(NSString*)iconUrl
  allowLowerScore:(BOOL)allowLowerScore reverse:(BOOL)reverse archived:(BOOL)archived defaultScore:(double)defaultScore published:(NSString*)published updated:(NSString*)updated;

-(void)toDebug;
@end
