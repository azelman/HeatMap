//+------------------------------------------------------------------+
//|                                         TimedHeatMapReversal.mq4 |
//|                                              Copyright 2015, AZ. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, AZ."
#property link      ""
#property version   "1.00"
#property strict

extern string Currencies   = "EUR;GBP;AUD;NZD;USD;CAD;CHF;JPY";
//extern string Currencies   = "JPY;CHF;CAD;USD;NZD;AUD;GBP;EUR";

int lastHour = 0;
int    cpairsLen;
int    ctimesLen;
string cpairs[];
int    aTime = PERIOD_H4;
int CRI[8];
string addition  = "";
string FontToUse = "Terminal";
string lastSymbol;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
	{
//--- create timer
	 EventSetTimer(100);
//---

	 if (StringSubstr(Currencies,StringLen(Currencies),1) != ";")
										Currencies = StringConcatenate(Currencies,";");

			int  s      = 0;
			int  i      = StringFind(Currencies,";",s);
			string current;
			while (i > 0)
			{
				current = StringSubstr(Currencies,s,i-s);
				ArrayResize(cpairs,ArraySize(cpairs)+1);
				printf("Init - Parsing currencies: " + ArraySize(cpairs) + " " + current));
				cpairs[ArraySize(cpairs)-1] = current;
				s = i + 1;
				i = StringFind(Currencies,";",s);
			}
			cpairsLen = ArraySize(cpairs);

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
	int currentHour = Hour();
	if(currentHour == lastHour || currentHour % 4 != 0) {
	 return;
	}

	printf("Current hour ------------------------------------------- " + currentHour);

	// Display of the heat map
	int    i,k, first, second;
	for (i = 0;   i < cpairsLen; i++)
			for (k = i+1; k < cpairsLen; k++)
			{
	
				string symbol = cpairs[i]+cpairs[k]+addition;				
				printf("Processing symbol " + symbol + " i=" + i +" k="+ k);
				double price  = iClose(symbol,aTime,1);
				bool   normal = true;
				bool   exist  = true;

				if (price == 0)
				{
					symbol = cpairs[k]+cpairs[i]+addition;
					price  = iClose(symbol,aTime,1);
					normal = false;
				}
				if (price == 0) {
				 exist = false;
				 printf("Cannot read forex pair " + symbol);
				}

				// printf("Processing symbol " + symbol  + i +" "+ k);

				 double close = iClose(symbol,aTime,2);
				 double high  = iHigh(symbol,aTime,2);
				 double low   = iLow(symbol,aTime,2);


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
	string currenciesHeader = "----------";
	for (i = 0;   i < cpairsLen; i++){
		if(CRI[i] < CRI[min]) min = i;
		if(CRI[i] > CRI[max]) max = i;

		CRIs = CRIs + StringFormat(";  %5d", CRI[i]);
		CRI[i] = 0;
		currenciesHeader +=  " " + cpairs[i] + " ---";
	}

	printf(CRIs);
	printf(currenciesHeader);

	string symbol = cpairs[min]+cpairs[max]+addition;
	double price  = iClose(symbol,aTime,1);
	bool buy = true;
	if (price == 0)
	{
		symbol = cpairs[max]+cpairs[min]+addition;
		price  = iClose(symbol,aTime,1);
		buy = false;
	}

	int closePrice = iOpen(lastSymbol, PERIOD_M1, 0);
	printf("Closing position " + lastSymbol + " for price " + closePrice);
	
	string newOrder = " BUY ";
	if(buy){
			printf("Buying: " + symbol + " for price " + price);
	} else {
			printf("Selling: " + symbol + " for price " + price);
			newOrder = " SELL ";
	}
	
	SendMail("STOP " + lastSymbol + " @ " + closePrice + newOrder + symbol + " @ " + price, " ");
   
	lastSymbol = symbol;
	lastHour = currentHour;
	}
//+------------------------------------------------------------------+
