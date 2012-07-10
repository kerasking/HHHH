/**
 htmlcxx: 树的每个节点的数据类型，重载了一些运算符使其方便进行一些逻辑运算，并提供了根据节点内文本分析和存储节点属性的parseAttributes()方法。我们在使用HtmlCxx进行html解析的时候，经常会对Node数据类型进行操作以及用Node进行输出
**/
#ifndef __HTML_PARSER_NODE_H
#define __HTML_PARSER_NODE_H

#include <map>
#include <string>
#include <utility>

extern int IsSpace(int c);

namespace htmlcxx {
	namespace HTML {
		class Node {

			public:
				Node() {}
				//Node(const Node &rhs); //uses default
				~Node() {}

				inline void text(const std::string& text) { this->mText = text; }
				inline const std::string& text() const { return this->mText; }

				inline void closingText(const std::string &text) { this->mClosingText = text; }
				inline const std::string& closingText() const { return mClosingText; }

				inline void offset(unsigned int offset) { this->mOffset = offset; }
				inline unsigned int offset() const { return this->mOffset; }

				inline void length(unsigned int length) { this->mLength = length; }
				inline unsigned int length() const { return this->mLength; }

				inline void tagName(const std::string& tagname) { this->mTagName = tagname; }
				inline const std::string& tagName() const { return this->mTagName; }

				bool isTag() const { return this->mIsHtmlTag; }
				void isTag(bool is_html_tag){ this->mIsHtmlTag = is_html_tag; }

				bool isComment() const { return this->mComment; }
				void isComment(bool comment){ this->mComment = comment; }

				std::pair<bool, std::string> attribute(const std::string &attr) const
				{ 
					std::map<std::string, std::string>::const_iterator i = this->mAttributes.find(attr);
					if (i != this->mAttributes.end()) {
						return make_pair(true, i->second);
					} else {
						return make_pair(false, std::string());
					}
				}

				operator std::string() const;
				std::ostream &operator<<(std::ostream &stream) const;

				const std::map<std::string, std::string>& attributes() const { return this->mAttributes; }
				void parseAttributes();

				bool operator==(const Node &rhs) const;

			protected:

				std::string mText;
				std::string mClosingText;
				unsigned int mOffset;
				unsigned int mLength;
				std::string mTagName;
				std::map<std::string, std::string> mAttributes;
				bool mIsHtmlTag;
				bool mComment;
		};
	}
}

#endif
