/**
 * Bank.Inventory
 */
#import "MBGError.h"

/*! */
@interface MBGItemData : NSObject
{
	NSString* _id;
	NSString* _name;
	int _price;
	NSString* _description;
	NSString* _imageUrl;
}
/*! */
@property (nonatomic, retain) NSString* id;
/*! */
@property (nonatomic, retain) NSString* name;
/*! */
@property (nonatomic, assign) int price;
/*! */
@property (nonatomic, retain) NSString* description;
/*! */
@property (nonatomic, retain) NSString* imageUrl;

/*! */
+ (id) item;

@end

/*!
 * @abstract Provides an interface to retrieve items from inventory. 
 * @discussion The Mobage platform server is responsible for managing a game's item inventory.
 */
@interface MBGBankInventory : NSObject

/*!
 * @abstract Retrieves the item identified by its product ID from inventory on the Mobage platform server.
 * @param itemId The product ID for the item.
 * @param successCB Retrieves the item from inventory on the Mobage platform server.
 * @param errorCB Callback interface that handles errors.
 *
 */
+(void)getItem:(NSString *)itemId
	 onSuccess:( void (^)( MBGItemData* itemData ) )successCB 
	   onError:( void (^)( MBGError* error ) )errorCB;

@end

