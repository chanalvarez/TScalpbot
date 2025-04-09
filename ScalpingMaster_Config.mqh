//+------------------------------------------------------------------+
//|                                    ScalpingMaster_Config.mqh      |
//|                                          Copyright 2023, TraeAI   |
//|                                                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, TraeAI"
#property link      ""
#property strict

// Default configuration values for ScalpingMaster EA
// These can be overridden by input parameters

// Risk Management Defaults
#define DEFAULT_RISK_PERCENT 1.0
#define DEFAULT_MAX_RISK_PERCENT 3.0
#define DEFAULT_MIN_RISK_PERCENT 0.5
#define DEFAULT_LOT_SIZE 0.1
#define DEFAULT_TAKE_PROFIT 20
#define DEFAULT_STOP_LOSS 15
#define DEFAULT_TRAILING_STOP 25
#define DEFAULT_TRAILING_STEP 5
#define DEFAULT_MAX_SPREAD 5.0
#define DEFAULT_MAX_DAILY_TRADES 10
#define DEFAULT_MAX_DAILY_LOSS 5.0

// Strategy Parameters Defaults
#define DEFAULT_FAST_EMA 8
#define DEFAULT_SLOW_EMA 21
#define DEFAULT_RSI_PERIOD 14
#define DEFAULT_RSI_OVERBOUGHT 70
#define DEFAULT_RSI_OVERSOLD 30

// Time Filter Defaults
#define DEFAULT_START_HOUR 8
#define DEFAULT_END_HOUR 20
#define DEFAULT_FRIDAY_CLOSE_HOUR 16

// Advanced Features Defaults
#define DEFAULT_ADAPTIVE_RATE 0.1
#define DEFAULT_SESSION_ADJUSTMENT 0.2
#define DEFAULT_SENTIMENT_THRESHOLD 0.3
#define DEFAULT_SENTIMENT_PERIOD 20
#define DEFAULT_MIN_CORRELATION 0.7
#define DEFAULT_EQUITY_CURVE_PERIOD 50
#define DEFAULT_EQUITY_CURVE_THRESHOLD 0.1
#define DEFAULT_ML_UPDATE_FREQUENCY 20
#define DEFAULT_HISTORICAL_DAYS 30
#define DEFAULT_MIN_HISTORICAL_TRADES 100

// File Paths
#define DEFAULT_REPORT_FILE_PATH "Reports"