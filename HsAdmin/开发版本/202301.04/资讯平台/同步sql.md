# 同步sql

复权因子：
```mysql
select CONVERT(qsa.ID,char) as id, DATE_FORMAT(qsa.ExDiviDate,'%Y%m%d') as trade_date,
       case sm.SecuMarket
           when 83 then 1
           when 90 then 2
           end as market_no,
       sm.SecuCode as stock_code,
       qsa.AdjustingFactor as rstr_factor,
       qsa.ExDiviDate as create_date_time
from QT_StockAdjustFactor qsa
         left join SecuMain sm on qsa.InnerCode = sm.InnerCode;
```

日行情表：
```mysql
select CONVERT(qs.ID,char) as id , DATE_FORMAT(qs.TradingDay, '%Y%m%d') as trade_date,
       case sm.SecuMarket
           when 83 then 1
           when 90 then 2
           end as market_no,
       sm.SecuCode as stock_code, qs.PrevClosePrice as close_price, qs.OpenPrice as open_price, qs.ClosePrice as closing_price,
       qs.HighPrice max_price,qs.LowPrice as min_price, qs.TurnoverValue as deal_balance, qs.TurnoverVolume as deal_amount,
       qs.TurnoverVolume /qp.BuyNumUnit as deal_count, qp.PriceCeiling as top_price, qp.PriceFloor as bottom_price,
       qs.Ifsuspend as stop_flag, qs.TradingDay as create_date_time, sysdate as update_date_time
from qt_stockperformance qs
         join qt_pricelimit qp on qs.InnerCode = qp.InnerCode and qs.TradingDay = qp.TradingDay
         join secumain sm on qs.InnerCode = sm.InnerCode
```