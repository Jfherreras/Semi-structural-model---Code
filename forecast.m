%%%%%%%%%%%
%% Forecast ...
%%%%%%%%%%%
close all;
clear all;

%% Read the model
[m,p,mss] = readmodel(false)

%% Load the the historical data from the file '.csv'
% You can choose whether your forecast will use the initital conditions
% using univariate filters (makedata.m) or the Kalman filter (kalmanfilter.m).
% However, it is recommended to use Kalman filter outcomes due to
% the robustness of initial state estimation.

% h = dbload('history.csv'); % makedata
% h = dbload('kalm_his.csv'); % kalman filter
h = databank.fromCSV('kalm_his.csv');

%% Define the time frame of the forecast
% Change the time frame depending on you data and forecast period!
startfcast = qq(2021,4); %qq(2018,4);
endfcast   = qq(2032,4); %qq(2021,4);
% fcastrange = startfcast:endfcast;

% startfcast = qq(1996,1); 
% endfcast   = qq(2019,4); 
fcastrange = startfcast:endfcast;

%% Command 'simulate' simulates the model 'm' based on the database 'h' over
% the forecast range 'fcastrange'. Results are written into the object 's'
%s = simulate(m, h, fcastrange, 'anticipate', false);

%% In the forecast simulation variables can be set as numbers (for instance
% for external development as opposed to automatically used AR(1) process). 
% These preset variables are in the historical database and they require 
% creation of a 'plan' for this variable. The command 'plan' creates plan 
% for model 'm' over the forecast horizon in the object 'simplan'. These
% variables must be marked using the command 'exogenize', while the residual
% used for equalizing the model equation for the fixed variable must be marked using
% command 'endogenize'. The forecast is simulated in a similar way as 
% without the fixing. See example below where external inflation 
% and external interest rates could be taken, say, from IMF's WEO or 
% Consensus Forecast. Be aware that you must specify exactly till when
% the data is available in the database and the fixed variables 
% have to be preset in the database. Do not uncomment the code below, it is
% just an example of command syntax.
%
% % xrange = startfcast:endfcast; 
% % simplan = plan(m,xrange);
% % simplan = exogenize(simplan,{'DLA_CPI_RW','RS_RW'},xrange);
% % simplan = endogenize(simplan,{'SHK_DLA_CPI_RW','SHK_RS_RW'},xrange);
% 
%% In case you use exact numbers for external variables, 
% i.e. foreing inflation, interest rate or oil prices, the object "simplan" created below has to be inserted
% into the command simulate. Make sure that line 31 is commented; uncomment line lines starting
% from line 57.

%% Simulate -- plain model simulation
%simplan = plan(m,startfcast:endfcast); %plan command creates an object with the name simplan (in setting up the use of tunes below)
%iris version 20211222
simplan = Plan.forModel(m,startfcast:endfcast,"Anticipate", false,'method', 'Condition'); 

% Specify the exogenize and endogenize commands for each variable, 
% paying attention to each variable periods

%% Q3 %%%%%%%%%%%%%%%%%%%%%
% % % Forecast short term     %        | 2021Q4      | 2022Q1      | 2022Q2      | 2022Q3      | 2022Q4
% h.L_GDP(startfcast:startfcast+4) = [1235.917134	   1236.975490	 1237.257812   1237.609386	 1238.016880];
% simplan = exogenize(simplan,startfcast:startfcast+4,{'L_GDP'});
% simplan = endogenize(simplan,startfcast:startfcast+7,{'SHK_L_GDP_GAP'});

% h.DLA_GDP_BAR = tseries(qq(2020,1):qq(2020,4), [0.021991, 0.004247, -0.005128, -0.009487]); % prior for the EA gap

% External variables ("the rest of the world") -- replace with values from GPM
% h.DLA_CPI_RW(startfcast:startfcast+7)   = [1.6, 1.5, 1.4, 1.4, 1.3, 1.7, 1.8, 1.7];
% h.RS_RW(startfcast:startfcast+7)        = [0, 0, 0, 0, 0, 0.25, 0.5, 0.5]; 
% h.L_GDP_RW_GAP(startfcast:startfcast+7) = [-0.8, -0.7, -0.5, -0.4, -0.5, -0.4, -0.3, -0.2]; 

