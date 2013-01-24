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
	/* The values are the same as cocos2dx/platform/CCImage.h. */
	private static final int HORI_ALIGN_LEFT = 1;
	private static final int HORI_ALIGN_RIGHT = 2;
	private static final int HORI_ALIGN_CENTER = 3;
	private static final int VERT_ALIGN_TOP = 1;
	private static final int VERT_ALIGN_BOTTOM = 2;
	private static final int VERT_ALIGN_CENTER = 3;
	
	public static String	strText;
	public static int		lineCount = 1; //at least 1
	
	public static String	defaultFontName;
	public static int		defaultFontSize;
	public static int		defaultColor = 0x000000ff; //RGBA, black.
	
	public static int		alignmentHorz;
	public static int		alignmentVert;
	
	public static int		uiMaxWidth = 0;
	public static int		uiMaxHeight = 0;
	public static boolean 	withUILimit = false;
	
	public static int		calcWidth = 0;
	public static int		calcHeight = 0;
	public static int		calcStartX = 0;
	public static int		calcStartY = 0;

	public static int		bitmapWidth;
	public static int		bitmapHeight;
	
	public static TextIndex 				index = null;
	public static ParseFlag 				parseFlag = null;
	public static ArrayList<CharProperty> 	charList = null;

	
	
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
		//Log.d( "ndbmp", "[before translate] NDBitmap.parse(): " + strText);
		String newText = translateText( strText );
		//Log.d( "ndbmp", "[after translate] NDBitmap.parse(): " + newText);
		
		// reset proxy
		resetWith( newText, fontName, fontSize, alignment, width, height );

		// build char list, calc string size
		if (buildCharList())
		{		
			buildCharProperty( paint, width, height );
			calcAlignment();
			applyAlignment();
			//dumpCharList();
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
		lineCount 			= 1;
		
		alignmentHorz 		= (in_alignment & 0x0F);
		alignmentVert 		= (in_alignment >> 4) & 0x0F;
		
		uiMaxWidth			= in_width;
		uiMaxHeight			= in_height;
		
		withUILimit 		= (uiMaxWidth > 0 && uiMaxHeight > 0);
		
		//recreate objs.
		index 		= new TextIndex();
		parseFlag 	= new ParseFlag();
		charList 	= new ArrayList<CharProperty>();
		
// 		Log.d("ndbmp", "\r\n");
// 		Log.d("ndbmp", "resetWith: strText=" + strText);
// 		Log.d( "ndbmp", "resetWith: "
// 				+ " width=" + uiMaxWidth 
// 				+ ", height=" + uiMaxHeight 
// 				+ ", alignHorz=" + alignmentHorz 
// 				+ ", alignVert=" + alignmentVert
// 				+ ", in_alignment=" + in_alignment
// 				);
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
		}
		
		public char			c;
		public String		fontName;
		public int			fontSize;
		public int			color;
		public boolean		bLineFeed; //if true, strChar is ignored.
		public int 			x,y,w,h;
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
				int cr = Color.rgb( bytesColor[0], bytesColor[1], bytesColor[2]);
								
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
	 * isSingleLine
	 * @param strText
	 * @return
	 */
	private static boolean isSingleLine()
	{
		return strText.indexOf('\r') == -1
				&& strText.indexOf('\n') == -1;
	}
	
	/**
	 * buildCharProperty
	 * @param paint
	 * @param uiWidth
	 * @param uiHeight
	 */
	private static void buildCharProperty( Paint paint, int uiWidth, int uiHeight )
	{
		//Log.d("ndbmp","@@ buildCharProperty()");
			
		// calc char height
		final FontMetricsInt fm = paint.getFontMetricsInt();
		final int fontHeight = (int) Math.ceil(fm.bottom - fm.top);
		
		calcWidth = 0;
		calcHeight = 0;
		lineCount = 1;
		int x = 0, y = - fm.top;
		
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
				lineCount++;
				
				// zero width (don't need to draw)
				objChar.w = 0;
			}
			else
			{
				String str = String.valueOf( objChar.c );
				int charWidth = (int) FloatMath.ceil( paint.measureText( str, 0, str.length()));
				
				//if ui width not enough, change line.
				if (withUILimit && (x + charWidth > uiMaxWidth))
				{
					// move to next line
					x = 0;
					y += fontHeight;
					lineCount++;
					
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
				
				calcWidth = Math.max(calcWidth, x);
				calcHeight = y;
			}
		}//for
			
		// calc bitmap size
		if (withUILimit)
		{
			bitmapWidth = uiMaxWidth;
			bitmapHeight = uiMaxHeight;
		}
		else
		{
			bitmapWidth = calcWidth;
			bitmapHeight = calcHeight;			
		}		
	}
	
	/**
	 * calcAlignment
	 */
	private static void calcAlignment()
	{
		calcStartX = 0;
		calcStartY = 0;
		
		if (!withUILimit) return;
		
		if (lineCount == 1)
		{
			// deal with horizontal align
			if (alignmentHorz == HORI_ALIGN_CENTER)
			{
				calcStartX = (int) (0.5 * (uiMaxWidth - calcWidth));
				calcStartX = Math.max(0, calcStartX);
			}
			else if (alignmentHorz == HORI_ALIGN_RIGHT)
			{
				calcStartX = (int) (uiMaxWidth - calcWidth);
				calcStartX = Math.max(0, calcStartX);
			}
			
			// deal with vertical align
			if (alignmentVert == VERT_ALIGN_CENTER)
			{
				calcStartY = (int) (0.5 * (uiMaxHeight - calcHeight));
				calcStartY = Math.max(0, calcStartY);
			}
			else if (alignmentVert == VERT_ALIGN_BOTTOM)
			{
				calcStartY = (int) (uiMaxHeight - calcHeight);
				calcStartY = Math.max(0, calcStartY);
			}
		}
		else if (lineCount > 1)
		{
			// ONLY deal with vertical align
			if (alignmentVert == VERT_ALIGN_CENTER)
			{
				calcStartY = (int) (0.5 * (uiMaxHeight - calcHeight));
				calcStartY = Math.max(0, calcStartY);
			}
			else if (alignmentVert == VERT_ALIGN_BOTTOM)
			{
				calcStartY = (int) (uiMaxHeight - calcHeight);
				calcStartY = Math.max(0, calcStartY);
			}	
		}
	}
	
	/**
	 * applyAlignment
	 */
	private static void applyAlignment()
	{
		if (calcStartX != 0 || calcStartY != 0)
		{
			for (CharProperty objChar : charList) 
			{
				if (!objChar.bLineFeed)
				{
					objChar.x += calcStartX;
					objChar.y += calcStartY;
				}
			}
		}
		
		calcStartX = 0;
		calcStartY = 0;
	}
	
	/**
	 * translateText:	translate special tag
	 * @param strText
	 * @return
	 */
	private static String translateText( final String strText )
	{
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
			
//		String s1 = strText.replaceAll( "<c", "<C#" );
//		String s2 = s1.replace( "/e", "</C>");
//		return s2;
	}
	
	private static void dumpCharList()
	{
		Log.d("ndbmp", "@@ ---------------------------------\r\n");
		
		for (final CharProperty objChar : charList) 
		{
			if (objChar.bLineFeed)
			{
				Log.d( "ndbmp", "@@ linefeed" );
			}
			else
			{
				Log.d( "ndbmp", "@@ " 
							+ String.valueOf(objChar.c) 
							+ "  x=" + objChar.x
							+ "  y=" + objChar.y
							+ "  w=" + objChar.w
							+ "  h=" + objChar.h
							+ "  [" + objChar.color + "]"
							);
			}
		}
	}
}
