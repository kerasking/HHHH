/****************************************************************************
 * NDTextProxy.java
 *
 * support:
 *		bold:		<B>hello</B>
 *		italic:		<I>hello</I>
 *		color:		<C#RRGGBB>hello</C>
 *		font:		<FN#fontName>hello</FN>
 *
 * @todo: only text color supported, bold/italic/fontSize not supported by now.
 * 
 ****************************************************************************/
package org.cocos2dx.lib;

import java.util.*;
import android.util.*;
import android.graphics.*;
import android.graphics.Paint.*;

import org.cocos2dx.lib.*;

/**
 * NDTextProxy: all method are static.
 */
public class NDTextProxy 
{ 
	private static String	strText;	
	private static String	defaultFontName;
	private static int		defaultFontSize;
	private static int		defaultColor = 0xffffffff; //RGBA, white.
	
	private static int		alignmentHorz;
	private static int		alignmentVert;
	
	private static int		uiMaxWidth = 0;
	private static int		uiMaxHeight = 0;
	private static boolean 	withUILimit = false;
	
	private static TextIndex 				index = null;
	private static ParseFlag 				parseFlag = null;
	
	private static ArrayList<CharProperty> 	charList = null;
	public static ArrayList<CharLine>		charLineList = null;
	
	
	/**
	 * parse: 			parse a rich-format string
	 * @param paint
	 * @param strText
	 * @param fontName
	 * @param fontSize
	 * @param alignment
	 * @param width
	 * @param height
	 * @return
	 */
	public static boolean parse( Paint paint, 
			final String strText,
			final String fontName, final int fontSize, final int alignment,
			final int width, final int height )
	{
		// translate text
		String newText = NDTextTranslate.translateText( strText );
		
		// reset proxy
		resetWith( newText, fontName, fontSize, alignment, width, height );

		// build char list, calc string size
		if (buildCharList())
		{		
			buildCharProperty( paint, width, height );
			buildCharLines();
			
			NDTextAlign.calcAlignment( paint, charLineList, uiMaxWidth, uiMaxHeight, alignmentHorz, alignmentVert );
			dumpCharList();
			return true;
		}
		return false;
	}
	
	/**
	 * reset
	 */
	private static void resetWith( final String in_strText, 
			final String in_fontName, final int in_fontSize,
			final int in_alignment, final int in_width, final int in_height )
	{
		strText 			= in_strText;
		defaultFontName 	= in_fontName;
		defaultFontSize 	= in_fontSize;
		
		alignmentHorz 		= (in_alignment & 0x0F);
		alignmentVert 		= (in_alignment >> 4) & 0x0F;
		
		uiMaxWidth			= in_width;
		uiMaxHeight			= in_height;
		withUILimit 		= (uiMaxWidth > 0);
		
		//recreate objs.
		index 		= new TextIndex();
		parseFlag 	= new ParseFlag();
		charList 	= new ArrayList<CharProperty>();
		
 		log("\r\n");
 		log("resetWith: strText=" + strText);
 		log("resetWith: "
 				+ " width=" + uiMaxWidth 
 				+ ", height=" + uiMaxHeight 
 				+ ", alignHorz=" + alignmentHorz 
 				+ ", alignVert=" + alignmentVert
 				+ ", in_alignment=" + in_alignment
 				);
	}
	
	/**
	 * inner class CharProperty : for a single char
	 */
	public static class CharProperty
	{
		public CharProperty()
		{
			c = 0;
			fontName = "";
			fontSize = 0;
			color = 0;
			bLineFeed = false;
			bSpecialChar = false;
			outOfRange = false;
		}
		
		public char			c;
		public boolean		bSpecialChar;
		public String		fontName;
		public int			fontSize;
		public int			color;
		public boolean		bLineFeed; //if true, strChar is ignored.
		public int 			x,y,w,h;
		public boolean		outOfRange;
	}
	
	/**
	 * inner class CharLine: for a line of chars
	 *
	 */
	public static class CharLine
	{
		public ArrayList<CharProperty> charList = new ArrayList<CharProperty>();
		
		public int calcWidth = 0;
		public int calcHeight = 0;
		public int calcStartX = 0;
		public int calcStartY = 0;
		public int lineCount = 0;
	}
	
	/**
	 * inner class ParseFlag: store some flags during parsing
	 */
	private static class ParseFlag
	{
		 public ParseFlag()
		 {
			 isBold = false;
			 isItalic = false;
			 isColor = false;
			 isFontName = false;
			 newColor = 0;
			 newFontName = "";
		 }
		 
		 boolean isBold = false;
		 boolean isItalic = false;
		 boolean isColor = false;
		 boolean isFontName = false;
		 
		 int newColor;
		 String newFontName;
	}
	
