//tradetab

trade:([] time:`timespan$();
 sym:`$();
 price:`float$();
  size:`long$();
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


// Defining Aggregration table
agg:([] time:`timespan$();
          sym:`$();
          maxTrade:`float$();
          minTrade:`float$();
          volume:`long$();
          spread:`float$())
 