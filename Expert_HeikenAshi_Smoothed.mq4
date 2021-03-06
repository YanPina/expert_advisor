//+------------------------------------------------------------------+
//|                                   Expert_HeikenAshi_Smoothed.mq4 |
//|                                                      By Yan Pina |
//+------------------------------------------------------------------+
#property copyright "By Yan Pina"

extern string Indicadores =  "=======Configuração HeikenAshi Smoothed=======";
extern double MaPeriod            = 6;
extern double MaPeriod2           = 2;

extern string TimeToTrade= "Defina o horário de iniciar e parar os trades";
extern int Inicio= 9;//Horário do servidor
extern int Encerramento= 22;//Horário do servidor
      
extern string TS= "============TAKE -- STOP -- LOTS============";
extern double TakeProfit              = 100;
extern double StopLoss                = 100;
extern double Lots                    = 0.01;
extern string TravarNo0   = "========= Travar Ordem no 0 ==========";
extern double TirarRisco              = 50;
extern string PontosLucro = "Pontos de lucro acima da linha de entrada";
extern double PontosDeLucro           = 5;
extern int    MagicNumber = 1234;


//====================================================================================================// 

void OnTick()
  {

      //Informações da conta
      double SaldoConta=AccountInfoDouble(ACCOUNT_BALANCE);
      double Profit=AccountInfoDouble(ACCOUNT_PROFIT);
      
//====================================================================================================//
      //Definindo o sinal do Heiken Ashi Smoothed
      string sinal="";

//====================================================================================================//
            //Definindo o Heiken Ashi Smoothed
      
         double haOpen = iCustom(_Symbol,_Period,"Heiken_Ashi_Smoothed",2,MaPeriod,3,MaPeriod2,2,1);
         double haClose = iCustom(_Symbol,_Period,"Heiken_Ashi_Smoothed",2,MaPeriod,3,MaPeriod2,3,1);
         
//====================================================================================================//
            //Definindo os sinais de compra e venda
            
         if(haOpen < haClose) 
            sinal="Compra";

         
         if(haOpen > haClose)
            sinal="Venda";
            
            
//====================================================================================================//

      //Definindo os horários de negociação e Executando ordens de compra e venda
      if(Hour() >= Inicio && Hour() < Encerramento)
      {
         ChartSetInteger(0,CHART_COLOR_BACKGROUND,clrLightGreen);
           // Comprando
            if (sinal=="Compra" && OrdersTotal()==0)
           {
         OrderSend (_Symbol,OP_BUY,Lots,Ask,3,Ask-StopLoss*_Point,Ask+TakeProfit*_Point,MagicNumber,0,Green);
           }
             
         //Vendendo
           if (sinal=="Venda" && OrdersTotal()==0)
           {
         OrderSend (_Symbol,OP_SELL,Lots,Bid,3,Bid+StopLoss*_Point,Ask-TakeProfit*_Point,MagicNumber,0,Red);
           }
       }
      else ChartSetInteger(0,CHART_COLOR_BACKGROUND,clrTomato);


     
     
//====================================================================================================//
    //Fechando a ordem caso o Heiken Ashi Smoothed mude o sinal

    
    for (int i=OrdersTotal(); i>=0;i--)
    {
      //Selecionado a ordem
      if (OrderSelect(i,SELECT_BY_POS)==true)
      
      
      //Selecionando a ordem atual no ativo atual e fechando as ordens de compra
      if (OrderType()==OP_BUY && sinal=="Venda")
      {
         OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_BID),10);
      }
      
            //Selecionando a ordem atual no ativo atual e fechando as ordens de venda
      if (OrderType()==OP_SELL && sinal=="Compra")
      {  
         OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_ASK),10);
      }
      
    }
    
//====================================================================================================//
    //Travando as Ordens no 0
   for(int b= OrdersTotal()-1;b>=0;b--)
      {
         if (OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
         
         if(OrderSymbol()==Symbol())
         
         //Se a ordem for Compra
         if(OrderType()==OP_BUY)
         
         if(OrderStopLoss()<OrderOpenPrice())
         
         if(Ask > OrderOpenPrice()+TirarRisco*_Point)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+PontosDeLucro*_Point, OrderTakeProfit(),0,CLR_NONE);
            }
         
         //Se a ordem for Venda
         if(OrderType()==OP_SELL)
         
         if(OrderStopLoss()>OrderOpenPrice())
         
         if(Bid < OrderOpenPrice()-TirarRisco*_Point)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-PontosDeLucro*_Point, OrderTakeProfit(),0,CLR_NONE);
            }
      }
//====================================================================================================//
         //Fechando as ordens no fechamento do periodo de negociação

    for (int f=OrdersTotal(); f>=0;f--)
    {
      //Selecionado a ordem
      if (OrderSelect(f,SELECT_BY_POS)==true)
      
      
      //Selecionando a ordem atual no ativo atual e fechando as ordens de compra
      if (OrderType()==OP_BUY && Hour() >= Encerramento)
      {
         OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_BID),10);
      }
      
            //Selecionando a ordem atual no ativo atual e fechando as ordens de venda
      if (OrderType()==OP_SELL && Hour() >= Encerramento)
      {  
         OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_ASK),10);
      }
      
    } 

//====================================================================================================//
     Comment("O sinal do Heiken Ashi Smoothed é: ",sinal,"\n","\n",
     "Saldo da Conta: ",SaldoConta,"\n",
     "Profit: ",Profit);
  }