% simplan = exogenize(simplan,startfcast:startfcast+7,{'DLA_CPI_RW'});
% simplan = exogenize(simplan,startfcast:startfcast+7,{'RS_RW'});
% simplan = exogenize(simplan,startfcast:startfcast+7,{'L_GDP_RW_GAP'});
% 
% simplan = endogenize(simplan,startfcast:startfcast+7,{'SHK_DLA_CPI_RW'});
% simplan = endogenize(simplan,startfcast:startfcast+7,{'SHK_RS_RW'});
% simplan = endogenize(simplan,startfcast:startfcast+7,{'SHK_L_GDP_RW_GAP'});
%%-----------------------------

% % cross exchange rate
% h.DLA_S_CROSS(startfcast:startfcast+7)  = [0, 0, 0, 0, 0, 0, 0, 0]; 
% simplan = exogenize(simplan,startfcast:startfcast+7,{'DLA_S_CROSS'});
% simplan = endogenize(simplan,startfcast:startfcast+7,{'SHK_DLA_S_CROSS'});

%% Q3 Additional part
%% Defining world food and oil prices -- GPM
% h.DLA_WFOOD(startfcast:startfcast+7) = [2.4, 2.0, 1.6, 1.2, 0.8, 0.4, 0.0, 0.0];
% h.DLA_WOIL(startfcast:startfcast+7)  = [-12.4, -9.4, -5.5, -6.2, -6.3, -6.6, -6.9, -6.4];
% % 
% for i=startfcast:startfcast+7
%     h.L_WFOOD(i)=h.L_WFOOD(i-1)+h.DLA_WFOOD(i)/4;
%     h.L_WOIL(i)=h.L_WOIL(i-1)+h.DLA_WOIL(i)/4;   
%     h.L_CPI_RW(i)=h.L_CPI_RW(i-1)+h.DLA_CPI_RW(i)/4;   
% end
% % 
% h.L_RWFOOD(startfcast:startfcast+7) = h.L_WFOOD(startfcast:startfcast+7) - h.L_S_CROSS(startfcast:startfcast+7) - h.L_CPI_RW(startfcast:startfcast+7);
% h.L_RWOIL(startfcast:startfcast+7)  = h.L_WOIL(startfcast:startfcast+7)  - h.L_S_CROSS(startfcast:startfcast+7) - h.L_CPI_RW(startfcast:startfcast+7);
% 
% simplan = exogenize(simplan,startfcast:startfcast+7,{'L_WFOOD'});
% simplan = exogenize(simplan,startfcast:startfcast+7,{'L_WOIL'});
% simplan = endogenize(simplan,startfcast:startfcast+7,{'SHK_L_RWFOOD_GAP'});
% simplan = endogenize(simplan,startfcast:startfcast+7,{'SHK_L_RWOIL_GAP'});
%%--------------------

%% Q4: NTF
% % Retrieve these values from previous Workshop on the NTF exercise 
% % core CPI inflation
% h.DLA_CPIXFE(startfcast:startfcast) = [3.24];
% simplan = exogenize(simplan,startfcast,{'DLA_CPIXFE'});
% simplan = endogenize(simplan,startfcast,{'SHK_DLA_CPIXFE'});
% %  
% % % food CPI inflation
% h.DLA_CPIF(startfcast:startfcast) = [0.25];
% simplan = exogenize(simplan,startfcast:startfcast,{'DLA_CPIF'});
% simplan = endogenize(simplan,startfcast:startfcast,{'SHK_DLA_CPIF'});
% %  
% % % Energy price CPI inflation
% h.DLA_CPIE(startfcast:startfcast) = [9.78];
% simplan = exogenize(simplan,startfcast:startfcast,{'DLA_CPIE'});
% simplan = endogenize(simplan,startfcast:startfcast,{'SHK_DLA_CPIE'});
%------------------------------

%% expert judgments