	/**
	 * inner class TextIndex: index of string text
	 */
	private static class TextIndex
	{
		public TextIndex() { val = 0; }

		public void push() { val_bk = val; }
		public void pop() { val = val_bk; }
		
		public int val;
		private int val_bk;
	}
	
	/**
	 * buildCharList:	build a char list with a string
	 * @param strText
	 * @param fontName
	 * @param fontSize
	 * @return
	 */
	private static boolean buildCharList()
	{		
		int charCount = strText.length(); //not bytes len.
		for (index.val = 0; index.val < charCount; index.val++)
		{
			char c = strText.charAt(index.val);
			if (c == '<')
			{
				if (parseFlag( strText, charCount ))
				{
					index.val--;
					continue;
				}
				addCharProperty( c );
			}
			else if (c == '\r' || c == '\n')
			{
				addCharProperty_LineFeed();
			
				//treat \r\n as a linefeed, not two.
				if (index.val + 1 < charCount)
				{
					char cNext = strText.charAt(index.val + 1);
					if (cNext == '\r' || cNext == '\n')
					{
						index.val++;
					}
				}
			}
			else
			{
				addCharProperty( c );
			}
		}
		
		//trim: if last char is a lineFeed, then remove it
		int n = charList.size();
		if (n > 0 && charList.get(n-1).bLineFeed)
		{
			charList.remove(n-1);
		}
				
		return true; //always true to ensure a bitmap. 
	}

	/**
	 * addCharProperty:	add a char obj to list	
	 * @param charList
	 * @param fontName
	 * @param c
	 * @param parseFlag
	 * @return
	 */
	private static void addCharProperty( final char c )
	{
		CharProperty charProp = new CharProperty();		
		charProp.c = c;
		charProp.bSpecialChar = NDSpecialCharWidth.isSpecialChar(c);
		charProp.fontName = parseFlag.isFontName ? parseFlag.newFontName : defaultFontName;
		charProp.fontSize = defaultFontSize;
		charProp.color = parseFlag.isColor ? parseFlag.newColor : defaultColor;
		charList.add( charProp );
	}
	
	/**
	 * addCharProperty_LineFeed: a a line-feed char obj.
	 * @param charList
	 */
	private static void addCharProperty_LineFeed()
	{
		CharProperty charProp = new CharProperty();
		charProp.bLineFeed = true;
		charList.add( charProp );
	}
	
	/**
	 * parseFlag
	 * @param strText
	 * @param charCount
	 * @param index
	 * @param parseFlag
	 * @return
	 */
	private static boolean parseFlag( final String strText, final int charCount )
	{
		if (parseFlagBegin( strText, charCount ))
		{
			return true;
		}
		
		if (parseFlagEnd( strText, charCount ))
		{
			return true;
		}		
		
		return false;
	}
	
	/**
	 * parseFlagBegin
	 * @param strText		
	 * @param charCount		
	 * @param index			
	 * @param parseFlag
	 * @return
	 */
	private static boolean parseFlagBegin( final String strText, final int charCount )
	{
		char c = strText.charAt(index.val);
		if (c != '<') return false;
		
		// read next two char
		if (index.val + 2 >= charCount) return false;
		char c1 = strText.charAt(index.val + 1);
		char c2 = strText.charAt(index.val + 2);
		
		index.push();
		
		if (c1 == 'B' && c2 == '>')
		{
			parseFlag.isBold = true;
			index.val += 3; //3 for <B> 
			return true;
		}
		else if (c1 == 'I' && c2 == '>')
		{
			parseFlag.isItalic = true;
			index.val += 3; //3 for <I>
			return true;
		}
		else if (c1 == 'C' && c2 == '#')
		{
			//<c#RRGGBB>, total 8 bytes.
			if (index.val + 10 >= charCount) return false;
			index.val += 3; //3 for <C#
			
			String colorHex = strText.substring(index.val, index.val + 6);
			byte[] bytesColor = NDHexUtil.hexStringToBytes(colorHex);
			
			if (bytesColor.length >= 3) //3 for r,g,b
			{
				int r = bytesColor[0] & 0xff;
				int g = bytesColor[1] & 0xff;
				int b = bytesColor[2] & 0xff;
				int cr = Color.rgb( g, b, r ); //reverse order

				parseFlag.isColor = true;
				parseFlag.newColor = cr;
				
				index.val += 7; //6 for RRGGBB>
				return true;
			}
		}
		else if (c1 == 'F' && c2 == 'N')
		{
			index.val += 3; //3 for <FN
			int indexTail = strText.indexOf(">", index.val);
			if (indexTail > index.val)
			{
				String fontName = strText.substring(index.val, indexTail);
				parseFlag.isFontName = true;
				parseFlag.newFontName = fontName;
				
				index.val = indexTail + 1;
				return true;
			}
		}
		
		index.pop();
		return false;
	}
	
