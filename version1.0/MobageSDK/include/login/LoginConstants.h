//
//  LoginConstants.h
//
//  Copyright 2012 DeNA. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kHomePage;
extern NSString * const GAME_PAGE;
extern NSString * const PARA_AFFCODE;			//parameter name of attcode
extern NSString * const PARA_VERSION;			//parameter name of versoin
extern NSString * const PARA_SIM_NUMBER;		//parameter name of sim number
extern NSString * const PARA_MD5_SIGNATURE;		//parameter name of md5 signature
extern NSString * const PARA_SESSION_ID;		//parameter name of session id
extern NSString * const PARA_USER_ID;			//parameter name of user id
extern NSString * const PARA_GAME_ID;			//parameter name of game id
extern NSString * const PARA_BASE64_STR;		//parameter name of base64
extern NSString * const PARA_AND;				//name of connecting charactor
extern NSString * const PARA_AGENT_KEY;			//parameter name of user agent in http head
extern NSString * const PARA_AGENT_VALUE;		//parameter value of user agent in http head
extern NSString * const REGISTER_PATH;			//register path
extern NSString * const PARA_KEY_PATH;			//the path to get md5 encode key from server
extern NSString * const PARA_OS_KEY;			//the name and version of os
extern NSString * const PARA_OS_VALUE;			//the value that describes os
extern NSString * const PARA_AFFCODE_KEY;		//affcode key
extern NSString * const PARA_AFFCODE_VALUE;		//affcode value
extern NSString * const PARA_VERSION_KEY;		//version key
extern NSString * const PARA_VERSION_VALUE;		//version value
extern NSString * const PARA_PHONE_ID_KEY;		//the unique identifier of iphone
extern NSString * const PARA_PRIVATE_KEY;		// 
extern BOOL const mbg_is_test;					//whether it is under test environment
extern NSString	*		MD5_KEY;				//the result of md5 key
extern NSString * const GAME_ID;				//the GAME ID
extern NSString * const _DOMAIN;				//the domain

extern NSString	* const PLEASE_LOGIN;   //      please login
extern NSString * const PLEASE_LOGIN_VIEW;
extern NSString * const LOGIN_SSO;				//login sso
extern NSString * const LOGIN_COMPLETE;				//login complete
extern NSString * const PLEASE_REGISTER;				//please register
extern NSString * const TUTORIAL_LOGIN;				//tutorial login
extern NSString * const REGISTER_COMPLETE;
extern NSString * const UPDATE_COMPLETE;
extern NSString * const REQUEST_SENT;
extern NSString * const REQUEST_FAIL;
extern NSString * const INPUT_CAN_NOT_EMPTY;
extern NSString * const ACCOUNT_INPUT_INVALID;
extern NSString * const CONFIRM;
extern NSString * const RETRY;
extern NSString * const ERROR_HINT;
extern NSString * const PWD_ERROR;
extern NSString * const NAME_PWD_CANNOT_EMPTY;
extern NSString * const NAME_PWD_ERROR;
extern NSString * const CHOOSE_SEX;
extern NSString * const ERROR;
extern NSString * const CANCEL;
extern NSString * const FORGET_INPUT_INVALID;
extern NSString * const LOGOUT_COMPLETE;
extern NSString * const LOGOUT_FAIL;
extern NSString * const ERR_MSG;
extern NSString * const PWD_SHORT;

@interface LoginConstants : NSObject {
    
}

@end
