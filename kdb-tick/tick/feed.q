// open port to TP eg 5001
hOP: hopen 5001

// function to send quotes to TP
sendQuoteToTP:{neg[hOP](`.u.upd;`quote;quoteData[])};


// function to send trades to TP
sendTradeToTP:{neg[hOP](`.u.upd;`trade;tradeData[])};


// Generate a line of quote data 
quoteData: {
    
   n:1;
   (
    n?`NVDA`AAPL`GOOG`CCP`MSFT;
    n?100f;
    n?100f;
    n?500j;
    n?500j;
    n?100j
    )
 };


// Generate a line of trade data 
tradeData: {
    
   n:1;
   (
    
     n?`NVDA`AAPL`GOOG`CCP`MSFT;
     n?100f;
     n?500f;
     n?`buy`sell;
     n?`NYSE`LSE`NV
    )
 };


// define timer that calls sendQuoteToTP and sendQuoteToTP

.z.ts:{sendQuoteToTP[];sendTradeToTP[]};


// set timer
\t 1000