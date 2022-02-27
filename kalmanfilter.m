%%%%%%%%%
%%% FILTRATION
%%%%%%%%%
close all; 
clear all;

%% Data sample
sdate = qq(1996,1);   %qq(1999,1);
edate = qq(2021,4);   %qq(2021,3);   %qq(2018,3);

%% Reads the model
[m,p,mss] = readmodel(true)

%% Set variances for Kalman filtration
%% stds of shocks
Calibration
p.std_SHK_L_GDP_GAP  = std_L_GDP_20;      %0.441321522386604;%std_L_GDP_20;     %% 1;
p.std_SHK_RS_UNC     = std_RS_20;%1.220031966688612;%std_RS_20;%std_RS_20;        %% 1;

p.std_SHK_DLA_CPIXFE = std_DLA_CPIXFE_20;%1.574272819150997;%std_DLA_CPIXFE_20;%% 0.75;   
p.std_SHK_DLA_CPIE   = std_DLA_CPIE_20;%4.689794039749317;%std_DLA_CPIE_20;  %%15;     
p.std_SHK_DLA_CPIF   = std_DLA_CPI_F_20;%6.197800615667861;%std_DLA_CPI_F_20; %%4;      
p.std_SHK_L_CPI      = std_DLA_CPI_20;%2.277830289329865;%std_DLA_CPI_20;   %%15;     
p.std_SHK_L_S        = std_L_S_20;%9.878708145661536;%std_L_S_20;       %%3;
% 
p.std_SHK_D4L_CPI_TAR = std_D4L_CPI_20;     %0.569457572332466;%2;               %%1.3; 
p.std_SHK_DLA_GDP_BAR = std_DLA_GDP_BAR_20; %0.110330380596651;%std_DLA_GDP_BAR_20;%%0.5;
p.std_SHK_DLA_Z_BAR   = std_DLA_Z_BAR_20;   %3.191114460368246;%%0.5;    
p.std_SHK_RR_BAR      = std_RR_BAR_20;      %0.972602276586631;%std_RR_BAR_20;   %%0.3;    
p.std_SHK_DLA_S_TAR   = std_SHK_DLA_S_TAR;%0.01;%1;      

p.std_SHK_PREM        = std_SHK_PREM;% 0.6587149473;%1; 
p.std_SHK_CR_PREM     = std_SHK_CR_PREM;%0.6587149473;%1; 

p.std_SHK_L_GDP_RW_GAP  = std_L_GDP_RW_20;%0.073380304964615;%std_L_GDP_RW_20; %% 1;
p.std_SHK_RS_RW         = std_RS_RW_20;    %2.5; %% 1;
p.std_SHK_RR_RW_BAR     = std_RR_RW_BAR_20;%%0.5;
p.std_SHK_DLA_CPI_RW    = std_DLA_CPI_RW_20;  %% 2;
p.std_SHK_DLA_S_CROSS   = std_SHK_DLA_S_CROSS;%25; %% 25;

p.std_SHK_DLA_RWFOOD_BAR = std_SHK_DLA_RWFOOD_BAR;%10;%%10;
p.std_SHK_L_RWFOOD_GAP   = std_SHK_L_RWFOOD_GAP;%25;%%25;
p.std_SHK_DLA_RWOIL_BAR  = std_SHK_DLA_RWOIL_BAR;%10;%%10;
p.std_SHK_L_RWOIL_GAP    = std_SHK_L_RWOIL_GAP;%25;%%25;

% p.std_SHK_DLA_RPF_BAR   = std_SHK_DLA_RPF_BAR;%1.5; 
% p.std_SHK_DLA_RPXFE_BAR = std_SHK_DLA_RPXFE_BAR;%1;
p.std_SHK_DLA_RPF_BAR   = std_SHK_DLA_RPF_BAR_20;%1.5; 
p.std_SHK_DLA_RPXFE_BAR = std_SHK_DLA_RPXFE_BAR_20;%1;
% 
% m = assign(m,p);
% m = solve(m);

%% Load data
%d = dbload('history.csv');
d = databank.fromCSV('history.csv');

dhist=d;

