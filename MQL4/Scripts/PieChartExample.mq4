//+------------------------------------------------------------------+
//|                                              PieChartExample.mq4 |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Canvas\Canvas.mqh> 
#include <Math\Random.mqh>
#include <Color\Colors.mqh>
#include <SpatialReasoning\Rectangle.mqh>
#include <SpatialReasoning\Circle.mqh>
//+------------------------------------------------------------------+ 
//| Script program start function                                    | 
//+------------------------------------------------------------------+ 
void OnStart()
  {
   CCanvas canvas;
   int Height=100;
   int Width=Height*2;
   int padding=(int)MathFloor(Width*0.03);
   int marginLeft=(int)MathFloor(padding*2);
   int marginTop=50;
//--- create canvas 

   CoordinatePoint canvasTopLeft(marginLeft,marginTop);
   CoordinatePoint canvasBottomRight(canvasTopLeft.X.Get()+Width,canvasTopLeft.Y.Get()+Height);
   Rectangle canvasSurface(canvasTopLeft,canvasBottomRight);
   if(!canvas.CreateBitmapLabel(0,0,("PieChartCanvas"+(string)Random::Number(0,100000)),(int)canvasTopLeft.X.Get(),(int)canvasTopLeft.Y.Get(),(int)canvasSurface.GetWidth(),(int)canvasSurface.GetHeight(),COLOR_FORMAT_ARGB_NORMALIZE))
     {
      Print("Error creating canvas: ",GetLastError());
     }

   canvas.Erase(Colors::Argb(85,0,0,0));
//--- draw rectangle 

   CoordinatePoint topLeft(padding,padding);
   CoordinatePoint bottomRight(canvasSurface.GetWidth()-padding,canvasSurface.GetHeight()-padding);
   Rectangle r(topLeft,bottomRight);

   canvas.FillRectangle((int)r.A.X.Get(),(int)r.A.Y.Get(),(int)r.C.X.Get(),(int)r.C.Y.Get(),Colors::ArgbFromColor(clrGray,85));

   CoordinatePoint rCenter=r.GetCenter();
   Circle c();
   c.Center.Set(r.GetCenter());
   if(r.GetWidth()<r.GetHeight())
     {
      c.SetDiameter(r.GetWidth()-padding*2);
     }
   if(r.GetWidth()>r.GetHeight())
     {
      c.SetDiameter(r.GetHeight()-padding*2);
     }

   canvas.Pie((int)c.Center.X.Get(),(int)c.Center.Y.Get(),(int)c.GetRadius(),(int)c.GetRadius(),M_PI_4,2*M_PI-M_PI_4,Colors::ArgbFromColor(clrBlue,170),Colors::ArgbFromColor(clrRed,85));
//--- draw second pie 
   canvas.Pie((int)c.Center.X.Get(),(int)c.Center.Y.Get(),(int)c.GetRadius(),(int)c.GetRadius(),2*M_PI-M_PI_4,2*M_PI+M_PI_4,Colors::ArgbFromColor(clrYellow,170),Colors::ArgbFromColor(clrGreen,85));
//--- show updated canvas 
   canvas.Update();
  }
//+------------------------------------------------------------------+
