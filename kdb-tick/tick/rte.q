// rte.q - Simple version

\p 4000
\l schema.q

htp: hopen 5001

// Last value tables
lastQuote:([sym:`$()] time:`timespan$(); ask:`float$(); bid:`float$(); 
           askSize:`long$(); bidSize:`long$(); mode:`long$())

lastTrade:([sym:`$()] time:`timespan$(); price:`float$(); size:`float$(); 
           side:`$(); exchange:`$())

// Aggregation tables added
tradeAgg:([sym:`$()] maxPrice:`float$(); minPrice:`float$(); 
          totalVolume:`float$(); tradeCount:`long$())

topOfBook:([sym:`$()] bestBid:`float$(); bestAsk:`float$(); spread:`float$())

// Simple upd function
upd:{[t;d]
    t insert d;
    
    if[t~`trade;
        `lastTrade upsert d;
        // Recalculate aggregations from full table
        `tradeAgg upsert select maxPrice:max price, minPrice:min price, 
                               totalVolume:sum size, tradeCount:count i by sym from trade;
    ];
    
    if[t~`quote;
        `lastQuote upsert d;
        // Update top of book from last quotes
        `topOfBook upsert select bestBid:last bid, bestAsk:last ask, 
                                spread:last ask-bid by sym from quote;
    ];
    }

htp ".u.sub[`;`]"

-1 "RTE started on port 4000";