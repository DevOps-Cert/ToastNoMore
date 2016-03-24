#Item Buckets

### Scope
To help understand and define an Item Bucket strategy for sitecore for an intranet portal site with a list of personal profile pages.

### Categorisations
The 3 categorisation strategies used by default on Item Buckets are:
* Creation date yyyy/MM/dd/HH/mm => **sitecore/content/2016/3/24/11/00**
* ID and number of levels e.g. **{4fe63e93-d5d1-4128-80b8-283708713214: 4 levels} => sitecore/content/4/f/e/6/**
* Based on the item name and number of levels e.g. **{ItemName=Sitecore: 4 levels} => sitecore/content/S/i/t/e/**

Alternatives strategies:
* Web country codes: http://goes.gsfc.nasa.gov/text/web_country_codes.html
* Unique email addresses
* Autogroup into 100 items limit

Tidy-up URL example:
* Source: Alistair Deneys | https://adeneys.wordpress.com/2013/07/19/item-buckets-and-urls/
```C#
using System;
using System.Linq;
using Sitecore;
using Sitecore.Buckets.Managers;
using Sitecore.ContentSearch;
using Sitecore.ContentSearch.SearchTypes;
using Sitecore.Pipelines.HttpRequest;

namespace CustomBucketUrl
{
  public class CustomItemResolver : HttpRequestProcessor
  {
    public override void Process(HttpRequestArgs args)
    {
      if (Context.Item == null)
      {
        var requestUrl = args.Url.ItemPath;

        // remove last element from path and see if resulting path is a bucket
        var index = requestUrl.LastIndexOf('/');
        if (index > 0)
        {
          var bucketPath = requestUrl.Substring(0, index);
          var bucketItem = args.GetItem(bucketPath);

          if (bucketItem != null && BucketManager.IsBucket(bucketItem))
          {
            var itemName = requestUrl.Substring(index + 1);

            // locate item in bucket by name
            using (var searchContext = ContentSearchManager.GetIndex(bucketItem as IIndexable).CreateSearchContext())
            {
              var result = searchContext.GetQueryable<SearchResultItem>().Where(x => x.Name == itemName).FirstOrDefault();
              if(result != null)
                Context.Item = result.GetItem();
            }
          }
        }
      }
    }
  }
}
```

```C#
using System;
using Sitecore.Buckets.Managers;
using Sitecore.Buckets.Extensions;
using Sitecore.Links;
using Sitecore.IO;

namespace CustomBucketUrl
{
  public class CustomLinkManager : LinkProvider
  {
    public override string GetItemUrl(Sitecore.Data.Items.Item item,UrlOptions options)
    {
      if (BucketManager.IsItemContainedWithinBucket(item))
      {
        var bucketItem = item.GetParentBucketItemOrParent();
        if (bucketItem != null && bucketItem.IsABucket())
        {
          var bucketUrl = base.GetItemUrl(bucketItem, options);
          if (options.AddAspxExtension)
            bucketUrl = bucketUrl.Replace(".aspx", string.Empty);

            return FileUtil.MakePath(bucketUrl, item.Name) + (options.AddAspxExtension ? ".aspx" : string.Empty);
        }
      }

      return base.GetItemUrl(item, options);
    }
  }
}
```
```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration xmlns:patch="http://www.sitecore.net/xmlconfig/">
  <sitecore>
    <pipelines>
      <httpRequestBegin>
        <processor patch:after="processor[@type='Sitecore.Pipelines.HttpRequest.ItemResolver,Sitecore.Kernel']"type="CustomBucketUrl.CustomItemResolver, CustomBucketUrl" />
      </httpRequestBegin>
    </pipelines>
    <linkManager>
      <providers>
        <add name="sitecore">
          <patch:attribute name="type">CustomBucketUrl.CustomLinkManager, CustomBucketUrl</patch:attribute>
        </add>
      </providers>
    </linkManager>
  </sitecore>
</configuration>
```
### 100 Child Item Limit
100 Child Items seems to be more a limit on rendering the content tree for content editors, but some sources report it does affect read performance.

http://www.sitecore.net/learn/blogs/best-practice-blogs/jeff-cram/posts/2013/03/under-the-hood-with-sitecore-7-at-the-new-england-sitecore-user-group.aspx  
Rebuilt on .NET 4.5, Sitecore 7 features faster indexing capabilities and a new concept of Item Buckets. These buckets allow an item to contain nearly unlimited children and reorients end users to thinking about what an item is rather than where it’s located in the content tree. A welcome addition to the platform for developers who have been living within the best practice constraints of keeping children items in a node to under 100 items.

If Item Buckets sound familiar, they should. They were one of the most talked about topics at Sitecore Symposium 2012 in Las Vegas when Sitecore’s Tim Ward wowed the crowd with the concept and released a shared source module to the community. This of course is the same Tim Ward who is one of the lead architects behind Sitecore 7.

https://sdn.sitecore.net/upload/sitecore6/65/cms_tuning_guide_sc60-65-a4.pdf  
The structure of the content tree should be well balanced without having an excess number of items under any parent node. This number should not exceed 100, so careful planning is required to provide structure through the use of folders for organization. Excessive numbers of items, beyond 100, under any parent node decreases the performance perspective for a Sitecore user navigating the content tree in the Content Editor.

http://www.sitecore.net/~/media/Belux/Belux%20PDF%20Partner%20events/PartnereventSitecoreJBE1.ashx  
Limits scalability: Approximately 100 children per item, Approximately 1 million items per DB

http://www.sitecore.net/~/media/Community/Technical%20Blogs/Dev%20Sitecored/performance%20webinar/performancepresentation.ashx  
Sitecore itself has no hard limit on the number of items or the depth of the content tree however many browsers struggle with the time taken downloading the details of items with 100+ children

http://www.sitecore.net/learn/blogs/technical-blogs/john-west-sitecore-blog/posts/2010/11/maximize-sitecore-content-editor-performance.aspx  
The number of items under any parent item affects how quickly that parent unfolds. This also affects usability – think about trying to find a file in a folder with dozens of files. Try to limit the number of children per item to 25, and especially avoid items with more than 100 children.

[Sitecore 8.0 Configuring Search and Item Bucket Scalability](https://doc.sitecore.net/sitecore_experience_platform/80/setting_up__maintaining/search_and_indexing/configuring_search_and_item_bucket_scalability)  
BucketTriggerCountThis setting means that when an item has 100 children, Sitecore asks if you want to automatically convert this item into an item bucket.  

http://blog.boro2g.co.uk/large-number-sitecore-items-per-folder/  
  Nested folders (after) Total: 341, Time to read: 639ms
  Flat items (before) Total: 336, Time to read: 1786ms
