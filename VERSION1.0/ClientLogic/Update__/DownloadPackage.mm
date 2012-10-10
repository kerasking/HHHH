//
//  DownLoadPackage.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DownloadPackage.h"
#include "KData.h"
#include "KDirectory.h"

#import "Reachability.h"

bool isWifiNetWork()
{
	Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
	if (r == nil || [r currentReachabilityStatus] != ReachableViaWiFi) 
		return false;
	else 
		return true;
}

KData getHttpProxy()
{
	KData proxy = "";
	
	NSDictionary *dict = [[NSMutableDictionary alloc] 
						  initWithContentsOfFile:[NSString stringWithUTF8String:"/private/var/preferences/SystemConfiguration/preferences.plist"]];
	if (!dict)
	{
		return "";
	}
	NSDictionary *secondDict = [dict objectForKey:@"NetworkServices"];
	if (!secondDict)
	{
		[dict release];
		return "";
	}
	for (NSDictionary * key in [secondDict allValues])
	{
		if ([key objectForKey:@"Proxies"] && [key objectForKey:@"com.apple.CommCenter"])
		{
			NSDictionary *thirdDict = [[key objectForKey:@"com.apple.CommCenter"] objectForKey:@"Setup"];
			if (!thirdDict)
				continue;
			
			NSString *apnValue = [thirdDict valueForKey:@"apn"];
			if (apnValue == nil)
			{
				continue;
			}
			
			apnValue = [apnValue lowercaseString];
			
			if ([apnValue isEqualToString:@"cmwap"] || [apnValue isEqualToString:@"3GWAP"])
			{
				proxy = "10.0.0.172";;
			}
			else if ([apnValue isEqualToString:@"cmnet"] || [apnValue isEqualToString:@"3GNET"])
			{
				proxy = "";
			}
		}
	}
	[dict release];
	
	return proxy;
}

void DownloadCallback(void *param, int percent, int pos, int filelen)
{
	DownloadPackage* downer = (DownloadPackage*)param;
	if (downer) 
	{
		downer->m_fileLen = filelen;
		downer->ReflashPercent(percent, pos, filelen);
	}	
}

void* threadExcute(void* ptr)
{
	DownloadPackage* downer = (DownloadPackage*)ptr;
	if (downer) 
	{
		downer->DownloadThreadExcute();
	}
	return NULL;
}

@implementation MainThreadSelector

- (void)runWithParam:(NSArray *)param
{
	NSArray* ary = param;
	NSString* cmd = [ary objectAtIndex:0];
	if ([cmd isEqual:@"didDownloadStatus"]) 
	{
		DownloadPackage* downer = (DownloadPackage*)[[ary objectAtIndex:1] unsignedLongValue];
		DownloadStatus status = (DownloadStatus)[[ary objectAtIndex:2] intValue];
		DownloadPackageDelegate* delegate = dynamic_cast<DownloadPackageDelegate *> (downer->GetDelegate());
		if (delegate) 
		{
			delegate->DidDownloadStatus(downer, status);
		}
		
	}
	else if ([cmd isEqual:@"reflashPercent"])
	{
		DownloadPackage* downer = (DownloadPackage*)[[ary objectAtIndex:1] unsignedLongValue];
		int percent = [[ary objectAtIndex:2] intValue];
		int pos = [[ary objectAtIndex:3] intValue];
		int filelen = [[ary objectAtIndex:4] intValue];
		DownloadPackageDelegate* delegate = dynamic_cast<DownloadPackageDelegate *> (downer->GetDelegate());
		if (delegate) 
		{
			delegate->ReflashPercent(downer, percent, pos, filelen);
		}
	}
}

@end


IMPLEMENT_CLASS(DownloadPackage, NDObject)

DownloadPackage::DownloadPackage()
{	
	m_fileLen = 0;
	m_selObj = [[MainThreadSelector alloc] init];
	m_http = new KHttp();
	m_http->setNotifyCallback(DownloadCallback, this, 1);
}

DownloadPackage::~DownloadPackage()
{
	[m_selObj release];
	delete m_http;
}

void DownloadPackage::FromUrl(const char* url)
{
	m_url = url;
}

void DownloadPackage::ToPath(const char* path)
{
	m_path = path;
}

void DownloadPackage::DidDownloadStatus(DownloadStatus status)
{
	[m_selObj performSelectorOnMainThread:@selector(runWithParam:) 
							   withObject:[NSArray arrayWithObjects:@"didDownloadStatus", 
										  [NSNumber numberWithUnsignedLong:(unsigned long)this], 
										  [NSNumber numberWithInt:(int)status],
										  nil]
							waitUntilDone:NO];
}

void DownloadPackage::ReflashPercent(int percent, int pos, int filelen)
{
	[m_selObj performSelectorOnMainThread:@selector(runWithParam:) 
							   withObject:[NSArray arrayWithObjects:@"reflashPercent", 
										  [NSNumber numberWithUnsignedLong:(unsigned long)this], 
										  [NSNumber numberWithInt:percent],
										  [NSNumber numberWithInt:pos],
										  [NSNumber numberWithInt:filelen],
										  nil]	
							   waitUntilDone:NO];
}

void DownloadPackage::DownloadThreadExcute()
{
	if (m_url.empty() || m_path.empty()) 
	{
		DidDownloadStatus(DownloadStatusFailed);
		return;
	}
	
	NSString* saveDir = [[NSString stringWithUTF8String:m_path.c_str()] stringByDeletingLastPathComponent] ;
	if (!KDirectory::isDirectoryExist([saveDir UTF8String])) 
	{
		if (!KDirectory::createDir([saveDir UTF8String]))
		{
			DidDownloadStatus(DownloadStatusFailed);
			return;
		}
	}	
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (!isWifiNetWork())
	{
		KData proxy = getHttpProxy();
		if (!proxy.isEmpty())
		{
			m_http->setHttpProxy(proxy);
		}
	}
	
	m_http->setTimeout(60 * 1000);
	int donelen = m_http->getHttpFile(m_url.c_str(), m_path.c_str(), 0);
	
	if (m_http->getStatusCode() == 404) 
	{
		DidDownloadStatus(DownloadStatusResNotFound);
	}	
	else if (donelen >= m_fileLen) 
	{
		DidDownloadStatus(DownloadStatusSuccess);
	}
	else 
	{
		DidDownloadStatus(DownloadStatusFailed);
	}
	
	
	[pool release];
}

void DownloadPackage::Download()
{	
	pthread_t pid;
	pthread_create(&pid, NULL, threadExcute, this);	
}

