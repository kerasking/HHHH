/**
htmlcxx: DOM(DocumentObject Model 文档对象模型)方式，将XML格式的文档读至内存，并为每个节点建立一个对象，之后我们可以通过操作对象的方式来对节点进行操作，即是将XML的节点映射到了内存中的一系列对象之上。
优点:在建立好模型后的查询和修改速度较快。
缺点:在处理之前需要将整个XML文档全部读入内存进行解析，并根据XML树生成一个对象模型，当文档很大时，DOM方式就会突现出其肿大的特性，一个300KB的XML文档可以导致RAM或者虚拟内存中3000000KB的DOM树模型。

**/
#ifndef __HTML_PARSER_DOM_H__
#define __HTML_PARSER_DOM_H__

#include "ParserSax.h"
#include "tree.h"

namespace htmlcxx
{
	namespace HTML
	{
		class ParserDom : public ParserSax
		{
			public:
				ParserDom() {}
				~ParserDom() {}

				const tree<Node> &parseTree(const std::string &html);
				const tree<Node> &getTree()
				{ return mHtmlTree; }

			protected:
				virtual void beginParsing();

				virtual void foundTag(Node node, bool isEnd);
				virtual void foundText(Node node);
				virtual void foundComment(Node node);

				virtual void endParsing();
				
				tree<Node> mHtmlTree;
				tree<Node>::iterator mCurrentState;
		};

		std::ostream &operator<<(std::ostream &stream, const tree<HTML::Node> &tr);
	} //namespace HTML
} //namespace htmlcxx

#endif
