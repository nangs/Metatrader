//+------------------------------------------------------------------+
//|                                                       Monkey.mq4 |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property description "Current Experiment."
#property strict

#include <EA\Monkey\Monkey.mqh>
#include <EA\Monkey\MonkeySettings.mqh>
#include <EA\Monkey\MonkeyConfig.mqh>

Monkey *bot;
#include <EA\PortfolioManagerBasedBot\BasicEATemplate.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   MonkeyConfig config;

   GetBasicConfigs(config);

   config.botPeriod=BotPeriod;
   config.botTimeframe=PortfolioTimeframe;
   config.botMinimumTpSlDistance=BotMinimumTpSlDistance;
   config.botIndicatorColor=BotIndicatorColor;

   bot=new Monkey(config);
  }
//+------------------------------------------------------------------+
