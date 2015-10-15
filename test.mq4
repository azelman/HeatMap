//+------------------------------------------------------------------+
//|                                         TimedHeatMapReversal.mq4 |
//|                                              Copyright 2015, AZ. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, AZ."
#property link      ""
#property version   "1.00"
#property strict

//extern string Currencies   = "EUR;GBP;AUD;NZD;USD;CAD;CHF;JPY";
//extern string Currencies   = "JPY;CHF;CAD;USD;NZD;AUD;GBP;EUR";

int lastHour = 0;
int    cpairsLen;
int    ctimesLen;
string cpairs[8];

int CRI[8];
string addition  = "";
string FontToUse = "Terminal";
string lastSymbol;
double lastH4Price = 0;

input int aTime    = PERIOD_M1;
input double TakeProfit    = 100;
input double Lots          = 0.01;
input double TrailingStop  = 100;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
	{
//--- create timer
	 EventSetTimer(60);
//---
   
   cpairs[0] = "EUR";
   cpairs[1] = "GBP";
   cpairs[2] = "AUD";
   cpairs[3] = "NZD";
   cpairs[4] = "USD";
   cpairs[5] = "CAD";
   cpairs[6] = "CHF";
   cpairs[7] = "JPY";
   
	cpairsLen = ArraySize(cpairs);
   
   lastH4Price = iClose("EURUSD",aTime,1);
	 
	 return(INIT_SUCCEEDED);
	}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
	{
//--- destroy timer
	 EventKillTimer();

	}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
	{
//---

	}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
	{
//---
   trailingStop();

   double currentH4Price = iOpen("EURUSD",aTime,0);
   if(lastH4Price == currentH4Price){
      return;
   }

	int currentHour = Hour();

	printf("Current hour ------------------------------------------- " + currentHour);

	// Display of the heat map
	int    i,k, first, second;
	for (i = 0;   i < cpairsLen; i++)
			for (k = i+1; k < cpairsLen; k++)
			{
	
				string symbol = cpairs[i]+cpairs[k]+addition;				
				//printf("Processing symbol " + symbol + " i=" + i +" k="+ k);
				double price  = iClose(symbol,aTime,0);
				bool   normal = true;
				bool   exist  = true;

				if (price == 0)
				{
					symbol = cpairs[k]+cpairs[i]+addition;
					price  = iClose(symbol,aTime,0);
					normal = false;
				}
				if (price == 0) {
				 exist = false;
				 printf("Cannot read forex pair " + symbol);
				}

				// printf("Processing symbol " + symbol  + i +" "+ k);

				 double close = iClose(symbol,aTime,1);
				 double high  = iHigh(symbol,aTime,1);
				 double low   = iLow(symbol,aTime,1);


				 //for(int l = 0; l<2; l++){
						if(!normal){
							 first = i;
							 second = k;
						} else {
							 first = k;
							 second = i;
						}
						if (exist)
						{
							 while (true)
							 {
									if (price > high)  {CRI[first] -= 2; break; }
									if (price > close) {CRI[first] -= 1; break; }
									if (price== close) {break; }
									if (price < low)   {CRI[first] += 2 ; break; }
																			CRI[first] += 1; break;
							 }

							 while (true)
							 {
									if (price > high)  {CRI[second] += 2; break; }
									if (price > close) {CRI[second] += 1; break; }
									if (price== close) {break; }
									if (price < low)   {CRI[second] -= 2; break; }
																			CRI[second] -= 1; break;
							 }
						}

				//}

	 }
	 string CRIs = "CRI ";
	int min = 0;
	int max = 0;
	string currenciesHeader = "-------";
	for (i = 0;   i < cpairsLen; i++){
		if(CRI[i] < CRI[min]) min = i;
		if(CRI[i] > CRI[max]) max = i;

		CRIs = CRIs + StringFormat(";  %5d", CRI[i]);
		currenciesHeader +=  " " + cpairs[i] + " -";
	}
	
	for (i = 0;   i < cpairsLen; i++){
		CRI[i]  = 0;
	}

	printf(CRIs);
	printf(currenciesHeader);

	string symbol = cpairs[min]+cpairs[max]+addition;
	double priceCurrent  = iClose(symbol,PERIOD_M1,0);
	bool buy = true;
	if (priceCurrent == 0)
	{
		symbol = cpairs[max]+cpairs[min]+addition;
		priceCurrent  = iClose(symbol,PERIOD_M1,0);
		buy = false;
	}

	double closePrice = iOpen(lastSymbol, PERIOD_M1, 0);
   if(closePrice == 0){
      string newSymbol = StringSubstr(lastSymbol, 3, 3) + StringSubstr(lastSymbol, 0, 3);; 
      closePrice = iOpen(newSymbol, PERIOD_M5, 0);
   }
	printf("Closing position " + lastSymbol + " for price " + closePrice);
	
	if(buy){
			printf("Buying: " + symbol + " for price " + priceCurrent);
			openPosition(symbol + "micro", 0);
	} else {
			printf("Selling: " + symbol + " for price " + priceCurrent);
			openPosition(symbol + "micro", 1);
	}

	
	//SendMail("STOP " + lastSymbol + " @ " + closePrice + newOrder + symbol + " @ " + price, " ");
   
   
	lastSymbol = symbol;
	lastHour = currentHour;
	lastH4Price = currentH4Price;
	}
	
	
	void openPosition(string symbol, int OP) {
	   int ticket;
      if(AccountFreeMargin()<(100*Lots))
        {
         Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }
      //--- check for long position (BUY) possibility
      if(OP == 0)
        {
         ticket=OrderSend(symbol,OP_BUY,Lots,Ask,3,0,0,"THMR",333,0,Green);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("BUY order opened : ",OrderOpenPrice());
           }
         else
            Print("Error opening BUY order : ",GetLastError());
         return;
        }
      //--- check for short position (SELL) possibility
      if(OP == 1)
        {
         ticket=OrderSend(symbol,OP_SELL,Lots,Bid,3,0,0,"THMR",333,0,Red);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("SELL order opened : ",OrderOpenPrice());
           }
         else
            Print("Error opening SELL order : ",GetLastError());
        }
      //--- exit from the "no opened orders" block
      return;
	
	}
	
	void trailingStop(){
	int total=OrdersTotal();
	for(int cnt=0;cnt<total;cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)){
         Print("OrderModify error selecting order ", cnt);
         continue;
         }
         
         double tsPriceCurrent  = iOpen(OrderSymbol(),PERIOD_M1,0);
         //Print("OrderModify price current ", tsPriceCurrent);
         //--- long position is opened
         if(OrderType()==OP_BUY)
           {
            //--- check for trailing stop
            if(TrailingStop>0)
              {
                  if(OrderStopLoss()<tsPriceCurrent-Point*TrailingStop)
                    {
                     //--- modify order and exit
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),tsPriceCurrent-Point*TrailingStop,OrderOpenPrice()+Point*TakeProfit,0,Green))
                        Print("OrderModify error ",GetLastError());
                     return;
                    }
                 
              }
           }
         if(OrderType()==OP_SELL)
           {
            //--- check for trailing stop
            if(TrailingStop>0)
              {
                  if((OrderStopLoss()>(tsPriceCurrent+Point*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     //--- modify order and exit
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),tsPriceCurrent+Point*TrailingStop,OrderOpenPrice()-Point*TakeProfit,0,Red))
                        Print("OrderModify error ",GetLastError());
                     return;
                    }
                 
              }
           }
        }
     
	}
//+------------------------------------------------------------------+
