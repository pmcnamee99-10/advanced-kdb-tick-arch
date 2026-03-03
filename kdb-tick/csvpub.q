// csvpub.q - FIXED for your CSV format

if[3 > count .z.x;
    -1 "Usage: q csvpub.q <csv_file> <table_type> <tp_port>";
    exit 1]

csvFile: `$.z.x 0
tableType: `$.z.x 1
tpPort: `$":localhost:",.z.x 2

-1 "CSV File: ",string csvFile;
-1 "Table: ",string tableType;
-1 "TP Port: ",.z.x 2;

// Connect to TP
h: @[hopen; tpPort; {-1 "Failed to connect to TP: ",x; exit 1}]
-1 "Connected to TP";

// Column types - MUST MATCH YOUR CSV (no time column!)
// Your CSV: sym,price,size,side,exchange
colTypes: $[tableType = `trade;
    "SFJSS";    // S=sym, F=price, J=size, S=side, S=exchange
    tableType = `quote;
    "SFFJJJ";   
    ""]

if[colTypes ~ "";
    -1 "Unknown table type: ",string tableType;
    exit 1]

// Load CSV - skip header row with 1_
-1 "Loading CSV...";
raw: read0 hsym csvFile;
-1 "Raw lines: ",string count raw;
-1 "Header: ",first raw;

data: (colTypes; enlist ",") 0: 1_ raw   // 1_ skips header row

-1 "Rows loaded: ",string count data;
-1 "Schema: ";
show meta data;
-1 "First 3 rows:";
show 3#data;

// Publish as columnar data (how TP expects it)
-1 "Publishing to TP...";

// Convert table to list of columns
vals: value flip data;

-1 "Sending ",string[count data]," rows...";
neg[h] (`.u.upd; tableType; vals);
neg[h] (::);  // Flush async queue

-1 "Published ",string[count data]," rows";
hclose h;
-1 "Done!";
exit 0