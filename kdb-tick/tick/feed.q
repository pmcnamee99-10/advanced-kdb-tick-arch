
\l schema.q
 
// Get TP port from command line argument
tpPort:$[count .z.x; .z.x 0; "5001"]
h_tp:@[hopen;`$":localhost:",tpPort;{show "Connection failed: ",x;exit 1}]
 
// Generate line of Quote Data
quoteData:{(
    1?`MSFT`BP`FD`GOOG`GME;
    1?(100.2;112.6;108.4;105.8;107.9);
    1?(101.3;106.4;105.8;110.2;105.8);
    1?(100;200;300;400;500);
    1?(110;210;310;410;510);
    1?(50;60;70;80;90))};
 
// Generate line of Trade Data
tradeData:{(
    1?`MSFT`BP`FD`GOOG`GME;
    1?(130.2;125.5;178.5;140.4;131.6);
    1?(100;200;300;400;500);
    1?(`buy`sell);
    1?(`NASDAQ`NYSE`FTSE`N225`IEX))};
 
sendQuoteToTP:{neg[h_tp](".u.upd"; `quote; quoteData[])}   / Function to send Quotes to TP - async
sendTradeToTP:{neg[h_tp](".u.upd"; `trade; tradeData[])}   / Function to send Trades to TP - async
 
// Define Timer that calls sendQuoteToTP and sendTradeToTP
.z.ts:{
    sendTradeToTP[];
    sendQuoteToTP[];
    };
 
\t 100
 