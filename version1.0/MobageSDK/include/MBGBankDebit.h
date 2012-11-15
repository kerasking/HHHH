/**
 * Bank.Debit
 */
#import "MBGError.h"
#import "MBGBankInventory.h"

/*! */
@interface MBGBillingItem : NSObject
{
	MBGItemData* _item;
	int _quantity;
}
/*! */
@property (nonatomic, retain) MBGItemData* item;
/*! */
@property (nonatomic, assign) int quantity;

+ (id) billingItem;

@end

/*! */
@interface MBGTransaction : NSObject
{
	NSString* _id;
	NSArray* _items;
	NSString* _comment;
	NSString* _state;
	NSString* _published;
	NSString* _updated;
}
/*! */
@property (nonatomic, retain) NSString* id;
/*! */
@property (nonatomic, retain) NSArray* items;
/*! */
@property (nonatomic, retain) NSString* comment;
/*! */
@property (nonatomic, retain) NSString* state;
/*! */
@property (nonatomic, retain) NSString* published;
/*! */
@property (nonatomic, retain) NSString* updated;

+ (id) transaction;

@end

/*!
 * @abstract Bank.Debit is an interface for purchasing in-game items.
 * @discussion A transaction begins by calling <code>createTransaction()</code>, which presents
 * a UI to the user. If the user follows through with a purchase in the UI, <code>createTransaction()</code> changes its state from 
 * <code>new</code> to <code>authorized</code>. Once <code>createTransaction()</code> executes its callback, the game should call 
 * <code>openTransaction()</code>, which changes the state from <code>authorized</code> to <code>open</code> and puts funds into escrow. 
 * At this point, the game/game server should deliver the purchased items. Once the items have been delivered, the game should call   
 * <code>closeTransaction()</code>. If there is a problem at any point in the transaction lifecycle, you may call <code>cancelTransaction()</code>,
 * which sets the transaction state to <code>canceled</code> and restores funds from escrow back to the user.
 */
@interface MBGBankDebit : NSObject

/*!
 * @abstract Creates a transaction with the <code>transaction.state</code> set to <code>new</code>.
 * @discussion Mobage presents a user interface that prompts the user to confirm the transaction.
 * If the user decides not to proceed with the transaction, the callback error will indicate "user canceled."
 * In the client-only flow, it checks inventory and sets the state to <code>authorized</code>.
 * @param billingItems The billing items for the transaction. <br/><b>Note:</b> The array is limited to one item for this release.
 * @param comment comment for transaction
 * @param successCB callback Retrieves the transaction details.
 * @param cancelCB The callback interface that handles cancel event.
 * @param errorCB The callback interface that handles errors.
 *
 */
+(void)createTransaction:(NSMutableArray*)billingItems
				 comment:(NSString *)comment
			   onSuccess:( void (^)( MBGTransaction* transaction ) )successCB 
				onCancel:( void (^)( ) )cancelCB 
				 onError:( void (^)( MBGError* error ) )errorCB;
/*!
 * @param successCB callback Retrieves the transaction details.
 * @param errorCB The callback interface that handles errors.
 */
+(void)openTransaction:(NSString*)transactionId
				 onSuccess:( void (^)( MBGTransaction* transaction ) )successCB 
				   onError:( void (^)( MBGError* error ) )errorCB;

/*!
 * @param successCB callback Retrieves the transaction details.
 * @param errorCB The callback interface that handles errors.
 */
+(void)closeTransaction:(NSString*)transactionId
				 onSuccess:( void (^)( MBGTransaction* transaction ) )successCB 
				   onError:( void (^)( MBGError* error ) )errorCB;

/*!
 * @abstract Continues processing a transaction in the <code>new</code> state created in the Mobage platform server by the game server.
 * @discussion Checks the inventory, and transitions the <code>transaction.state</code> from <code>new</code> to <code>authorized</code>.
 * Then, it places funds into escrow. The <code>transaction.state</code> transitions from <code>authorized</code> to <code>open</code>, which
 * indicates the game server needs to deliver the virtual item.
 * @param transactionId The <code>transactionId</code> identifying this transaction.
 * @param successCB Retrieves the transaction details.
 * @param errorCB The callback interface that handles errors.
 */
+(void)continueTransaction:(NSString*)transactionId
				 onSuccess:( void (^)( MBGTransaction* transaction ) )successCB 
				  onCancel:( void (^)( ) )cancelCB 
				   onError:( void (^)( MBGError* error ) )errorCB;
/*!
 * @abstract Cancels the transaction, which indicates the transaction was canceled or the virtual item could not be delivered and
 * funds need to be returned.
 * @discussion The <code>transaction.state</code> transitions to <code>canceled.</code>
 * @param transactionId The <code>transactionId</code> identifying this transaction.
 * @param successCB Retrieves the transaction details.
 * @param errorCB The callback interface that handles errors.
 */
+(void)cancelTransaction:(NSString*)transactionId
			   onSuccess:( void (^)( MBGTransaction* transaction ) )successCB 
				 onError:( void (^)( MBGError* error ) )errorCB;

/*!
 * @abstract Retrieves the transaction corresponding to the given transaction ID parameter.
 * @param transactionId The <code>transactionId</code> identifying this transaction.
 * @param successCB Retrieves the transaction details.
 * @param errorCB The callback interface that handles errors.
 */
+(void)getTransaction:(NSString*)transactionId
			onSuccess:( void (^)( MBGTransaction* transaction ) )successCB 
			  onError:( void (^)( MBGError* error ) )errorCB;

/*!
 * @abstract **Not Supported for now**  Retrieves the user's transactions where the state is <code>new</code>, <code>authorized</code> or <code>open</code>.
 * @param successCB Retrieves the transaction details.
 * @param errorCB The callback interface that handles errors.
 */
+(void)getPendingTransactions:( void (^)( MBGTransaction* transaction ) )successCB 
					onError:( void (^)( MBGError* error ) )errorCB;


@end
