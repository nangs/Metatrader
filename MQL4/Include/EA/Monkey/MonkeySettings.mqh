//+------------------------------------------------------------------+
//|                                               MonkeySettings.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

sinput string MonkeySettings1; // ####
sinput string MonkeySettings2; // #### Signal Settings
sinput string MonkeySettings3; // ####

input int BotPeriod=120; // Period for calculating trigger and exit.
input double BotMinimumTpSlDistance=3.0; // Tp/Sl minimum distance, in spreads.
input color BotIndicatorColor=clrAliceBlue; // Indicator Color.

#include <EA\PortfolioManagerBasedBot\BasicSettings.mqh>
//+------------------------------------------------------------------+
