



\l schema.q

h_tp: hopen 5001

upd:{[tab;tabData] tab upsert tabData}




.u.x:.z.x,(count .z.x)_(":5001";":5015");

.u.end:{
  t: tables `.;                           
  t@: where `g = attr each t@\:`sym;     

  .Q.hdpf[`$":" , .u.x 1; `:db; x; `sym]; 
  
  @[; `sym; `g#] each t;                
 };

\p 5002


h_tp ".u.sub[`;`]"


