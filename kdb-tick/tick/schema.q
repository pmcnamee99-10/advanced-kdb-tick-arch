//tradetab

trade:([] time:`timespan$();
 sym:`$();
 price:`float$();
  size:`float$();
  side:`$();
  exchange:`$());



//quotetab

quote:([] time:`timespan$();
  sym:`$();
   ask:`float$(); 
   bid:`float$();
   askSize:`long$();
   bidSize:`long$(); 
   mode:`long$());