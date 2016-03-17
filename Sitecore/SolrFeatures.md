#Solr Features

This document summarises Apache Solr (http://lucene.apache.org/solr) search features for the purposes of determining UX capabilities.

###Public Solr Servers
Public Solr Server List: https://wiki.apache.org/solr/PublicServers  

Some examples:
* http://evolvingweb.github.io/ajax-solr/examples/reuters/
* https://www.youtube.com/watch?v=0X1PHKuQ6eY : Facets
* https://www.youtube.com/watch?v=aa5e_phA9Rc : MoreLikeThis
* https://www.youtube.com/watch?v=fQMnc4DKQNc : Maps/Geolocation

###Solr search capabilities
https://cwiki.apache.org/confluence/display/solr/Searching  
* **Request handler**: Logic on how to process a request
* **Query parser**: Lucene ([Standard Query Parser](https://cwiki.apache.org/confluence/display/solr/The+Standard+Query+Parser))
* **Filter query**: Filter query runs a query against the entire index and caches the results
* **Highlighting**: Multi-term highlighting showing selected search terms that will be displayed in colored boxes
* **Faceting**: Faceting is the arrangement of search results into categories (which are based on indexed terms).
* **Clustering**: (see: [http://search.carrot2.org](http://search.carrot2.org/stable/search?query=solr&results=100&source=web&algorithm=lingo&view=foamtree&skin=fancy-compact)) Clustering groups search results by similarities discovered when a search is executed, rather than when content is indexed. 
* **Reponse writer**: Generates a formatted response to the search (https://cwiki.apache.org/confluence/display/solr/Response+Writers)
* **Relevance**: Relevance is the degree to which a query response satisfies a user who is searching for information.
* **Spell checking**: The [SpellCheck component](https://cwiki.apache.org/confluence/display/solr/Spell+Checking) is designed to provide inline query suggestions based on other, similar, terms. The basis for these suggestions can be terms in a field in Solr, externally created text files, or fields in other Lucene indexes
* **Re-Ranking**: [Query Re-Ranking](https://cwiki.apache.org/confluence/display/solr/Query+Re-Ranking) allows you to run a simple query (A) for matching documents and then re-rank the top N documents using the scores from a more complex query (B). 
* **Auto-suggest**: [The SuggestComponent](https://cwiki.apache.org/confluence/display/solr/Suggester) in Solr provides users with automatic suggestions for query terms. You can use this to implement a powerful auto-suggest feature in your search application.
* **MoreLikeThis**: The MoreLikeThis search component enables users to query for documents similar to a document in their result list. It does this by using terms from the original document to find similar documents in the index.
* **Pagination of results**: In Solr basic [paginated searching](https://cwiki.apache.org/confluence/display/solr/Pagination+of+Results) is supported using the start and rows parameters
* **Result Grouping**: [Result Grouping](https://cwiki.apache.org/confluence/display/solr/Result+Grouping) is separate from Faceting. Result Grouping groups documents with a common field value into groups and returns the top documents for each group. For example, if you searched for "DVD" on an electronic retailer's e-commerce site, you might be returned three categories such as "TV and Video," "Movies," and "Computers," with three results per category. In this case, the query term "DVD" appeared in all three categories, so Solr groups them together in order to increase relevancy for the user.
* **Collapse and Expand results**: The [Collapsing query parser and the Expand component](https://cwiki.apache.org/confluence/display/solr/Collapse+and+Expand+Results) combine to form an approach to grouping documents for field collapsing in search results. The Collapsing query parser groups documents (collapsing the result set) according to your parameters, while the Expand component provides access to documents in the collapsed group for use in results display or other processing by a client application.
* **Spatial search**: spatial/geospatial searches. 
* **Stats component**: The Stats component returns simple statistics for numeric, string, and date fields within the document set
* **Query elevation component**: The Query Elevation Component lets you configure the top results for a given query regardless of the normal Lucene scoring
* **Client API**: https://cwiki.apache.org/confluence/display/solr/Client+API+Lineup

###Solr Faceting 
![FacetingImage](https://cwiki.apache.org/confluence/download/attachments/32604233/worddav88969a784fb8a63d8c46e9c043f5f953.png)

###Solr Clustering
![Carrot2Image](https://cwiki.apache.org/confluence/download/attachments/34836344/carrot2.png?version=1&modificationDate=1440417669000&api=v2)

####Solr Grouping
The grouping of the search term "DVD" groups search results into 3 categories 'TV & Video', 'Movies', 'Computers'  
![GroupingImage](https://home.apache.org/~hossman/solr-meetup-20131007/slide-resources/bestbuy-grouping.jpg)
___

###Full-Text Search
Phrases, wildcards, joins, grouping etc. across data types

###Schema and Schemaless (data-driven schemas)
https://cwiki.apache.org/confluence/display/solr/Documents%2C+Fields%2C+and+Schema+Design  
The schema is the place where you tell Solr how it should build indexes from input documents.

####Field Types
* https://cwiki.apache.org/confluence/display/solr/Solr+Field+Types
* https://cwiki.apache.org/confluence/display/solr/Field+Types+Included+with+Solr

####Analyzers, Tokenizers, and Filters
Field [**analyzers**](https://cwiki.apache.org/confluence/display/solr/Analyzers) are used both during ingestion, when a document is indexed, and at query time. An analyzer examines the text of fields and generates a token stream. Analyzers may be a single class or they may be composed of a series of tokenizer and filter classes.  

[**Tokenizers**](https://cwiki.apache.org/confluence/display/solr/About+Tokenizers) break field data into lexical units, or tokens.  

[**Filters**](https://cwiki.apache.org/confluence/display/solr/About+Filters) examine a stream of tokens and keep them, transform or discard them, or create new ones. Tokenizers and filters may be combined to form pipelines, or chains, where the output of one is input to the next. Such a sequence of tokenizers and filters is called an analyzer and the resulting output of an analyzer is used to match query results or build indices.  

###Facets

###Geospatial Search

###Text Analysis
Solr ships with support for most of the widely spoken languages in the world (English, Chinese, Japanese, German, French and many more)

###Security
Authentication and Role based Authorization

###Query Suggestions and Spelling
Solr ships with advanced capabilites for auto-complete (typeahead search), spell checking and more

###Document Parsing
Index rich content such as Adobe PDF, Microsoft Word and more.

###Apache UIMA
Apache UIMA, making it easy to leverage NLP and other tools as part of your application
