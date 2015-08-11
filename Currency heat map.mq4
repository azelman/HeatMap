//+------------------------------------------------------------------+
//|                                            Currency heat map.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 1

//
//
//
//
//

extern string Currencies   = "USD;EUR;GBP;JPY;CHF;CAD;AUD;NZD";
extern string TimeFrames   = "H4;D1";
extern color  StrongUp     = LimeGreen;
extern color  WeakUp       = Green;
extern color  NoMove       = DimGray;
extern color  WeakDown     = FireBrick;
extern color  StrongDown   = Red;
extern color  DoesNotExist = Black;
extern bool   UseMSLineDrawFont = false;

//
//
//
//
//

string shortName;
int    shortLength;
int    window;  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int    cpairsLen;
int    ctimesLen;
string cpairs[];
int    aTimes[];
int CRI[8];
string addition  = "";
string FontToUse = "Terminal";

int hour = 0;
int seconds = 0;
//
//
//
//
//

int init()
{
   if (UseMSLineDrawFont) FontToUse = "MS LIneDraw";
   Currencies = StringUpperCase(StringTrimLeft(StringTrimRight(Currencies)));
   if (StringSubstr(Currencies,StringLen(Currencies),1) != ";")
                    Currencies = StringConcatenate(Currencies,";");

                                 

      int  s      = 0;
      int  i      = StringFind(Currencies,";",s);
      string current;
         while (i > 0)
         {
            current = StringSubstr(Currencies,s,i-s);
               ArrayResize(cpairs,ArraySize(cpairs)+1);
                           cpairs[ArraySize(cpairs)-1] = current;
                           s = i + 1;
                           i = StringFind(Currencies,";",s);
         }
      cpairsLen = ArraySize(cpairs);



      TimeFrames = StringUpperCase(StringTrimLeft(StringTrimRight(TimeFrames)));
      if (StringSubstr(TimeFrames,StringLen(TimeFrames),1) != ";")
                       TimeFrames = StringConcatenate(TimeFrames,";");

                                  
            
         s = 0;
         i = StringFind(TimeFrames,";",s);
         int time;
            while (i > 0)
            {
               current = StringSubstr(TimeFrames,s,i-s);
               time    = stringToTimeFrame(current);
               if (time > 0) {
                     ArrayResize(aTimes,ArraySize(aTimes)+1);
                                 aTimes[ArraySize(aTimes)-1] = time; }
                                 s = i + 1;
                                     i = StringFind(TimeFrames,";",s);
            }
      ctimesLen = ArraySize(aTimes);
      
   
   if (IsMini()) addition="micro";
      shortName   = MakeUniqueName("CHM ","");
      shortLength = StringLen(shortName);
      IndicatorShortName(shortName);
   return(0);
}

int deinit()
{
   clearObjects();
   return(0);
}