%% simulate/forecast with the plan
% s = simulate(m, h, fcastrange, 'plan', simplan, 'method=', 'selective', 'nonlinPer=', 30, 'anticipate', false); % for new IRIS
% s = simulate(m, h, fcastrange, 'plan', simplan, 'nonlinearize=', 40, 'maxiter=', 1000, 'anticipate', false); % for old IRIS
% iris version 20211222

s = simulate(m, h, fcastrange, "Plan", simplan,"prependInput", true); % for new IRIS
% s = simulate(m, h, fcastrange, "Plan", simplan,"prependInput", true,"Contributions", true); % for new IRIS
% [S,Flag] = simulate(m, h, fcastrange, "Plan", simplan,"prependInput", true,"Contributions", true); % for new IRIS

%% append forecast to the historical data
% Command 'dbextend' puts together the historical database 'h' and the
% results of the simulation saved in object 's'. Single database 's' is
% created

h = dbextend(h,s);

% %% Additional forecast-implied data to be saved
% % Oil prices, level, USD/barrel
% % USD/EUR exchange rate, level
% for i = startfcast:endfcast
%     h.L_WOIL(i) = h.L_WOIL(i-1) + h.DLA_WOIL(i)/4;
%     h.WOIL(i) = exp(h.L_WOIL(i)/100);
%     h.L_WFOOD(i) = h.L_WFOOD(i-1) + h.DLA_WFOOD(i)/4;
%     h.L_S_CROSS(i) = h.L_S_CROSS(i-1) + h.DLA_S_CROSS(i)/4;
%     h.S_CROSS(i) = exp(h.L_S_CROSS(i)/100);
% end

% Results are saved in file 'fcastdata.mat'  
%dbsave('fcastdata.csv',h);
databank.toCSV(h,'fcastdata.csv');


%% Graphs and Tables
% Prepares the forecast report: graphs and tables in the Acrobat .pdf format
Tablerng = startfcast-3:startfcast+7;
Plotrng = startfcast-3:startfcast+11;
Histrng = startfcast-3:startfcast-1;

% Specify country and units for exchange rate
country = 'The Colombian Republic';
exchange = 'COP/USD';

% Report
x = report.new(country);

% Figures
sty = struct();
sty.line.linewidth = 1.5;
sty.line.linestyle = {'-';'--';':'};
% sty.line.color = {'k';'k';'k'};
sty.axes.box = 'on';
sty.legend.location = 'Best';

x.figure('Forecast - Main Indicators','subplot',[3,2],'style',sty,'range',Plotrng,'dateformat','YYYY:P');

x.graph('Inflation, %','legend',true);
x.series('',[h.DLA_CPI h.D4L_CPI h.D4L_CPI_TAR],'legend',{'q-o-q','y-o-y','Target'});
x.highlight('',Histrng);

x.graph('Nominal Interest Rate, % p.a.','legend',false);
x.series('',[h.RS]);
x.highlight('',Histrng);

x.graph(['Nominal Exchange Rate - ' exchange],'legend',false);
x.series('',[exp(h.L_S/100)]);
x.highlight('',Histrng);

x.graph('Nominal Exchange Rate Deprec., %','legend',true);
x.series('',[h.DLA_S (h.L_S - h.L_S{-4})],'legend',{'q-o-q','y-o-y'});
x.highlight('',Histrng);

x.graph('Output Gap, %','legend',false);
x.series('',[h.L_GDP_GAP]);
x.highlight('',Histrng);

x.graph('Monetary Conditions, %','legend',true);
x.series('', [h.MCI h.RR_GAP h.L_Z_GAP],'legend',{'MCI','RIR gap', 'RER gap'});
x.highlight('',Histrng);

x.pagebreak();

% Tables
TableOptions = {'range',Tablerng,'vline',startfcast-1,'decimal',1,'dateformat','YYYY:P',...
    'long',true,'longfoot','---continued','longfootposition','right'};

x.table('Forecast - Main Indicators',TableOptions{:});

x.subheading('');
  x.series('CPI ',h.D4L_CPI,'units','% (y-o-y)');
  x.series('',h.DLA_CPI,'units','% (q-o-q)');
  x.series('Target',h.D4L_CPI_TAR,'units','%');
