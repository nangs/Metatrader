//+------------------------------------------------------------------+
//|                                                                  |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property description "Buys or sells when current MA goes above or below previous MA."
#property description "This will only buy, sell, or close at the beginning of a new bar."
#property description "Try it on Daily bars with the default settings, for a trendy pair."
//----
extern double Leverage_Per_Position=5;
extern int Minimum_Free_Equity_Percent=10;
extern int Slippage=10;
extern ENUM_TIMEFRAMES MA_Timeframe_Previous=60;
extern ENUM_TIMEFRAMES MA_Timeframe_Current=60;
extern int MA_Period_Previous=20;
extern int MA_Period_Current=18;
extern int MA_Shift_Previous=1;
extern int MA_Shift_Current=1;
extern ENUM_MA_METHOD MA_Method=0;
extern ENUM_APPLIED_PRICE MA_Applied_Price=1;

double freeEquityFactor=Minimum_Free_Equity_Percent/100;
datetime lastBarTime=Time[0];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseOrders(int Type)
  {
   int ticket,i;
   bool Result;
//----
   Result=True;
   if(OrdersTotal()!=0)
     {
      for(i=0;i<OrdersTotal();i++)
        {
         ticket=OrderSelect(i,SELECT_BY_POS);
         if(OrderType()==Type)
           {
            if(Type==OP_BUY)
              {
               Result=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage);
              }
            if(Type==OP_SELL)
              {
               Result=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage);
              }
           }
         else
           {
            Result=False;
           }
        }
     }
   return(Result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   bool output=false;
   if(lastBarTime!=Time[0])
     {
      lastBarTime=Time[0];
      output=true;
     }
   return output;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!IsNewBar())
     {
      return;
     }
   if(Bars<MA_Period_Current)
     {
      Print("bars less than MA_Period_Current. Waiting for more history.");
      return;
     }
   if(Bars<MA_Period_Previous)
     {
      Print("bars less than MA_Period_Previous. Waiting for more history.");
      return;
     }
   int ticket;
   string symbol=Symbol();

   double MA=iMA(symbol,MA_Timeframe_Current,MA_Period_Current,MA_Shift_Current,MA_Method,MA_Applied_Price,0);
   double MAPrev=iMA(symbol,MA_Timeframe_Previous,MA_Period_Previous,MA_Shift_Previous,MA_Method,MA_Applied_Price,0);
   double minLots = MarketInfo(symbol,MODE_MINLOT);
   double maxLots = MarketInfo(symbol,MODE_MAXLOT);
   double Lots=NormalizeDouble(AccountBalance()/100000,2);
   Comment("MA Previous ",MAPrev,"MA ",MA,"Lots ",Lots);
   if(Lots<minLots)
     {
      Lots=minLots;
     }
   if(Lots>maxLots)
     {
      Lots=maxLots;
     }
// Check any open SELL orders
   if(Open[0]<MA-Point && Ask<MA) 
     {
      if(CloseOrders(OP_SELL)==True && MAPrev<MA)
        {
         if(AccountFreeMarginCheck(symbol,OP_BUY,Lots)<=AccountEquity()*freeEquityFactor || GetLastError()==134)
           {
            PrintFormat("Not Opening order, not enough free margin for %2.2f lots.",Lots);
            return;
           }
         ticket=OrderSend(symbol,OP_BUY,Lots,Ask,Slippage,0,0);
         if(ticket<0)
           {
            Print(GetLastError());
           }
        }
     }
// Check any open BUY orders
   if(Open[0]>MA+Point && Bid>MA) 
     {
      if(CloseOrders(OP_BUY)==True && MAPrev>MA)
        {
         if(AccountFreeMarginCheck(symbol,OP_SELL,Lots)<=AccountEquity()*freeEquityFactor || GetLastError()==134)
           {
            PrintFormat("Not Opening order, not enough free margin for %2.2f lots.",Lots);
            return;
           }
         ticket=OrderSend(symbol,OP_SELL,Lots,Bid,Slippage,0,0);
         if(ticket<0)
           {
            Print(GetLastError());
           }
        }
     }
//----
   return;
  }
//+------------------------------------------------------------------+
