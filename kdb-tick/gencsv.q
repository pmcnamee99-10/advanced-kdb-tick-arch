// gencsv.q - FIXED VERSION

n: 100;

trades:([] 
    sym: n?`MSFT`GOOG`BP`GME`FD;
    price: n?100f + n?50f;
    size: `long$ n?100 200 300 400 500;   // Explicit long type
    side: n?`buy`sell;
    exchange: n?`NASDAQ`NYSE`FTSE`IEX
    );

// Save to CSV (with headers)
`:trades.csv 0: csv 0: trades

-1 "Created trades.csv with ",string[n]," rows";
-1 "Columns: ",", " sv string cols trades;
-1 "Preview:";
show 5#trades;
exit 0