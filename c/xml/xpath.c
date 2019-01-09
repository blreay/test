#include <libxml/parser.h>
#include <libxml/xpath.h>

/* 解析文档 */
xmlDocPtr getdoc(char *docname){
	xmlDocPtr doc;
	doc = xmlParseFile(docname);
	if(doc == NULL){
		fprintf(stderr, "Document not parsed successfully. \n");
		return NULL;
	}

	return doc;
}

/* 查询节点集 */
xmlXPathObjectPtr getnodeset(xmlDocPtr doc, xmlChar *xpath){
	xmlXPathContextPtr context;
	xmlXPathObjectPtr result; /* 存储查询结果 */

	/* 创建一个xpath上下文 */
	context = xmlXPathNewContext(doc);
	if(context == NULL){
		printf("Error in xmlXPathNewContext\n");
		return NULL;
	}
	/* 查询XPath表达式 */
	result = xmlXPathEvalExpression(xpath, context);
	xmlXPathFreeContext(context); /* 释放上下文指针 */
	if(result == NULL){
		printf("Error in xmlXPathEvalExpression\n");
		return NULL;
	}
	/* 检查结果集是否为空 */
	if(xmlXPathNodeSetIsEmpty(result->nodesetval)){
		xmlXPathFreeObject(result); /* 如为这空就释放 */
		printf("No result\n");
		return NULL;
	}
	return result;
}

int main(int argc, char ** argv){
	char *docname;
	xmlDocPtr doc;
	/* 查找所有keyword元素，而不管它们在文档中的位置 */
	//xmlChar *xpath=(xmlChar*)"//keyword";
	//xmlChar *xpath=(xmlChar*)"//jsdljcl:dataset";
	xmlChar *xpath=(xmlChar*)"//jsdljcl\:dataset";
	xmlNodeSetPtr nodeset;
	xmlXPathObjectPtr result;
	int i;
	xmlChar *keyword;

	if(argc <= 1){
		printf("Usage: %s docname\n", argv[0]);
		return(0);
	}

	docname = argv[1];
	doc = getdoc(docname);
	result = getnodeset(doc, xpath);
	if(result){
		/* 得到keyword节点集 */
		nodeset = result->nodesetval;
		for(i=0; i < nodeset->nodeNr; i++){ /* 打印每个节点中的内容 */
			keyword = xmlNodeListGetString(doc, nodeset->nodeTab[i]->xmlChildrenNode, 1);
			printf("keyword: %s\n", keyword);
			xmlFree(keyword);
		}
		xmlXPathFreeObject(result); /* 释放结果集 */
	}

	xmlFreeDoc(doc); /* 释放文档树 */
	xmlCleanupParser(); /* 清除库内存 */
	return(1);
}
