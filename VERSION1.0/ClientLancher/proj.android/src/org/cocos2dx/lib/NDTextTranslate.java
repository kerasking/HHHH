/****************************************************************************
 * NDTextTranslate.java
 * translate color-text string into well-formed format
 * 
 ****************************************************************************/
package org.cocos2dx.lib;

import java.util.*;
import android.util.*;
import android.graphics.*;

/**
 * NDTextTranslate: all method are static.
 */
public class NDTextTranslate 
{ 
	private static boolean isACloserThanB( final int a, final int b )
	{
		//eg: a=3,b=5 then a is closer than b
		//		a=3, b=-1 then a is also closer than b, b is invalid.
		if (a != -1)
		{
			if (b == -1 || a < b)
				return true;
		}
		return false;
	}
	
	/**
	 * insertText: insert strB into strA at index pos.
	 * @param strText
	 * @param index
	 * @param insertString
	 * @return
	 */
	private static String insertText( final String strA, final int index, final String strB )
	{
		if (strA.length() == 0) return strB;
		
		if (index == 0)
		{
			return strB + strA;
		}
		else if (index < strA.length())
		{
			String left = strA.substring(0, index);
			String right = strA.substring(index);
			return left + strB + right;
		}
		return "";
	}
	
	public static void testFormatText( String strText )
	{
		log( "before formatText(): " + strText);
		strText = formatText( strText );
		log( "after  formatText(): " + strText);
	}
	
	/**
	 * formatText: the input text maybe not well-formed, try to fix it.
	 * @param strText
	 * @return
	 */
	private static String formatText( String strText )
	{
		int start = 0;
		
		boolean hasBeginTag = false;
		
		while (start < strText.length())
		{
			int find1 = strText.indexOf("<c", start);
			int find2 = strText.indexOf("/e", start);
			
			if (hasBeginTag)
			{
				if (isACloserThanB( find1, find2 ))
				{
					// we expect a end-tag, but meet with a begin-tag, so we need to insert a end-tag before it.
					strText = insertText( strText, find1, "/e" );
					start = find1 + 4; //4 for "/e<c"
				}
				else if (isACloserThanB( find2, find1 ))
				{
					// correct: start-tag and end-tag match ok,.
					start = find2 + 2;
					hasBeginTag = false;
				}
				else
				{
					// neither tag found, we just append a end-tag
					strText = strText + "/e";
				}
			}
			else // we don't have a begin tag
			{
				if (isACloserThanB( find1, find2 ))
				{
					// correct: now we have a begin-tag
					start = find1 + 2; //2 for "<c"
					hasBeginTag = true;
				}
				else if (isACloserThanB( find2, find1 ))
				{
					// we have a end-tag before a begin-tag, we ignore the end-tag as normal text
					start = find2 + 2;
				}
				else
				{
					// neither tag found, it's ok
					break;
				}				
			}
		}
		
		return strText;
	}
	
	public static String translateText( String strText )
	{
		log( "[before translate]: " + strText);
		String newText = doTranslateText( strText );
		log( "[after translate]: " + newText);
		return newText;
	}

	/**
	 * translateText:	doTranslate special tag
	 * @param strText
	 * @return
	 */
	private static String doTranslateText( String strText )
	{
		// strText maybe not well-formed, format it before translate.
		strText = formatText( strText );
		
		String result = "";
		int len = strText.length();
		int start = 0;
		
		while (start < len)
		{
			int find = strText.indexOf("<c", start);
			if (find != -1)
			{
				// we find a "<c" 
				int index = find + 2;
				String leftPart = strText.substring(start, find);
				String color = strText.substring(index, index+6);
				
				result += leftPart;
				result += "<C#";
				result += color;
				result += ">";
				
				start = index + 6;
				
				// try to find "/e"
				find = strText.indexOf("/e", start);
				if (find != -1)
				{
					leftPart = strText.substring(start, find);
					
					result += leftPart;
					result += "</C>";
					
					start = find + 2;
				}				
			}
			else
			{
				result += strText.substring(start);
				break;
			}
		}
		return result;
	}
			
	private static void log( final String str )
	{
		NDBitmap.log( str );
	}
}