x.subheading('');  
  x.series('Exchange Rate',exp(h.L_S/100),'units',exchange);
  x.series('',(h.L_S-h.L_S{-4}),'units','% (y-o-y)');
x.subheading('');
  x.series('GDP',h.D4L_GDP,'units','% (y-o-y)');
x.subheading('');
  x.series('Interest Rate',h.RS,'units','% p.a.');

x.subheading('');
x.subheading('Inflation');
  x.series('CPI ',h.D4L_CPI,'units','% (y-o-y)');
  x.series('Core Inflation',h.D4L_CPIXFE,'units','% (y-o-y)');
  x.series('Food Prices',h.D4L_CPIF,'units','% (y-o-y)');
  x.series('Energy Prices',h.D4L_CPIE,'units','% (y-o-y)');

x.subheading('');
x.subheading('Real Economy');
  x.series('Output Gap',h.L_GDP_GAP,'units','%');
  x.series('GDP',h.DLA_GDP,'units','% (q-o-q)');
  x.series('Potential GDP',h.DLA_GDP_BAR,'units','% (q-o-q)');
  
x.subheading('');
x.subheading('Monetary Conditions');
  x.series('Monetary Conditions',h.MCI,'units','%');
  x.series('Real Interest Rate Gap',h.RR_GAP,'units','p.p.');
  x.series('Credit Premium',h.CR_PREM,'units','p.p.');
  x.series('Real Exchange Rate Gap',h.L_Z_GAP,'units','%');

x.pagebreak();
x.table('Forecast - Inflation Decomposition',TableOptions{:});

x.subheading('Contributions');
  x.series('CPI',h.DLA_CPI,'units','% (q-o-q)');
  x.series('Core Inflation',(1-h.w_CPIF-h.w_CPIE).*h.DLA_CPIXFE,'units','p.p.');
  x.series('Food Prices',h.w_CPIF.*h.DLA_CPIF,'units','p.p.');
  x.series('Energy Prices',h.w_CPIE.*h.DLA_CPIE,'units','p.p.');
  
x.subheading('');
x.subheading('Core Inflation');
  x.series('Core Inflation',h.DLA_CPIXFE,'units','%');
  x.series('Lag',h.a1.*h.DLA_CPIXFE{-1},'units','p.p.');
  x.series('Expectations',(1-h.a1).*h.E_DLA_CPIXFE,'units','p.p.');
  x.series('RMC',h.a2.*h.RMC,'units','p.p.');
  x.series('RMC - Domestic',h.a2.*h.a3.*h.L_GDP_GAP,'units','p.p.');
  x.series('RMC - Imported',h.a2.*(1-h.a3).*(h.L_Z_GAP-h.L_RPXFE_GAP),'units','p.p.');
  x.series('Residual',h.SHK_DLA_CPIXFE,'units','p.p.');

x.subheading('');
x.subheading('Food Prices');
  x.series('Food Prices',h.DLA_CPIF,'units','%');
  x.series('Lag',h.a21.*h.DLA_CPIF{-1},'units','p.p.');
  x.series('Expectations',(1-h.a21).*h.E_DLA_CPIF,'units','p.p.');
  x.series('Relative Food Prices',h.a22.*h.a23.*h.L_RWFOOD_GAP ,'units','p.p.');
  x.series('RER and Rel. Price',h.a22.*h.a23.*(+ h.L_Z_GAP - h.L_RPF_GAP),'units','p.p.');
  x.series('Business Cycle',h.a22.*(1-h.a23).*h.L_GDP_GAP,'units','p.p.');
  x.series('Residual',h.SHK_DLA_CPIF,'units','p.p.');
  

x.subheading('');
x.subheading('Energy Prices');
  x.series('Energy Prices',h.DLA_CPIE,'units','%');
  x.series('Lag',h.a31.*h.DLA_CPIE{-1},'units','p.p.');
  x.series('Expectations',(1-h.a31).*h.E_DLA_CPIE,'units','p.p.');
  x.series('Relative Oil Price',h.a32.*h.L_RWOIL_GAP,'units','p.p.');
  x.series('RER and Rel.Price',h.a32.*(h.L_Z_GAP - h.L_RPE_GAP),'units','p.p.');
  x.series('Residual',h.SHK_DLA_CPIE,'units','p.p.');

