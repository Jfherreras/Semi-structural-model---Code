%% Compute Calibration 
% clear all; close all; clc;

d = dbload('history.csv');

%% Standard deviation
% Results that use "_10" or "_20" uses data 10 or 20 years ago.

%% Domestic Calibration
% Output gap shock: 1/2 of stand
    std_L_GDP    = std(d.DLA_GDP/4)/2;
    std_L_GDP_10 = std(d.DLA_GDP(qq(2009,1):qq(2019,4))/4)/2;
    std_L_GDP_20 = std(d.DLA_GDP(qq(1999,1):qq(2019,4))/4)/2;
    
% Trend GDP
    std_DLA_GDP_BAR    = std_L_GDP/4;  % No debería ser 1/4 del output gap shock? std(std(d-DLAGDP/4)/2)/4
    std_DLA_GDP_BAR_10 = std_L_GDP_10/4;
    std_DLA_GDP_BAR_20 = std_L_GDP_20/4;

% Core inflation Cost-Push Shock
    std_DLA_CPIXFE     = std(d.DLA_CPIXFE)/2;
    std_DLA_CPIXFE_10  = std(d.DLA_CPIXFE(qq(2009,1):qq(2019,4)))/2;
    std_DLA_CPIXFE_20  = std(d.DLA_CPIXFE_U((qq(1999,1):qq(2019,4))))/2;

% Food inflation Cost-Push Shock
    std_DLA_CPI_F      = std(d.DLA_CPIF)/2;
    std_DLA_CPI_F_10   = std(d.DLA_CPIF(qq(2009,1):qq(2019,4)))/2;
    std_DLA_CPI_F_20   = std(d.DLA_CPIF((qq(1999,1):qq(2019,4))));

% Regulated inflation Cost-Push Shock
    std_DLA_CPIE       = std(d.DLA_CPIE)/2;
    std_DLA_CPIE_10    = std(d.DLA_CPIE(qq(2009,1):qq(2019,4)))/2;
    std_DLA_CPIE_20    = std(d.DLA_CPIE((qq(1999,1):qq(2019,4))));
    
% Headline inflation Cost-Push Shock
    std_DLA_CPI        = std(d.DLA_CPI)/2;
    std_DLA_CPI_10     = std(d.DLA_CPI(qq(2009,1):qq(2019,4)))/2;
    std_DLA_CPI_20     = std(d.DLA_CPI((qq(1999,1):qq(2019,4))));

% YoY Headline inflation Cost-Push Shock
    std_D4L_CPI        = std(d.DLA_CPI/4)/2;
    std_D4L_CPI_10     = std(d.DLA_CPI(qq(2009,1):qq(2019,4))/4)/2;
    std_D4L_CPI_20     = std(d.DLA_CPI((qq(1999,1):qq(2019,4)))/4);
     
% Monetary policy Shock
    std_RS             = std(d.RS)/3;
    std_RS_10          = std(d.RS(qq(2009,1):qq(2019,4)))/3;
    std_RS_20          = std(d.RS((qq(1999,1):qq(2019,4))))/3;

% Neutral Real Interest Rate
    std_RR_BAR         = std_RS/3;
    std_RR_BAR_10      = std_RS_10/3;
    std_RR_BAR_20      = std_RS_20/3;
    
% UIP Shock    
    std_L_S            = std(d.L_S)/2;
    std_L_S_10         = std(d.L_S(qq(2009,1):qq(2019,4)))/2;
    std_L_S_20         = std(d.L_S((qq(1999,1):qq(2019,4))))/2;
    
% Equilibrium RER Shock    
    std_DLA_Z_BAR      = std_L_S/5;
    std_DLA_Z_BAR_10   = std_L_S_20/5;
    std_DLA_Z_BAR_20   = std_L_S_20/5;
    
