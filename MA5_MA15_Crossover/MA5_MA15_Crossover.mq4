//+------------------------------------------------------------------+
//|                                                       MA_TBO.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int OnInit()
    {
        return INIT_SUCCEEDED;
    }
void OnDeinit(const int reason)
    {
        // Remove the drawing object when the indicator is removed from the chart
        ObjectDelete("MovingAverage");
    }

// Input
double lotSize = 0.01;

// State (do not disturb)
int buyTicket = 0;
int sellTicket = 0;
bool tradeOngoing = false;

void OnTick()
    {
        double maRed = iMA(_Symbol, _Period, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
        double maGreen = iMA(_Symbol, _Period, 15, 0, MODE_EMA, PRICE_CLOSE, 0);
        Comment(1+Point);
        
        if (tradeOngoing == false) {
            if (maGreen < maRed) { 
                buyTicket = OrderSend(_Symbol, OP_BUY, lotSize, Ask, 10, 0, 0, "MA_TBO", 8008);
                tradeOngoing = true;
            } 
            else if (maGreen > maRed) {
                sellTicket = OrderSend(_Symbol, OP_SELL, lotSize, Bid, 10, 0, 0, "MA_TBO", 8008);
                tradeOngoing = true;
            }
        }

        if (tradeOngoing == true) {
            if (buyTicket != 0) {
                if (maGreen > maRed) {
                    CloseOrder(buyTicket);
                    buyTicket = 0;
                    tradeOngoing = false;
                }
            }
            else if (sellTicket != 0) {
                if (maGreen < maRed) {
                    CloseOrder(sellTicket);
                    sellTicket = 0;
                    tradeOngoing = false;
                }
            }
        }
    }

//+------------------------------------------------------------------+

void CloseOrder(int pTicket)
{
    while(IsTradeContextBusy())
    {
        Sleep(50);
    }

    if(OrderSelect(pTicket, SELECT_BY_TICKET))
    {
        double lots = OrderLots();
        double price = 0;
        if(OrderType() == OP_BUY) price = Bid;
        else if(OrderType() == OP_SELL) price = Ask;
        
        bool closed = OrderClose(pTicket, lots, price, 100);
        
        if(!closed) Alert("Trade no closed: ", pTicket);
    }
}