	/**
	 * parseFlagEnd
	 * @param strText
	 * @param charCount
	 * @param index
	 * @param parseFlag
	 * @return
	 */
	private static boolean parseFlagEnd( final String strText, final int charCount )
	{
		char c = strText.charAt(index.val);
		if (c != '<') return false;
		
		// read next two char
		if (index.val + 3 >= charCount) return false;
		char c1 = strText.charAt(index.val + 1);
		char c2 = strText.charAt(index.val + 2);
		char c3 = strText.charAt(index.val + 3);
	
		index.push();
		
		if (c1 == '/' && c2 == 'C' && c3 == '>')
		{
			parseFlag.isColor = false;
			parseFlag.newColor = 0;
			
			index.val += 4; //4 for </C>
			return true;
		}
		if (c1 == '/' && c2 == 'I' && c3 == '>')
		{
			parseFlag.isBold = false;
			
			index.val += 4; //4 for </I>
			return true;
		}
		else if (c1 == '/' && c2 == 'F' && c3 == 'N')
		{
			if (index.val + 4 < charCount) 
			{
				char c4 = strText.charAt(index.val + 4);
				if (c4 == '>')
				{
					index.val += 5; //5 for </FN>
					return true;					
				}
			}
		}
		
		index.pop();
		return false;
	}
	
	/**
	 * buildCharProperty
	 * @param paint
	 * @param uiWidth
	 * @param uiHeight
	 */
	private static void buildCharProperty( Paint paint, int uiWidth, int uiHeight )
	{
		log("@@ buildCharProperty()");
			
		// calc char height
		final FontMetricsInt fm = paint.getFontMetricsInt();
		final int fontHeight = (int) Math.ceil(fm.bottom - fm.top);
		
		int x = 0;
		int y = (int) (-fm.top * 1);//@tune
		
		for ( CharProperty objChar : charList ) 
		{
			objChar.x = x;
			objChar.y = y;
			objChar.h = fontHeight;
			
			if (objChar.bLineFeed)
			{
				// move to next line
				x = 0;
				y += fontHeight;				
				
				// zero width (don't need to draw)
				objChar.w = 0;
			}
			else
			{
				String str = String.valueOf( objChar.c );
				int charWidth = (int) FloatMath.ceil( paint.measureText( str, 0, str.length()));
				
				// fix width for special char
				if (objChar.bSpecialChar && NDBitmap.isVerOlder())
				{
					charWidth = NDSpecialCharWidth.fixCharWidth(objChar.c, charWidth, objChar.fontName); //@tune
				}
				
				//if ui width not enough, change line.
				if (withUILimit && (x + charWidth > uiMaxWidth))
				{
					// move to next line
					x = 0;
					y += fontHeight;
					
					// set xywh
					objChar.x = x;
					objChar.y = y;
					objChar.w = charWidth;
					objChar.h = fontHeight;
					
					// move forward
					x += charWidth;
				}
				else
				{
					// move forward
					objChar.w = charWidth;
					x += charWidth;								
				}
				
				// check if clipped
				if (uiMaxHeight > 0 && objChar.y > uiMaxHeight + fontHeight)
				{
					objChar.outOfRange = true;
				}
			}
		}//for
	}
	
	/**
	 * build lines from char list, check "\r\n"
	 */
	private static void buildCharLines()
	{
		if (charLineList == null)
		{
			charLineList = new ArrayList<CharLine>();
		}
		
		charLineList.clear();
		if (charList.size() == 0) return;
		
		CharLine charLine = new CharLine();
		charLineList.add( charLine );
		
		for ( CharProperty objChar : charList )
		{
			if (objChar.bLineFeed)
			{
				charLine = new CharLine();
				charLineList.add( charLine );				
			}
			else
			{
				charLine.charList.add(objChar);
			}
		}

		log( "has " + charLineList.size() + " lines\r\n");
	}
	
	public static int getBitmapWidth()
	{
		return NDTextAlign.bitmapWidth;
	}
	
	public static int getBitmapHeight()
	{
		return NDTextAlign.bitmapHeight;
	}
			
	private static void dumpCharList()
	{
		if (!NDBitmap.verbose) return;
		
		log( "---------------------------------");
		
		for (final CharProperty objChar : charList) 
		{
			if (objChar.bLineFeed)
			{
				log("@@ linefeed" );
			}
			else
			{
				log( String.valueOf(objChar.c) 
							+ "  x=" + objChar.x
							+ "  y=" + objChar.y
							+ "  w=" + objChar.w
							+ "  h=" + objChar.h
							+ "  [" + objChar.color + "]"
							);
			}
		}
	}
	
	public static void log( final String str )
	{
		NDBitmap.log( str );
	}
}