%% Foreign Calibration    
% Foreign Output Gap
    std_L_GDP_RW    = std(d.DLA_GDP_RW/4)/2;
    std_L_GDP_RW_10 = std(d.DLA_GDP_RW(qq(2009,1):qq(2019,4))/4)/2;
    std_L_GDP_RW_20 = std(d.DLA_GDP_RW(qq(1999,1):qq(2019,4))/4)/2;
    
% Trend Foreign GDP bar
    std_DLA_GDP_RW_BAR    = std_L_GDP_RW/4;
    std_DLA_GDP_RW_BAR_10 = std_L_GDP_RW_10/4;
    std_DLA_GDP_RW_BAR_20 = std_L_GDP_RW_20/4;
    
% Foreign Nominal Interest Rate
    std_RS_RW             = std(d.RS_RW)/3;
    std_RS_RW_10          = std(d.RS_RW(qq(2009,1):qq(2019,4)))/3;
    std_RS_RW_20          = std(d.RS_RW((qq(1999,1):qq(2019,4))))/3;
    
% Neutral Real Interest Rate
    std_RR_RW_BAR         = std_RS_RW/3;
    std_RR_RW_BAR_10      = std_RS_RW_10/3;
    std_RR_RW_BAR_20      = std_RS_RW_20/3; 
    
% Headline foreign inflation Cost-Push Shock
    std_DLA_CPI_RW = std(d.DLA_CPI_RW)/2;
    std_DLA_CPI_RW_10 = std(d.DLA_CPI_RW(qq(2009,1):qq(2019,4)))/2;
    std_DLA_CPI_RW_20 = std(d.DLA_CPI_RW((qq(1999,1):qq(2019,4))))/2;
    %% 
% Calibración JF

std_SHK_DLA_S_TAR      = std(d.DLA_S)/2;%0.01;%1;      

std_SHK_PREM           = 0.1317429895/2; % Sacado de la serie 2003Q1-2021Q4 a mano
std_SHK_CR_PREM        = 0.1317429895/2; 


std_SHK_DLA_S_CROSS    = std(d.DLA_S/4)/2;%25; %% 25;

std_SHK_DLA_RWFOOD_BAR = std(d.DLA_RWFOOD/4)/8;%10;%%10;
std_SHK_DLA_RWFOOD_BAR_20 = std(d.DLA_RWFOOD(qq(1999,1):qq(2017,3))/4)/2;
std_L_RPF_20 = std(d.L_RPF(qq(1999,1):qq(2019,4))/4)/2;
std_SHK_L_RWFOOD_GAP   = std(d.L_RWFOOD_GAP)/4;%%25;
std_SHK_DLA_RWOIL_BAR  = std(d.DLA_RWOIL_BAR/4)/2;%10;%%10;
std_SHK_DLA_RWOIL_BAR_20 = std(d.DLA_RWOIL(qq(1999,1):qq(2017,3))/4)/2;
std_SHK_L_RWOIL_GAP    = std(d.L_RWOIL_GAP)/4;%25;%%25;

std_SHK_DLA_RPF_BAR    = std(d.DLA_RPF_BAR/4)/2;%1.5; 1/4 de la sd del shock gap
std_SHK_DLA_RPXFE_BAR  = std(d.DLA_RPXFE_BAR/4)/2;%1;
    
% Alternativa

std_L_RPF              = std(d.L_RPF/4)/2;
std_L_RPXFE            = std(d.L_RPXFE/4)/2;

std_SHK_DLA_RPF_BAR2   = std_L_RPF/4;
std_SHK_DLA_RPXFE_BAR2 = std_L_RPXFE/4;

std_L_RPF_20 = std(d.L_RPF(qq(1999,1):qq(2019,4))/4)/2;
std_L_RPXFE_20 = std(d.L_RPXFE(qq(1999,1):qq(2019,4))/4)/2;

std_SHK_DLA_RPF_BAR_20   = std_L_RPF_20/4;
std_SHK_DLA_RPXFE_BAR_20 = std_L_RPXFE_20/4;
   