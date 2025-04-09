//+------------------------------------------------------------------+
//|                                             ScalpingMaster.mq4   |
//|                                          Copyright 2023, TraeAI  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, TraeAI"
#property link      ""
#property version   "1.00"
#property strict

// Basic Settings
input string  GeneralSettings     = "===== General Settings =====";
input int     magicNumber         = 12345;     // Magic number
input double  lotSize             = 0.01;      // Fixed lot size
input bool    UseAutoLotSize      = true;      // Use automatic lot size calculation
input double  RiskPercentInput    = 1.0;       // Risk percent per trade (if auto lot size)
input double  MinRiskPercentInput = 0.5;       // Minimum risk percent
input double  MaxRiskPercentInput = 2.0;       // Maximum risk percent
input int     slippage            = 3;         // Allowed slippage in pips

// Trading Parameters
input string  TradingParameters   = "===== Trading Parameters =====";
input int     FastEMA             = 8;         // Fast EMA period
input int     SlowEMA             = 21;        // Slow EMA period
input int     RSIPeriod           = 14;        // RSI period
input int     RSIOverbought       = 70;        // RSI overbought level
input int     RSIOversold         = 30;        // RSI oversold level
input int     TakeProfit          = 15;        // Take profit in pips
input int     StopLoss            = 10;        // Stop loss in pips
input bool    UseTrailingStop     = true;      // Use trailing stop
input int     TrailingStop        = 8;         // Trailing stop in pips
input int     TrailingStep        = 1;         // Trailing step in pips

// Time Filter
input string  TimeFilterSettings  = "===== Time Filter =====";
input bool    UseTimeFilter       = true;      // Use time filter
input int     StartHour           = 8;         // Start hour (server time)
input int     EndHour             = 20;        // End hour (server time)
input bool    CloseAllFriday      = true;      // Close all positions on Friday
input int     FridayCloseHour     = 20;        // Hour to close positions on Friday

// Risk Management
input string  RiskSettings        = "===== Risk Management =====";
input int     MaxDailyTrades      = 10;        // Maximum trades per day
input double  MaxDailyLoss        = 5.0;       // Maximum daily loss (% of balance)
input double  MaxSpread           = 25;       // Maximum allowed spread in pips
input bool    tradingAllowed      = true;      // Enable/disable trading

// Adaptive Parameters
input string  AdaptiveSettings    = "===== Adaptive Parameters =====";
input bool    UseAdaptiveParams   = true;      // Use adaptive parameters
input bool    SaveAdaptiveState   = true;      // Save adaptive state between sessions
input double  AdaptiveRate        = 0.1;       // Adaptive learning rate (0-1)

// Machine Learning
input string  MLSettings          = "===== Machine Learning =====";
input bool    UseML               = true;      // Use machine learning
input int     MLUpdateFrequency   = 20;        // Update ML model every X trades
input bool    SaveMLState         = true;      // Save ML state between sessions

// Market Regime Detection
input string  RegimeSettings      = "===== Market Regime Detection =====";
input bool    UseRegimeDetection  = true;      // Use market regime detection
input int     RegimeDetectionPeriod = 50;      // Period for regime detection

// Historical Learning
input string  HistoricalLearning  = "===== Enhanced Historical Learning =====";
input bool    UseHistoricalData   = true;      // Learn from historical data
input int     HistoricalDays      = 30;        // Days of historical data to analyze
input int     MinHistoricalTrades = 100;       // Minimum trades to analyze

// Pattern Recognition
input string  PatternRecognition  = "===== Pattern Recognition =====";
input bool    UsePatternRecognition = true;    // Use candlestick pattern recognition
input double  PatternWeight       = 0.3;       // Weight of pattern signals (0-1)

// Market Correlation
input string  CorrelationSettings = "===== Market Correlation =====";
input bool    UseCorrelation      = true;      // Use market correlation
input string  CorrelatedPair1     = "EURUSD";  // Correlated pair 1
input string  CorrelatedPair2     = "GBPUSD";  // Correlated pair 2
input double  MinCorrelation      = 0.7;       // Minimum correlation threshold

// Market Sentiment
input string  SentimentAnalysis   = "===== Market Sentiment Analysis =====";
input bool    UseSentimentAnalysis = true;     // Use market sentiment analysis
input int     SentimentPeriod     = 50;        // Period for sentiment calculation
input double  SentimentThreshold  = 0.6;       // Sentiment threshold (0-1)

// Trading Session
input string  SessionSettings     = "===== Trading Session Analysis =====";
input bool    UseSessionAnalysis  = true;      // Adapt to different trading sessions
input bool    TradeLondonSession  = true;      // Trade during London session
input bool    TradeNewYorkSession = true;      // Trade during New York session
input bool    TradeAsianSession   = false;     // Trade during Asian session
input double  SessionAdjustment   = 0.3;       // Session parameter adjustment (0-1)

// Equity Curve
input string  EquityCurveSettings = "===== Equity Curve Analysis =====";
input bool    UseEquityCurveFilter = true;     // Use equity curve filtering
input int     EquityCurvePeriod   = 20;        // Number of trades for equity curve analysis
input double  EquityCurveThreshold = 0.4;      // Threshold for equity curve trend (-1 to 1)

// Reporting
input string  ReportingSettings   = "===== Performance Reporting =====";
input bool    SaveReports         = true;      // Save performance reports
input int     ReportFrequency     = 50;        // Generate report every X trades
input string  ReportFilePath      = "Reports"; // Folder for reports

// Global variables
double adaptiveFastEMA, adaptiveSlowEMA;
double adaptiveRSIOverbought, adaptiveRSIOversold;
double adaptiveTakeProfit, adaptiveStopLoss;
double adaptiveTrailingStop, adaptiveTrailingStep;
string adaptiveCorrelatedPair1, adaptiveCorrelatedPair2;
double pointMultiplier;
// Global variables for risk management
double RiskPercent;
double MinRiskPercent;
double MaxRiskPercent;
int totalTrades = 0;
double dailyLoss = 0;
double startingEquity;
bool mlInitialized = false;
double mlWeights[];
int tradeHistoryCount = 0;
int currentRegime = 0;
double regimeVolatility = 0;
double equityCurve[];
int equityCurveCount = 0;
bool equityCurvePositive = true;
int winningTrades = 0;
int losingTrades = 0;
double grossProfit = 0;
double grossLoss = 0;
double largestWin = 0;
double largestLoss = 0;
int consecutiveWins = 0;
int consecutiveLosses = 0;
int maxConsecutiveWins = 0;
int maxConsecutiveLosses = 0;
datetime startingTime;

// Pattern types
enum CANDLE_PATTERN
{
   PATTERN_NONE,
   PATTERN_DOJI,
   PATTERN_HAMMER,
   PATTERN_SHOOTING_STAR,
   PATTERN_ENGULFING_BULL,
   PATTERN_ENGULFING_BEAR,
   PATTERN_MORNING_STAR,
   PATTERN_EVENING_STAR
};

// Trading session types
enum TRADING_SESSION
{
   SESSION_NONE,
   SESSION_ASIAN,
   SESSION_LONDON,
   SESSION_NEWYORK,
   SESSION_LONDON_NEWYORK_OVERLAP
};

// Trade data structure for ML
struct TradeData
{
   datetime time;
   int type;
   double openPrice;
   double closePrice;
   double profit;
   double fastEMA;
   double slowEMA;
   double rsi;
   double atr;
   double spread;
   int hour;
   int dayOfWeek;
   double macd;
   double macdSignal;
   double bollingerUpper;
   double bollingerLower;
   double bollingerWidth;
   double adx;
   double volumeChange;
   CANDLE_PATTERN pattern;
};

