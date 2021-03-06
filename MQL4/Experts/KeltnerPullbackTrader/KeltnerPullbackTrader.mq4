//+------------------------------------------------------------------+
//|                                        KeltnerPullbackTrader.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property description "Does Magic."
#property strict

#include <EA\KeltnerPullbackTrader\KeltnerPullbackTrader.mqh>
#include <EA\KeltnerPullbackTrader\KeltnerPullbackTraderSettings.mqh>
#include <EA\KeltnerPullbackTrader\KeltnerPullbackTraderConfig.mqh>

KeltnerPullbackTrader *bot;
#include <EA\PortfolioManagerBasedBot\BasicEATemplate.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   KeltnerPullbackTraderConfig config;

   GetBasicConfigs(config);

   config.keltnerPullbackTimeframe=PortfolioTimeframe;
   
   config.keltnerPullbackMaShift=KeltnerPullbackMaShift;
   config.keltnerPullbackMaPeriod=KeltnerPullbackMaPeriod;
   config.keltnerPullbackMaMethod=KeltnerPullbackMaMethod;
   config.keltnerPullbackMaAppliedPrice=KeltnerPullbackMaAppliedPrice;
   config.keltnerPullbackMaColor=KeltnerPullbackMaColor;
   
   config.keltnerPullbackAtrPeriod=KeltnerPullbackAtrPeriod;
   config.atrSkew=AtrSkew;
   config.keltnerPullbackAtrMultiplier=KeltnerPullbackAtrMultiplier;
   config.keltnerPullbackShift=KeltnerPullbackShift;
   config.keltnerPullbackAtrColor=KeltnerPullbackAtrColor;
   config.keltnerPullbackMinimumTpSlDistance=KeltnerPullbackMinimumTpSlDistance;
   
   config.parallelSignals=KeltnerPullbackParallelSignals;

   bot=new KeltnerPullbackTrader(config);

  }
//+------------------------------------------------------------------+
