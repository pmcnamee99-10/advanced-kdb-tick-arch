// rdb2.q - Subscribes to aggregation table only

\l schema.q

h_tp: hopen 5001

// Update function with error handling
upd:{[tab;tabData] 
    // Debug: show what we receive
    //-1 "Received: ",string[tab]," with type ",string type tabData;
    
    // Try to insert, catch errors
    @[tab; tabData; {-1 "Insert error: ",x}]
    }

// Alternative upd - simpler insert
upd:{[tab;tabData] tab insert tabData}

// Subscribe to agg table ONLY
h_tp ".u.sub[`agg;`]"

\p 5003

-1 "RDB2 started on port 5003";
-1 "Subscribed to: agg";