%**************
% Colombian Republic
%**************

close all;
clear all;

%% Load model to take parameters
[m,p,mss] = readmodel(false)

%% Load quarterly data
% Command 'dbdload' loads the data from the 'csv' file (save from Excel as
% .csv in the current directory). All the data are now available in the
% database 'd' 
%d = dbload('data.csv');
d = databank.fromCSV('data.csv');
%% Seasonal adjustment
list = dbnames(d);

for i = 1:length(list)
    if length(list{i})>1
        if strcmp('_U', list{i}(end-1:end))
            d.(list{i}(1:end-2)) = x12(d.(list{i}), Inf, 'mode', 'm');
%             d = rmfield(d, list{i});
        end
    end
end

%% Make log of variables
exceptions = {'RS','RS_RW','D4L_CPI_TAR', 'w_CPIF', 'w_CPIE'};

list = dbnames(d);

for i = 1:length(list)
    if isempty(strmatch(list{i},exceptions,'exact'))
        d.(['L_' list{i}]) = 100*log(d.(list{i}));
    end
end

%% Define the real exchange rate
d.L_Z = d.L_S + d.L_CPI_RW - d.L_CPI;

%% Food and oil indexes in local currency
d.L_RWFOOD = d.L_WFOOD - d.L_S_CROSS - d.L_CPI_RW;
d.L_RWOIL  = d.L_WOIL - d.L_S_CROSS - d.L_CPI_RW;

%% Relative prices
d.L_RPF   = d.L_CPIF - d.L_CPI;
d.L_RPE   = d.L_CPIE - d.L_CPI;
d.L_RPXFE = d.L_CPIXFE - d.L_CPI;

%% Growth rate qoq, yoy
exceptions = {'RS','RS_RW','D4L_CPI_TAR','w_CPIF', 'w_CPIE'};

list = dbnames(d);

for i = 1:length(list)
    if isempty(strmatch(list{i}, exceptions,'exact'))
        if length(list{i})>1
            if strcmp('L_', list{i}(1:2))
                d.(['DLA_' list{i}(3:end)])  = 4*(d.(list{i}) - d.(list{i}){-1});
                d.(['D4L_' list{i}(3:end)]) = d.(list{i}) - d.(list{i}){-4};
            end
        end
    end
end

%% CPI weights
d.w_CPIXFE = 1 - d.w_CPIF - d.w_CPIE;

%% Time varying CPI weights
d.wt_CPIF   = d.w_CPIF*d.CPIF{-1}/d.CPI{-1};
d.wt_CPIE   = d.w_CPIE*d.CPIE{-1}/d.CPI{-1};
d.wt_CPIXFE = d.w_CPIXFE*d.CPIXFE{-1}/d.CPI{-1};

d.wt4_CPIF   = d.w_CPIF*d.CPIF{-4}/d.CPI{-4};
d.wt4_CPIE   = d.w_CPIE*d.CPIE{-4}/d.CPI{-4};
d.wt4_CPIXFE = d.w_CPIXFE*d.CPIXFE{-4}/d.CPI{-4};

d.w_CPIF   = d.wt_CPIF(end);
d.w_CPIE   = d.wt_CPIE(end);
d.w_CPIXFE = d.wt_CPIXFE(end);

disp('Time-varying food and energy weights at the end of the sample:');
disp(['w_CPIF:' num2str(d.w_CPIF)]);
disp(['w_CPIE:' num2str(d.w_CPIE)]);

%% Real Interest Rates
% Domestic real interest rate
d.RR = d.RS - d.D4L_CPI;

% Foreign real interest rate
d.RR_RW = d.RS_RW - d.D4L_CPI_RW;

%% Trends and Gaps - Hodrick-Prescott filter
list = {'RR','L_Z','L_RWFOOD','L_RWOIL','L_RPF','L_RPXFE','L_RPE','RR_RW','L_GDP','L_GDP_RW'};

for i = 1:length(list)
    [d.([list{i} '_BAR']), d.([list{i} '_GAP'])] = hpf(d.(list{i}));
end

%% Trend and Gap for Output - Band-pass filter
% save HP results
d.L_GDP_BAR_HP = d.L_GDP_BAR;
d.L_GDP_GAP_HP = d.L_GDP_GAP; 

% Band-pass
d.L_GDP_GAP = bpass(d.L_GDP,[6,32],inf,'detrend',false);
d.L_GDP_BAR = hpf((d.L_GDP-d.L_GDP_GAP),inf,'lambda',5);
d.DLA_GDP_BAR = 4*(d.L_GDP_BAR - d.L_GDP_BAR{-1});

