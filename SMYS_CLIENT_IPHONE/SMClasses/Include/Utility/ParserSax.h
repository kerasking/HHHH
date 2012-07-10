/**
htmlcxx:SAX(Simple APIfor XML)基于事件(Event)的XML处理模式，该模式和DOM相反，不需要将整个XML树读入内存后再进行处理，而是将XML文档作为一个输入“流”来处理，在处理该流的时候会触发很多事件，如SAX解析器在处理文档第一个字符的时候，发现是文档的开始，就会触发Start doucment事件，用户可以重载这个事件函数来对该事件进行相应处理。又如当遇到新的节点时，则会触发Start element事件，此时我们可以对该节点名进行一些判断，并作出相应的处理等。
优点:不用等待所有数据都被处理后再开始分析，且不需要将整个文档都装入内存中，这对大文档来说是个巨大的优点。一般来说SAX要比DOM方式快很多。
缺点:由于在处理过程中没有储存任何数据，因此在处理过程中不能够对数据流进行后移，或者回溯等操作。
**/
#ifndef __HTML_PARSER_SAX_H__
#define __HTML_PARSER_SAX_H__

#include <string>

#include "Node.h"
#ifdef _ANDROID_
#include <ctype.h>
#endif
#ifdef WIN32
	#ifndef strcasecmp
		#define strcasecmp _stricmp
	#endif
#else
	inline int strncasecmp(const char *s1, const char *s2, register int n) 
	{
		while (--n >= 0 && toupper((unsigned char)*s1) == toupper((unsigned char)*s2++)) 
			if (*s1++ == '\0')  
				return 0;

		return(n < 0 ? 0 : toupper((unsigned char)*s1) - toupper((unsigned char)*--s2));
	}
#endif

namespace htmlcxx
{
	namespace HTML
	{
		class ParserSax
		{
			public:
				ParserSax() : mpLiteral(0), mCdata(false) {}
				virtual ~ParserSax() {}

				/** Parse the html code */
				inline void parse(const std::string &html);

				template <typename _Iterator>
				void parse(_Iterator begin, _Iterator end);

			protected:
				// Redefine this if you want to do some initialization before
				// the parsing
				virtual void beginParsing() {}

				virtual void foundTag(Node node, bool isEnd) {}
				virtual void foundText(Node node) {}
				virtual void foundComment(Node node) {}

				virtual void endParsing() {}


				template <typename _Iterator>
				void parse(_Iterator &begin, _Iterator &end,
						std::forward_iterator_tag);

				template <typename _Iterator>
				void parseHtmlTag(_Iterator b, _Iterator c);

				template <typename _Iterator>
				void parseContent(_Iterator b, _Iterator c);

				template <typename _Iterator>
				void parseComment(_Iterator b, _Iterator c);

				template <typename _Iterator>
				_Iterator skipHtmlTag(_Iterator ptr, _Iterator end);
				
				template <typename _Iterator>
				_Iterator skipHtmlComment(_Iterator ptr, _Iterator end);

				unsigned long mCurrentOffset;
				const char *mpLiteral;
				bool mCdata;
		};
		
		
		
		static
		struct literal_tag {
			int len;
			const char* str;
			int is_cdata;
		}   
		literal_mode_elem[] =
		{   
			{6, "script", 1},
			{5, "style", 1},
			{3, "xmp", 1},
			{9, "plaintext", 1},
			{8, "textarea", 0},
			{0, 0, 0}
		};
		
		template <typename _Iterator>
		void ParserSax::parse(_Iterator begin, _Iterator end)
		{
			//	std::cerr << "Parsing iterator" << std::endl;
			parse(begin, end, typename std::iterator_traits<_Iterator>::iterator_category());
		}
		