dd.OBS_L_CPI        = d.L_CPI;
dd.OBS_L_CPIF       = d.L_CPIF;
dd.OBS_L_CPIE       = d.L_CPIE;
dd.OBS_L_CPIXFE     = d.L_CPIXFE;
dd.OBS_L_GDP        = d.L_GDP;
dd.OBS_L_S          = d.L_S;
dd.OBS_RS           = d.RS;
dd.OBS_RS_RW        = d.RS_RW;
dd.OBS_L_CPI_RW     = d.L_CPI_RW;
dd.OBS_L_WFOOD      = d.L_WFOOD;
dd.OBS_L_WOIL       = d.L_WOIL;
dd.OBS_L_S_CROSS    = d.L_S_CROSS;
dd.OBS_L_GDP_RW_GAP = d.L_GDP_RW_GAP;
dd.OBS_D4L_CPI_TAR  = d.D4L_CPI_TAR;
dd.OBS_RR_RW_BAR    = d.RR_RW_BAR;

%% expert tunes
dd.OBS_L_GDP_BAR    = tseries();
dd.OBS_L_Z_BAR      = tseries();
dd.OBS_RR_BAR       = tseries();
dd.OBS_L_RPE_GAP    = tseries();
dd.OBS_L_GDP_BAR    = tseries();
dd.OBS_L_Z_BAR      = tseries(); %%dd.OBS_L_Z_BAR(sdate:qq(2007,4))   = d.L_Z_BAR(sdate:qq(2007,4));
dd.OBS_L_Z_BAR      = tseries(); %%dd.OBS_L_Z_BAR(qq(2013,4))      = d.L_Z - 3; 
dd.OBS_RR_BAR       = tseries();
dd.OBS_L_RWFOOD_BAR = d.L_RWFOOD_BAR;
dd.OBS_L_RWOIL_BAR  = d.L_RWOIL_BAR;
dd.OBS_L_RPE_GAP  = tseries();

%% Filtration
[m_kf,g,v,delta,pe] = filter(m,dd,sdate:edate);

h = g.mean;
d = dbextend(d,h);
d.D4L_GDP_BAR = tseries(qq(2020,1):qq(2020,4), [0.021991, 0.004247, -0.005128, -0.009487]); % prior for the EA gap

%% Save the database
% Database is saved in file 'kalm_his.mat'
%dbsave(d,'kalm_his.csv');
databank.toCSV(d,'kalm_his.csv');

% return;

%% Graphs
% Specify country
country = 'The Czech Republic - Filtration';

% Report
x = report.new(country,'visible',true);

% Figures
rng = sdate:edate;
sty = struct();
sty.line.linewidth = 1.5;
sty.line.linestyle = {'-';'--'};
% sty.line.color = {'k';'r'};
sty.axes.box = 'off';
sty.legend.location='Best';