// Array to store trade history
TradeData tradeHistory[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // for xauusd
   pointMultiplier = 10;
   if(Symbol() == "XAUUSD" || Symbol() == "GOLD" || Symbol() == "XAU/USD") 
   {
      pointMultiplier = 1;  // Gold uses different point value
   
      // Adjust TP/SL for gold's higher volatility
      adaptiveTakeProfit = TakeProfit * 2;
      adaptiveStopLoss = StopLoss * 2;
      adaptiveTrailingStop = TrailingStop * 2;
      adaptiveTrailingStep = TrailingStep * 2;
   
      // Update correlation pairs to be more relevant for gold
      adaptiveCorrelatedPair1 = "USDCHF";  // Inverse correlation with gold
      adaptiveCorrelatedPair2 = "USDJPY";  // Often correlated with USD strength
   }
   else
   {
      // Initialize adaptive values for non-XAUUSD pairs
      adaptiveTakeProfit = TakeProfit;
      adaptiveStopLoss = StopLoss;
      adaptiveTrailingStop = TrailingStop;
      adaptiveTrailingStep = TrailingStep;
      adaptiveCorrelatedPair1 = CorrelatedPair1;
      adaptiveCorrelatedPair2 = CorrelatedPair2;
   }

   // Initialize the random number generator
   MathSrand(GetTickCount());
   
   // Initialize risk parameters from inputs
   RiskPercent = RiskPercentInput;
   MinRiskPercent = MinRiskPercentInput;
   MaxRiskPercent = MaxRiskPercentInput;
   
   // Set up chart for better visualization
   ChartSetInteger(0, CHART_FOREGROUND, false);
   ChartSetInteger(0, CHART_SHIFT, true);
   ChartSetInteger(0, CHART_AUTOSCROLL, true);
   
   // Initialize performance tracking
   totalTrades = 0;
   winningTrades = 0;
   losingTrades = 0;
   grossProfit = 0;
   grossLoss = 0;
   largestWin = 0;
   largestLoss = 0;
   consecutiveWins = 0;
   consecutiveLosses = 0;
   maxConsecutiveWins = 0;
   maxConsecutiveLosses = 0;
   startingTime = TimeCurrent();
   startingEquity = AccountEquity();
   
   // Initialize adaptive parameters
   if(UseAdaptiveParams)
   {
      adaptiveFastEMA = FastEMA;
      adaptiveSlowEMA = SlowEMA;
      adaptiveRSIOverbought = RSIOverbought;
      adaptiveRSIOversold = RSIOversold;
      adaptiveTakeProfit = TakeProfit;
      adaptiveStopLoss = StopLoss;
      
      // Load adaptive state if enabled
      if(SaveAdaptiveState)
      {
         LoadAdaptiveState();
      }
   }
   
   // Initialize ML system
   if(UseML)
   {
      InitializeML();
      
      // Analyze historical data if enabled
      if(UseHistoricalData)
      {
         AnalyzeHistoricalData();
      }
   }
   
   // Initialize equity curve
   if(UseEquityCurveFilter)
   {
      InitializeEquityCurve();
   }
   
   // Display initialization message
   Comment("ScalpingMaster EA initialized with adaptive and ML features. Ready to trade.");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Save states when EA is removed
   if(UseAdaptiveParams && SaveAdaptiveState)
   {
      SaveAdaptiveState();
   }
   
   if(UseML && SaveMLState)
   {
      SaveMLState();
   }
   
   Comment("");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check if trading is allowed
   if(!tradingAllowed) return;
   
   // Check for closed orders and update ML data
   CheckClosedOrders();
   
   // Generate market insights
   GenerateMarketInsights();
   
   // Detect market regime
   if(UseRegimeDetection)
   {
      DetectMarketRegime();
      AdjustForMarketRegime();
   }
   
   // Check if it's time to reset daily counters
   static datetime lastDay = 0;
   datetime currentTime = TimeCurrent();
   MqlDateTime timeStruct;
   TimeToStruct(currentTime, timeStruct);
   
   // Reset daily counters at the start of a new day
   if(timeStruct.day != TimeDay(lastDay))
   {
      totalTrades = 0;
      dailyLoss = 0;
      lastDay = currentTime;
   }
   
   // Check if we should close all trades on Friday
   if(CloseAllFriday && timeStruct.day_of_week == 5 && timeStruct.hour >= FridayCloseHour)
   {
      CloseAllPositions();
      return;
   }
   
   // Check time filter
   if(UseTimeFilter && (timeStruct.hour < StartHour || timeStruct.hour >= EndHour))
   {
      return;
   }
   
   // Check if we're in an active trading session
   if(UseSessionAnalysis && !IsActiveSession())
   {
      Comment("Not in active trading session");
      return;
   }
   
   // Adjust parameters for current session
   if(UseSessionAnalysis)
   {
      AdjustForSession();
   }
   
   // Update equity curve periodically
   static datetime lastEquityUpdate = 0;
   
   if(UseEquityCurveFilter && currentTime - lastEquityUpdate > 300) // Every 5 minutes
   {
      UpdateEquityCurve();
      lastEquityUpdate = currentTime;
   }
   
   // Check equity curve before trading
   if(UseEquityCurveFilter && !equityCurvePositive && equityCurveCount >= 5)
   {
      // If equity curve is negative, be more conservative
      double rsi = iRSI(Symbol(), 0, RSIPeriod, PRICE_CLOSE, 0);
      if(rsi > 40 && rsi < 60) // Near middle - avoid trades in uncertain conditions
      {
         Comment("Equity curve filter active - avoiding uncertain trades");
         return;
      }
   }
   
   // Check if we've reached maximum daily trades
   if(totalTrades >= MaxDailyTrades)
   {
      return;
   }
   
   // Check if we've reached maximum daily loss
   if(dailyLoss >= MaxDailyLoss)
   {
      return;
   }
   
   // Check for open positions
   if(CountOpenPositions() > 0)
   {
      // Manage open positions (trailing stop, ML-based exit, etc.)
      ManageOpenPositions();
      return;
   }
   
   // Check if spread is too high
   if(MarketInfo(Symbol(), MODE_SPREAD) > MaxSpread)
   {
      Comment("Spread too high: ", MarketInfo(Symbol(), MODE_SPREAD));
      return;
   }
   
   // Get indicator values - use adaptive parameters if enabled
   double emaFast = UseAdaptiveParams ? adaptiveFastEMA : FastEMA;
   double emaSlow = UseAdaptiveParams ? adaptiveSlowEMA : SlowEMA;
   double rsiOverbought = UseAdaptiveParams ? adaptiveRSIOverbought : RSIOverbought;
   double rsiOversold = UseAdaptiveParams ? adaptiveRSIOversold : RSIOversold;
   
   double fastEMA = iMA(Symbol(), 0, (int)emaFast, 0, MODE_EMA, PRICE_CLOSE, 0);
   double slowEMA = iMA(Symbol(), 0, (int)emaSlow, 0, MODE_EMA, PRICE_CLOSE, 0);
   double rsi = iRSI(Symbol(), 0, RSIPeriod, PRICE_CLOSE, 0);
   
   // Detect candlestick pattern
   CANDLE_PATTERN currentPattern = PATTERN_NONE;
   double patternSignal = 0;
   
   if(UsePatternRecognition)
   {
      currentPattern = DetectCandlePattern(0);
      patternSignal = GetPatternSignal(currentPattern) * PatternWeight;
      
      // Log detected pattern
      if(currentPattern != PATTERN_NONE)
      {
         string patternNames[] = {"None", "Doji", "Hammer", "Shooting Star", "Bullish Engulfing", 
                                 "Bearish Engulfing", "Morning Star", "Evening Star"};
         Print("Detected pattern: ", patternNames[currentPattern], 
               " (Signal: ", DoubleToString(patternSignal, 2), ")");
      }
   }
   
   // Get sentiment bias
   double sentimentBias = GetSentimentBias();
   
   // Use ML to predict trade outcome if enabled
   bool mlBuySignal = false;
   bool mlSellSignal = false;
   
   if(UseML && mlInitialized && tradeHistoryCount >= MLUpdateFrequency)
   {
      // Create a temporary trade data structure to predict outcome
      TradeData tempTrade;
      tempTrade.time = TimeCurrent();
      tempTrade.fastEMA = fastEMA;
      tempTrade.slowEMA = slowEMA;
      tempTrade.rsi = rsi;
      tempTrade.atr = iATR(Symbol(), 0, 14, 0);
      tempTrade.spread = MarketInfo(Symbol(), MODE_SPREAD);
      
      MqlDateTime dt;
      TimeToStruct(tempTrade.time, dt);
      tempTrade.hour = dt.hour;
      tempTrade.dayOfWeek = dt.day_of_week;
      
      // Add additional features
      tempTrade.macd = iMACD(Symbol(), 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
      tempTrade.macdSignal = iMACD(Symbol(), 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
      tempTrade.bollingerUpper = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
      tempTrade.bollingerLower = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
      tempTrade.bollingerWidth = tempTrade.bollingerUpper - tempTrade.bollingerLower;
      tempTrade.adx = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_MAIN, 0);
      tempTrade.volumeChange = (double)iVolume(Symbol(), 0, 0) / MathMax(1, iVolume(Symbol(), 0, 1));
      tempTrade.pattern = currentPattern;
      
      // Predict buy outcome
      tempTrade.type = OP_BUY;
      double buyPrediction = PredictTradeOutcome(tempTrade);
      
      // Predict sell outcome
      tempTrade.type = OP_SELL;
      double sellPrediction = PredictTradeOutcome(tempTrade);
      
      // Set ML signals based on predictions
      mlBuySignal = buyPrediction > 0.3;  // Threshold for positive prediction
      mlSellSignal = sellPrediction > 0.3;
      
      Comment("ML Predictions - Buy: ", DoubleToString(buyPrediction, 2), 
              ", Sell: ", DoubleToString(sellPrediction, 2),
              "\nRegime: ", currentRegime,
              "\nAdaptive EMA: ", DoubleToString(emaFast, 1), "/", DoubleToString(emaSlow, 1),
              "\nSentiment: ", DoubleToString(sentimentBias, 2));
   }
   
   // Enhanced trading logic with pattern recognition and sentiment
   bool buySignal = fastEMA > slowEMA && rsi < rsiOversold;
   bool sellSignal = fastEMA < slowEMA && rsi > rsiOverbought;
   
   // Adjust signals based on pattern recognition
   if(UsePatternRecognition)
   {
      if(patternSignal > 0.5) buySignal = true;  // Strong bullish pattern
      else if(patternSignal < -0.5) sellSignal = true;  // Strong bearish pattern
      else if(patternSignal > 0.3) buySignal = buySignal || rsi < 45;  // Moderate bullish pattern
      else if(patternSignal < -0.3) sellSignal = sellSignal || rsi > 55;  // Moderate bearish pattern
   }
   
   // Adjust signals based on sentiment
   if(UseSentimentAnalysis)
   {
      if(sentimentBias > SentimentThreshold)
      {
         // Strong bullish sentiment - strengthen buy signals, weaken sell signals
         if(rsi < 45) buySignal = true;  // More aggressive on buys
         if(rsi < 75) sellSignal = false;  // More conservative on sells
      }
      else if(sentimentBias < -SentimentThreshold)
      {
         // Strong bearish sentiment - strengthen sell signals, weaken buy signals
         if(rsi > 55) sellSignal = true;  // More aggressive on sells
         if(rsi > 25) buySignal = false;  // More conservative on buys
      }
   }
   
   // Check correlation confirmation
   bool buyConfirmed = !UseCorrelation || CheckCorrelationConfirmation(OP_BUY);
   bool sellConfirmed = !UseCorrelation || CheckCorrelationConfirmation(OP_SELL);
   
   // Final decision with ML, correlation, and sentiment
   if(buySignal && buyConfirmed && (!UseML || mlBuySignal))
   {
      // Buy signal
      OpenPosition(OP_BUY);
   }
   else if(sellSignal && sellConfirmed && (!UseML || mlSellSignal))
   {
      // Sell signal
      OpenPosition(OP_SELL);
   }
   
   // Generate performance report periodically
   if(SaveReports && totalTrades % ReportFrequency == 0 && totalTrades > 0)
   {
      GenerateReport();
   }
   
   // Save adaptive and ML state periodically
   static datetime lastSaveTime = 0;
   if(currentTime - lastSaveTime > 3600) // Every hour
   {
      if(UseAdaptiveParams && SaveAdaptiveState)
      {
         SaveAdaptiveState();
      }
      
      if(UseML && SaveMLState)
      {
         SaveMLState();
      }
      
      lastSaveTime = currentTime;
   }
   
   // Create dashboard
   CreateDashboard();
}

//+------------------------------------------------------------------+
//| Open a new position                                              |
//+------------------------------------------------------------------+
void OpenPosition(int type)
{
   // Calculate lot size
   double lots = lotSize;
   
   if(UseAutoLotSize)
   {
      double riskAmount = AccountBalance() * RiskPercent / 100;
      double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
      double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
      
      if(tickSize != 0 && tickValue != 0)
      {
         double pointValue = tickValue / tickSize;
         double riskPips = StopLoss;
         
         if(riskPips > 0 && pointValue > 0)
         {
            lots = NormalizeDouble(riskAmount / (riskPips * pointValue), 2);
         }
      }
      
      // Ensure lot size is within limits
      double minLot = MarketInfo(Symbol(), MODE_MINLOT);
      double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
      double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
      
      lots = MathMax(minLot, MathMin(maxLot, lots));
      lots = NormalizeDouble(lots / lotStep, 0) * lotStep;
   }
   
   // Get adaptive TP/SL values
   double takeProfit = UseAdaptiveParams ? adaptiveTakeProfit : TakeProfit;
   double stopLoss = UseAdaptiveParams ? adaptiveStopLoss : StopLoss;
   
   // Calculate TP/SL levels
   double tpLevel = 0, slLevel = 0;
   
   if(type == OP_BUY)
   {
      tpLevel = Ask + takeProfit * Point() * 10;
      slLevel = Ask - stopLoss * Point() * 10;
   }
   else if(type == OP_SELL)
   {
      tpLevel = Bid - takeProfit * Point() * 10;
      slLevel = Bid + stopLoss * Point() * 10;
   }
   
   // Open the position
   int ticket = 0;
   
   if(type == OP_BUY)
   {
      ticket = OrderSend(Symbol(), OP_BUY, lots, Ask, slippage, slLevel, tpLevel, 
                        "ScalpingMaster", magicNumber, 0, clrGreen);
   }
   else if(type == OP_SELL)
   {
      ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, slippage, slLevel, tpLevel, 
                        "ScalpingMaster", magicNumber, 0, clrRed);
   }
   
   // Check for errors
   if(ticket <= 0)
   {
      Print("Error opening position: ", GetLastError());
      return;
   }
   
   // Update trade counter
   totalTrades++;
   
   Print("Opened ", (type == OP_BUY ? "BUY" : "SELL"), " position #", ticket, 
         " at ", (type == OP_BUY ? Ask : Bid), 
         " with TP: ", tpLevel, " SL: ", slLevel);
}

