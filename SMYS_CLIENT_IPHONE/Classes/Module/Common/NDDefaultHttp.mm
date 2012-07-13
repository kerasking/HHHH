/*
 *  NDDefaultHttp.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-12.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDDefaultHttp.h"
@interface NDDefaultHttp(delegate)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

- (void)errCallBack:(NDHttpErrCode)code;

@end

@implementation NDDefaultHttp

- (void)dealloc
{
	if (_recvdata) 
	{
		[_recvdata release];
	}
	
	[super dealloc];
}

- (void)AysnSendRequst:(NSString*)url delegate:(NDObject*)object
{
	NDHttpErrCode retCode = NDHttpErrCodeNone;
	
	NSURL *urlObject = nil;
	NSURLRequest *request = nil;
	NSURLConnection *connection = nil;
	
	if (url == nil 
		|| (urlObject = [NSURL URLWithString:url]) == nil
		|| (request  = [[NSURLRequest alloc] initWithURL:urlObject]) == nil
		|| (connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]) == nil
		) 
	{
		retCode = NDHttpErrCodeInvalidUrl;
	}
	
	[connection release];
	[request release];	
	
	_delegate = object;
	
	if (retCode != NDHttpErrCodeNone) 
	{
		[self errCallBack:retCode];
		
		return;
	}
	
	if (_recvdata) 
	{
		[_recvdata release];
	}
	
	_recvdata = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;  
	NSInteger statusCode = [HTTPresponse statusCode];  
	
	NDHttpErrCode retCode = NDHttpErrCodeNone;
	
	if ( 404 == statusCode)
	{
		retCode = NDHttpErrCodeNotFound;
	}
	
	if ( 500 == statusCode )
	{
		retCode = NDHttpErrCodeInternalServerError;
	}
	
	[self errCallBack:retCode];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self errCallBack:NDHttpErrCodeOtherError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (!_recvdata || [_recvdata length] == 0) 
	{
		[self errCallBack:NDHttpErrCodeNoData];
	}
	else if (_delegate) 
	{
		NDDefaultHttpDelegate* delegate = dynamic_cast<NDDefaultHttpDelegate*> (_delegate);
		if (delegate) 
		{
			delegate->OnRecvData(self, (char*)[_recvdata bytes], [_recvdata length]);
		}
	}
	
	if (_recvdata) 
	{
		[_recvdata release];
		_recvdata = nil;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_recvdata appendData:data];
}

- (void)errCallBack:(NDHttpErrCode)code
{
	if (_delegate && code != NDHttpErrCodeNone) 
	{
		NDDefaultHttpDelegate* delegate = dynamic_cast<NDDefaultHttpDelegate*> (_delegate);
		if (delegate) 
		{
			delegate->OnRecvError(self, code);
		}
	}
}

@end