		template <typename _Iterator>
		void ParserSax::parse(_Iterator &begin, _Iterator &end, std::forward_iterator_tag)
		{
			typedef _Iterator iterator;
			//	std::cerr << "Parsing forward_iterator" << std::endl;
			mCdata = false;
			mpLiteral = 0;
			mCurrentOffset = 0;
			this->beginParsing();
			
			//	DEBUGP("Parsed text\n");
			
			while (begin != end)
			{
				*begin; // This is for the multi_pass to release the buffer
				iterator c(begin);
				
				while (c != end)
				{
					// For some tags, the text inside it is considered literal and is
					// only closed for its </TAG> counterpart
					while (mpLiteral)
					{
						//				DEBUGP("Treating literal %s\n", mpLiteral);
						while (c != end && *c != '<') ++c;
						
						if (c == end) {
							if (c != begin) this->parseContent(begin, c);
							goto DONE;
						}
						
						iterator end_text(c);
						++c;
						
						if (*c == '/')
						{
							++c;
							const char *l = mpLiteral;
							while (*l && ::tolower(*c) == *l)
							{
								++c;
								++l;
							}
							
							// FIXME: Mozilla stops when it sees a /plaintext. Check
							// other browsers and decide what to do
							if (!*l && strcmp(mpLiteral, "plaintext"))
							{
								// matched all and is not tag plaintext
								while (IsSpace(*c)) ++c;
								
								if (*c == '>')
								{
									++c;
									if (begin != end_text)
										this->parseContent(begin, end_text);
									mpLiteral = 0;
									c = end_text;
									begin = c;
									break;
								}
							}
						}
						else if (*c == '!')
						{
							// we may find a comment and we should support it
							iterator e(c);
							++e;
							
							if (e != end && *e == '-' && ++e != end && *e == '-')
							{
								//						DEBUGP("Parsing comment\n");
								++e;
								c = this->skipHtmlComment(e, end);
							}
							
							//if (begin != end_text)
							//this->parseContent(begin, end_text, end);
							
							//this->parseComment(end_text, c, end);
							
							// continue from the end of the comment
							//begin = c;
						}
					}
					
					if (*c == '<')
					{
						iterator d(c);
						++d;
						if (d != end)
						{
							if (isalpha(*d))
							{
								// beginning of tag
								if (begin != c)
									this->parseContent(begin, c);
								
								//						DEBUGP("Parsing beginning of tag\n");
								d = this->skipHtmlTag(d, end);
								this->parseHtmlTag(c, d);
								
								// continue from the end of the tag
								c = d;
								begin = c;
								break;
							}
							
							if (*d == '/')
							{
								if (begin != c)
									this->parseContent(begin, c);
								
								iterator e(d);
								++e;
								if (e != end && isalpha(*e))
								{
									// end of tag
									//							DEBUGP("Parsing end of tag\n");
									d = this->skipHtmlTag(d, end);
									this->parseHtmlTag(c, d);
								}
								else
								{
									// not a conforming end of tag, treat as comment
									// as Mozilla does
									//							DEBUGP("Non conforming end of tag\n");
									d = this->skipHtmlTag(d, end);
									this->parseComment(c, d);
								}
								
								// continue from the end of the tag
								c = d;
								begin = c;
								break;
							}
							
							if (*d == '!')
							{
								// comment
								if (begin != c)
									this->parseContent(begin, c);
								
								iterator e(d);
								++e;
								
								if (e != end && *e == '-' && ++e != end && *e == '-')
								{
									//							DEBUGP("Parsing comment\n");
									++e;
									d = this->skipHtmlComment(e, end);
								}
								else
								{
									d = this->skipHtmlTag(d, end);
								}
								
								this->parseComment(c, d);
								
								// continue from the end of the comment
								c = d;
								begin = c;
								break;
							}
							
							if (*d == '?' || *d == '%')
							{
								// something like <?xml or <%VBSCRIPT
								if (begin != c)
									this->parseContent(begin, c);
								
								d = this->skipHtmlTag(d, end);
								
								this->parseComment(c, d);
								
								// continue from the end of the comment
								c = d;
								begin = c;
								break;
							}
						}
					}
					c++;
				}
				
				// There may be some text in the end of the document
				if (begin != c)
				{
					this->parseContent(begin, c);
					begin = c;
				}
			}
			
		DONE:
			this->endParsing();
			return;
		}
		
		template <typename _Iterator>
		void ParserSax::parseComment(_Iterator b, _Iterator c)
		{
			//	DEBUGP("Creating comment node %s\n", std::string(b, c).c_str());
			htmlcxx::HTML::Node com_node;
			//FIXME: set_tagname shouldn't be needed, but first I must check
			//legacy code
			std::string comment(b, c);
//			com_node.tagName(comment);
			com_node.text(comment);
			com_node.offset(mCurrentOffset);
			com_node.length((unsigned int)comment.length());
			com_node.isTag(false);
			com_node.isComment(true);
			
			mCurrentOffset += com_node.length();
			
			// Call callback method
			this->foundComment(com_node);
		}
		
