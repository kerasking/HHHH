//
//  TokenUtility.h
//
//  Copyright 2012 DeNA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"



@interface TokenUtility : NSObject<ASIHTTPRequestDelegate> {
    
}

+ (TokenUtility*) shareInstance;

- (void) checkLoginStatus;

@end
