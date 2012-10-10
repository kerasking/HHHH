//
//  XMLReader.m
//  Untitled
//
//  Created by Ｓie Kensou on 8/19/09.
//  Copyright 2009 网龙. All rights reserved.
//

#import "XMLReader.h"

#include <libxml/parser.h>
#include <libxml/xmlmemory.h>
#include <libxml/xmlwriter.h>

xmlNodePtr getXmlNode( xmlNodePtr node );
xmlNodePtr getNextXmlNode( xmlNodePtr node );

@interface XMLReader(Private)

-(void)parseXML2Dictionary:(xmlDocPtr)commands;
-(void)parseNodeOfDoc:(xmlDocPtr)commands node:(xmlNodePtr)rootNode toContainer:(id)container;
-(id)getNodeFromPathArray:(NSArray*)subPaths withIndexs:(int*)indexArray size:(int)arraySize;
-(void)writeNodeToFile:(xmlTextWriterPtr)writer node:(id)subNode;

@end


@implementation XMLReader

#pragma mark -
#pragma mark INIT, SAVE and DEALLOC FUCTIONS

-(id)initWithFile:(char*)file
{
	if ( self = [super init] )
	{
		if ( _dataDic )
		{
			[_dataDic removeAllObjects];
			[_dataDic release];
			_dataDic = nil;
		}
		
		xmlKeepBlanksDefault(1);
		xmlDocPtr commands;
		commands = xmlParseFile(file);
		[self parseXML2Dictionary:commands];
		xmlFreeDoc(commands);
		//NSLog(@"result %@", _dataDic);
	}
	return self;
}

-(id)initWithData:(char*)data length:(int)size
{
	if ( self = [super init] )
	{
		if ( _dataDic )
		{
			[_dataDic removeAllObjects];
			[_dataDic release];
			_dataDic = nil;
		}
		
		xmlKeepBlanksDefault(1);		
		xmlDocPtr commands;
		commands = xmlParseMemory(data, size);		
		[self parseXML2Dictionary:commands];
		xmlFreeDoc(commands);
	}
	return self;
}

-(void)writeNodeToFile:(xmlTextWriterPtr)writer node:(id)subNode
{
	if ( [subNode isKindOfClass:[NSDictionary class]] )
	{
		NSEnumerator* enumerator = [subNode keyEnumerator];
		NSString* key;
		while( key = [enumerator nextObject] )
		{
			id subObject = [subNode objectForKey:key];
			if ( [subObject isKindOfClass:[NSString class]] )
			{
				xmlTextWriterWriteElement(writer, (xmlChar*)[key UTF8String], (xmlChar*)[subObject UTF8String]);
			}
			else
			{
				xmlTextWriterStartElement(writer, (xmlChar*)[key UTF8String]);
				[self writeNodeToFile:writer node:[subNode objectForKey:key]];
				xmlTextWriterEndElement(writer);
			}
		}
	}
	else if ( [subNode isKindOfClass:[NSArray class]] )
	{
		for ( int i = 0; i < [subNode count]; i++ )
		{
			NSDictionary* subDic = [subNode objectAtIndex:i];
			[self writeNodeToFile:writer node:subDic];
		}
	}
}

-(BOOL)saveToFile:(char*)file
{
	xmlTextWriterPtr writer;
	writer = xmlNewTextWriterFilename( file, 0 );
	if ( !writer )
	{
		NSLog(@"create new text writer err" );
		return NO;
	}
	
	xmlTextWriterStartDocument( writer, "1.0", "UTF-8", NULL );
	xmlTextWriterSetIndent( writer, 1);
	xmlTextWriterSetIndentString( writer, (xmlChar*)"\t");
	
	[self writeNodeToFile:writer node:_dataDic];
	
	xmlTextWriterEndDocument( writer );
	xmlFreeTextWriter( writer );
	return YES;
}


-(void)dealloc
{
	[_dataDic removeAllObjects];
	[_dataDic release];
	[super dealloc];
}

#pragma mark -
#pragma mark PARSE FUCTIONS
-(void)parseXML2Dictionary:(xmlDocPtr)commands
{
	if ( commands == NULL)
	{
		NSLog(@"xmlDocPtr NULL!You may have passed a invalid xml");
		return;
	}
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	xmlNodePtr rootNode = xmlDocGetRootElement( commands );
	
	if ( rootNode )
	{
		_dataDic = [[NSMutableDictionary alloc] init];
		[self parseNodeOfDoc:commands node:rootNode toContainer: _dataDic];
	}

	[pool release];	
}

