// eod.q - End of Day Process (FIXED v5)
// Usage: q eod.q <date>

\l tick/schema.q

// ============================================
// CONFIGURATION  
// ============================================

.eod.date: $[count .z.x; "D"$.z.x 0; .z.D];
.eod.hdbPath: hsym `$"./hdb";
.eod.logFile: hsym `$"schema",ssr[string .eod.date; "."; "."];

// Compression: (blockSize; algorithm; level)
// blockSize: 17 = 2^17 = 128KB blocks
// algorithm: 2 = gzip
// level: 9 = max compression
.eod.comp: (17; 2; 9);
.eod.noComp: `sym`time;

// ============================================
// STARTUP
// ============================================

-1 "═══════════════════════════════════════";
-1 "       END OF DAY PROCESS";
-1 "═══════════════════════════════════════";
-1 "Date:     ",string .eod.date;
-1 "Log:      ",string .eod.logFile;
-1 "HDB:      ",string .eod.hdbPath;
-1 "";

if[not count key .eod.logFile;
    -1 "ERROR: Log file not found";
    exit 1];

msgCount: -11!(-2; .eod.logFile);
-1 "Log messages: ",string msgCount;

// ============================================
// INITIALIZE TABLES
// ============================================

-1 "\nInitializing tables...";

.eod.trade: ([] 
    time:`timespan$(); 
    sym:`$(); 
    price:`float$(); 
    size:`long$(); 
    side:`$(); 
    exchange:`$()
    );

.eod.quote: ([]
    time:`timespan$();
    sym:`$();
    ask:`float$();
    bid:`float$();
    askSize:`long$();
    bidSize:`long$();
    mode:`long$()
    );

.eod.tableCounts: ()!();

// ============================================
// REPLAY LOG
// ============================================

-1 "\nReplaying log...";

.eod.cnt: 0;
.eod.st: .z.P;

upd:{[t;x]
    .eod.cnt+: 1;
    .eod.tableCounts[t]+: 1;
    
    if[0 = .eod.cnt mod 200000; 
        -1 "  Processed: ",string[.eod.cnt]," ..."
    ];
    
    if[t = `trade;
        .eod.trade,: flip `time`sym`price`size`side`exchange!x;
        :();
    ];
    
    if[t = `quote;
        .eod.quote,: flip `time`sym`ask`bid`askSize`bidSize`mode!x;
        :();
    ];
    };

@[-11!; .eod.logFile; {-1 "Replay error: ",x}];

-1 "\nReplay complete: ",string[.eod.cnt]," messages in ",string .z.P - .eod.st;
-1 "\nTables in log:";
show .eod.tableCounts;
-1 "\nData loaded:";
-1 "  trade: ",string count .eod.trade;
-1 "  quote: ",string count .eod.quote;

// ============================================
// SAVE WITH COMPRESSION
// ============================================

.eod.save:{[hdb;dt;tblName;data;comp;noComp]
    if[0 = count data; -1 "  ",string[tblName]," - empty"; :0];
    
    -1 "\nSaving ",string[tblName]," (",string[count data]," rows)...";
    
    data: `sym xasc data;
    data: .Q.en[hdb] data;
    data: @[data; `sym; `p#];
    
    pp: ` sv hdb,(`$string dt),tblName,`;
    system "mkdir -p ",1_string pp;
    
    // Save each column
    // Compression format: (path; blockSize; algo; level) set data
    {[pp;nc;cmp;d;c]
        path: ` sv pp,c;
        colData: d c;
        
        $[c in nc;
            // No compression
            path set colData;
            // With compression: (path; blockSize; algo; level)
            (path; cmp 0; cmp 1; cmp 2) set colData
        ];
        
        -1 "    ",string[c],": ",string[hcount path]," bytes",$[c in nc;" (raw)";" (gzip)"];
    }[pp;noComp;comp;data] each cols data;
    
    (` sv pp,`.d) set cols data;
    count data
    };

-1 "\n═══════════════════════════════════════";
-1 "SAVING TO HDB";
-1 "═══════════════════════════════════════";
-1 "Compression: blockSize=128KB, algo=gzip, level=9";
-1 "Uncompressed: ",", " sv string .eod.noComp;

total: 0;
total+: .eod.save[.eod.hdbPath; .eod.date; `trade; .eod.trade; .eod.comp; .eod.noComp];
total+: .eod.save[.eod.hdbPath; .eod.date; `quote; .eod.quote; .eod.comp; .eod.noComp];

// ============================================
// VERIFY
// ============================================

-1 "\n═══════════════════════════════════════";
-1 "VERIFICATION";  
-1 "═══════════════════════════════════════";

-1 "\nHDB files:";
system "ls -la ./hdb/",string[.eod.date],"/trade/";

-1 "\nLoading HDB...";
system "l ./hdb";

-1 "  Tables: ",", " sv string tables[];
-1 "  Trade count: ",string count select from trade where date = .eod.date;
-1 "  Quote count: ",string count select from quote where date = .eod.date;

-1 "\nSample:";
show 3# select from trade where date = .eod.date;

-1 "\n════════════════════════════════════════";
-1 "  ✓ EOD COMPLETE - ",string[total]," rows saved";
-1 "════════════════════════════════════════";

exit 0