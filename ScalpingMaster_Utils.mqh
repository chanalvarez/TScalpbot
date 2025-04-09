//+------------------------------------------------------------------+
//|                                        ScalpingMaster_Utils.mqh   |
//|                                          Copyright 2023, TraeAI   |
//|                                                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, TraeAI"
#property link      ""
#property strict

//+------------------------------------------------------------------+
//| Calculate Fibonacci levels                                        |
//+------------------------------------------------------------------+
void CalculateFibonacciLevels(double &levels[], double high, double low)
{
   ArrayResize(levels, 7);
   
   // Standard Fibonacci retracement levels
   levels[0] = low;                          // 0.0
   levels[1] = low + (high - low) * 0.236;   // 23.6%
   levels[2] = low + (high - low) * 0.382;   // 38.2%
   levels[3] = low + (high - low) * 0.5;     // 50.0%
   levels[4] = low + (high - low) * 0.618;   // 61.8%
   levels[5] = low + (high - low) * 0.786;   // 78.6%
   levels[6] = high;                         // 100.0%
}

//+------------------------------------------------------------------+
//| Calculate pivot points                                            |
//+------------------------------------------------------------------+
void CalculatePivotPoints(double &pivots[], double high, double low, double close)
{
   ArrayResize(pivots, 7);
   
   // Calculate pivot point
   double pivot = (high + low + close) / 3;
   
   // Calculate support and resistance levels
   pivots[0] = pivot;                         // Pivot Point (PP)
   pivots[1] = 2 * pivot - high;              // Support 1 (S1)
   pivots[2] = pivot - (high - low);          // Support 2 (S2)
   pivots[3] = pivot - 2 * (high - low);      // Support 3 (S3)
   pivots[4] = 2 * pivot - low;               // Resistance 1 (R1)
   pivots[5] = pivot + (high - low);          // Resistance 2 (R2)
   pivots[6] = pivot + 2 * (high - low);      // Resistance 3 (R3)
}

//+------------------------------------------------------------------+
//| Calculate Bollinger Bands width                                   |
//+------------------------------------------------------------------+
double CalculateBollingerWidth(int period, double deviation, int shift)
{
   double upper = iBands(Symbol(), 0, period, deviation, 0, PRICE_CLOSE, MODE_UPPER, shift);
   double lower = iBands(Symbol(), 0, period, deviation, 0, PRICE_CLOSE, MODE_LOWER, shift);
   double middle = iBands(Symbol(), 0, period, deviation, 0, PRICE_CLOSE, MODE_MAIN, shift);
   
   return (upper - lower) / middle;
}

//+------------------------------------------------------------------+
//| Calculate Average True Range percentage                           |
//+------------------------------------------------------------------+
double CalculateATRPercent(int period, int shift)
{
   double atr = iATR(Symbol(), 0, period, shift);
   double close = iClose(Symbol(), 0, shift);
   
   return atr / close * 100;
}

//+------------------------------------------------------------------+
//| Calculate MACD histogram                                          |
//+------------------------------------------------------------------+
double CalculateMACDHistogram(int fastEMA, int slowEMA, int signalPeriod, int shift)
{
   double macd = iMACD(Symbol(), 0, fastEMA, slowEMA, signalPeriod, PRICE_CLOSE, MODE_MAIN, shift);
   double signal = iMACD(Symbol(), 0, fastEMA, slowEMA, signalPeriod, PRICE_CLOSE, MODE_SIGNAL, shift);
   
   return macd - signal;
}