-(void)parseNodeOfDoc:(xmlDocPtr)commands node:(xmlNodePtr)rootNode toContainer:(id)container
{
	xmlChar* szVal;
	xmlNodePtr curNode = getXmlNode(rootNode->xmlChildrenNode);
	NSMutableArray* subArray = nil;
	NSMutableDictionary* subDic = nil;
	id subContainer;
	
	if ( curNode != NULL && getXmlNode(curNode->xmlChildrenNode))
	{
		subDic = [[NSMutableDictionary alloc] init];
		subContainer = subDic;
		
		while( curNode )
		{
			NSString* nodeName = [[NSString stringWithUTF8String:(char*)curNode->name] lowercaseString];
			id object = [subDic objectForKey:nodeName];
			if ( object && subArray == nil )
			{
				subArray = [[NSMutableArray alloc] init];
				[subArray addObject:subDic];
				[subDic release];
				subContainer = subArray;
			}
			
			[self parseNodeOfDoc:commands node:curNode toContainer:subContainer];
			
			curNode = getNextXmlNode(curNode);
		}
		
		if ( [container isKindOfClass:[NSMutableDictionary class]] )
		{
			[container setObject:subContainer forKey:
						[[NSString stringWithUTF8String:(char*)rootNode->name] lowercaseString]];
		}
		else if ( [container isKindOfClass:[NSMutableArray class]] )
		{
			subDic = [[NSMutableDictionary alloc] initWithCapacity:1];
			[subDic setObject:subContainer forKey:
						[[NSString stringWithUTF8String:(char*)rootNode->name] lowercaseString]];
			[container addObject:subDic];
			[subDic release];
		}
		[subContainer release];
	}
	else if ( curNode != NULL )
	{
		szVal = xmlNodeListGetString( commands, curNode, 1 );
		NSString* strVal = @"";
		if ( szVal )
		{
			strVal = [NSString stringWithUTF8String:(char*)szVal];
			xmlFree(szVal);
		}
		
		if ( [container isKindOfClass:[NSMutableDictionary class]] )
		{
			[container setObject:strVal	forKey:
					[[NSString stringWithUTF8String:(char*)rootNode->name] lowercaseString]];
		}
		else if ( [container isKindOfClass:[NSMutableArray class]] )
		{
			[container addObject:container];
		}
	}
}



#pragma mark -
#pragma mark GET VALUE FUCTIONS

-(id)getNodeFromPathArray:(NSArray*)subPaths withIndexs:(int*)indexArray size:(int)arraySize;
{
	id container = _currentNode;
	int arrayIndex = 0;
	NSString* string;
	for ( int i = 0; i < [subPaths count]; i++ )
	{
		string = (NSString*)[subPaths objectAtIndex:i];
		if ( [string length] == 0 )
			continue;
		
//		if ( !container )
//		{
//			container = [_dataDic objectForKey:string];
//		}
//		else 
		if ( [container isKindOfClass:[NSDictionary class]] )
		{
			container = [container objectForKey:string];
		}
		else if ( [container isKindOfClass:[NSArray class]] )
		{
			if ( arrayIndex >= arraySize || indexArray == NULL )
			{
				NSLog(@"index num is not enough!");
				container = nil;
				break;
			}
			else
			{
				container = [container objectAtIndex:indexArray[arrayIndex]];
				i--;			// we'll scroll back for the string
				arrayIndex++;
			}
		}
		else 
		{
			NSLog(@"error!path %@ is not valid or unique", string);
		}
		
		if ( container == nil )			//if container is nil here, it means there's error occured.
			break;
	}
	
	if ( container == nil )			//if container is nil here, it means there's error occured.
	{
		NSLog(@"error!path %@ is not valid or unique", string);
		return nil;
	}	
	
	_currentNode = container;
	return container;
}


-(id)getObjectWithPath:(NSString*)path andIndexs:(int*)indexArray size:(int)arraySize
{
	if ( !_dataDic )
		return nil;

	_currentNode = _dataDic;
	return [self getObjectFromNode:_currentNode Path:path andIndexs:indexArray size:arraySize];
}

-(int)getIntWithPath:(NSString*)path andIndexs:(int*)indexArray size:(int)arraySize
{
	NSString* res = (NSString*)[self getObjectWithPath:path andIndexs:indexArray size:arraySize];
	if ( res == nil )
		return -1;
	return [res intValue];
}

-(NSString*)getStringWithPath:(NSString*)path andIndexs:(int*)indexArray size:(int)arraySize
{
	NSString* res = (NSString*)[self getObjectWithPath:path andIndexs:indexArray size:arraySize];
	return res;
}

-(id)getObjectFromNode:(id)node Path:(NSString*)path andIndexs:(int*)indexArray size:(int)arraySize
{
	if ( !_dataDic || !node)
		return nil;

	if ( ![node isKindOfClass:[NSArray class]] && ![node isKindOfClass:[NSDictionary class]] )
	{
		NSLog(@"the node you pass in is not a valid node!");
		return nil;
	}
	_currentNode = node;
	
	NSArray* subPaths = [[path lowercaseString] componentsSeparatedByString:@"/"];
	id container = nil;
	container = [self getNodeFromPathArray:subPaths withIndexs:indexArray size:arraySize];
	return container;
	
}


-(int)getIntFromNode:(id)node Path:(NSString*)path andIndexs:(int*)indexArray size:(int)arraySize
{
	NSString* res = (NSString*)[self getObjectFromNode:node Path:path andIndexs:indexArray size:arraySize];
	if ( res == nil )
		return -1;
	return [res intValue];	
}

-(NSString*)getStringFromNode:(id)node Path:(NSString*)path andIndexs:(int*)indexArray size:(int)arraySize
{
	NSString* res = (NSString*)[self getObjectFromNode:node Path:path andIndexs:indexArray size:arraySize];
	return res;
}

//test
-(void)printXML
{
	NSLog(@"from the root node:\n%@", _dataDic);
}

@end


#pragma mark -
#pragma mark XML SUPPORT FUCTIONS
xmlNodePtr getXmlNode( xmlNodePtr node )
{
	while ( node && xmlIsBlankNode(node) )
	{		
		node = node->next;
	}
	return node;
}

xmlNodePtr getNextXmlNode( xmlNodePtr node )
{
	do
	{		
		node = node->next;
	}
	while ( node && xmlIsBlankNode(node) );
	return node;
}