x.pagebreak();
x.table('Forecast - Demand and Supply',TableOptions{:});

x.subheading('Ouptut Gap Decomposition');
  x.series('Output Gap',h.L_GDP_GAP,'units','%');
  x.series('Lag',h.b1.*h.L_GDP_GAP{-1},'units','p.p.');
  x.series('Monetary Conditions',-h.b2.*h.MCI,'units','p.p.');
  x.series('Real Interest Rate',-h.b2.*h.b4.*h.RR_GAP,'units','p.p.');
  x.series('Credit Premium',-h.b2.*h.b4.*h.CR_PREM,'units','p.p.');
  x.series('Real Exchange Rate',-h.b2.*(1-h.b4).*(-h.L_Z_GAP),'units','p.p.');
  x.series('Foreign Output Gap',h.b3.*h.L_GDP_RW_GAP,'units','p.p.');
  x.series('Residual',h.SHK_L_GDP_GAP,'units','p.p.');
  
x.subheading('');
x.subheading('Supply Side Assumptions');
  x.series('Potential Output',h.DLA_GDP_BAR,'units','% (q-o-q)');
  x.series('',(h.L_GDP_BAR-h.L_GDP_BAR{-4}),'units','% (y-o-y)');
  x.subheading('');
  x.series('Eq. Real Interest Rate',h.RR_BAR,'units','%');
  x.subheading('');
  x.series('Eq. Real Exchange Rate',h.DLA_Z_BAR,'units','% (q-o-q)');
  x.series('',(h.L_Z_BAR-h.L_Z_BAR{-4}),'units','% (y-o-y)'); 
  
x.pagebreak();
x.table('Forecast - Policy Decomposition',TableOptions{:});

x.subheading('Interest Rate Decomposition');
  x.series('Interest Rate',h.RS,'units','% p.a.');
  x.series('Lag',h.g1.*h.RS{-1},'units','p.p.');
  x.series('Neutral Rate',(1-h.g1).*h.RSNEUTRAL,'units','p.p.');
  x.series('Expected Inflation DEv.',(1-h.g1).*h.g2.*(h.D4L_CPI{+3} - h.D4L_CPI_TAR{+3}),'units','p.p.');
  x.series('Output Gap',(1-h.g1).*h.g3.*h.L_GDP_GAP,'units','p.p.');
  x.series('Residual',h.SHK_RS,'units','p.p.');

x.subheading('');
x.subheading('Monetary Conditions Decomposition');
  x.series('Monetary Conditions',h.MCI,'units','%');
  x.series('Real Interest Rate Gap',h.b4.*h.RR_GAP,'units','p.p.');
  x.series('Credit Premium',h.b4.*h.CR_PREM,'units','p.p.');
  x.series('Real Exchange Rate Gap',(1-h.b4).*(-h.L_Z_GAP),'units','p.p');
  
x.pagebreak();
x.table('Forecast - Foreign Variables',TableOptions{:});

x.subheading('European Monetary Union');
  x.series('Inflation',h.DLA_CPI_RW,'units','% (q-o-q)');
  x.series('Interest Rate',h.RS_RW,'units','% p.a.');
  x.series('Output Gap',h.L_GDP_RW_GAP,'units','%');

x.subheading('');
x.subheading('World Food and Oil Prices');
  x.series('World Food Price',h.DLA_WFOOD,'units','% (q-o-q)');
  x.series('World Food Price',h.D4L_WFOOD,'units','% (y-o-y)');
  x.series('World Oil Prices',h.DLA_WOIL,'units','% (q-o-q)'); 
  x.series('World Oil Prices',h.D4L_WOIL,'units','% (y-o-y)'); 
  
x.subheading('');
x.subheading('USD/EUR Exchange Rate');
  x.series('',h.DLA_S_CROSS,'units','% (q-o-q)');
  x.series('',h.S_CROSS,'units','level', 'decimal', 2);

x.publish('Forecast','display',false);
disp('Done!');
    