%% Growth rates of equilibria
list = {'L_GDP_BAR', 'L_GDP_RW_BAR', 'L_Z_BAR', 'L_RWOIL_BAR', 'L_RWFOOD_BAR'};

for i = 1:length(list)
   d.(['DLA' list{i}(2:end)]) = 4*(d.(list{i}) - d.(list{i}){-1});
   d.(['D4L' list{i}(2:end)]) = d.(list{i}) - d.(list{i}){-4};
end

%% Implied risk premium
d.PREM = d.RR_BAR - d.RR_RW_BAR - d.DLA_Z_BAR;
d.SHKN_PREM = tseries(get(d.L_S,'range'),0);


%% Compute the exchange rate target over the history (not applied for the Czech case except the period of the FX commitment)
% Exchange rate target is automatically calculated as to equal observed
% FX commitment since Nov. 2013 -- beware officially the target is just a
% lower bound, depreciation was allowed and thus it is not a point target
% as defined below
PRIOR_LS_TAR  = tseries(qq(2013,4):qq(2017,1),  100*log(27));
d.L_S_TAR     = hpf(d.L_S, Inf, 'lambda', 1600, 'level', PRIOR_LS_TAR);
d.DLA_S_TAR   = 4*(d.L_S_TAR - d.L_S_TAR{-1});

%% Credit premium
d.CR_PREM = tseries(get(d.RR_GAP,'range'),0);

%% Relative prices trends
d.L_RPXFE_BAR = d.L_RPXFE - d.L_RPXFE_GAP;
d.L_RPF_BAR = d.L_RPF - d.L_RPF_GAP;

d.DLA_RPXFE_BAR = 4*(d.L_RPXFE_BAR - d.L_RPXFE_BAR{-1});
d.DLA_RPF_BAR = 4*(d.L_RPF_BAR - d.L_RPF_BAR{-1});


%% Save the database
% Database is saved in file 'history.csv'
%dbsave(d,'history.csv');
databank.toCSV(d,'history.csv');

%% Report - Stylized Facts
% Specify country
country = 'The Colombian Republic - Stylized Facts';
exchange = 'COP/USD';

% Report
x = report.new(country);

% Figures
rng = get(d.D4L_CPI,'first2last');

sty = struct();
sty.line.linewidth = 1;
sty.line.linestyle = {'-';'--'};
% sty.line.color = {'k';'k'};
sty.axes.box = 'off';
sty.legend.location='Best';

x.figure('Nominal Variables', 'subplot', [3,2], 'style', sty, 'range', rng);

x.graph('Inflation, percent','legend',true);
x.series('',[d.DLA_CPI d.D4L_CPI],'Legend=',{'q-o-q','y-o-y'});

x.graph('Inflation, percent y-o-y','legend',true);
x.series('',[d.D4L_CPI d.D4L_CPI_TAR],'Legend=',{'Inflation','Inflation Target'});

x.graph('Nominal Interest Rate, percent p.a.','legend',false);
x.series('',[d.RS]);
 
 x.graph('NER Depreciation - COP/USD, percent','legend',true);
 x.series('',[d.DLA_S d.D4L_S],'Legend=', {'q-o-q','y-o-y'});
 
 x.graph('NER - CZK/EUR','legend',false);
 x.series('',[exp(d.L_S/100)]);
 
 x.graph('Foreign Inflation, percent','legend',true);
 x.series('',[d.DLA_CPI_RW d.D4L_CPI_RW],'Legend=',{'q-o-q','y-o-y'});

x.pagebreak();

x.figure('CPI Sub-components', 'subplot', [2,2], 'style', sty, 'range', rng);

x.graph('Core Inflation, percent','legend',true);
x.series('',[d.DLA_CPIXFE d.D4L_CPIXFE],'Legend=',{'q-o-q','y-o-y'});

x.graph('Food Price Inflation, percent','legend',true);
x.series('',[d.DLA_CPIF d.D4L_CPIF],'Legend=',{'q-o-q','y-o-y'});

x.graph('Energy Price Inflation, percent','legend',true);
x.series('',[d.DLA_CPIE d.D4L_CPIE],'Legend=',{'q-o-q','y-o-y'});

 x.graph('Contributions to YoY Headline Inflation (approx.), pp','legend',true);
 x.series('',[(1-d.wt4_CPIF-d.wt4_CPIE)*d.D4L_CPIXFE, d.wt4_CPIF*d.D4L_CPIF, d.wt4_CPIE*d.D4L_CPIE], ...
     'legend=', {'Core', 'Food', 'Energy'}, 'plotfunc', @conbar);
 x.series('Headline', d.D4L_CPI);

x.pagebreak();

