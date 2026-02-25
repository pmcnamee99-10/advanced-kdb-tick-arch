// logging.q - Logging script with connection tracking

// Connection tracking table
.log.conns:([] time:`timestamp$(); event:`$(); handle:`int$(); user:`$(); ip:`$())

// Standard out function
.log.out:{[message] 
    -1 " | " sv (string .z.p; "User:",$[null .z.u;"SYSTEM";string .z.u]; "INFO"; message; "Mem:",string[.Q.w[][`used]])
    }

// Standard error function
.log.err:{[message] 
    -2 " | " sv (string .z.p; "User:",$[null .z.u;"SYSTEM";string .z.u]; "ERROR"; message; "Mem:",string[.Q.w[][`used]])
    }

// Connection opened - log and track
.z.po:{[h] 
    `.log.conns insert (.z.P; `OPEN; h; .z.u; `$string .z.a);
    .log.out["CONN OPEN | handle:",string[h]," | user:",$[null .z.u;"unknown";string .z.u]," | ip:",string .z.a]
    }

// Connection closed - log and track
.z.pc:{[h] 
    `.log.conns insert (.z.P; `CLOSE; h; `; `);
    .log.out["CONN CLOSE | handle:",string h]
    }

// View open connections
.log.open:{select from .log.conns where event=`OPEN}

// View all connection history
.log.all:{.log.conns}

.log.out["LOGGING LOADED"]