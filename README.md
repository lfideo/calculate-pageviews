# calculate-pageviews
The query in `webmasterClicks.sql` file calculates the number of pageviews for each url that is present in a given table within a specific time window. 
It takes into account the time window - the start date, when the url appeared in the index, and the end date, when the url is removed from the index.
Then it calculates clicks that occured throughout that time frame.

The query first joins the table to itself  in order to find all possible combintions for `APPEARED` and `REMOVED` (a query can be added or removed from the index multiple times) events for each query, 
then it does another self join to add a column with `excluded_url_status`, because this column intentionally gets lost in the first iteration, in order to avoid extra grouping.
In the `add_pageviews` CTE, I join yandex metrika table to calculate pageviews, with respect to the defined time windows. 
As a final step, I use the `union all` operation to add rows that don’t have pageviews in the yandex metrika table, because a url can be deleted from the index, even without having a single pageview.

Here is how the initial seo table looks like:
| url  | event_date                  | event               | excluded_url_status |
|------|-----------------------------|---------------------|---------------------|
| test | 2023-05-19T00:00:00.000+03:00 | REMOVED_FROM_SEARCH | LOW_QUALITY         |
| test | 2023-05-19T00:00:00.000+03:00 | APPEARED_IN_SEARCH  | NULL                |
| test | 2023-05-19T00:00:00.000+03:00 | APPEARED_IN_SEARCH  | NULL                |
| test | 2023-05-19T00:00:00.000+03:00 | APPEARED_IN_SEARCH  | NULL                |
| test | 2023-05-19T00:00:00.000+03:00 | APPEARED_IN_SEARCH  | NULL                |

Here is how the initial metrika table looks like:
| date       | URL | pageviews |
|------------|-----|-----------|
| 2023-05-16 | test| 1884      |
| 2023-05-12 | test| 139       |
| 2023-05-10 | test| 6         |
| 2023-05-16 | test| 4         |
| 2023-05-15 | test| 3         |
