// debug_log.q - Inspect TP log contents
\l tick/schema.q

logFile: `:schema2026.03.03

-1 "Trade table schema:";
show meta trade;
-1 "\nTrade columns: ",", " sv string cols trade;
-1 "Column count: ",string count cols trade;

-1 "\n═══════════════════════════════════════";
-1 "Inspecting log messages...";
-1 "═══════════════════════════════════════\n";

upd:{[t;x]
    -1 "─────────────────────────────────";
    -1 "Table: ",string t;
    -1 "Type of x: ",string type x;
    
    $[0h = type x;
        [
            -1 "x is a list with ",string[count x]," elements";
            -1 "Types of elements: "," " sv string type each x;
            -1 "First element type: ",string type first x;
            -1 "First element: ";
            show first x;
            if[2 < count x;
                -1 "Second element: ";
                show x 1;
            ];
        ];
        98h = type x;
        [
            -1 "x is a TABLE";
            -1 "Columns: ",", " sv string cols x;
            -1 "Row count: ",string count x;
            show 3#x;
        ];
        99h = type x;
        [
            -1 "x is a DICT";
            show x;
        ];
        [
            -1 "x is atomic or other type";
            show x;
        ]
    ];
    
    -1 "";
    };

// Replay just first 5 messages
-1 "First 5 messages:\n";
-11!(5; logFile);

-1 "\n═══════════════════════════════════════";
-1 "Debug complete";
exit 0