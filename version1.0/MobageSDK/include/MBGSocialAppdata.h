/**
 * Social.Common.Appdata
 */
#import <Foundation/Foundation.h>
#import "MBGError.h"
/*!
 * @abstract Mobage provides a common API for application data, which you may use for both Japan and the US. 
 * @discussion <code>Appdata</code> is consistent with the Open Social <code>osapi.appdata</code> interface, and enables the application to store name/value pairs for application data.
 * To add or update application data, call <code>updateEntries()</code>. To retrieve entries, call <code>getEntries()</code>. To delete entries, 
 * call <code>deleteEntries()</code>.
 */
@interface MBGSocialAppdata : NSObject

/*!
 * @abstract Retrieves a hash of one or more key/value pairs.
 * @discussion If the <code>keys</code> parameter is <code>null</code>, <code>undefined</code> or an empty array, <code>getEntries()</code> returns all key/value pairs to the callback function.
 * @param keys Takes an array of key names (as NSString).
 * <br /> If null or an empty array, it returns all key/value pair entries.
 * @param successCB Retrieves a hash of key/value pairs.
 * @param errorCB The callback interface that handles errors.
 */
+ (void) getEntries : (NSArray*) keys
		   onSuccess:( void (^)( NSDictionary* entries ) )successCB 
			 onError:( void (^)( MBGError* error ) )errorCB;
/*!
 * @abstract Inserts or updates <b>all</b> key/value pairs. It replaces the currently stored key/value pairs.
 * @discussion <b>Note:</b> Limited to 30 key/value pairs per user per game.  Maximum key name limited to 32 bytes. Maximum value limited to 1024 bytes.
 * @param entries Takes a NSDictionary object of key(NSString) / value(NSString) pairs.
 * @param successCB Retrieves the updated entries.
 * @param errorCB The callback interface that handles errors.
 *
 */
+ (void) updateEntries : (NSDictionary*) entries
			  onSuccess:( void (^)( NSArray* keys ) )successCB 
				onError:( void (^)( MBGError* error ) )errorCB;
/*!
 * @abstract Deletes one or more key/value pairs.
 * @param keys Takes an array of key names (as NSString).
 * <br />If <code>null</code>, the return object in the callback will not be defined.
 * @param successCB  Retrieves a hash of the deleted entries.
 * @param errorCB The callback interface that handles errors.
 */
+ (void) deleteEntries : (NSArray*) keys
			  onSuccess:( void (^)( NSArray* keys ) )successCB 
				onError:( void (^)( MBGError* error ) )errorCB;
@end
