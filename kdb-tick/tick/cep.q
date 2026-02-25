 

\l schema.q
 
// Get arguments (as strings)
tpPort:$[count .z.x; .z.x 0; "5001"]
cepPort:$[1<count .z.x; .z.x 1; "5004"]
 
system "p ",cepPort                                                                                       / Set port
 
h_tp:@[hopen; `$":localhost:",tpPort; {show "Connection failed: ",x; exit 1}]
system "t 2000"


upd:{[tab; data] tab upsert data }                                                                        / Upsert data to local tables
 
.z.ts:{
    if[(0<count trade) and 0<count quote;                                                                 / Check we have data
        cutoff:.z.N - 0D00:00:02;                                                                         / 2 second rolling window
       
        recentTrade:select from trade where time > cutoff;                                                / Get recent trades (only ~20 total)
        recentQuote:select from quote where time > cutoff;                                                / Get recent quotes
       
        if[(0<count recentTrade) and 0<count recentQuote;                                                 / Only proceed if data exists
            t1:select maxTrade:max price, minTrade:min price, volume:sum size by sym from recentTrade;
            t2:select spread:avg ask - bid by sym from recentQuote;
           
            aggreData:`time`sym xcols update time:.z.N from 0!t1 lj t2;                                   / Create agg data
           
            delete from `agg;                                                                           / Clear old agg data
            `agg upsert  -5_aggreData;                                                                     / Insert new aggregations
           
            neg[h_tp](`.u.upd; `agg; value flip aggreData);                                             / Publish as columnar lists
           
            delete from `trade where time < cutoff;                                                       / Clean up old trade data
            delete from `quote where time < cutoff;                                                       / Clean up old quote data
            ];
        ];
    }
 
h_tp ".u.sub[`;`]"    
 
 