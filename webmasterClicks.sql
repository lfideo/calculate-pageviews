with url_event_windows as (
    select  
        sub.url,
        sub.host_url,
        sub.event,
        sub.start_date,
        sub.end_date,
        ue3.excluded_url_status
    from (
        select
            ue1.url,
            ue1.host_url,
            ue2.event,
            ue1.event_date as start_date,
            MIN(ue2.event_date) as end_date
        from
            seo_table ue1
        join
            seo_table ue2
        on
            ue1.url = ue2.url
            and ue1.event like 'APPEARED%'
            and ue2.event like 'REMOVED%'
            and ue2.event_date >= ue1.event_date
        group by
            ue1.url,
            ue1.host_url,
            ue1.event_date,
            ue2.event
        ) as sub
    join
        seo_table ue3
    on
        sub.url=ue3.url
        and ue3.event like 'REMOVED%'
        and sub.end_date=ue3.event_date

), add_pageviews as (
    select
        uew.url,
        uew.host_url,
        uew.excluded_url_status,
        cast(left(uew.start_date, 10)as date) as start_date,
        cast(left(uew.end_date, 10)as date) as end_date,
        coalesce(SUM(su.pageviews),0) as pageviews
    from
        url_event_windows uew
    left join
        metrika_table su
        ON
        uew.url = su.url
        and su.date between uew.start_date and uew.end_date
    group by
        uew.url,
        uew.host_url,
        uew.start_date,
        uew.event,
        uew.excluded_url_status,  
        uew.end_date
), final as (
    select 
        url,
        host_url,
        excluded_url_status,
        start_date,
        end_date,
        pageviews
    from add_pageviews
    union all
    select 
        url,
        host_url,
        excluded_url_status,
        event_date as start_date,
        event_date as end_date,
        0 as pageviews
    from seo_table
    where url not in (
        select distinct url
        from add_pageviews
    ) and event like 'REMOVED%'
) select * from final

