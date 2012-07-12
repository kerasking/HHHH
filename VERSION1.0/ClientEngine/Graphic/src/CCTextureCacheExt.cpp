/*
 *  CCTextureCacheExt.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-7.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "CCTextureCacheExt.h"
// 
// #include "CCTexture2D.h"
// #include "CCFileUtils.h"
// #include "NDColorPool.h"
// #include "cpLog.h"
// #include "ccMacros.h"
// 
// int readInt(const Byte* data, int offset) {
// 	return ((data[offset] & 0xFF) << 24) | ((data[offset + 1] & 0xFF) << 16) | ((data[offset + 2] & 0xFF) << 8) | (data[offset + 3] & 0xFF);
// }
// 
// void analyze(const Byte* data, int* para) {
// 	int offset = 8;
// 	int chunkLen = 0;
// 	while (data[offset + 4] != 0x50 || data[offset + 5] != 0x4c || data[offset + 6] != 0x54 || data[offset + 7] != 0x45) {
// 		chunkLen = readInt(data, offset);
// 		offset += (4 + 4 + chunkLen + 4);
// 	}
// 	chunkLen = readInt(data, offset);
// 	para[2] = chunkLen / 3;
// 	para[0] = offset + 8;
// 	para[1] = offset + 8 + chunkLen;
// }
// 
// void replaceColor(char* data, int* para, int oldColor, int newColor) {
// 	char rr = (char) ((oldColor >> 16) & 0xff);
// 	char gg = (char) ((oldColor >> 8) & 0xff);
// 	char bb = (char) (oldColor & 0xff);
// 	for (int i = 0, offset = para[0]; i < para[2]; i++, offset += 3) {
// 		if (rr == data[offset] && gg == data[offset + 1] && bb == data[offset + 2]) {
// 			data[offset] = (char) ((newColor >> 16) & 0xff);
// 			data[offset + 1] = (char) ((newColor >> 8) & 0xff);
// 			data[offset + 2] = (char) (newColor & 0xff);
// 			break;
// 		}
// 	}
// }
// 
// int update_crc(char* buf, int off, int len) {
// 	uint c = 0xffffffff;
// 	int n, k;
// 	uint xx;
// 	int crc_table[256] = { 0 };
// 	
// 	for (n = 0; n < 256; n++) {
// 		xx = n;
// 		for (k = 0; k < 8; k++) {
// 			if ((xx & 1) == 1) {
// 				xx = 0xedb88320 ^ (xx >> 1);
// 			} else {
// 				xx = xx >> 1;
// 			}
// 		}
// 		crc_table[n] = xx;
// 	}
// 	
// 	for (n = off; n < len + off; n++) {
// 		c = crc_table[(c ^ buf[n]) & 0xff] ^ (c >> 8);
// 	}
// 	return (c ^ 0xffffffff);
// }
// 
// void fillData(char* data, int* para) {
// 	int checksum = update_crc(data, para[0] - 4, para[2] * 3 + 4);
// 	data[para[1]] = (char) ((checksum >> 24) & 0xff);
// 	data[para[1] + 1] = (char) ((checksum >> 16) & 0xff);
// 	data[para[1] + 2] = (char) ((checksum >> 8) & 0xff);
// 	data[para[1] + 3] = (char) ((checksum) & 0xff);
// }
// 
// @implementation CCTextureCache(ChangeColor)
// 
// -(CCTexture2D*) addColorImage: (NSString*)imageName
// {
// 	NSAssert(imageName != NULL, @"TextureCache: imageName MUST not be nill");
// 
// 	NSArray* arrName = [imageName componentsSeparatedByString:@"@"];
// 	if ([arrName count] == 1 || [arrName count] == 0) {
// 		return [self addImage:imageName];
// 	}
// 	
// 	int colorIndex = [(NSString*)[arrName objectAtIndex:1] intValue];
// 	if (colorIndex < 1) {
// 		return [self addImage:[arrName objectAtIndex:0]];
// 	}
// 	
// 	NSString* colorFile = [(NSString*)[arrName objectAtIndex:0] stringByReplacingOccurrencesOfString:@".png" withString:@".ini"];
// 	const char* pColorFile = [colorFile UTF8String];
// 	CCTexture2D * tex = NULL;
// 	
// 	// MUTEX:
// 	// Needed since addImageAsync calls this method from a different thread
// 	[dictLock_ lock];
// 	
// 	tex=[textures_ objectForKey: imageName];
// 	
// 	if( ! tex ) {
// 		NDColorPool& colorPool = NDColorPoolObj;
// 		VEC_COLOR_ARRAY changeColor;
// 		
// 		// 换色: 1.加载颜色数组
// 		bool bChangeSuc = false;
// 		if (colorPool.GetColorFromPool(pColorFile, colorIndex, changeColor)) {
// 			VEC_COLOR_ARRAY originColor;
// 			if (colorPool.GetColorFromPool(pColorFile, 0, originColor)) {
// 				NSData* data = [NSData dataWithContentsOfFile:[arrName objectAtIndex:0]];
// 				
// 				int parameter[3] = { 0, 0, 0 };
// 				
// 				analyze((const Byte*)[data bytes], parameter);
// 				
// 				NSUInteger len = [data length];
// 				char* buf = (char*)malloc(sizeof(char)*len);
// 				[data getBytes:buf];
// 				
// 				for (size_t i = 0; i < originColor.size(); i++) {
// 					replaceColor(buf, parameter, originColor.at(i), changeColor.at(i));
// 				}
// 				
// 				fillData(buf, parameter);
// 				
// 				NSData* newData = [NSData dataWithBytes:buf length:len];
// 				
// 				UIImage* changeImg = [UIImage imageWithData:newData];
// 				tex = [ [CCTexture2D alloc] initWithImage: changeImg ];
// 				bChangeSuc = true;
// 				
// 				free(buf);
// 			}
// 		}
// 		if (!bChangeSuc) {
// 			UIImage *image = [ [UIImage alloc] initWithContentsOfFile: [arrName objectAtIndex:0] ];
// 			tex = [ [CCTexture2D alloc] initWithImage: image ];
// 			[image release];
// 		}
// 		
// 		if( tex ) {
// 			[textures_ setObject: tex forKey:imageName];
// 		}
// 		[tex release];
// 	}
// 	
// 	[dictLock_ unlock];
// 	
// 	return tex;
// }
// 
// -(CCTexture2D*) addImage:(NSString *)path keepData:(BOOL)keep
// {
// 	NSAssert(path != NULL, @"TextureCache: fileimage MUST not be nill");
// 	
// 	CCTexture2D * tex = NULL;
// 	
// 	// MUTEX:
// 	// Needed since addImageAsync calls this method from a different thread
// 	[dictLock_ lock];
// 	
// 	tex=[textures_ objectForKey: path];	
// 	
// 	if( ! tex ) {
// 		
// 		// Split up directory and filename
// //#ifdef DEBUG		
// //		NSString *fullpath = [NSString stringWithUTF8String: cocos2d::CCFileUtils::fullPathFromRelativePath([path UTF8String])];
// //#else
// //		NSString *fullpath = [CCFileUtils fullPathFromRelativePath: path ];
// //#endif
// 		
// 		// todo
// 		NSString *fullpath = NULL;
// 		{
// 			if(([path length] > 0) && ([path characterAtIndex:0] == '/'))
// 			{
// 				fullpath = path;
// 			}
// 			else 
// 			{
// 				NSMutableArray *imagePathComponents = [NSMutableArray arrayWithArray:[path pathComponents]];
// 				NSString *file = [imagePathComponents lastObject];
// 				
// 				[imagePathComponents removeLastObject];
// 				NSString *imageDirectory = [NSString pathWithComponents:imagePathComponents];
// 				
// 				NSString *fullpath = [[NSBundle mainBundle] pathForResource:file ofType:NULL inDirectory:imageDirectory];
// 				if (fullpath == NULL)
// 					fullpath = path;
// 			}	
// 		}
// 		
// 		NSString *lowerCase = [path lowercaseString];
// 		// all images are handled by UIImage except PVR extension that is handled by our own handler
// 		if ( [lowerCase hasSuffix:@".pvr"] )
// 			tex = [self addPVRTCImage:fullpath];
// 		
// 		// Issue #886: TEMPORARY FIX FOR TRANSPARENT JPEGS IN IOS4
// 		else if ( [lowerCase hasSuffix:@".jpg"] || [lowerCase hasSuffix:@".jpeg"]) {
// 			// convert jpg to png before loading the texture
// 			UIImage *jpg = [[UIImage alloc] initWithContentsOfFile:fullpath];
// 			UIImage *png = [[UIImage alloc] initWithData:UIImagePNGRepresentation(jpg)];
// 			tex = [ [CCTexture2D alloc] initWithImage:png keepData:keep];
// 			[png release];
// 			[jpg release];
// 			
// 			if( tex )
// 				[textures_ setObject: tex forKey:path];
// 			else
// 				CCLOG(@"cocos2d: Couldn't add image:%@ in CCTextureCache", path);
// 				
// 				[tex release];
// 		}
// 		
// 		else {
// 			
// 			//# work around for issue #910
// #if 0
// 			UIImage *image = [UIImage imageNamed:path];
// 			tex = [ [CCTexture2D alloc] initWithImage:image keepData:keep];
// #else
// 			// prevents overloading the autorelease pool
// 			UIImage *image = [ [UIImage alloc] initWithContentsOfFile: fullpath ];
// 			tex = [ [CCTexture2D alloc] initWithImage:image keepData:keep];
// 			[image release];
// #endif //
// 			
// 			if( tex ) {
// 				[textures_ setObject: tex forKey:path];
// 			} else {
// 				CCLOG(@"cocos2d: Couldn't add image:%@ in CCTextureCache", path);
// 			}
// 			
// 			[tex release];
// 		}
// 	}
// 	
// 	[dictLock_ unlock];
// 	
// 	return tex;
// }
// 
// @end
// 
// #pragma mark -
// #pragma mark Memory Monitor
// 
// @implementation CCTextureCache (Memory)
// 
// -(void) Recyle
// {
// 	/*
// 	if (NULL == textures_)
// 	{
// 		return;
// 	}
// 	
// 	NSArray * allKeys = [textures_ allKeys];
// 	
// 	if (NULL == allKeys)
// 	{
// 		return;
// 	}
// 	
// 	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
// 	
// 	NSMutableArray *recyle = [[NSMutableArray alloc] init];
// 	
// 	for (NSUInteger i = 0; i < [allKeys count]; i++) 
// 	{
// 		NSString* key	= [allKeys objectAtIndex:i];
// 		if (NULL == key)
// 		{
// 			continue;
// 		}
// 		
// 		CCTexture2D *texture = [textures_ objectForKey:key];
// 		if (NULL == texture)
// 		{
// 			continue;
// 		}
// 		
// 		if (1 >= [texture retainCount])
// 		{
// 			[recyle addObject:key];
// 		}
// 	}
// 	
// 	if (0 < [recyle count])
// 	{
// 		[textures_ removeObjectsForKeys:recyle];
// 	}
// 	
// 	[recyle release];
// 	[pool release];
// 	*/
// 	
// 	[self removeUnusedTextures];
// }
// 
// @end
// 
