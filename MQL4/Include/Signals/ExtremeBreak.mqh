//+------------------------------------------------------------------+
//|                                                 ExtremeBreak.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <ChartObjects\ChartObjectsShapes.mqh>
#include <Common\Comparators.mqh>
#include <Signals\AbstractSignal.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ExtremeBreak : public AbstractSignal
  {
private:
   Comparators       compare;
   int               Period;
   double            Low;
   double            High;
   int               minimumPointsDistance;
   CChartObjectRectangle s;
public:
                     ExtremeBreak(int period,ENUM_TIMEFRAMES timeframe,int shift=2,int minimumPointsTpSl=50);
   bool              Validate(ValidationResult *v);
   SignalResult     *Analyze(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ExtremeBreak::ExtremeBreak(int period,ENUM_TIMEFRAMES timeframe,int shift=2,int minimumPointsTpSl=50)
  {
   this.Period=period;
   this.Timeframe=timeframe;
   this.Shift=shift;
   this.minimumPointsDistance=minimumPointsTpSl;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ExtremeBreak::Validate(ValidationResult *v)
  {
   v.Result=true;

   if(!compare.IsNotBelow(this.Period,1))
     {
      v.Result=false;
      v.AddMessage("Period must be 1 or greater.");
     }

   if(!compare.IsNotBelow(this.Shift,0))
     {
      v.Result=false;
      v.AddMessage("Shift must be 0 or greater.");
     }

   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *ExtremeBreak::Analyze(string symbol,int shift)
  {
   this.Signal.Reset();
   this.Low  = iLow(symbol, this.Timeframe, iLowest(symbol,this.Timeframe,MODE_LOW,this.Period,shift));
   this.High = iHigh(symbol, this.Timeframe, iHighest(symbol,this.Timeframe,MODE_HIGH,this.Period,shift));

   long chartId=MarketWatch::GetChartId(symbol,this.Timeframe);
   if(s.Attach(chartId,this.ID(),0,2))
     {
      s.SetPoint(0,Time[shift+this.Period],this.High);
      s.SetPoint(1,Time[shift],this.Low);
     }
   else
     {
      s.Create(chartId,this.ID(),0,Time[shift+this.Period],this.High,Time[shift],this.Low);
      s.Color(clrAquamarine);
      s.Background(false);
     }

   ChartRedraw(chartId);

   double point=MarketInfo(symbol,MODE_POINT);
   double minimumPoints=(double)this.minimumPointsDistance;

   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);

   if(gotTick)
     {
      if(tick.bid<this.Low)
        {
         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_SELL;
         this.Signal.price=tick.bid;
         this.Signal.stopLoss=this.High;
         this.Signal.takeProfit=tick.bid-(this.High-tick.bid);
        }
      if(tick.ask>this.High)
        {
         this.Signal.isSet=true;
         this.Signal.orderType=OP_BUY;
         this.Signal.price=tick.ask;
         this.Signal.symbol=symbol;
         this.Signal.time=tick.time;
         this.Signal.stopLoss=this.Low;
         this.Signal.takeProfit=(tick.ask+(tick.ask-this.Low));
        }
      if(this.Signal.isSet)
        {
         if(MathAbs(this.Signal.price-this.Signal.takeProfit)/point<minimumPoints)
           {
            this.Signal.Reset();
           }
         if(MathAbs(this.Signal.price-this.Signal.stopLoss)/point<minimumPoints)
           {
            this.Signal.Reset();
           }
        }
     }
   return this.Signal;
  }
//+------------------------------------------------------------------+
