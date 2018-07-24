//+------------------------------------------------------------------+
//|                                                 OrderManager.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <stdlib.mqh>
#include <Generic\ArrayList.mqh>
#include <Common\ValidationResult.mqh>
#include <Common\SimpleParsers.mqh>
#include <Common\BaseLogger.mqh>
#include <Common\Comparators.mqh>
#include <Signals\SignalResult.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderManager
  {
private:
   SimpleParsers     simpleParsers;
public:
   int               Slippage;
   BaseLogger        Logger;
   void              OrderManager();
   bool              OrderManager::Validate();
   bool              OrderManager::Validate(ValidationResult *validationResult);
   bool              CanTrade();
   bool              CanTrade(string symbol,datetime time);
   void              SendOrder(SignalResult *s,double lotSize);
   void              CloseOrders(string symbol,datetime minimumAge);
   double            PairOpenPositionCount(string symbol,datetime minimumAge);
   double            PairProfit(string symbol);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderManager::OrderManager()
  {
   this.Slippage=10;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::Validate()
  {
   ValidationResult *v=new ValidationResult();
   bool out=this.Validate(v);
   delete v;
   return out;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderManager::Validate(ValidationResult *validationResult)
  {
   Comparators compare;
   validationResult.Result=true;

   if(compare.IsLessThan(this.Slippage,(int)0))
     {
      validationResult.AddMessage("The Slippage must be greater than or equal to zero.");
      validationResult.Result=false;
     }

   return validationResult.Result;
  }
//+------------------------------------------------------------------+
//| Basic check on whether trading is allowed and enabled for the    |
//| current symbol at the current time.                              |
//+------------------------------------------------------------------+
bool OrderManager::CanTrade()
  {
   return IsTesting() || IsTradeAllowed();
  }
//+------------------------------------------------------------------+
//| Basic check on whether trading is allowed and enabled.           |
//+------------------------------------------------------------------+
bool OrderManager::CanTrade(string symbol,datetime time)
  {
   return IsTesting() || IsTradeAllowed(symbol,time);
  }
//+------------------------------------------------------------------+
//| Gets the highest price paid for any order older than the         |
//| minimum age, on the given pair.                                  |
//+------------------------------------------------------------------+
double OrderManager::PairOpenPositionCount(string symbol,datetime minimumAge)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)
         && (OrderType()==OP_BUY || OrderType()==OP_SELL)
         && OrderSymbol()==symbol
         && (OrderOpenTime()<=minimumAge))
        {
         num=num+1;
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the current net profit of open positions on the given        |
//|currency pair.                                                    |
//+------------------------------------------------------------------+
double OrderManager::PairProfit(string symbol)
  {
   double sum=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && (OrderType()==OP_BUY || OrderType()==OP_SELL) && OrderSymbol()==symbol)
        {
         sum=sum+OrderProfit();
        }
     }
   return sum;
  }
//+------------------------------------------------------------------+
//| Closes all orders for the specified symbol that are older than   |
//| the minimum age.                                                 |
//+------------------------------------------------------------------+
void OrderManager::CloseOrders(string symbol,datetime minimumAge)
  {
   int ticket,i;
//----
   while(PairOpenPositionCount(symbol,minimumAge)>0)
     {
      for(i=0;i<OrdersTotal();i++)
        {
         ticket=OrderSelect(i,SELECT_BY_POS);
         if(OrderType()==OP_BUY && OrderSymbol()==symbol && (OrderOpenTime()<=minimumAge))
           {
            if(OrderClose(OrderTicket(),OrderLots(),Bid,this.Slippage)==false)
              {
               this.Logger.Error((string)GetLastError());
              }
           }
         if(OrderType()==OP_SELL && OrderSymbol()==symbol && (OrderOpenTime()<=minimumAge))
           {
            if(OrderClose(OrderTicket(),OrderLots(),Ask,this.Slippage)==false)
              {
               this.Logger.Error((string)GetLastError());
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderManager::SendOrder(SignalResult *r,double lotSize)
  {
   double minStops=(MarketInfo(r.symbol,MODE_STOPLEVEL)+MarketInfo(r.symbol,MODE_SPREAD))*MarketInfo(r.symbol,MODE_POINT);
   double tpd=MathAbs(r.price - r.takeProfit);
   double sld=MathAbs(r.price - r.stopLoss);
   if(sld>minStops && tpd>minStops)
     {
      int d=(int)SymbolInfoInteger(r.symbol,SYMBOL_DIGITS);
      int ticket=OrderSend(
                           (string)r.symbol,
                           (ENUM_ORDER_TYPE)r.orderType,
                           NormalizeDouble(lotSize,2),
                           NormalizeDouble(r.price,d),
                           (int)this.Slippage,
                           NormalizeDouble(r.stopLoss,d),
                           NormalizeDouble(r.takeProfit,d));
      if(ticket<0)
        {
         this.Logger.Error("OrderSend Error : "+ ErrorDescription(GetLastError()));
         this.Logger.Error(StringConcatenate(
                           "Order Sent : symbol= ",r.symbol,
                           ", type= ",EnumToString((ENUM_ORDER_TYPE)r.orderType),
                           ", lots= ",NormalizeDouble(lotSize,2),
                           ", price= ",NormalizeDouble(r.price,d),
                           ", slippage= ",this.Slippage,
                           ", stop loss= ",NormalizeDouble(r.stopLoss,d),
                           ", take profit=  ",NormalizeDouble(r.takeProfit,d)));
         if(IsTesting())
           {
            ExpertRemove();
           }
        }
     }
  }
//+------------------------------------------------------------------+