x.figure('Real Variables and Trends', 'subplot', [3,2], 'style', sty, 'range', rng);

x.graph('GDP, 100*log','legend',true);
x.series('',[d.L_GDP d.L_GDP_BAR],'Legend=',{'Level', 'Trend'});

x.graph('GDP Growth (percent y-o-y)','legend',false);
x.series('',[d.D4L_GDP d.D4L_GDP_BAR]);

x.graph('Real Interest Rate, percent p.a.','legend',false);
x.series('',[d.RR d.RR_BAR]);

x.graph('Foreign Real Interest Rate, percent p.a.','legend',false);
x.series('',[d.RR_RW d.RR_RW_BAR]);

x.graph('Real Exchange Rate, 100*log','legend',false);
x.series('',[d.L_Z d.L_Z_BAR]);

x.graph('Real Exchange Rate Depreciation, percent q-o-q ann.','legend',false);
x.series('',[d.DLA_Z d.DLA_Z_BAR]);

x.pagebreak();

x.figure('Gaps', 'subplot', [3,2], 'style', sty, 'range', rng);

x.graph('GDP Gap, percent','legend',true);
x.series('',[d.L_GDP_GAP_HP, d.L_GDP_GAP],'Legend=',{'HP', 'BP'});

x.graph('Real Interest Rate Gap, percent p.a.','legend',false);
x.series('',[d.RR_GAP]);

x.graph('Real Exchange Rate Gap, percent','legend',false);
x.series('',[d.L_Z_GAP]);

x.graph('Relative World Oil Price Gap, percent','legend',false);
x.series('',[d.L_RWOIL_GAP]);

x.graph('Foreign Output Gap, percent','legend',false);
x.series('',[d.L_GDP_RW_GAP]);

x.graph('Relative World Food Price Gap, percent','legend',false);
x.series('',[d.L_RWFOOD_GAP]);

x.pagebreak();

x.figure('Relative Prices', 'subplot', [3,1], 'style', sty, 'range', rng);

x.graph('Relative Price -- L_RPXFE, 100*log','legend',true);
x.series('',[d.L_RPXFE d.L_RPXFE_BAR],'Legend=',{'Level', 'Trend'});

x.graph('Relative Price -- L_RPF, 100*log','legend',false);
x.series('',[d.L_RPF d.L_RPF_BAR],'Legend=',{'Level', 'Trend'});

x.graph('Relative Price -- L_RPE, 100*log','legend',false);
x.series('',[d.L_RPE d.L_RPE_BAR],'Legend=',{'Level', 'Trend'});

x.pagebreak();

x.figure('Foreign Variables', 'subplot', [3,2], 'style', sty, 'range', rng);

x.graph('Foreign Nom. Interest Rate, % pa','legend',false);
x.series('',[d.RS_RW]);

x.graph('Foreign CPI Inflation, %','legend',true);
x.series('',[d.DLA_CPI_RW, d.D4L_CPI_RW],'Legend=',{'QoQ', 'YoY'});

x.graph('Foreign Real Rate, %','legend',true);
x.series('',[d.RR_RW, d.RR_RW_BAR],'Legend=',{'Level', 'Trend'});

x.graph('Foreign Real GDP Growth, %','legend',true);
x.series('',[d.DLA_GDP_RW, d.D4L_GDP_RW],'Legend=',{'QoQ', 'YoY'});

x.graph('YoY Foreign Real GDP Growth, %','legend',true);
x.series('',[d.D4L_GDP_RW, d.D4L_GDP_RW_BAR],'Legend=',{'Actual', 'Trend'});

x.graph('Foreign Output Gap, %','legend',false);
x.series('',[d.L_GDP_RW_GAP]);

x.pagebreak();

sty.legend.location = 'SouthEast';
x.figure('Foreign Variables', 'subplot', [2,2], 'style', sty, 'range', rng);

x.graph('World Oil Price Inflation, %','legend',true);
x.series('',[d.DLA_WOIL, d.D4L_WOIL],'Legend=',{'QoQ', 'YoY'});

x.graph('World Food Price Inflation, %','legend',true);
x.series('',[d.DLA_WFOOD, d.D4L_WFOOD],'Legend=',{'QoQ', 'YoY'});

x.graph('RP of Oil to US CPI','legend',true);
x.series('',[d.L_RWOIL d.L_RWOIL_BAR],'Legend=',{'Level', 'Trend'});

x.graph('RP of Food to US CPI','legend',true);
x.series('',[d.L_RWFOOD d.L_RWFOOD_BAR],'Legend=',{'Level', 'Trend'});

x.publish('Stylized_facts','display',false);
disp('Done!!!');
