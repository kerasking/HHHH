//
//  XMLReader.h
//  Untitled
//
//  Created by Ｓie Kensou on 8/19/09.
//  Copyright 2009 网龙. All rights reserved.
//
//xml文件解析类－－－作者通用平台组林峰

#import <UIKit/UIKit.h>

//this class only deal with simple xml, it'll ignore attributes in the xml
@interface XMLReader : NSObject
{
	NSMutableDictionary* _dataDic;
	id					 _currentNode;
}

-(id)initWithFile:(char*)file;
-(id)initWithData:(char*)data length:(int)size;

-(BOOL)saveToFile:(char*)file;

//warning! you should not use the return objects after you relase this class

//get value with a path, if the path to the value has arrays, an  array with the indexs for the arrays is required;
//if not, you can set indexArray nil;
//if the num of indexs is less than the array num in the path, nil is returned.

-(id)getObjectWithPath:(NSString*)path andIndexs:(int*)indexArray size:(int)arraySize;
//if there an error occurs, -1 will be returned
-(int)getIntWithPath:(NSString*)path andIndexs:(int*)indexArray size:(int)arraySize;
//if there an error occurs, nil will be returned
-(NSString*)getStringWithPath:(NSString*)path andIndexs:(int*)indexArray size:(int)arraySize;

// get object by path after node, node must be object returned by method getObjectWithPath:andIndexs:size
// if not, or node is a leaf node, nil will be returned
-(id)getObjectFromNode:(id)node Path:(NSString*)path andIndexs:(int*)indexArray size:(int)arraySize;
//if there an error occurs, -1 will be returned
-(int)getIntFromNode:(id)node Path:(NSString*)path andIndexs:(int*)indexArray size:(int)arraySize;
//if there an error occurs, nil will be returned
-(NSString*)getStringFromNode:(id)node Path:(NSString*)path andIndexs:(int*)indexArray size:(int)arraySize;

//debug
-(void)printXML;

@end