//+------------------------------------------------------------------+
//| Calculate RSI divergence                                          |
//+------------------------------------------------------------------+
bool CheckRSIDivergence(int period, int lookback, bool &bullish, bool &bearish)
{
   bullish = false;
   bearish = false;
   
   // Find price highs and lows
   int priceHighBar1 = -1, priceHighBar2 = -1;
   int priceLowBar1 = -1, priceLowBar2 = -1;
   
   // Find first high and low
   for(int i = 0; i < lookback; i++)
   {
      bool isHigh = true;
      bool isLow = true;
      
      for(int j = 1; j <= 3; j++)
      {
         if(i+j < lookback)
         {
            if(iHigh(Symbol(), 0, i) <= iHigh(Symbol(), 0, i+j))
               isHigh = false;
            if(iLow(Symbol(), 0, i) >= iLow(Symbol(), 0, i+j))
               isLow = false;
         }
         
         if(i-j >= 0)
         {
            if(iHigh(Symbol(), 0, i) <= iHigh(Symbol(), 0, i-j))
               isHigh = false;
            if(iLow(Symbol(), 0, i) >= iLow(Symbol(), 0, i-j))
               isLow = false;
         }
      }
      
      if(isHigh && priceHighBar1 == -1)
         priceHighBar1 = i;
      else if(isHigh && priceHighBar1 != -1 && priceHighBar2 == -1)
         priceHighBar2 = i;
         
      if(isLow && priceLowBar1 == -1)
         priceLowBar1 = i;
      else if(isLow && priceLowBar1 != -1 && priceLowBar2 == -1)
         priceLowBar2 = i;
         
      if(priceHighBar1 != -1 && priceHighBar2 != -1 && priceLowBar1 != -1 && priceLowBar2 != -1)
         break;
   }
   
   // Check if we found the required highs and lows
   if(priceHighBar1 == -1 || priceHighBar2 == -1 || priceLowBar1 == -1 || priceLowBar2 == -1)
      return false;
      
   // Get RSI values at the price highs and lows
   double rsiHigh1 = iRSI(Symbol(), 0, period, PRICE_CLOSE, priceHighBar1);
   double rsiHigh2 = iRSI(Symbol(), 0, period, PRICE_CLOSE, priceHighBar2);
   double rsiLow1 = iRSI(Symbol(), 0, period, PRICE_CLOSE, priceLowBar1);
   double rsiLow2 = iRSI(Symbol(), 0, period, PRICE_CLOSE, priceLowBar2);
   
   // Check for bearish divergence (price higher high, RSI lower high)
   if(iHigh(Symbol(), 0, priceHighBar1) > iHigh(Symbol(), 0, priceHighBar2) && rsiHigh1 < rsiHigh2)
      bearish = true;
      
   // Check for bullish divergence (price lower low, RSI higher low)
   if(iLow(Symbol(), 0, priceLowBar1) < iLow(Symbol(), 0, priceLowBar2) && rsiLow1 > rsiLow2)
      bullish = true;
      
   return (bullish || bearish);
}

//+------------------------------------------------------------------+
//| Calculate Stochastic crossover                                    |
//+------------------------------------------------------------------+
bool CheckStochasticCrossover(int kPeriod, int dPeriod, int slowing, int shift, bool &bullish, bool &bearish)
{
   bullish = false;
   bearish = false;
   
   double k1 = iStochastic(Symbol(), 0, kPeriod, dPeriod, slowing, MODE_SMA, 0, MODE_MAIN, shift);
   double d1 = iStochastic(Symbol(), 0, kPeriod, dPeriod, slowing, MODE_SMA, 0, MODE_SIGNAL, shift);
   double k2 = iStochastic(Symbol(), 0, kPeriod, dPeriod, slowing, MODE_SMA, 0, MODE_MAIN, shift+1);
   double d2 = iStochastic(Symbol(), 0, kPeriod, dPeriod, slowing, MODE_SMA, 0, MODE_SIGNAL, shift+1);
   
   // Bullish crossover (K crosses above D)
   if(k1 > d1 && k2 <= d2)
      bullish = true;
      
   // Bearish crossover (K crosses below D)
   if(k1 < d1 && k2 >= d2)
      bearish = true;
      
   return (bullish || bearish);
}