//+------------------------------------------------------------------+
//| Count open positions                                             |
//+------------------------------------------------------------------+
int CountOpenPositions()
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
//| Close all open positions                                         |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
         {
            bool result = false;
            
            if(OrderType() == OP_BUY)
               result = OrderClose(OrderTicket(), OrderLots(), Bid, slippage, clrRed);
            else if(OrderType() == OP_SELL)
               result = OrderClose(OrderTicket(), OrderLots(), Ask, slippage, clrRed);
               
            if(!result)
               Print("Error closing position #", OrderTicket(), ": ", GetLastError());
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Apply trailing stop to an open position                          |
//+------------------------------------------------------------------+
void TrailingStopPosition(int ticket, double trailingStop, double trailingStep)
{
   if(!OrderSelect(ticket, SELECT_BY_TICKET))
      return;
      
   if(OrderSymbol() != Symbol() || OrderMagicNumber() != magicNumber)
      return;
      
   double point = Point() * 10;
   
   if(OrderType() == OP_BUY)
   {
      if(Bid - OrderOpenPrice() > trailingStop * point)
      {
         if(OrderStopLoss() < Bid - trailingStop * point)
         {
            bool result = OrderModify(OrderTicket(), OrderOpenPrice(), 
                                     Bid - trailingStop * point, 
                                     OrderTakeProfit(), 0, clrGreen);
                                     
            if(!result)
               Print("Error modifying trailing stop: ", GetLastError());
         }
      }
   }
   else if(OrderType() == OP_SELL)
   {
      if(OrderOpenPrice() - Ask > trailingStop * point)
      {
         if(OrderStopLoss() > Ask + trailingStop * point || OrderStopLoss() == 0)
         {
            bool result = OrderModify(OrderTicket(), OrderOpenPrice(), 
                                     Ask + trailingStop * point, 
                                     OrderTakeProfit(), 0, clrRed);
                                     
            if(!result)
               Print("Error modifying trailing stop: ", GetLastError());
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check for closed orders and update ML data                       |
//+------------------------------------------------------------------+
void CheckClosedOrders()
{
   static int lastOrdersTotal = 0;
   int currentOrdersTotal = OrdersHistoryTotal();
   
   // If number of history orders has changed
   if(currentOrdersTotal > lastOrdersTotal)
   {
      // Check the new closed orders
      for(int i = lastOrdersTotal; i < currentOrdersTotal; i++)
      {
         if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         {
            // Check if it's our EA's order
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
            {
               // Get trade details
               int type = OrderType();
               double openPrice = OrderOpenPrice();
               double closePrice = OrderClosePrice();
               double profit = OrderProfit();
               
               // Add to ML history if enabled
               if(UseML && mlInitialized)
               {
                  AddTradeToHistory(type, openPrice, closePrice, profit);
               }
               
               // Update performance metrics
               if(profit > 0)
               {
                  winningTrades++;
                  grossProfit += profit;
                  
                  // Update largest win
                  if(profit > largestWin)
                     largestWin = profit;
                  
                  // Update consecutive wins/losses
                  consecutiveWins++;
                  consecutiveLosses = 0;
                  
                  // Update max consecutive wins
                  if(consecutiveWins > maxConsecutiveWins)
                     maxConsecutiveWins = consecutiveWins;
               }
               else
               {
                  losingTrades++;
                  grossLoss += profit;  // profit is negative here
                  
                  // Update largest loss
                  if(profit < largestLoss)
                     largestLoss = profit;
                  
                  // Update consecutive wins/losses
                  consecutiveWins = 0;
                  consecutiveLosses++;
                  
                  // Update max consecutive losses
                  if(consecutiveLosses > maxConsecutiveLosses)
                     maxConsecutiveLosses = consecutiveLosses;
                  
                  // Update daily loss
                  dailyLoss += MathAbs(profit);
               }
            }
         }
      }
      
      lastOrdersTotal = currentOrdersTotal;
   }
}

//+------------------------------------------------------------------+
//| Manage open positions with adaptive trailing stop                |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
         {
            // Apply trailing stop if enabled
            if(UseTrailingStop)
            {
               TrailingStopPosition(OrderTicket(), TrailingStop, TrailingStep);
            }
            
            // Check if we should close based on ML prediction
            if(UseML && mlInitialized && tradeHistoryCount >= MLUpdateFrequency)
            {
               // Create a temporary trade data structure to predict outcome
               TradeData tempTrade;
               tempTrade.time = TimeCurrent();
               tempTrade.type = OrderType();
               tempTrade.openPrice = OrderOpenPrice();
               tempTrade.fastEMA = iMA(Symbol(), 0, FastEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
               tempTrade.slowEMA = iMA(Symbol(), 0, SlowEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
               tempTrade.rsi = iRSI(Symbol(), 0, RSIPeriod, PRICE_CLOSE, 0);
               tempTrade.atr = iATR(Symbol(), 0, 14, 0);
               tempTrade.spread = MarketInfo(Symbol(), MODE_SPREAD);
               
               MqlDateTime dt;
               TimeToStruct(tempTrade.time, dt);
               tempTrade.hour = dt.hour;
               tempTrade.dayOfWeek = dt.day_of_week;
               
               // Add additional features
               tempTrade.macd = iMACD(Symbol(), 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
               tempTrade.macdSignal = iMACD(Symbol(), 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
               tempTrade.bollingerUpper = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
               tempTrade.bollingerLower = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
               tempTrade.bollingerWidth = tempTrade.bollingerUpper - tempTrade.bollingerLower;
               tempTrade.adx = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_MAIN, 0);
               tempTrade.volumeChange = (double)iVolume(Symbol(), 0, 0) / MathMax(1, iVolume(Symbol(), 0, 1));
      
               tempTrade.pattern = DetectCandlePattern(0);
               
               // Predict trade outcome
               double prediction = PredictTradeOutcome(tempTrade);
               
               // Close position if prediction turns negative
               if(prediction < -0.5)
               {
                  bool result = false;
                  
                  if(OrderType() == OP_BUY)
                     result = OrderClose(OrderTicket(), OrderLots(), Bid, slippage, clrRed);
                  else if(OrderType() == OP_SELL)
                     result = OrderClose(OrderTicket(), OrderLots(), Ask, slippage, clrRed);
                     
                  if(result)
                     Print("Closed position #", OrderTicket(), " based on ML prediction: ", prediction);
                  else
                     Print("Error closing position #", OrderTicket(), ": ", GetLastError());
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Initialize ML system                                             |
//+------------------------------------------------------------------+
void InitializeML()
{
   if(!UseML) return;
   
   // Initialize trade history array
   ArrayResize(tradeHistory, 1000);
   tradeHistoryCount = 0;
   
   // Initialize weights
   ArrayResize(mlWeights, 15);
   for(int i = 0; i < 15; i++)
   {
      mlWeights[i] = 0.1;  // Initialize with small random values
   }
   
   // Load ML state if enabled
   if(SaveMLState)
   {
      LoadMLState();
   }
   
   mlInitialized = true;
   Print("ML system initialized");
}

//+------------------------------------------------------------------+
//| Add trade to history for ML                                      |
//+------------------------------------------------------------------+
void AddTradeToHistory(int type, double openPrice, double closePrice, double profit)
{
   if(!UseML || !mlInitialized) return;
   
   // Resize array if needed
   if(tradeHistoryCount >= ArraySize(tradeHistory))
   {
      ArrayResize(tradeHistory, tradeHistoryCount + 100);
   }
   
   // Add new trade to history with enhanced features
   int idx = tradeHistoryCount;
   tradeHistory[idx].time = TimeCurrent();
   tradeHistory[idx].type = type;
   tradeHistory[idx].openPrice = openPrice;
   tradeHistory[idx].closePrice = closePrice;
   tradeHistory[idx].profit = profit;
   
   // Store market conditions at time of trade
   tradeHistory[idx].fastEMA = iMA(Symbol(), 0, FastEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
   tradeHistory[idx].slowEMA = iMA(Symbol(), 0, SlowEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
   tradeHistory[idx].rsi = iRSI(Symbol(), 0, RSIPeriod, PRICE_CLOSE, 0);
   tradeHistory[idx].atr = iATR(Symbol(), 0, 14, 0);
   tradeHistory[idx].spread = MarketInfo(Symbol(), MODE_SPREAD);
   
   // Store time information
   MqlDateTime dt;
   TimeToStruct(tradeHistory[idx].time, dt);
   tradeHistory[idx].hour = dt.hour;
   tradeHistory[idx].dayOfWeek = dt.day_of_week;
   
   // Store additional features
   tradeHistory[idx].macd = iMACD(Symbol(), 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
   tradeHistory[idx].macdSignal = iMACD(Symbol(), 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
   tradeHistory[idx].bollingerUpper = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   tradeHistory[idx].bollingerLower = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   tradeHistory[idx].bollingerWidth = tradeHistory[idx].bollingerUpper - tradeHistory[idx].bollingerLower;
   tradeHistory[idx].adx = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_MAIN, 0);
   tradeHistory[idx].volumeChange = (double)iVolume(Symbol(), 0, 0) / MathMax(1, iVolume(Symbol(), 0, 1));
   tradeHistory[idx].pattern = DetectCandlePattern(0);
   
   tradeHistoryCount++;
   
   // Update ML model if needed
   if(tradeHistoryCount % MLUpdateFrequency == 0 && tradeHistoryCount >= MLUpdateFrequency)
   {
      UpdateMLModel();
   }
}

//+------------------------------------------------------------------+
//| Predict trade outcome using ML model                             |
//+------------------------------------------------------------------+
double PredictTradeOutcome(TradeData &trade)
{
   if(!UseML) return 0;
   
   // Enhanced linear model with more features
   double prediction = 0;
   
   // Basic features
   prediction += mlWeights[0] * (trade.fastEMA - trade.slowEMA);
   prediction += mlWeights[1] * trade.rsi;
   prediction += mlWeights[2] * trade.atr;
   prediction += mlWeights[3] * trade.spread;
   prediction += mlWeights[4] * trade.hour;
   prediction += mlWeights[5] * trade.dayOfWeek;
   prediction += mlWeights[6] * (trade.type == OP_BUY ? 1 : -1);
   
   // Additional features
   prediction += mlWeights[7] * trade.macd;
   prediction += mlWeights[8] * (trade.macd - trade.macdSignal);
   prediction += mlWeights[9] * ((iClose(Symbol(), 0, 0) - trade.bollingerLower) / 
                                (trade.bollingerUpper - trade.bollingerLower) - 0.5);
   prediction += mlWeights[10] * trade.bollingerWidth;
   prediction += mlWeights[11] * trade.adx;
   prediction += mlWeights[12] * trade.volumeChange;
   prediction += mlWeights[13] * GetPatternSignal(trade.pattern);
   prediction += mlWeights[14];  // Bias term
   
   // Apply sigmoid to get value between -1 and 1
   prediction = 2 / (1 + MathExp(-prediction)) - 1;
   
   return prediction;
}

//+------------------------------------------------------------------+
//| Update ML model with trade history                               |
//+------------------------------------------------------------------+
void UpdateMLModel()
{
   if(!UseML || tradeHistoryCount < MLUpdateFrequency) return;
   
   Print("Updating ML model with ", tradeHistoryCount, " trades");
   
   // Simple gradient descent to optimize weights
   double learningRate = 0.01;
   int iterations = 100;
   
   // Resize weights array if needed
   if(ArraySize(mlWeights) < 15)
   {
      ArrayResize(mlWeights, 15);
      for(int i = 0; i < 15; i++)
      {
         mlWeights[i] = 0.1;  // Initialize new weights
      }
   }
   
   for(int iter = 0; iter < iterations; iter++)
   {
      // Calculate gradient for each weight
      double gradients[15];
      ArrayInitialize(gradients, 0);
      
      for(int i = 0; i < tradeHistoryCount; i++)
      {
         // Skip trades with zero profit (still open)
         if(tradeHistory[i].profit == 0) continue;
         
         // Calculate prediction error
         double prediction = PredictTradeOutcome(tradeHistory[i]);
         double actual = tradeHistory[i].profit > 0 ? 1 : -1;
         double error = prediction - actual;
         
         // Update gradients for all features
         gradients[0] += error * (tradeHistory[i].fastEMA - tradeHistory[i].slowEMA);
         gradients[1] += error * tradeHistory[i].rsi;
         gradients[2] += error * tradeHistory[i].atr;
         gradients[3] += error * tradeHistory[i].spread;
         gradients[4] += error * tradeHistory[i].hour;
         gradients[5] += error * tradeHistory[i].dayOfWeek;
         gradients[6] += error * (tradeHistory[i].type == OP_BUY ? 1 : -1);
         gradients[7] += error * tradeHistory[i].macd;
         gradients[8] += error * (tradeHistory[i].macd - tradeHistory[i].macdSignal);
         gradients[9] += error * ((iClose(Symbol(), 0, i) - tradeHistory[i].bollingerLower) / 
                                 (tradeHistory[i].bollingerUpper - tradeHistory[i].bollingerLower) - 0.5);
         gradients[10] += error * tradeHistory[i].bollingerWidth;
         gradients[11] += error * tradeHistory[i].adx;
         gradients[12] += error * tradeHistory[i].volumeChange;
         gradients[13] += error * GetPatternSignal(tradeHistory[i].pattern);
         gradients[14] += error;  // Bias term
      }
      
      // Update weights
      for(int i = 0; i < 15; i++)
      {
         mlWeights[i] -= learningRate * gradients[i] / tradeHistoryCount;
      }
   }
   
   // Save updated ML state
   SaveMLState();
   
   // Update adaptive parameters based on ML insights
   if(UseAdaptiveParams)
   {
      UpdateAdaptiveParameters();
   }
   
   // Log the most influential features
   string topFeatures = "Top influential features: ";
   double maxWeight = 0;
   int maxIndex = 0;
   
   for(int i = 0; i < 15; i++)
   {
      if(MathAbs(mlWeights[i]) > maxWeight)
      {
         maxWeight = MathAbs(mlWeights[i]);
         maxIndex = i;
      }
   }
   
   string featureNames[] = {"EMA Diff", "RSI", "ATR", "Spread", "Hour", "Day of Week", "Direction", 
                           "MACD", "MACD Signal", "BB Position", "BB Width", "ADX", "Volume Change", 
                           "Pattern", "Bias"};
   
   topFeatures += featureNames[maxIndex] + " (" + DoubleToString(mlWeights[maxIndex], 3) + ")";
   Print(topFeatures);
}

//+------------------------------------------------------------------+
//| Save ML state to file                                            |
//+------------------------------------------------------------------+
void SaveMLState()
{
   if(!UseML || !SaveMLState) return;
   
   string fileName = "d:\\xampp\\htdocs\\TScalpbot\\ML_State_" + Symbol() + ".bin";
   int fileHandle = FileOpen(fileName, FILE_WRITE|FILE_BIN);
   
   if(fileHandle != INVALID_HANDLE)
   {
      // Save number of weights
      int numWeights = ArraySize(mlWeights);
      if(numWeights <= 0) {
         Print("Warning: mlWeights array is empty or invalid");
         numWeights = 15; // Default size
         ArrayResize(mlWeights, numWeights);
         for(int i = 0; i < numWeights; i++) {
            mlWeights[i] = 0.1; // Initialize with default values
         }
      }
      
      FileWriteInteger(fileHandle, numWeights);
      
      // Save weights
      for(int i = 0; i < numWeights; i++)
      {
         FileWriteDouble(fileHandle, mlWeights[i]);
      }
      
      FileClose(fileHandle);
      Print("ML state saved to ", fileName);
   }
   else
   {
      Print("Error saving ML state: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Load ML state from file                                          |
//+------------------------------------------------------------------+
void LoadMLState()
{
   if(!UseML || !SaveMLState) return;
   
   string fileName = "d:\\xampp\\htdocs\\TScalpbot\\ML_State_" + Symbol() + ".bin";
   
   if(FileIsExist(fileName))
   {
      int fileHandle = FileOpen(fileName, FILE_READ|FILE_BIN);
      
      if(fileHandle != INVALID_HANDLE)
      {
         // Read number of weights
         int numWeights = FileReadInteger(fileHandle);
         
         // Resize weights array
         ArrayResize(mlWeights, numWeights);
         
         // Read weights
         for(int i = 0; i < numWeights; i++)
         {
            mlWeights[i] = FileReadDouble(fileHandle);
         }
         
         FileClose(fileHandle);
         Print("ML state loaded from ", fileName);
      }
      else
      {
         Print("Error loading ML state: ", GetLastError());
      }
   }
   else
   {
      Print("ML state file not found, using default weights");
   }
}

//+------------------------------------------------------------------+
//| Save adaptive parameters state to file                           |
//+------------------------------------------------------------------+
void SaveAdaptiveState()
{
   if(!UseAdaptiveParams || !SaveAdaptiveState) return;
   
   string fileName = "d:\\xampp\\htdocs\\TScalpbot\\Adaptive_State_" + Symbol() + ".bin";
   int fileHandle = FileOpen(fileName, FILE_WRITE|FILE_BIN);
   
   if(fileHandle != INVALID_HANDLE)
   {
      FileWriteDouble(fileHandle, adaptiveFastEMA);
      FileWriteDouble(fileHandle, adaptiveSlowEMA);
      FileWriteDouble(fileHandle, adaptiveRSIOverbought);
      FileWriteDouble(fileHandle, adaptiveRSIOversold);
      FileWriteDouble(fileHandle, adaptiveTakeProfit);
      FileWriteDouble(fileHandle, adaptiveStopLoss);
      
      FileClose(fileHandle);
      Print("Adaptive state saved to ", fileName);
   }
   else
   {
      Print("Error saving adaptive state: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Load adaptive parameters state from file                         |
//+------------------------------------------------------------------+
void LoadAdaptiveState()
{
   if(!UseAdaptiveParams || !SaveAdaptiveState) return;
   
   string fileName = "d:\\xampp\\htdocs\\TScalpbot\\Adaptive_State_" + Symbol() + ".bin";
   
   if(FileIsExist(fileName))
   {
      int fileHandle = FileOpen(fileName, FILE_READ|FILE_BIN);
      
      if(fileHandle != INVALID_HANDLE)
      {
         adaptiveFastEMA = FileReadDouble(fileHandle);
         adaptiveSlowEMA = FileReadDouble(fileHandle);
         adaptiveRSIOverbought = FileReadDouble(fileHandle);
         adaptiveRSIOversold = FileReadDouble(fileHandle);
         adaptiveTakeProfit = FileReadDouble(fileHandle);
         adaptiveStopLoss = FileReadDouble(fileHandle);
         
         FileClose(fileHandle);
         Print("Adaptive state loaded from ", fileName);
      }
      else
      {
         Print("Error loading adaptive state: ", GetLastError());
      }
   }
   else
   {
      Print("Adaptive state file not found, using default parameters");
      adaptiveFastEMA = FastEMA;
      adaptiveSlowEMA = SlowEMA;
      adaptiveRSIOverbought = RSIOverbought;
      adaptiveRSIOversold = RSIOversold;
      adaptiveTakeProfit = TakeProfit;
      adaptiveStopLoss = StopLoss;
   }
}

//+------------------------------------------------------------------+
//| Update adaptive parameters based on performance                  |
//+------------------------------------------------------------------+
void UpdateAdaptiveParameters()
{
   // ... existing code ...
   
   // Calculate win rate
   int wins = 0, losses = 0;
   for(int i = 0; i < tradeHistoryCount; i++)
   {
      if(tradeHistory[i].profit > 0)
         wins++;
      else if(tradeHistory[i].profit < 0)
         losses++;
   }
   
   // Fix the division by zero error by adding a check
   double winRate = (wins + losses > 0) ? (double)wins / (wins + losses) : 0.5;
   
   // Adjust parameters based on win rate
   if(winRate > 0.6)
   {
      // Good performance - make small adjustments
      Print("Good performance detected, making minor adjustments");
   }
   else if(winRate < 0.4)
   {
      /// Poor performance - make larger adjustments
   Print("Poor performance detected, making significant adjustments");
      
      // Adjust EMA periods - Replace MathRandom() with MathRand()/32768.0
   adaptiveFastEMA = MathMax(5, adaptiveFastEMA * (1 + AdaptiveRate * (0.5 - MathRand()/32768.0)));
   adaptiveSlowEMA = MathMax(10, adaptiveSlowEMA * (1 + AdaptiveRate * (0.5 - MathRand()/32768.0)));
   
   // Adjust RSI levels
   adaptiveRSIOverbought = MathMin(85, MathMax(60, adaptiveRSIOverbought + AdaptiveRate * 10 * (0.5 - MathRand()/32768.0)));
   adaptiveRSIOversold = MathMax(15, MathMin(40, adaptiveRSIOversold + AdaptiveRate * 10 * (0.5 - MathRand()/32768.0)));
   
   // Adjust TP/SL
   adaptiveTakeProfit = MathMax(5, adaptiveTakeProfit * (1 + AdaptiveRate * (0.5 - MathRand()/32768.0)));
   adaptiveStopLoss = MathMax(5, adaptiveStopLoss * (1 + AdaptiveRate * (0.5 - MathRand()/32768.0)));
   }
   
   // Analyze recent trades to find optimal parameters
   double bestFastEMA = adaptiveFastEMA;
   double bestSlowEMA = adaptiveSlowEMA;
   double bestRSIOverbought = adaptiveRSIOverbought;
   double bestRSIOversold = adaptiveRSIOversold;
   double bestTP = adaptiveTakeProfit;
   double bestSL = adaptiveStopLoss;
   
   // Find parameters that would have performed best
   double bestPerformance = -1000000;
   
   // Test different parameter combinations
   for(int fastEMA = (int)MathMax(5, adaptiveFastEMA * 0.7); fastEMA <= (int)MathMin(20, adaptiveFastEMA * 1.3); fastEMA += 2)
   {
      for(int slowEMA = (int)MathMax(15, adaptiveSlowEMA * 0.7); slowEMA <= (int)MathMin(50, adaptiveSlowEMA * 1.3); slowEMA += 5)
      {
         if(fastEMA >= slowEMA) continue;
         
         double performance = SimulatePerformance(fastEMA, slowEMA, adaptiveRSIOverbought, adaptiveRSIOversold, adaptiveTakeProfit, adaptiveStopLoss);
         
         if(performance > bestPerformance)
         {
            bestPerformance = performance;
            bestFastEMA = fastEMA;
            bestSlowEMA = slowEMA;
         }
      }
   }
   
   // Test different RSI levels
   for(int rsiOB = (int)MathMax(60, adaptiveRSIOverbought - 10); rsiOB <= (int)MathMin(90, adaptiveRSIOverbought + 10); rsiOB += 5)
   {
      for(int rsiOS = (int)MathMax(10, adaptiveRSIOversold - 10); rsiOS <= (int)MathMin(40, adaptiveRSIOversold + 10); rsiOS += 5)
      {
         double performance = SimulatePerformance(bestFastEMA, bestSlowEMA, rsiOB, rsiOS, adaptiveTakeProfit, adaptiveStopLoss);
         
         if(performance > bestPerformance)
         {
            bestPerformance = performance;
            bestRSIOverbought = rsiOB;
            bestRSIOversold = rsiOS;
         }
      }
   }
   
   // Test different TP/SL combinations
   for(int tp = (int)MathMax(5, adaptiveTakeProfit * 0.7); tp <= (int)MathMin(50, adaptiveTakeProfit * 1.3); tp += 5)
   {
      for(int sl = (int)MathMax(5, adaptiveStopLoss * 0.7); sl <= (int)MathMin(30, adaptiveStopLoss * 1.3); sl += 3)
      {
         double performance = SimulatePerformance(bestFastEMA, bestSlowEMA, bestRSIOverbought, bestRSIOversold, tp, sl);
         
         if(performance > bestPerformance)
         {
            bestPerformance = performance;
            bestTP = tp;
            bestSL = sl;
         }
      }
   }
   
   // Apply changes gradually using adaptive rate
   adaptiveFastEMA = adaptiveFastEMA * (1 - AdaptiveRate) + bestFastEMA * AdaptiveRate;
   adaptiveSlowEMA = adaptiveSlowEMA * (1 - AdaptiveRate) + bestSlowEMA * AdaptiveRate;
   adaptiveRSIOverbought = adaptiveRSIOverbought * (1 - AdaptiveRate) + bestRSIOverbought * AdaptiveRate;
   adaptiveRSIOversold = adaptiveRSIOversold * (1 - AdaptiveRate) + bestRSIOversold * AdaptiveRate;
   adaptiveTakeProfit = adaptiveTakeProfit * (1 - AdaptiveRate) + bestTP * AdaptiveRate;
   adaptiveStopLoss = adaptiveStopLoss * (1 - AdaptiveRate) + bestSL * AdaptiveRate;
   
   Print("Updated adaptive parameters - FastEMA: ", DoubleToString(adaptiveFastEMA, 1), 
         ", SlowEMA: ", DoubleToString(adaptiveSlowEMA, 1),
         ", RSI OB/OS: ", DoubleToString(adaptiveRSIOverbought, 1), "/", DoubleToString(adaptiveRSIOversold, 1),
         ", TP/SL: ", DoubleToString(adaptiveTakeProfit, 1), "/", DoubleToString(adaptiveStopLoss, 1));
}

//+------------------------------------------------------------------+
//| Simulate performance with given parameters                       |
//+------------------------------------------------------------------+
double SimulatePerformance(double fastEMA, double slowEMA, double rsiOB, double rsiOS, double tp, double sl)
{
   double totalProfit = 0;
   double wins = 0, losses = 0;
   
   // Use recent trades for simulation
   int startIdx = MathMax(0, tradeHistoryCount - 50);
   
   for(int i = startIdx; i < tradeHistoryCount; i++)
   {
      // Skip trades with zero profit (still open)
      if(tradeHistory[i].profit == 0) continue;
      
      // Check if our parameters would have taken this trade
      bool wouldTrade = false;
      
      if(tradeHistory[i].type == OP_BUY)
      {
         wouldTrade = tradeHistory[i].fastEMA > tradeHistory[i].slowEMA && tradeHistory[i].rsi < rsiOS;
      }
      else if(tradeHistory[i].type == OP_SELL)
      {
         wouldTrade = tradeHistory[i].fastEMA < tradeHistory[i].slowEMA && tradeHistory[i].rsi > rsiOB;
      }
      
      if(wouldTrade)
      {
         // Simulate trade outcome with new TP/SL
         double originalTP = tradeHistory[i].type == OP_BUY ? 
                  tradeHistory[i].openPrice + TakeProfit * Point() * pointMultiplier :
                  tradeHistory[i].openPrice - TakeProfit * Point() * pointMultiplier;
                  
         double originalSL = tradeHistory[i].type == OP_BUY ? 
                  tradeHistory[i].openPrice - StopLoss * Point() * pointMultiplier :
                  tradeHistory[i].openPrice + StopLoss * Point() * pointMultiplier;
                           
         double newTP = tradeHistory[i].type == OP_BUY ? 
                      tradeHistory[i].openPrice + tp * Point() * 10 :
                      tradeHistory[i].openPrice - tp * Point() * 10;
                      
         double newSL = tradeHistory[i].type == OP_BUY ? 
                      tradeHistory[i].openPrice - sl * Point() * 10 :
                      tradeHistory[i].openPrice + sl * Point() * 10;
         
         // Check if new TP/SL would change outcome
         if(tradeHistory[i].profit > 0)
         {
            // Original trade was a win
            if(MathAbs(newTP - tradeHistory[i].openPrice) < MathAbs(originalTP - tradeHistory[i].openPrice))
            {
               // New TP is closer - would still win but with less profit
               totalProfit += tp;
               wins++;
            }
            else
            {
               // New TP is further - would still win with more profit
               totalProfit += tp;
               wins++;
            }
         }
         else
         {
            // Original trade was a loss
            if(MathAbs(newSL - tradeHistory[i].openPrice) > MathAbs(originalSL - tradeHistory[i].openPrice))
            {
               // New SL is further - might turn into a win
               totalProfit += tp * 0.3 - sl * 0.7; // Estimate
               wins += 0.3; // Partial win
               losses += 0.7; // Partial loss
            }
            else
            {
               // New SL is closer - would still lose but with less loss
               totalProfit -= sl;
               losses++;
            }
         }
      }
   }
   
   // Calculate performance metrics
   double winRate = (wins + losses > 0) ? (double)wins / (wins + losses) : 0;
   double profitFactor = (losses > 0) ? (totalProfit + (double)losses) / losses : 1;
   
   return totalProfit * 0.7 + winRate * 100 * 0.3;

   
}

//+------------------------------------------------------------------+
//| Detect market regime (trending, ranging, volatile)               |
//+------------------------------------------------------------------+
void DetectMarketRegime()
{
   if(!UseRegimeDetection) return;
   
   // Calculate ADX to determine trend strength
   double adx = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_MAIN, 0);
   
   // Calculate ATR to determine volatility
   double atr = iATR(Symbol(), 0, 14, 0);
   double atrPercent = atr / iClose(Symbol(), 0, 0) * 100;
   
   // Calculate Bollinger Bands width for range detection
   double bbUpper = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double bbLower = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   double bbWidth = (bbUpper - bbLower) / iClose(Symbol(), 0, 0) * 100;
   
   // Determine regime
   if(adx > 25)
   {
      if(atrPercent > 0.1)
      {
         // Strong trend with high volatility
         currentRegime = 1;
         regimeVolatility = atrPercent;
      }
      else
      {
         // Strong trend with low volatility
         currentRegime = 2;
         regimeVolatility = atrPercent;
      }
   }
   else
   {
      if(bbWidth < 0.5)
      {
         // Tight range
         currentRegime = 3;
         regimeVolatility = bbWidth;
      }
            else if(atrPercent > 0.1)
      {
         // Volatile range
         currentRegime = 4;
         regimeVolatility = atrPercent;
      }
      else
      {
         // Quiet range
         currentRegime = 5;
         regimeVolatility = atrPercent;
      }
   }
   
   string regimeNames[] = {"Unknown", "Strong Trend (High Vol)", "Strong Trend (Low Vol)", 
                          "Tight Range", "Volatile Range", "Quiet Range"};
   
   Print("Market Regime: ", regimeNames[currentRegime], 
         " (ADX: ", DoubleToString(adx, 1), 
         ", ATR%: ", DoubleToString(atrPercent, 2),
         ", BB Width: ", DoubleToString(bbWidth, 2), ")");
}

//+------------------------------------------------------------------+
//| Adjust parameters for current market regime                      |
//+------------------------------------------------------------------+
void AdjustForMarketRegime()
{
   if(!UseRegimeDetection || !UseAdaptiveParams) return;
   
   // Reset to base values first
   adaptiveFastEMA = FastEMA;
   adaptiveSlowEMA = SlowEMA;
   adaptiveRSIOverbought = RSIOverbought;
   adaptiveRSIOversold = RSIOversold;
   adaptiveTakeProfit = TakeProfit;
   adaptiveStopLoss = StopLoss;
   
   // Adjust based on regime
   switch(currentRegime)
   {
      case 1: // Strong Trend (High Vol)
         // Use longer EMAs for stronger trend confirmation
         adaptiveFastEMA *= 1.2;
         adaptiveSlowEMA *= 1.2;
         // Wider RSI bands for trend following
         adaptiveRSIOverbought = MathMin(85, adaptiveRSIOverbought + 5);
         adaptiveRSIOversold = MathMax(15, adaptiveRSIOversold - 5);
         // Wider TP/SL for higher volatility
         adaptiveTakeProfit *= 1.3;
         adaptiveStopLoss *= 1.3;
         break;
         
      case 2: // Strong Trend (Low Vol)
         // Use standard EMAs for trend following
         // Wider RSI bands for trend following
         adaptiveRSIOverbought = MathMin(85, adaptiveRSIOverbought + 5);
         adaptiveRSIOversold = MathMax(15, adaptiveRSIOversold - 5);
         // Standard TP/SL
         break;
         
      case 3: // Tight Range
         // Use shorter EMAs for quicker signals
         adaptiveFastEMA *= 0.8;
         adaptiveSlowEMA *= 0.8;
         // Tighter RSI bands for range trading
         adaptiveRSIOverbought = MathMax(65, adaptiveRSIOverbought - 5);
         adaptiveRSIOversold = MathMin(35, adaptiveRSIOversold + 5);
         // Tighter TP/SL for range
         adaptiveTakeProfit *= 0.8;
         adaptiveStopLoss *= 0.8;
         break;
         
      case 4: // Volatile Range
         // Use shorter EMAs for quicker signals
         adaptiveFastEMA *= 0.9;
         adaptiveSlowEMA *= 0.9;
         // Standard RSI bands
         // Wider TP/SL for volatility
         adaptiveTakeProfit *= 1.2;
         adaptiveStopLoss *= 1.2;
         break;
         
      case 5: // Quiet Range
         // Use shorter EMAs for quicker signals
         adaptiveFastEMA *= 0.7;
         adaptiveSlowEMA *= 0.7;
         // Tighter RSI bands for range trading
         adaptiveRSIOverbought = MathMax(65, adaptiveRSIOverbought - 5);
         adaptiveRSIOversold = MathMin(35, adaptiveRSIOversold + 5);
         // Tighter TP/SL for quiet market
         adaptiveTakeProfit *= 0.7;
         adaptiveStopLoss *= 0.7;
         break;
   }
   
   Print("Adjusted for regime - FastEMA: ", DoubleToString(adaptiveFastEMA, 1), 
         ", SlowEMA: ", DoubleToString(adaptiveSlowEMA, 1),
         ", RSI OB/OS: ", DoubleToString(adaptiveRSIOverbought, 1), "/", DoubleToString(adaptiveRSIOversold, 1),
         ", TP/SL: ", DoubleToString(adaptiveTakeProfit, 1), "/", DoubleToString(adaptiveStopLoss, 1));
}

//+------------------------------------------------------------------+
//| Analyze historical data to initialize ML model                   |
//+------------------------------------------------------------------+
void AnalyzeHistoricalData()
{
   if(!UseHistoricalData || !UseML) return;
   
   Print("Analyzing historical data...");
   
   // Calculate number of bars to analyze
   int barsToAnalyze = HistoricalDays * 24 * 60 / Period();
   int availableBars = MathMin(barsToAnalyze, Bars);
   
   // Create simulated trades from historical data
   int tradesCreated = 0;
   
   for(int i = availableBars - 1; i >= 1; i--)
   {
      // Skip if we've created enough trades
      if(tradesCreated >= MinHistoricalTrades) break;
      
      // Get indicator values for this bar
      double fastEMA = iMA(Symbol(), 0, FastEMA, 0, MODE_EMA, PRICE_CLOSE, i);
      double slowEMA = iMA(Symbol(), 0, SlowEMA, 0, MODE_EMA, PRICE_CLOSE, i);
      double rsi = iRSI(Symbol(), 0, RSIPeriod, PRICE_CLOSE, i);
      
      // Check for buy signal
      if(fastEMA > slowEMA && rsi < RSIOversold)
      {
         // Simulate a buy trade
         SimulateHistoricalTrade(i, OP_BUY);
         tradesCreated++;
      }
      // Check for sell signal
      else if(fastEMA < slowEMA && rsi > RSIOverbought)
      {
         // Simulate a sell trade
         SimulateHistoricalTrade(i, OP_SELL);
         tradesCreated++;
      }
   }
   
   Print("Created ", tradesCreated, " simulated trades from historical data");
   
   // Update ML model with historical data
   if(tradesCreated > 0)
   {
      UpdateMLModel();
   }
}

//+------------------------------------------------------------------+
//| Simulate a historical trade for ML training                      |
//+------------------------------------------------------------------+
void SimulateHistoricalTrade(int startBar, int type)
{
   // Get open price
   double openPrice = type == OP_BUY ? iOpen(Symbol(), 0, startBar) + MarketInfo(Symbol(), MODE_SPREAD) * Point() : iOpen(Symbol(), 0, startBar);
   
   // Calculate TP/SL levels
   double tpLevel = type == OP_BUY ? openPrice + TakeProfit * Point() * 10 : openPrice - TakeProfit * Point() * 10;
   double slLevel = type == OP_BUY ? openPrice - StopLoss * Point() * 10 : openPrice + StopLoss * Point() * 10;
   
   // Simulate trade outcome
   double closePrice = openPrice;
   double profit = 0;
   bool closed = false;
   
   for(int i = startBar - 1; i >= 0 && !closed; i--)
   {
      double high = iHigh(Symbol(), 0, i);
      double low = iLow(Symbol(), 0, i);
      
      // Check if TP hit
      if((type == OP_BUY && high >= tpLevel) || (type == OP_SELL && low <= tpLevel))
      {
         closePrice = tpLevel;
         profit = type == OP_BUY ? tpLevel - openPrice : openPrice - tpLevel;
         closed = true;
      }
      // Check if SL hit
      else if((type == OP_BUY && low <= slLevel) || (type == OP_SELL && high >= slLevel))
      {
         closePrice = slLevel;
         profit = type == OP_BUY ? slLevel - openPrice : openPrice - slLevel;
         closed = true;
      }
      
      // Limit simulation to 100 bars
      if(startBar - i > 100)
      {
         closePrice = iClose(Symbol(), 0, i);
         profit = type == OP_BUY ? closePrice - openPrice : openPrice - closePrice;
         closed = true;
      }
   }
   
   // Convert profit to account currency
   profit = profit / Point() * MarketInfo(Symbol(), MODE_TICKVALUE) * 10;
   
   // Add to trade history
   if(tradeHistoryCount >= ArraySize(tradeHistory))
   {
      ArrayResize(tradeHistory, tradeHistoryCount + 100);
   }
   
   tradeHistory[tradeHistoryCount].bollingerUpper = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, startBar);
   tradeHistory[tradeHistoryCount].bollingerLower = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, startBar);
   tradeHistory[tradeHistoryCount].bollingerWidth = tradeHistory[tradeHistoryCount].bollingerUpper - tradeHistory[tradeHistoryCount].bollingerLower;
   tradeHistory[tradeHistoryCount].adx = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_MAIN, startBar);
   tradeHistory[tradeHistoryCount].volumeChange = (double)iVolume(Symbol(), 0, startBar) / MathMax(1, iVolume(Symbol(), 0, startBar + 1));
   tradeHistory[tradeHistoryCount].pattern = DetectCandlePattern(startBar);
   
   tradeHistoryCount++;
   
   // Store market conditions at time of trade
   tradeHistory[tradeHistoryCount].fastEMA = iMA(Symbol(), 0, FastEMA, 0, MODE_EMA, PRICE_CLOSE, startBar);
   tradeHistory[tradeHistoryCount].slowEMA = iMA(Symbol(), 0, SlowEMA, 0, MODE_EMA, PRICE_CLOSE, startBar);
   tradeHistory[tradeHistoryCount].rsi = iRSI(Symbol(), 0, RSIPeriod, PRICE_CLOSE, startBar);
   tradeHistory[tradeHistoryCount].atr = iATR(Symbol(), 0, 14, startBar);
   tradeHistory[tradeHistoryCount].spread = MarketInfo(Symbol(), MODE_SPREAD);
   
   // Store time information
   MqlDateTime dt;
   TimeToStruct(tradeHistory[tradeHistoryCount].time, dt);
   tradeHistory[tradeHistoryCount].hour = dt.hour;
   tradeHistory[tradeHistoryCount].dayOfWeek = dt.day_of_week;
   
   // Store additional features
   tradeHistory[tradeHistoryCount].macd = iMACD(Symbol(), 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, startBar);
   tradeHistory[tradeHistoryCount].macdSignal = iMACD(Symbol(), 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, startBar);
   tradeHistory[tradeHistoryCount].bollingerUpper = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, startBar);
   tradeHistory[tradeHistoryCount].bollingerLower = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, startBar);
   tradeHistory[tradeHistoryCount].bollingerWidth = tradeHistory[tradeHistoryCount].bollingerUpper - tradeHistory[tradeHistoryCount].bollingerLower;
   tradeHistory[tradeHistoryCount].adx = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_MAIN, startBar);
   tradeHistory[tradeHistoryCount].volumeChange = (double)iVolume(Symbol(), 0, startBar) / MathMax(1, iVolume(Symbol(), 0, startBar + 1));
   tradeHistory[tradeHistoryCount].pattern = DetectCandlePattern(startBar);
   
   tradeHistoryCount++;
}

//+------------------------------------------------------------------+
//| Detect candlestick pattern                                       |
//+------------------------------------------------------------------+
CANDLE_PATTERN DetectCandlePattern(int shift)
{
   if(!UsePatternRecognition) return PATTERN_NONE;
   
   double open = iOpen(Symbol(), 0, shift);
   double close = iClose(Symbol(), 0, shift);
   double high = iHigh(Symbol(), 0, shift);
   double low = iLow(Symbol(), 0, shift);
   
   double bodySize = MathAbs(open - close);
   double totalSize = high - low;
   double upperWick = high - MathMax(open, close);
   double lowerWick = MathMin(open, close) - low;
   
   // Previous candle
   double prevOpen = iOpen(Symbol(), 0, shift + 1);
   double prevClose = iClose(Symbol(), 0, shift + 1);
   double prevHigh = iHigh(Symbol(), 0, shift + 1);
   double prevLow = iLow(Symbol(), 0, shift + 1);
   double prevBodySize = MathAbs(prevOpen - prevClose);
   
   // Next candle (for 3-candle patterns)
   double nextOpen = iOpen(Symbol(), 0, shift - 1);
   double nextClose = iClose(Symbol(), 0, shift - 1);
   
   // Detect Doji
   if(bodySize < totalSize * 0.1)
   {
      return PATTERN_DOJI;
   }
   
   // Detect Hammer
   if(bodySize < totalSize * 0.3 && lowerWick > bodySize * 2 && upperWick < bodySize * 0.5)
   {
      return PATTERN_HAMMER;
   }
   
   // Detect Shooting Star
   if(bodySize < totalSize * 0.3 && upperWick > bodySize * 2 && lowerWick < bodySize * 0.5)
   {
      return PATTERN_SHOOTING_STAR;
   }
   
   // Detect Bullish Engulfing
   if(close > open && prevClose < prevOpen && 
      close > prevOpen && open < prevClose && 
      bodySize > prevBodySize * 0.8)
   {
      return PATTERN_ENGULFING_BULL;
   }
   
   // Detect Bearish Engulfing
   if(close < open && prevClose > prevOpen && 
      close < prevOpen && open > prevClose && 
      bodySize > prevBodySize * 0.8)
   {
      return PATTERN_ENGULFING_BEAR;
   }
   
   // Detect Morning Star (3-candle bullish reversal)
   if(shift > 1 && 
      prevClose < prevOpen && // First candle bearish
      MathAbs(open - close) < prevBodySize * 0.3 && // Second candle small
      nextClose > nextOpen && // Third candle bullish
      nextClose > (prevOpen + prevClose) / 2) // Third candle closes above middle of first
   {
      return PATTERN_MORNING_STAR;
   }
   
   // Detect Evening Star (3-candle bearish reversal)
   if(shift > 1 && 
      prevClose > prevOpen && // First candle bullish
      MathAbs(open - close) < prevBodySize * 0.3 && // Second candle small
      nextClose < nextOpen && // Third candle bearish
      nextClose < (prevOpen + prevClose) / 2) // Third candle closes below middle of first
   {
      return PATTERN_EVENING_STAR;
   }
   
   return PATTERN_NONE;
}

//+------------------------------------------------------------------+
//| Get signal strength from pattern (-1 to 1)                       |
//+------------------------------------------------------------------+
double GetPatternSignal(CANDLE_PATTERN pattern)
{
   switch(pattern)
   {
      case PATTERN_DOJI:
         return 0; // Neutral
         
      case PATTERN_HAMMER:
         return 0.7; // Bullish
         
      case PATTERN_SHOOTING_STAR:
         return -0.7; // Bearish
         
      case PATTERN_ENGULFING_BULL:
         return 0.8; // Strongly bullish
         
      case PATTERN_ENGULFING_BEAR:
         return -0.8; // Strongly bearish
         
      case PATTERN_MORNING_STAR:
         return 0.9; // Very strongly bullish
         
      case PATTERN_EVENING_STAR:
         return -0.9; // Very strongly bearish
         
      default:
         return 0; // Neutral
   }
}

//+------------------------------------------------------------------+
//| Check correlation confirmation for trade direction                |
//+------------------------------------------------------------------+
bool CheckCorrelationConfirmation(int type)
{
   if(!UseCorrelation) return true;
   
   // Get current trend direction for main pair
   double mainFastEMA = iMA(Symbol(), 0, FastEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
   double mainSlowEMA = iMA(Symbol(), 0, SlowEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
   int mainTrend = mainFastEMA > mainSlowEMA ? 1 : -1;
   
   // Check correlated pair 1
   if(CorrelatedPair1 != "")
   {
      double pair1FastEMA = iMA(CorrelatedPair1, 0, FastEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
      double pair1SlowEMA = iMA(CorrelatedPair1, 0, SlowEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
      int pair1Trend = pair1FastEMA > pair1SlowEMA ? 1 : -1;
      
      // Calculate correlation
      double correlation1 = CalculateCorrelation(Symbol(), CorrelatedPair1, 50);
      
      // If strong correlation and trends don't match, reject signal
      if(MathAbs(correlation1) > MinCorrelation)
      {
         if(correlation1 > 0 && mainTrend != pair1Trend)
         {
            Print("Correlation filter: ", CorrelatedPair1, " trend doesn't confirm signal");
            return false;
         }
         else if(correlation1 < 0 && mainTrend == pair1Trend)
         {
            Print("Correlation filter: ", CorrelatedPair1, " trend doesn't confirm signal (inverse)");
            return false;
         }
      }
   }
   
   // Check correlated pair 2
   if(CorrelatedPair2 != "")
   {
      double pair2FastEMA = iMA(CorrelatedPair2, 0, FastEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
      double pair2SlowEMA = iMA(CorrelatedPair2, 0, SlowEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
      int pair2Trend = pair2FastEMA > pair2SlowEMA ? 1 : -1;
      
      // Calculate correlation
      double correlation2 = CalculateCorrelation(Symbol(), CorrelatedPair2, 50);
      
      // If strong correlation and trends don't match, reject signal
      if(MathAbs(correlation2) > MinCorrelation)
      {
         if(correlation2 > 0 && mainTrend != pair2Trend)
         {
            Print("Correlation filter: ", CorrelatedPair2, " trend doesn't confirm signal");
            return false;
         }
         else if(correlation2 < 0 && mainTrend == pair2Trend)
         {
            Print("Correlation filter: ", CorrelatedPair2, " trend doesn't confirm signal (inverse)");
            return false;
         }
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate correlation between two symbols                        |
//+------------------------------------------------------------------+
double CalculateCorrelation(string symbol1, string symbol2, int period)
{
   if(period <= 1) return 0;
   
   double x[]; // Price changes for symbol1
   double y[]; // Price changes for symbol2
   
   ArrayResize(x, period);
   ArrayResize(y, period);
   
   // Get price changes
   for(int i = 0; i < period; i++)
   {
      x[i] = iClose(symbol1, 0, i) - iClose(symbol1, 0, i + 1);
      y[i] = iClose(symbol2, 0, i) - iClose(symbol2, 0, i + 1);
   }
   
   // Calculate correlation
   double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;
   
   for(int i = 0; i < period; i++)
   {
      sumX += x[i];
      sumY += y[i];
      sumXY += x[i] * y[i];
      sumX2 += x[i] * x[i];
      sumY2 += y[i] * y[i];
   }
   
   double correlation = (period * sumXY - sumX * sumY) / 
                       (MathSqrt(period * sumX2 - sumX * sumX) * MathSqrt(period * sumY2 - sumY * sumY));
   
   return correlation;
}

//+------------------------------------------------------------------+
//| Calculate market sentiment                                       |
//+------------------------------------------------------------------+
double CalculateMarketSentiment()
{
   if(!UseSentimentAnalysis) return 0.5; // Neutral
   
   int bullishBars = 0;
   int bearishBars = 0;
   
   // Analyze recent price action
   for(int i = 0; i < SentimentPeriod; i++)
   {
      double open = iOpen(Symbol(), 0, i);
      double close = iClose(Symbol(), 0, i);
      
      if(close > open)
         bullishBars++;
      else if(close < open)
         bearishBars++;
   }
   
   // Calculate sentiment (0 = bearish, 1 = bullish)
   double sentiment = (double)bullishBars / (bullishBars + bearishBars);
   
   // Calculate additional sentiment indicators
   double adx = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_MAIN, 0);
   double plusDI = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_PLUSDI, 0);
   double minusDI = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_MINUSDI, 0);
   
   // Adjust sentiment based on trend strength
   if(adx > 25)
   {
      if(plusDI > minusDI)
         sentiment = (sentiment + 1) / 2; // Bias toward bullish
      else
         sentiment = sentiment / 2; // Bias toward bearish
   }
   
   // Check for extreme overbought/oversold conditions
   double rsi = iRSI(Symbol(), 0, 14, PRICE_CLOSE, 0);
   if(rsi > 70)
      sentiment = MathMax(0.2, sentiment - 0.2); // Reduce bullish sentiment
   else if(rsi < 30)
      sentiment = MathMin(0.8, sentiment + 0.2); // Reduce bearish sentiment
   
   return sentiment;
}

//+------------------------------------------------------------------+
//| Get sentiment-based trading bias (-1 to 1)                       |
//+------------------------------------------------------------------+
double GetSentimentBias()
{
   if(!UseSentimentAnalysis) return 0; // No bias
   
   double sentiment = CalculateMarketSentiment();
   
   // Convert to bias (-1 to 1)
   double bias = (sentiment - 0.5) * 2;
   
   // Only apply strong bias when sentiment is beyond threshold
   if(MathAbs(bias) < SentimentThreshold)
      return 0;
      
   return bias;
}

//+------------------------------------------------------------------+
//| Get current trading session                                      |
//+------------------------------------------------------------------+
TRADING_SESSION GetCurrentSession()
{
   if(!UseSessionAnalysis) return SESSION_LONDON; // Default
   
   // Get current GMT time
   datetime serverTime = TimeCurrent();
   int gmtOffset = 0; // Adjust based on your broker's server time
   
   MqlDateTime dt;
   TimeToStruct(serverTime, dt);
   int hour = dt.hour;
   
   // Adjust for GMT offset
   hour = (hour + 24 - gmtOffset) % 24;
   
   // Determine session
   if(hour >= 0 && hour < 8)
      return SESSION_ASIAN;
   else if(hour >= 8 && hour < 12)
      return SESSION_LONDON;
   else if(hour >= 12 && hour < 16)
      return SESSION_LONDON_NEWYORK_OVERLAP;
   else if(hour >= 16 && hour < 20)
      return SESSION_NEWYORK;
   else
      return SESSION_NONE;
}

//+------------------------------------------------------------------+
//| Check if current session is active for trading                   |
//+------------------------------------------------------------------+
bool IsActiveSession()
{
   if(!UseSessionAnalysis) return true;
   
   TRADING_SESSION session = GetCurrentSession();
   
   switch(session)
   {
      case SESSION_ASIAN:
         return TradeAsianSession;
         
      case SESSION_LONDON:
         return TradeLondonSession;
         
      case SESSION_NEWYORK:
         return TradeNewYorkSession;
         
      case SESSION_LONDON_NEWYORK_OVERLAP:
         return TradeLondonSession || TradeNewYorkSession;
         
      default:
         return false;
   }
}

//+------------------------------------------------------------------+
//| Adjust parameters based on current session                       |
//+------------------------------------------------------------------+
void AdjustForSession()
{
   if(!UseSessionAnalysis) return;
   
   TRADING_SESSION session = GetCurrentSession();
   
   // Reset to base values first
   if(UseAdaptiveParams)
   {
      adaptiveFastEMA = FastEMA;
      adaptiveSlowEMA = SlowEMA;
      adaptiveRSIOverbought = RSIOverbought;
      adaptiveRSIOversold = RSIOversold;
      adaptiveTakeProfit = TakeProfit;
      adaptiveStopLoss = StopLoss;
   }
   
   // Apply session-specific adjustments
   switch(session)
   {
      case SESSION_ASIAN:
         // Asian session tends to be ranging - use shorter EMAs, tighter TP/SL
         if(UseAdaptiveParams)
         {
            adaptiveFastEMA *= (1 - SessionAdjustment);
            adaptiveSlowEMA *= (1 - SessionAdjustment);
            adaptiveTakeProfit *= (1 - SessionAdjustment * 0.5);
            adaptiveStopLoss *= (1 - SessionAdjustment * 0.5);
         }
         break;
         
      case SESSION_LONDON:
         // London session can be volatile - use standard parameters
         break;
         
      case SESSION_LONDON_NEWYORK_OVERLAP:
         // Overlap tends to have highest volatility - widen TP/SL
         if(UseAdaptiveParams)
         {
            adaptiveTakeProfit *= (1 + SessionAdjustment);
            adaptiveStopLoss *= (1 + SessionAdjustment);
         }
         break;
         
      case SESSION_NEWYORK:
         // New York session can trend strongly - use longer EMAs
         if(UseAdaptiveParams)
         {
            adaptiveFastEMA *= (1 + SessionAdjustment * 0.5);
            adaptiveSlowEMA *= (1 + SessionAdjustment * 0.5);
         }
         break;
   }
   
   // Log session adjustments
   string sessionNames[] = {"None", "Asian", "London", "New York", "London-NY Overlap"};
   Print("Adjusted for ", sessionNames[session], " session - FastEMA: ", adaptiveFastEMA, 
         ", SlowEMA: ", adaptiveSlowEMA, 
         ", TP: ", adaptiveTakeProfit, 
         ", SL: ", adaptiveStopLoss);
}

//+------------------------------------------------------------------+
//| Initialize equity curve                                          |
//+------------------------------------------------------------------+
void InitializeEquityCurve()
{
   if(!UseEquityCurveFilter) return;
   
   ArrayResize(equityCurve, EquityCurvePeriod);
   equityCurveCount = 0;
   equityCurvePositive = true;
   
   // Initialize with current equity
   equityCurve[0] = AccountEquity();
   equityCurveCount = 1;
}

//+------------------------------------------------------------------+
//| Update equity curve with new value                               |
//+------------------------------------------------------------------+
void UpdateEquityCurve()
{
   if(!UseEquityCurveFilter) return;
   
   // Shift array if full
   if(equityCurveCount >= EquityCurvePeriod)
   {
      for(int i = 0; i < EquityCurvePeriod - 1; i++)
      {
         equityCurve[i] = equityCurve[i + 1];
      }
      equityCurveCount = EquityCurvePeriod - 1;
   }
   
   // Add current equity
   equityCurve[equityCurveCount] = AccountEquity();
   equityCurveCount++;
   
   // Calculate equity curve trend
   if(equityCurveCount >= 5) // Need at least 5 points
   {
      double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
      
      for(int i = 0; i < equityCurveCount; i++)
      {
         sumX += i;
         sumY += equityCurve[i];
         sumXY += i * equityCurve[i];
         sumX2 += i * i;
      }
      
      double slope = (equityCurveCount * sumXY - sumX * sumY) / (equityCurveCount * sumX2 - sumX * sumX);
      double normalizedSlope = slope / equityCurve[0] * 100; // Normalize as percentage
      
      // Determine if equity curve is positive
      equityCurvePositive = normalizedSlope > EquityCurveThreshold;
      
      // Log equity curve status
      string status = equityCurvePositive ? "POSITIVE" : "NEGATIVE";
      Print("Equity curve trend: ", status, " (", DoubleToString(normalizedSlope, 2), "%)");
      
            // Adjust risk based on equity curve
      if(UseAutoLotSize)
      {
         if(equityCurvePositive)
         {
            // Increase risk slightly when equity curve is positive
            RiskPercent = MathMin(MaxRiskPercent, RiskPercent * 1.05);
         }
         else
         {
            // Decrease risk when equity curve is negative
            RiskPercent = MathMax(MinRiskPercent, RiskPercent * 0.9);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Generate market insights for dashboard                           |
//+------------------------------------------------------------------+
void GenerateMarketInsights()
{
   // Calculate key indicators
   double atr = iATR(Symbol(), 0, 14, 0);
   double atrPercent = atr / iClose(Symbol(), 0, 0) * 100;
   double adx = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_MAIN, 0);
   double plusDI = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_PLUSDI, 0);
   double minusDI = iADX(Symbol(), 0, 14, PRICE_CLOSE, MODE_MINUSDI, 0);
   double rsi = iRSI(Symbol(), 0, 14, PRICE_CLOSE, 0);
   
   // Determine market conditions
   string volatility = atrPercent < 0.05 ? "Very Low" : 
                      atrPercent < 0.1 ? "Low" : 
                      atrPercent < 0.2 ? "Medium" : 
                      atrPercent < 0.3 ? "High" : "Very High";
                      
   string trend = adx < 15 ? "No Trend" : 
                 adx < 25 ? "Weak Trend" : 
                 adx < 50 ? "Strong Trend" : "Very Strong Trend";
                 
   string direction = plusDI > minusDI ? "Bullish" : "Bearish";
   
   string momentum = rsi < 30 ? "Oversold" : 
                    rsi > 70 ? "Overbought" : 
                    rsi < 45 ? "Bearish" : 
                    rsi > 55 ? "Bullish" : "Neutral";
   
   // Store insights for dashboard
   string insights = "Market Insights:\n";
   insights += "Volatility: " + volatility + " (" + DoubleToString(atrPercent, 2) + "%)\n";
   insights += "Trend: " + trend + " " + direction + " (ADX: " + DoubleToString(adx, 1) + ")\n";
   insights += "Momentum: " + momentum + " (RSI: " + DoubleToString(rsi, 1) + ")\n";
   
   // Add session information
   if(UseSessionAnalysis)
   {
      string sessionNames[] = {"None", "Asian", "London", "New York", "London-NY Overlap"};
      insights += "Session: " + sessionNames[GetCurrentSession()] + "\n";
   }
   
   // Add regime information
   if(UseRegimeDetection)
   {
      string regimeNames[] = {"Unknown", "Strong Trend (High Vol)", "Strong Trend (Low Vol)", 
                             "Tight Range", "Volatile Range", "Quiet Range"};
      insights += "Regime: " + regimeNames[currentRegime] + "\n";
   }
   
   // Add sentiment information
   if(UseSentimentAnalysis)
   {
      double sentiment = CalculateMarketSentiment();
      string sentimentDesc = sentiment < 0.3 ? "Bearish" : 
                            sentiment > 0.7 ? "Bullish" : "Neutral";
      insights += "Sentiment: " + sentimentDesc + " (" + DoubleToString(sentiment * 100, 0) + "%)\n";
   }
   
   // Add pattern information
   if(UsePatternRecognition)
   {
      CANDLE_PATTERN pattern = DetectCandlePattern(0);
      string patternNames[] = {"None", "Doji", "Hammer", "Shooting Star", "Bullish Engulfing", 
                              "Bearish Engulfing", "Morning Star", "Evening Star"};
      if(pattern != PATTERN_NONE)
      {
         insights += "Pattern: " + patternNames[pattern] + "\n";
      }
   }
   
   // Add correlation information
   if(UseCorrelation)
   {
      if(CorrelatedPair1 != "")
      {
         double corr1 = CalculateCorrelation(Symbol(), CorrelatedPair1, 50);
         insights += CorrelatedPair1 + " Correlation: " + DoubleToString(corr1, 2) + "\n";
      }
      
      if(CorrelatedPair2 != "")
      {
         double corr2 = CalculateCorrelation(Symbol(), CorrelatedPair2, 50);
         insights += CorrelatedPair2 + " Correlation: " + DoubleToString(corr2, 2) + "\n";
      }
   }
   
   // Store for dashboard
   Comment(insights);
}

//+------------------------------------------------------------------+
//| Create dashboard with performance metrics                        |
//+------------------------------------------------------------------+
void CreateDashboard()
{
   // Calculate performance metrics
   double localTotalTrades = winningTrades + losingTrades;  // Renamed from totalTrades to avoid conflict with global variable
   double winRate = localTotalTrades > 0 ? winningTrades / localTotalTrades * 100 : 0;
   double profitFactor = grossLoss != 0 ? MathAbs(grossProfit / grossLoss) : 0;
   double expectancy = localTotalTrades > 0 ? (grossProfit + grossLoss) / localTotalTrades : 0;
   double averageWin = winningTrades > 0 ? grossProfit / winningTrades : 0;
   double averageLoss = losingTrades > 0 ? grossLoss / losingTrades : 0;
   double riskRewardRatio = averageLoss != 0 ? MathAbs(averageWin / averageLoss) : 0;
   
   // Calculate drawdown
   double maxBalance = AccountBalance();
   double currentDrawdown = (maxBalance - AccountBalance()) / maxBalance * 100;
   
   // Create dashboard string
   string dashboard = "===== ScalpingMaster Performance =====\n";
   dashboard += "Balance: " + DoubleToString(AccountBalance(), 2) + " " + AccountCurrency() + "\n";
   dashboard += "Equity: " + DoubleToString(AccountEquity(), 2) + " " + AccountCurrency() + "\n";
   dashboard += "Profit: " + DoubleToString(AccountEquity() - startingEquity, 2) + " " + AccountCurrency() + "\n";
   dashboard += "Drawdown: " + DoubleToString(currentDrawdown, 2) + "%\n\n";
   
   dashboard += "Total Trades: " + IntegerToString(totalTrades) + "\n";
   dashboard += "Win Rate: " + DoubleToString(winRate, 1) + "%\n";
   dashboard += "Profit Factor: " + DoubleToString(profitFactor, 2) + "\n";
   dashboard += "Expectancy: " + DoubleToString(expectancy, 2) + "\n";
   dashboard += "Risk/Reward: " + DoubleToString(riskRewardRatio, 2) + "\n\n";
   
   dashboard += "Consecutive Wins: " + IntegerToString(consecutiveWins) + "\n";
   dashboard += "Consecutive Losses: " + IntegerToString(consecutiveLosses) + "\n";
   dashboard += "Max Consecutive Wins: " + IntegerToString(maxConsecutiveWins) + "\n";
   dashboard += "Max Consecutive Losses: " + IntegerToString(maxConsecutiveLosses) + "\n\n";
   
   dashboard += "Largest Win: " + DoubleToString(largestWin, 2) + "\n";
   dashboard += "Largest Loss: " + DoubleToString(largestLoss, 2) + "\n";
   dashboard += "Average Win: " + DoubleToString(averageWin, 2) + "\n";
   dashboard += "Average Loss: " + DoubleToString(averageLoss, 2) + "\n\n";
   
   // Add adaptive parameters if enabled
   if(UseAdaptiveParams)
   {
      dashboard += "===== Adaptive Parameters =====\n";
      dashboard += "Fast EMA: " + DoubleToString(adaptiveFastEMA, 1) + "\n";
      dashboard += "Slow EMA: " + DoubleToString(adaptiveSlowEMA, 1) + "\n";
      dashboard += "RSI OB/OS: " + DoubleToString(adaptiveRSIOverbought, 1) + "/" + DoubleToString(adaptiveRSIOversold, 1) + "\n";
      dashboard += "TP/SL: " + DoubleToString(adaptiveTakeProfit, 1) + "/" + DoubleToString(adaptiveStopLoss, 1) + "\n\n";
   }
   
   // Add ML information if enabled
   if(UseML && mlInitialized)
   {
      dashboard += "===== Machine Learning =====\n";
      dashboard += "Trades Analyzed: " + IntegerToString(tradeHistoryCount) + "\n";
      
      // Find top features
      double maxWeight = 0;
      int maxIndex = 0;
      
      for(int i = 0; i < ArraySize(mlWeights); i++)
      {
         if(MathAbs(mlWeights[i]) > maxWeight)
         {
            maxWeight = MathAbs(mlWeights[i]);
            maxIndex = i;
         }
      }
      
      string featureNames[] = {"EMA Diff", "RSI", "ATR", "Spread", "Hour", "Day of Week", "Direction", 
                              "MACD", "MACD Signal", "BB Position", "BB Width", "ADX", "Volume Change", 
                              "Pattern", "Bias"};
      
      if(maxIndex < ArraySize(featureNames))
      {
         dashboard += "Top Feature: " + featureNames[maxIndex] + " (" + DoubleToString(mlWeights[maxIndex], 3) + ")\n\n";
      }
   }
   
   // Display dashboard
   Comment(dashboard);
}

//+------------------------------------------------------------------+
//| Generate performance report                                      |
//+------------------------------------------------------------------+
void GenerateReport()
{
   if(!SaveReports) return;
   
   // Create report directory if it doesn't exist
   string reportDir = "d:\\xampp\\htdocs\\TScalpbot\\" + ReportFilePath;
   
   if(!FolderCreate(reportDir))
   {
      int lastError = GetLastError();
      if(lastError != 5 && lastError != 183) // 5 or 183 = directory already exists
      {
         Print("Error creating report directory: ", lastError);
         return;
      }
   }
   
   // Create report filename
   string reportFile = reportDir + "\\Report_" + Symbol() + "_" + 
                      TimeToString(TimeCurrent(), TIME_DATE) + ".html";
   
   // Calculate performance metrics
   int totalTradesReport = winningTrades + losingTrades;  // Changed variable name to avoid conflict
   double winRate = totalTradesReport > 0 ? winningTrades / totalTradesReport * 100 : 0;
   double profitFactor = grossLoss != 0 ? MathAbs(grossProfit / grossLoss) : 0;
   double expectancy = totalTradesReport > 0 ? (grossProfit + grossLoss) / totalTradesReport : 0;
   double averageWin = winningTrades > 0 ? grossProfit / winningTrades : 0;
   double averageLoss = losingTrades > 0 ? grossLoss / losingTrades : 0;
   double riskRewardRatio = averageLoss != 0 ? MathAbs(averageWin / averageLoss) : 0;
   
   // Create HTML report
   int fileHandle = FileOpen(reportFile, FILE_WRITE|FILE_TXT);
   
   if(fileHandle != INVALID_HANDLE)
   {
      if(fileHandle != INVALID_HANDLE)
   {
      // Write HTML header
      FileWrite(fileHandle, "<html>");
      FileWrite(fileHandle, "<head>");
      FileWrite(fileHandle, "<title>ScalpingMaster Performance Report</title>");
      FileWrite(fileHandle, "<style>");
      FileWrite(fileHandle, "body { font-family: Arial, sans-serif; margin: 20px; }");
      FileWrite(fileHandle, "h1, h2 { color: #333366; }");
      FileWrite(fileHandle, "table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }");
      FileWrite(fileHandle, "th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }");
      FileWrite(fileHandle, "th { background-color: #f2f2f2; }");
      FileWrite(fileHandle, "tr:nth-child(even) { background-color: #f9f9f9; }");
      FileWrite(fileHandle, ".positive { color: green; }");
      FileWrite(fileHandle, ".negative { color: red; }");
      FileWrite(fileHandle, "</style>");
      FileWrite(fileHandle, "</head>");
      FileWrite(fileHandle, "<body>");
      
      // Report header
      FileWrite(fileHandle, "<h1>ScalpingMaster Performance Report</h1>");
      FileWrite(fileHandle, "<p>Symbol: ", Symbol(), "</p>");
      FileWrite(fileHandle, "<p>Period: ", CustomPeriodToString(Period()), "</p>");
      FileWrite(fileHandle, "<p>Date: ", TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES), "</p>");
      FileWrite(fileHandle, "<p>Running since: ", TimeToString(startingTime, TIME_DATE|TIME_MINUTES), "</p>");
      
      // Account summary
      FileWrite(fileHandle, "<h2>Account Summary</h2>");
      FileWrite(fileHandle, "<table>");
      FileWrite(fileHandle, "<tr><th>Metric</th><th>Value</th></tr>");
      FileWrite(fileHandle, "<tr><td>Balance</td><td>", DoubleToString(AccountBalance(), 2), " ", AccountCurrency(), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Equity</td><td>", DoubleToString(AccountEquity(), 2), " ", AccountCurrency(), "</td></tr>");
      
      double profit = AccountEquity() - startingEquity;
      string profitClass = profit >= 0 ? "positive" : "negative";
      FileWrite(fileHandle, "<tr><td>Profit</td><td class='", profitClass, "'>", DoubleToString(profit, 2), " ", AccountCurrency(), "</td></tr>");
      
      double profitPercent = startingEquity > 0 ? profit / startingEquity * 100 : 0;
      FileWrite(fileHandle, "<tr><td>Profit %</td><td class='", profitClass, "'>", DoubleToString(profitPercent, 2), "%</td></tr>");
      
      FileWrite(fileHandle, "</table>");
      
      // Performance metrics
      FileWrite(fileHandle, "<h2>Performance Metrics</h2>");
      FileWrite(fileHandle, "<table>");
      FileWrite(fileHandle, "<tr><th>Metric</th><th>Value</th></tr>");
      FileWrite(fileHandle, "<tr><td>Total Trades</td><td>", IntegerToString(totalTradesReport), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Winning Trades</td><td>", IntegerToString(winningTrades), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Losing Trades</td><td>", IntegerToString(losingTrades), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Win Rate</td><td>", DoubleToString(winRate, 2), "%</td></tr>");
      FileWrite(fileHandle, "<tr><td>Profit Factor</td><td>", DoubleToString(profitFactor, 2), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Expectancy</td><td>", DoubleToString(expectancy, 2), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Risk/Reward Ratio</td><td>", DoubleToString(riskRewardRatio, 2), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Max Consecutive Wins</td><td>", IntegerToString(maxConsecutiveWins), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Max Consecutive Losses</td><td>", IntegerToString(maxConsecutiveLosses), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Largest Win</td><td class='positive'>", DoubleToString(largestWin, 2), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Largest Loss</td><td class='negative'>", DoubleToString(largestLoss, 2), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Average Win</td><td>", DoubleToString(averageWin, 2), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Average Loss</td><td>", DoubleToString(averageLoss, 2), "</td></tr>");
      FileWrite(fileHandle, "</table>");
      
      // EA Settings
      FileWrite(fileHandle, "<h2>EA Settings</h2>");
      FileWrite(fileHandle, "<table>");
      FileWrite(fileHandle, "<tr><th>Parameter</th><th>Value</th></tr>");
      FileWrite(fileHandle, "<tr><td>Magic Number</td><td>", IntegerToString(magicNumber), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Lot Size</td><td>", DoubleToString(lotSize, 2), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Use Auto Lot Size</td><td>", UseAutoLotSize ? "Yes" : "No", "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Risk Percent</td><td>", DoubleToString(RiskPercent, 2), "%</td></tr>");
      FileWrite(fileHandle, "<tr><td>Fast EMA</td><td>", IntegerToString(FastEMA), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Slow EMA</td><td>", IntegerToString(SlowEMA), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>RSI Period</td><td>", IntegerToString(RSIPeriod), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>RSI Overbought/Oversold</td><td>", IntegerToString(RSIOverbought), "/", IntegerToString(RSIOversold), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Take Profit</td><td>", IntegerToString(TakeProfit), " pips</td></tr>");
      FileWrite(fileHandle, "<tr><td>Stop Loss</td><td>", IntegerToString(StopLoss), " pips</td></tr>");
      FileWrite(fileHandle, "<tr><td>Use Trailing Stop</td><td>", UseTrailingStop ? "Yes" : "No", "</td></tr>");
      
      if(UseTrailingStop)
      {
         FileWrite(fileHandle, "<tr><td>Trailing Stop</td><td>", IntegerToString(TrailingStop), " pips</td></tr>");
         FileWrite(fileHandle, "<tr><td>Trailing Step</td><td>", IntegerToString(TrailingStep), " pips</td></tr>");
      }
      
      FileWrite(fileHandle, "<tr><td>Use Time Filter</td><td>", UseTimeFilter ? "Yes" : "No", "</td></tr>");
      
      if(UseTimeFilter)
      {
         FileWrite(fileHandle, "<tr><td>Trading Hours</td><td>", IntegerToString(StartHour), ":00 - ", IntegerToString(EndHour), ":00</td></tr>");
      }
      
      FileWrite(fileHandle, "<tr><td>Close All Friday</td><td>", CloseAllFriday ? "Yes" : "No", "</td></tr>");
      
      if(CloseAllFriday)
      {
         FileWrite(fileHandle, "<tr><td>Friday Close Hour</td><td>", IntegerToString(FridayCloseHour), ":00</td></tr>");
      }
      
      FileWrite(fileHandle, "<tr><td>Max Daily Trades</td><td>", IntegerToString(MaxDailyTrades), "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Max Daily Loss</td><td>", DoubleToString(MaxDailyLoss, 2), "%</td></tr>");
      FileWrite(fileHandle, "<tr><td>Max Spread</td><td>", DoubleToString(MaxSpread, 1), " pips</td></tr>");
      FileWrite(fileHandle, "</table>");
      
      // Advanced Features
      FileWrite(fileHandle, "<h2>Advanced Features</h2>");
      FileWrite(fileHandle, "<table>");
      FileWrite(fileHandle, "<tr><th>Feature</th><th>Status</th></tr>");
      FileWrite(fileHandle, "<tr><td>Adaptive Parameters</td><td>", UseAdaptiveParams ? "Enabled" : "Disabled", "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Machine Learning</td><td>", UseML ? "Enabled" : "Disabled", "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Market Regime Detection</td><td>", UseRegimeDetection ? "Enabled" : "Disabled", "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Historical Learning</td><td>", UseHistoricalData ? "Enabled" : "Disabled", "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Pattern Recognition</td><td>", UsePatternRecognition ? "Enabled" : "Disabled", "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Market Correlation</td><td>", UseCorrelation ? "Enabled" : "Disabled", "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Market Sentiment Analysis</td><td>", UseSentimentAnalysis ? "Enabled" : "Disabled", "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Trading Session Analysis</td><td>", UseSessionAnalysis ? "Enabled" : "Disabled", "</td></tr>");
      FileWrite(fileHandle, "<tr><td>Equity Curve Filter</td><td>", UseEquityCurveFilter ? "Enabled" : "Disabled", "</td></tr>");
      FileWrite(fileHandle, "</table>");
      
      // Adaptive Parameters (if enabled)
      if(UseAdaptiveParams)
      {
         FileWrite(fileHandle, "<h2>Current Adaptive Parameters</h2>");
         FileWrite(fileHandle, "<table>");
         FileWrite(fileHandle, "<tr><th>Parameter</th><th>Original Value</th><th>Adaptive Value</th></tr>");
         FileWrite(fileHandle, "<tr><td>Fast EMA</td><td>", IntegerToString(FastEMA), "</td><td>", DoubleToString(adaptiveFastEMA, 1), "</td></tr>");
         FileWrite(fileHandle, "<tr><td>Slow EMA</td><td>", IntegerToString(SlowEMA), "</td><td>", DoubleToString(adaptiveSlowEMA, 1), "</td></tr>");
         FileWrite(fileHandle, "<tr><td>RSI Overbought</td><td>", IntegerToString(RSIOverbought), "</td><td>", DoubleToString(adaptiveRSIOverbought, 1), "</td></tr>");
         FileWrite(fileHandle, "<tr><td>RSI Oversold</td><td>", IntegerToString(RSIOversold), "</td><td>", DoubleToString(adaptiveRSIOversold, 1), "</td></tr>");
         FileWrite(fileHandle, "<tr><td>Take Profit</td><td>", IntegerToString(TakeProfit), "</td><td>", DoubleToString(adaptiveTakeProfit, 1), "</td></tr>");
         FileWrite(fileHandle, "<tr><td>Stop Loss</td><td>", IntegerToString(StopLoss), "</td><td>", DoubleToString(adaptiveStopLoss, 1), "</td></tr>");
         FileWrite(fileHandle, "</table>");
      }
      
      // ML Information (if enabled)
      if(UseML && mlInitialized && tradeHistoryCount > 0)
      {
         FileWrite(fileHandle, "<h2>Machine Learning Insights</h2>");
         FileWrite(fileHandle, "<p>Trades analyzed: ", IntegerToString(tradeHistoryCount), "</p>");
         
         // Feature importance
         FileWrite(fileHandle, "<h3>Feature Importance</h3>");
         FileWrite(fileHandle, "<table>");
         FileWrite(fileHandle, "<tr><th>Feature</th><th>Weight</th></tr>");
         
         string featureNames[] = {"EMA Diff", "RSI", "ATR", "Spread", "Hour", "Day of Week", "Direction", 
                                 "MACD", "MACD Signal", "BB Position", "BB Width", "ADX", "Volume Change", 
                                 "Pattern", "Bias"};
         
         for(int i = 0; i < MathMin(ArraySize(mlWeights), ArraySize(featureNames)); i++)
         {
            string weightClass = mlWeights[i] >= 0 ? "positive" : "negative";
            FileWrite(fileHandle, "<tr><td>", featureNames[i], "</td><td class='", weightClass, "'>", DoubleToString(mlWeights[i], 3), "</td></tr>");
         }
         
         FileWrite(fileHandle, "</table>");
      }
      
      // Market Regime (if enabled)
      if(UseRegimeDetection)
      {
         FileWrite(fileHandle, "<h2>Current Market Regime</h2>");
         string regimeNames[] = {"Unknown", "Strong Trend (High Vol)", "Strong Trend (Low Vol)", 
                                "Tight Range", "Volatile Range", "Quiet Range"};
         
         FileWrite(fileHandle, "<p>Regime: ", regimeNames[currentRegime], "</p>");
         FileWrite(fileHandle, "<p>Volatility: ", DoubleToString(regimeVolatility, 2), "</p>");
      }
      
      // Report footer
      FileWrite(fileHandle, "<hr>");
      FileWrite(fileHandle, "<p><em>Report generated by ScalpingMaster EA on ", TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES), "</em></p>");
      FileWrite(fileHandle, "</body>");
      FileWrite(fileHandle, "</html>");
      
      FileClose(fileHandle);
      Print("Performance report saved to ", reportFile);
   }
   else
   {
      Print("Error creating report file: ", GetLastError());
   }
   }
}

//+------------------------------------------------------------------+
//| Helper function to convert period to string                       |
//+------------------------------------------------------------------+
string CustomPeriodToString(int period)
{
   switch(period)
   {
      case PERIOD_M1:  return "M1";
      case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
      default:         return IntegerToString(period);
   }
}

//+------------------------------------------------------------------+
//| Calculate position size based on risk                            |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   if(!UseAutoLotSize) return lotSize;
   
   double riskAmount = AccountBalance() * RiskPercent / 100;
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double stopLossPips = UseAdaptiveParams ? adaptiveStopLoss : StopLoss;
   
   // Calculate lot size based on risk
   double calculatedLot = riskAmount / (stopLossPips * tickValue * 10);
   
   // Round to broker lot step
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   calculatedLot = MathFloor(calculatedLot / lotStep) * lotStep;
   
   // Apply min/max limits
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   calculatedLot = MathMax(minLot, MathMin(maxLot, calculatedLot));
   
   // Add XAUUSD adjustment
   if(Symbol() == "XAUUSD" || Symbol() == "GOLD" || Symbol() == "XAU/USD") 
   {
      calculatedLot = calculatedLot / 10; // Reduce lot size for gold due to higher value
   }
   
   return calculatedLot;
}



//+------------------------------------------------------------------+
//| End of ScalpingMaster EA                                         |
//+------------------------------------------------------------------+