% Output Gap
x.figure('Output Gap','subplot',[3,2],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('GDP, 100*log','legend',false);
x.series('',[d.L_GDP d.L_GDP_BAR]);

x.graph('GDP Growth qoq, percent annualized','legend',true);
x.series('',[d.DLA_GDP d.DLA_GDP_BAR],'legend',{'Actual', 'Trend'});

x.graph('Output Gap, percent','legend',false);
x.series('',[d.L_GDP_GAP]);

x.graph('Foreign GDP Gap, percent','legend',false);
x.series('',[d.L_GDP_RW_GAP]);

x.graph('MCI, percent','legend',true);
x.series('', [d.b4.*d.RR_GAP, d.b4.*d.CR_PREM, (1-d.b4).*(-d.L_Z_GAP)], 'legend', {'RR Gap', 'CR Prem', 'L Z GAP'}, 'plotfunc', @conbar);
x.series('MCI',[d.MCI]);

% Output gap decompostion          
x.figure('Output Gap Decomposition','subplot',[2,1],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Output Gap, percent','legend',true);
x.series('Actual', d.L_GDP_GAP);
x.series('Predicted', d.L_GDP_GAP-d.SHK_L_GDP_GAP);

x.graph('Output Gap Decomposition, pp','legend',true);
x.series('',[d.b1.*d.L_GDP_GAP{-1}, -d.b2.*d.b4.*d.RR_GAP,-d.b2.*d.b4.*d.CR_PREM, d.b2.*(1-d.b4).*d.L_Z_GAP, d.b3.*d.L_GDP_RW_GAP, d.SHK_L_GDP_GAP], ... 
            'legend=', {'Lag', 'RIR Gap', 'CR Prem', 'RER Gap', 'Foreign Gap', 'Shock'}, 'plotfunc', @conbar);

% RIR and RER      
sty.legend.location = 'NorthWest';
x.figure('Real Interest and Exchange Rates','subplot',[3,2],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Real Interest Rate, percent p.a.','legend',false);
x.series('',[d.RR d.RR_BAR]);

x.graph('Risk Premium, percent p.a.','legend',false);
x.series('',[d.PREM]);

x.graph('Real Exchange Rate, 100*log','legend',false);
x.series('',[d.L_Z d.L_Z_BAR]);

x.graph('Eq. Real Exchange Rate Apprec., percent','legend',false);
x.series('',[d.DLA_Z d.DLA_Z_BAR]);

x.graph('RER Decomposition, pp','legend',true);
x.series('',[d.DLA_S, -d.DLA_CPI, d.DLA_CPI_RW], ... 
            'legend=', {'Nom. ER', 'Domestic Infl.', 'RW Infl.'}, 'plotfunc', @conbar);

x.graph('RER Gap, percent','legend',false);
x.series('',[d.L_Z_GAP]);


% Inflation
sty.legend.location = 'Best';
x.figure('Inflation','subplot',[3,2],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Headline Inflation, percent','legend',true);
x.series('qoq',[d.DLA_CPI]);
x.series('yoy',[d.D4L_CPI]);

x.graph('Inflation Target, percent','legend',true);
x.series('yoy',[d.D4L_CPI]);
x.series('D4L CPI TAR',[d.D4L_CPI_TAR]);

x.graph('Core Inflation, percent','legend',false);
x.series('qoq',[d.DLA_CPIXFE]);
x.series('yoy',[d.D4L_CPIXFE]);

x.graph('Food Price Inflation, percent','legend',false);
x.series('qoq',[d.DLA_CPIF]);
x.series('yoy',[d.D4L_CPIF]);

x.graph('Energy Price Inflation, percent','legend',false);
x.series('qoq',[d.DLA_CPIE]);
x.series('yoy',[d.D4L_CPIE]);

% Inflation decomposition --  Core Inflation
x.figure('Core Inflation','subplot',[3,1],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Core Inflation qoq, percent','legend',true);
x.series('Actual',d.DLA_CPIXFE);
x.series('Predicted',d.DLA_CPIXFE-d.SHK_DLA_CPIXFE);

x.graph('Core Inflation and Marginal Costs, percent','legend',true);
x.series('Core Inflation (de-mean)',d.DLA_CPIXFE-mean(d.DLA_CPIXFE));
x.series('RMC', d.RMC);

x.graph('Marginal Cost Decomposition -- Core Infl., pp','legend',true);
x.series('',[d.a3.*d.L_GDP_GAP, (1-d.a3).*d.L_Z_GAP, -(1-d.a3).*d.L_RPXFE_GAP], 'legend=', {'Output Gap', 'RER Gap', 'Rel. Prices'}, 'plotfunc', @conbar);
x.series('RMC', d.RMC);

% Inflation decomposition -- Food
x.figure('Food Price Inflation','subplot',[3,1],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Food Price Inflation qoq, percent','legend',true);
x.series('Actual',d.DLA_CPIF);
x.series('Predicted',d.DLA_CPIF-d.SHK_DLA_CPIF);

x.graph('Food Price Inflation and Marginal Costs, percent','legend',true);
x.series('Food Price Inflation (de-mean)',d.DLA_CPIF-mean(d.DLA_CPIF));
x.series('RMC F', d.RMC_F);

x.graph('Marginal Cost Decomposition -- Food Price Infl., pp','legend',true);
x.series('',[d.a23.*d.L_RWFOOD_GAP, d.a23.*d.L_Z_GAP, -d.a23.*d.L_RPF_GAP, (1-d.a23).*d.L_GDP_GAP], 'legend=', {'L RWFOOD Gap', 'RER Gap', 'Rel. Price Gap', 'Output Gap'}, 'plotfunc', @conbar);
x.series('RMC F', d.RMC_F);

% Inflation decomposition -- Energy
x.figure('Energy Price Inflation','subplot',[3,1],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Energy Price Inflation qoq, percent','legend',true);
x.series('Actual',d.DLA_CPIE);
x.series('Predicted',d.DLA_CPIE-d.SHK_DLA_CPIE);

x.graph('Energy Price Inflation and Marginal Costs, percent','legend',true);
x.series('Energy Price Inflation (de-mean)',d.DLA_CPIE-mean(d.DLA_CPIE));
x.series('RMC E', d.RMC_E);

x.graph('Marginal Cost Decomposition -- Energy Price Infl., pp','legend',true);
x.series('',[d.L_RWOIL_GAP, d.L_Z_GAP, -d.L_RPE_GAP], 'legend=', {'L RWOIL Gap', 'RER Gap', 'Rel. Price Gap'}, 'plotfunc', @conbar);
x.series('RMC E', d.RMC_E);

% Interest rate decomposition   
sty.legend.location = 'NorthEast';
x.figure('Interest Rate Path','subplot',[2,1],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Nom. Interest Rate, percent','legend',true);
x.series('Actual', d.RS);
x.series('Predicted', d.RS-d.SHK_RS_UNC);

x.graph('RF Decomposition, pp','legend',true);
x.series('',[d.g1.*d.RS{-1}, (1-d.g1).*d.RSNEUTRAL, (1-d.g1).*d.g2.*d.D4L_CPI_DEV, (1-d.g1).*d.g3.*d.L_GDP_GAP], ... 
            'legend=', {'Smoothing', 'IR Neutral', 'Exp. Infl. Dev', 'Output Gap'}, 'plotfunc', @conbar);

x.figure('Relative Prices', 'subplot', [3,1], 'style', sty, 'range', rng);

x.graph('Relative Price -- L_RPXFE, 100*log','legend',true);
x.series('',[d.L_RPXFE d.L_RPXFE_BAR],'Legend',{'Level', 'Trend'});

x.graph('Relative Price -- L_RPF, 100*log','legend',false);
x.series({'Level', 'Trend'},[d.L_RPF d.L_RPF_BAR]);

x.graph('Relative Price -- L_RPE, 100*log','legend',false);
x.series({'Level', 'Trend'},[d.L_RPE d.L_RPE_BAR]);

x.pagebreak();

sty.legend.location = 'Best';
x.figure('Foreign Variables', 'subplot', [3,2], 'style', sty, 'range', rng);

x.graph('Foreign Nom. Interest Rate, % pa','legend',false);
x.series('',[d.RS_RW]);

x.graph('Foreign CPI Inflation, %','legend',true);
x.series('',[d.DLA_CPI_RW, d.D4L_CPI_RW],'legend',{'QoQ', 'YoY'});

x.graph('Foreign Real Rate, %','legend',true);
x.series('',[d.RR_RW, d.RR_RW_BAR],'legend',{'Level', 'Trend'});

x.graph('Foreign Real GDP Growth, %','legend',true);
x.series('',[d.DLA_GDP_RW, d.D4L_GDP_RW],'legend',{'QoQ', 'YoY'});

x.graph('YoY Foreign Real GDP Growth, %','legend',true);
x.series('',[d.D4L_GDP_RW, d.D4L_GDP_RW_BAR],'legend',{'Actual', 'Trend'});

x.graph('Foreign Output Gap, %','legend',false);
x.series('',[d.L_GDP_RW_GAP]);

x.pagebreak();

sty.legend.location = 'SouthEast';

x.figure('Foreign Variables (cont.)', 'subplot', [2,2], 'style', sty, 'range', rng);

x.graph('World Oil Price Inflation, %','legend',true);
x.series('',[d.DLA_WOIL, d.D4L_WOIL],'legend',{'QoQ', 'YoY'});

x.graph('World Food Price Inflation, %','legend',true);
x.series('',[d.DLA_WFOOD, d.D4L_WFOOD],'legend',{'QoQ', 'YoY'});

x.graph('R.P. of Oil to US CPI, 100*log','legend',true);
x.series('',[d.L_RWOIL d.L_RWOIL_BAR],'legend',{'Level', 'Trend'});

x.graph('R.P. of Food to US CPI, 100*log','legend',true);
x.series('',[d.L_RWFOOD d.L_RWFOOD_BAR],'legend',{'Level', 'Trend'});

x.pagebreak();

% Residuals
x.figure('Structural Shocks','subplot',[3,2],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Core Inflation','legend',false);
x.series('',[d.SHK_DLA_CPIXFE]);

x.graph('Food Price Inflation','legend',false);
x.series('',[d.SHK_DLA_CPIF]);

x.graph('Energy Price Inflation','legend',false);
x.series('',[d.SHK_DLA_CPIE]);

x.graph('Demand Shock','legend',false);
x.series('',[d.SHK_L_GDP_GAP]);

x.graph('Interest Rate','legend',false);
x.series('',[d.SHK_RS_UNC]);

x.graph('Exchange Rate','legend',false);
x.series('',[d.SHK_L_S]);

x.publish('Filtration','display',false);
disp('Done!!!');