//+------------------------------------------------------------------+
//| Check for price action patterns                                   |
//+------------------------------------------------------------------+
bool CheckPriceActionPattern(int shift, string &patternName, int &direction)
{
   direction = 0; // 1 for bullish, -1 for bearish, 0 for neutral
   patternName = "None";
   
   // Get candle data
   double open1 = iOpen(Symbol(), 0, shift);
   double high1 = iHigh(Symbol(), 0, shift);
   double low1 = iLow(Symbol(), 0, shift);
   double close1 = iClose(Symbol(), 0, shift);
   
   double open2 = iOpen(Symbol(), 0, shift+1);
   double high2 = iHigh(Symbol(), 0, shift+1);
   double low2 = iLow(Symbol(), 0, shift+1);
   double close2 = iClose(Symbol(), 0, shift+1);
   
   double open3 = iOpen(Symbol(), 0, shift+2);
   double high3 = iHigh(Symbol(), 0, shift+2);
   double low3 = iLow(Symbol(), 0, shift+2);
   double close3 = iClose(Symbol(), 0, shift+2);
   
   // Calculate candle sizes
   double body1 = MathAbs(open1 - close1);
   double body2 = MathAbs(open2 - close2);
   double body3 = MathAbs(open3 - close3);
   
   double range1 = high1 - low1;
   double range2 = high2 - low2;
   double range3 = high3 - low3;
   
   // Check for Pin Bar (Hammer/Shooting Star)
   if(body1 < range1 * 0.3) // Small body
   {
      double upperWick = high1 - MathMax(open1, close1);
      double lowerWick = MathMin(open1, close1) - low1;
      
      // Hammer (bullish)
      if(lowerWick > body1 * 2 && upperWick < body1 * 0.5)
      {
         patternName = "Hammer";
         direction = 1;
         return true;
      }
      
      // Shooting Star (bearish)
      if(upperWick > body1 * 2 && lowerWick < body1 * 0.5)
      {
         patternName = "Shooting Star";
         direction = -1;
         return true;
      }
   }
   
   // Check for Engulfing patterns
   bool bullishCandle1 = close1 > open1;
   bool bullishCandle2 = close2 > open2;
   
   // Bullish Engulfing
   if(bullishCandle1 && !bullishCandle2 && 
      open1 < close2 && close1 > open2 && 
      body1 > body2 * 0.8)
   {
      patternName = "Bullish Engulfing";
      direction = 1;
      return true;
   }
   
   // Bearish Engulfing
   if(!bullishCandle1 && bullishCandle2 && 
      open1 > close2 && close1 < open2 && 
      body1 > body2 * 0.8)
   {
      patternName = "Bearish Engulfing";
      direction = -1;
      return true;
   }
   
   // Check for Doji
   if(body1 < range1 * 0.1)
   {
      patternName = "Doji";
      direction = 0;
      return true;
   }
   
   // Check for Morning Star (bullish reversal)
   bool bearishCandle3 = close3 < open3;
   if(bearishCandle3 && body2 < body3 * 0.5 && bullishCandle1 && 
      close1 > (open3 + close3) / 2)
   {
      patternName = "Morning Star";
      direction = 1;
      return true;
   }
   
   // Check for Evening Star (bearish reversal)
   bool bullishCandle3 = close3 > open3;
   if(bullishCandle3 && body2 < body3 * 0.5 && !bullishCandle1 && 
      close1 < (open3 + close3) / 2)
   {
      patternName = "Evening Star";
      direction = -1;
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Calculate support and resistance levels                           |
//+------------------------------------------------------------------+
void CalculateSupportResistance(int lookback, double &supportLevels[], double &resistanceLevels[], int &supportCount, int &resistanceCount)
{
   supportCount = 0;
   resistanceCount = 0;
   
   ArrayResize(supportLevels, 10);
   ArrayResize(resistanceLevels, 10);
   
   // Find swing highs and lows
   for(int i = 5; i < lookback - 5; i++)
   {
      // Check for swing high
      bool isSwingHigh = true;
      for(int j = 1; j <= 5; j++)
      {
         if(iHigh(Symbol(), 0, i) <= iHigh(Symbol(), 0, i+j) || 
            iHigh(Symbol(), 0, i) <= iHigh(Symbol(), 0, i-j))
         {
            isSwingHigh = false;
            break;
         }
      }
      
      // Check for swing low
      bool isSwingLow = true;
      for(int j = 1; j <= 5; j++)
      {
         if(iLow(Symbol(), 0, i) >= iLow(Symbol(), 0, i+j) || 
            iLow(Symbol(), 0, i) >= iLow(Symbol(), 0, i-j))
         {
            isSwingLow = false;
            break;
         }
      }
      
      // Add to arrays
      if(isSwingHigh && resistanceCount < 10)
      {
         resistanceLevels[resistanceCount] = iHigh(Symbol(), 0, i);
         resistanceCount++;
      }
      
      if(isSwingLow && supportCount < 10)
      {
         supportLevels[supportCount] = iLow(Symbol(), 0, i);
         supportCount++;
      }
   }
   
   // Sort levels
   ArraySort(supportLevels, WHOLE_ARRAY, 0, MODE_ASCEND);
   ArraySort(resistanceLevels, WHOLE_ARRAY, 0, MODE_ASCEND);
   
   // Remove duplicates
   for(int i = 0; i < supportCount - 1; i++)
   {
      if(MathAbs(supportLevels[i] - supportLevels[i+1]) < Point() * 10)
      {
         // Merge levels
         supportLevels[i] = (supportLevels[i] + supportLevels[i+1]) / 2;
         
         // Shift array
         for(int j = i+1; j < supportCount - 1; j++)
         {
            supportLevels[j] = supportLevels[j+1];
         }
         
         supportCount--;
         i--; // Recheck this position
      }
   }
   
   for(int i = 0; i < resistanceCount - 1; i++)
   {
      if(MathAbs(resistanceLevels[i] - resistanceLevels[i+1]) < Point() * 10)
      {
         // Merge levels
         resistanceLevels[i] = (resistanceLevels[i] + resistanceLevels[i+1]) / 2;
         
         // Shift array
         for(int j = i+1; j < resistanceCount - 1; j++)
         {
            resistanceLevels[j] = resistanceLevels[j+1];
         }
         
         resistanceCount--;
         i--; // Recheck this position
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate market volatility score (0-100)                         |
//+------------------------------------------------------------------+
double CalculateVolatilityScore()
{
   // Calculate ATR
   double atr = iATR(Symbol(), 0, 14, 0);
   double atrPercent = atr / iClose(Symbol(), 0, 0) * 100;
   
   // Calculate Bollinger Bands width
   double bbWidth = CalculateBollingerWidth(20, 2, 0);
   
   // Calculate price range over last 24 hours
   double highestHigh = iHigh(Symbol(), 0, iHighest(Symbol(), 0, MODE_HIGH, 24, 0));
   double lowestLow = iLow(Symbol(), 0, iLowest(Symbol(), 0, MODE_LOW, 24, 0));
   double rangePercent = (highestHigh - lowestLow) / iClose(Symbol(), 0, 0) * 100;
   
   // Calculate volatility score (0-100)
   double atrScore = MathMin(100, atrPercent * 100);
   double bbScore = MathMin(100, bbWidth * 200);
   double rangeScore = MathMin(100, rangePercent * 25);
   
   return (atrScore * 0.4 + bbScore * 0.3 + rangeScore * 0.3);
}

//+------------------------------------------------------------------+
//| Calculate trend strength score (0-100)                            |
//+------------------------------------------------------------------+
double CalculateTrendStrengthScore()
{
   // Calculate ADX
   double adx = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_MAIN, 0);
   
   // Calculate EMA direction and consistency
   double ema20 = iMA(Symbol(), 0, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ema50 = iMA(Symbol(), 0, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ema100 = iMA(Symbol(), 0, 100, 0, MODE_EMA, PRICE_CLOSE, 0);
   
   // Check if EMAs are aligned (all rising or all falling)
   bool emaAligned = ((ema20 > ema50 && ema50 > ema100) || (ema20 < ema50 && ema50 < ema100));
   
   // Calculate price consistency
   int consistentBars = 0;
   bool uptrend = (ema20 > ema50);
   
   for(int i = 0; i < 10; i++)
   {
      if((uptrend && iClose(Symbol(), 0, i) > iOpen(Symbol(), 0, i)) ||
         (!uptrend && iClose(Symbol(), 0, i) < iOpen(Symbol(), 0, i)))
      {
         consistentBars++;
      }
   }
   
   // Calculate trend strength score (0-100)
   double adxScore = MathMin(100, adx * 2);
   double emaScore = emaAligned ? 100 : 0;
   double consistencyScore = consistentBars * 10;
   
   return (adxScore * 0.5 + emaScore * 0.3 + consistencyScore * 0.2);
}

//+------------------------------------------------------------------+
//| Calculate market regime score                                     |
//+------------------------------------------------------------------+
int DetermineMarketRegime()
{
   double volatility = CalculateVolatilityScore();
   double trendStrength = CalculateTrendStrengthScore();
   
   // Determine regime
   if(trendStrength > 70)
   {
      if(volatility > 70)
         return 1; // Strong Trend (High Vol)
      else
         return 2; // Strong Trend (Low Vol)
   }
   else
   {
      if(volatility < 30)
         return 5; // Quiet Range
      else if(volatility > 70)
         return 4; // Volatile Range
      else
         return 3; // Tight Range
   }
}

//+------------------------------------------------------------------+
//| Calculate optimal lot size based on risk                          |
//+------------------------------------------------------------------+
double CalculateOptimalLotSize(double riskPercent, double stopLossPips)
{
   double accountEquity = AccountEquity();
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   
   // Calculate risk amount in account currency
   double riskAmount = accountEquity * riskPercent / 100;
   
   // Calculate pip value
   double pipValue = tickValue * (Point() / tickSize);
   
   // Calculate lot size
   double lotSize = riskAmount / (stopLossPips * pipValue);
   
   // Normalize lot size
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   
   // Ensure lot size is within limits
   lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
   
   return lotSize;
}

//+------------------------------------------------------------------+
//| Apply trailing stop to position                                   |
//+------------------------------------------------------------------+
void TrailingStopPosition(int ticket, int trailingStop, int trailingStep)
{
   if(!OrderSelect(ticket, SELECT_BY_TICKET))
      return;
      
   double point = MarketInfo(OrderSymbol(), MODE_POINT);
   int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
   double bid = MarketInfo(OrderSymbol(), MODE_BID);
   double ask = MarketInfo(OrderSymbol(), MODE_ASK);
   
   // For 5-digit brokers
   double multiplier = 1;
   if(digits == 3 || digits == 5)
      multiplier = 10;
      
   double trailingStopLevel = trailingStop * point * multiplier;
   double trailingStepLevel = trailingStep * point * multiplier;
   
   if(OrderType() == OP_BUY)
   {
      double newStopLoss = NormalizeDouble(bid - trailingStopLevel, digits);
      
      if(newStopLoss > OrderStopLoss() + trailingStepLevel || OrderStopLoss() == 0)
      {
         if(OrderModify(OrderTicket(), OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, clrBlue))
            Print("Trailing stop updated for Buy order #", OrderTicket(), " to ", newStopLoss);
         else
            Print("Error updating trailing stop: ", GetLastError());
      }
   }
   else if(OrderType() == OP_SELL)
   {
      double newStopLoss = NormalizeDouble(ask + trailingStopLevel, digits);
      
      if(newStopLoss < OrderStopLoss() - trailingStepLevel || OrderStopLoss() == 0)
      {
         if(OrderModify(OrderTicket(), OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, clrRed))
            Print("Trailing stop updated for Sell order #", OrderTicket(), " to ", newStopLoss);
         else
            Print("Error updating trailing stop: ", GetLastError());
      }
   }
}

//+------------------------------------------------------------------+
//| Check if it's time to close all positions (Friday closure)        |
//+------------------------------------------------------------------+
bool IsTimeToCloseAll(int fridayCloseHour)
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Check if it's Friday and after the specified hour
   return (dt.day_of_week == 5 && dt.hour >= fridayCloseHour);
}

//+------------------------------------------------------------------+
//| Close all positions for current symbol and magic number           |
//+------------------------------------------------------------------+
void CloseAllPositions(int magicNumber)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
         {
            bool result = false;
            
            if(OrderType() == OP_BUY)
               result = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, clrRed);
            else if(OrderType() == OP_SELL)
               result = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, clrRed);
               
            if(!result)
               Print("Error closing order #", OrderTicket(), ": ", GetLastError());
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check if daily loss limit has been reached                        |
//+------------------------------------------------------------------+
bool IsDailyLossLimitReached(double maxDailyLossPercent, double startEquity)
{
   double currentEquity = AccountEquity();
   double dailyLoss = (startEquity - currentEquity) / startEquity * 100;
   
   return (dailyLoss >= maxDailyLossPercent);
}

//+------------------------------------------------------------------+
//| Count open positions for current symbol and magic number          |
//+------------------------------------------------------------------+
int CountOpenPositions(int magicNumber)
{
   int count = 0;
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
         {
            count++;
         }
      }
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| Count daily trades for current symbol and magic number            |
//+------------------------------------------------------------------+
int CountDailyTrades(int magicNumber)
{
   int count = 0;
   
   // Get today's date
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   datetime todayStart = StringToTime(StringFormat("%04d.%02d.%02d 00:00", dt.year, dt.mon, dt.day));
   
   // Count closed trades today
   for(int i = 0; i < OrdersHistoryTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber && 
            OrderCloseTime() >= todayStart)
         {
            count++;
         }
      }
   }
   
   // Add open trades
   count += CountOpenPositions(magicNumber);
   
   return count;
}