int start()
{
   string name;
   int    gaph = (cpairsLen*66+10);
   int    gapv = (cpairsLen*15+20);
   int    i,k,t;
   int currentSeconds = Seconds();
   int currentHour = Minute();
         window = WindowFind(shortName);  
   
  
   
   // Display of the heat map
   for (t = 0;   t < ctimesLen; t++){   
      for (i = 0;   i < cpairsLen; i++)
      for (k = i+1; k < cpairsLen; k++)
      {
      
         string symbol = cpairs[i]+cpairs[k]+addition;
         double price  = iClose(symbol,aTimes[t],0);
         bool   normal = true;
         bool   exist  = true;
            
            if (price == 0)
               {
                  symbol = cpairs[k]+cpairs[i]+addition;
                  price  = iClose(symbol,aTimes[t],0);
                  normal = false;
               }                  
            if (price == 0) exist = false;
               
         double close = iClose(symbol,aTimes[t],1);
         double high  = iHigh(symbol,aTimes[t],1);
         double low   = iLow(symbol,aTimes[t],1);
         
         
         for (int l=0; l<2; l++)
         {  
            color  theColor = DoesNotExist;
               if (exist)
               {
                  if (!normal) 
                     while (true)
                     {
                        if (price > high)  { theColor = StrongUp;   CRI[i] -= 2; break; }
                        if (price > close) { theColor = WeakUp;     CRI[i] -= 1; break; }
                        if (price== close) { theColor = NoMove;     break; }
                        if (price < low)   { theColor = StrongDown; CRI[i] += 2 ; break; }
                                             theColor = WeakDown;   CRI[i] += 1; break; 
                     }
                  else               
                     while (true)
                     {
                        if (price > high)  { theColor = StrongDown; CRI[i] += 2; break; }
                        if (price > close) { theColor = WeakDown; CRI[i] += 1; break; }
                        if (price== close) { theColor = NoMove; break; }
                        if (price < low)   { theColor = StrongUp; CRI[i] -= 2; break; }
                                             theColor = WeakUp; CRI[i] -= 1; break; 
                  }
               }
               
               //
               //
               //
               //
               //
               
               name = shortName+t+k+i;
               if (ObjectFind(name) == -1)
                     ObjectCreate(name,OBJ_LABEL,window,0,0,0,0);
                     ObjectSet(name,OBJPROP_XDISTANCE,i*66+100+gaph*(t%2));
                     ObjectSet(name,OBJPROP_YDISTANCE,k*15+ 20+gapv*(t/2));
                     ObjectSetText(name,"лллллллл",10,FontToUse,theColor);
               int tmp = k; k = i; i = tmp;
               normal = (!normal);
         }                                    
      }
      
      // Display of the times/currency graph
      name = shortName+"t"+t+i;
      if (ObjectFind(name) == -1)
          ObjectCreate(name,OBJ_LABEL,window,0,0,0,0);
             ObjectSet(name,OBJPROP_XDISTANCE,5 +(t%2)*30);
             ObjectSet(name,OBJPROP_YDISTANCE,20+(t/2)*15);
             ObjectSetText(name,TimeFrameToString(aTimes[t]),10,"Arial Bold");

      //
      //
      //
      //
      //
      
      for (i = 0; i < cpairsLen; i++)
      {
         name = shortName+"h"+t+i;
         if (ObjectFind(name) == -1)
             ObjectCreate(name,OBJ_LABEL,window,0,0,0,0);
                ObjectSet(name,OBJPROP_XDISTANCE,i*66+120+gaph*(t%2));
                ObjectSet(name,OBJPROP_YDISTANCE,       1+gapv*(t/2));
                ObjectSetText(name,cpairs[i] + " " + CRI[i],9,"Arial Bold");
         if ((t%2)>0) continue;
         name = shortName+"v"+t+i;
         if (ObjectFind(name) == -1)
            ObjectCreate(name,OBJ_LABEL,window,0,0,0,0);
             ObjectSet(name,OBJPROP_XDISTANCE,     65);
             ObjectSet(name,OBJPROP_YDISTANCE,i*15+20+gapv*(t/2));
             ObjectSetText(name,cpairs[i],10,"Arial Bold");
      }
      
      
      if(currentSeconds % 10 == 0 && seconds != currentSeconds){
         
         if(t==0)
            printf("-------------------------------------------");
         
         //string currencyValues[8];
         //for (i = 0;   i < cpairsLen; i++){
            //currencyValues[i] = CRI[i] + "." + cpairs[i];   
         //   currencyValues[i] = CRI[i];
         //}
         
         
         //ArraySort(currencyValues);
         string CRIs = "CRI ";
         
         for (i = 0;   i < cpairsLen; i++)
            CRIs = CRIs + StringFormat(";  %5d", CRI[i]);
         
         string data = StringFormat("%s; %d; %s", TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS), t, CRIs);  
         printf(data);  
         
         if(currentHour != hour){
            write_data(data);  
         }
         
         if(t==3)
            printf("-------------------------------------USD--EUR--GBP--JPY--CHF--CAD--AUD--NZD");   
               
      }
      
      
      
      for (i = 0; i < cpairsLen; i++)
      {
        CRI[i] = 0;                 
      }
      
   }
   seconds = currentSeconds;
   hour = currentHour; 
   
   
   // Display of the summation
   
   
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

bool   IsMini() { return(StringFind(Symbol(),"m") > -1); }
string MakeUniqueName(string first, string rest)
{
   string result = first+(MathRand()%1001)+rest;

   while (WindowFind(result)> 0)
          result = first+(MathRand()%1001)+rest;
   return(result);
}

//
//
//
//
//

void clearObjects()
{
   for (int i = ObjectsTotal(); i>=0; i--)
   {
         string name = ObjectName(i);
         if (StringSubstr(name,0,shortLength) == shortName) ObjectDelete(name);
   }         
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   int tf=0;
       tfs = StringTrimLeft(StringTrimRight(StringUpperCase(tfs)));
         if (tfs=="M1" || tfs=="1")     tf=PERIOD_M1;
         if (tfs=="M5" || tfs=="5")     tf=PERIOD_M5;
         if (tfs=="M15"|| tfs=="15")    tf=PERIOD_M15;
         if (tfs=="M30"|| tfs=="30")    tf=PERIOD_M30;
         if (tfs=="H1" || tfs=="60")    tf=PERIOD_H1;
         if (tfs=="H4" || tfs=="240")   tf=PERIOD_H4;
         if (tfs=="D1" || tfs=="1440")  tf=PERIOD_D1;
         if (tfs=="W1" || tfs=="10080") tf=PERIOD_W1;
         if (tfs=="MN" || tfs=="43200") tf=PERIOD_MN1;
  return(tf);
}
string TimeFrameToString(int tf)
{
   string tfs;
   switch(tf) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN";
   }
   return(tfs);
}

//
//
//
//
//

string StringUpperCase(string str)
{
   string   s = str;
   int      lenght = StringLen(str) - 1;
   int      chr;
   
   while(lenght >= 0)
      {
         chr = StringGetChar(s, lenght);
         
         //
         //
         //
         //
         //
         
         if((chr > 96 && chr < 123) || (chr > 223 && chr < 256))
                  s = StringSetChar(s, lenght, chr - 32);
         else 
              if(chr > -33 && chr < 0)
                  s = StringSetChar(s, lenght, chr + 224);
         lenght--;
   }
   return(s);
}

int write_data(string CRIs)
{
  //Print("writeData");
  int handle;
  string filename = "history_CRI.txt";
  handle = FileOpen(filename,FILE_CSV|FILE_READ|FILE_WRITE,';');
  if(handle < 1)
  {
    Comment("Creation of "+filename+" failed. Error #", GetLastError());
    return(0);
  }
  if(!FileSeek(handle, 0, SEEK_END)) {
      Print("new file");
   }
 
  FileWrite(handle, CRIs);
  FileClose(handle);
  Comment("File "+filename+" has been created. "+TimeToStr(TimeCurrent(), TIME_SECONDS) );
  return(0);
}  