		template <typename _Iterator>
		void ParserSax::parseContent(_Iterator b, _Iterator c)
		{
			//	DEBUGP("Creating text node %s\n", (std::string(b, c)).c_str());
			htmlcxx::HTML::Node txt_node;
			//FIXME: set_tagname shouldn't be needed, but first I must check
			//legacy code
			std::string text(b, c);
			//txt_node.tagName(text);
			txt_node.text(text);
			txt_node.offset(mCurrentOffset);
			txt_node.length((unsigned int)text.length());
			txt_node.isTag(false);
			txt_node.isComment(false);
			
			mCurrentOffset += txt_node.length();
			
			// Call callback method
			this->foundText(txt_node);
		}
		
		template <typename _Iterator>
		void ParserSax::parseHtmlTag(_Iterator b, _Iterator c)
		{
			_Iterator name_begin(b);
			++name_begin;
			bool is_end_tag = (*name_begin == '/');
			if (is_end_tag) ++name_begin;
			
			_Iterator name_end(name_begin);
			while (name_end != c && isalnum(*name_end)) 
			{
				++name_end;
			}
			
			std::string name(name_begin, name_end);
			//	DEBUGP("Found %s tag %s\n", is_end_tag ? "closing" : "opening", name.c_str());
			
			if (!is_end_tag) 
			{
				std::string::size_type tag_len = name.length();
				for (int i = 0; literal_mode_elem[i].len; ++i)
				{
					if (tag_len == literal_mode_elem[i].len)
					{
							if (!strcasecmp(name.c_str(), literal_mode_elem[i].str))
							{
								mpLiteral = literal_mode_elem[i].str;
								break;
							}
					}
				}
			} 
			
			htmlcxx::HTML::Node tag_node;
			//by now, length is just the size of the tag
			std::string text(b, c);
			tag_node.length(static_cast<unsigned int>(text.length()));
			tag_node.tagName(name);
			tag_node.text(text);
			tag_node.offset(mCurrentOffset);
			tag_node.isTag(true);
			tag_node.isComment(false);
			
			mCurrentOffset += tag_node.length();
			
			this->foundTag(tag_node, is_end_tag);
		}
		
		template <typename _Iterator>
		_Iterator ParserSax::skipHtmlComment(_Iterator c, _Iterator end)
		{
			while ( c != end ) {
				if (*c++ == '-' && c != end && *c == '-')
				{
					_Iterator d(c);
					while (++c != end && IsSpace(*c));
					if (c == end || *c++ == '>') break;
					c = d;
				}
			}
			
			return c;
		}
		

			
			template <typename _Iterator>
			static inline
			_Iterator find_next_quote(_Iterator c, _Iterator end, char quote)
			{
				//	std::cerr << "generic find" << std::endl;
				while (c != end && *c != quote) ++c;
				return c;
			}
			
			template <>
			inline
			const char *find_next_quote(const char *c, const char *end, char quote)
			{
				//	std::cerr << "fast find" << std::endl;
				const char *d = reinterpret_cast<const char*>(memchr(c, quote, end - c));
				
				if (d) return d;
				else return end;
			}

		
		template <typename _Iterator>
		_Iterator ParserSax::skipHtmlTag(_Iterator c, _Iterator end)
		{
			while (c != end && *c != '>')
			{
				if (*c != '=') 
				{
					++c;
				}
				else
				{ // found an attribute
					++c;
					while (c != end && IsSpace(*c)) ++c;
					
					if (c == end) break;
					
					if (*c == '\"' || *c == '\'') 
					{
						_Iterator save(c);
						char quote = *c++;
						c = find_next_quote(c, end, quote);
						//				while (c != end && *c != quote) ++c;
						//				c = static_cast<char*>(memchr(c, quote, end - c));
						if (c != end) 
						{
							++c;
						} 
						else 
						{
							c = save;
							++c;
						}
						//				DEBUGP("Quotes: %s\n", std::string(save, c).c_str());
					}
				}
			}
			
			if (c != end) ++c;
			
			return c;
		}
		inline  void ParserSax::parse(const std::string &html)
		{
			//	std::cerr << "Parsing string" << std::endl;
			parse(html.c_str(), html.c_str() + html.length());
		}
		
	}//namespace HTML
}//namespace htmlcxx


#endif
