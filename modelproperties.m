clear all
close all

%%
%%% Simulates set of basic shocks
% Read the model
[m,p,mss] = readmodel(false);

%% Shocks
% List of shocks
% One period unexpected shocks: inflation, output, exchange rate, interest rate
% Creates a list (vector) of shocks and list of their names. Used shocks' names must
% be the names found in the model code (in file 'model.model') except of the prefix
% 'e_'
listshocks = {'SHK_DLA_CPIXFE','SHK_L_GDP_GAP','SHK_L_S','SHK_RS_UNC','SHK_L_RWFOOD_GAP','SHK_DLA_RPF_BAR','SHK_L_RWOIL_GAP'};
listtitles = {'Core Inflation Shock','Aggregate Demand Shock', 'Exchange Rate Shock', 'Interest Rate Shock','World Food Prices Shock',...
				'Shock to Relative Price of Food','World Oil Prices Shock'};

% Sets the time frame for the simulation 
startsim = qq(1,1);
endsim = qq(4,4); % four-year simulation horizon

% For each shock a zero database is created (command 'zerodb') and named as 
% database 'd.{shock_name}'
for i = 1:length(listshocks);
    d.(listshocks{i}) = zerodb(m,startsim-4:endsim);
end

% Fills the respective databases with the shocks' values for the starting
% point of the simulation (startsim). For simplicity, all shocks are set to
% 1 percent
d.SHK_DLA_CPIXFE.SHK_DLA_CPIXFE(startsim)     = 1;
d.SHK_L_GDP_GAP.SHK_L_GDP_GAP(startsim)       = 1;
d.SHK_L_S.SHK_L_S(startsim)                   = 1;
d.SHK_RS_UNC.SHK_RS_UNC(startsim)             = 1;
d.SHK_L_RWFOOD_GAP.SHK_L_RWFOOD_GAP(startsim) = 10;
d.SHK_DLA_RPF_BAR.SHK_DLA_RPF_BAR(startsim)   = 10;
d.SHK_L_RWOIL_GAP.SHK_L_RWOIL_GAP(startsim)   = 10;

% Simulates the shocks using the command 'simulate'. For this model
% 'm' and respective database 'd.{shock_name} are used. Results are written 
% in object 's.{shock_name}'. Command 'dboverlay' merges the historical 
% database d.{shock_name} with simulation database s.{shock_name}. 
for i=1:length(listshocks);    
    s.(listshocks{i}) = simulate(m,d.(listshocks{i}),startsim:endsim,'deviation',true);
    s.(listshocks{i}) = dbextend(d.(listshocks{i}),s.(listshocks{i}));
end

% Report
x = report.new('Shocks');

% Figures
sty = struct();
sty.line.linewidth = 1.5;
sty.line.linestyle = {'-';'--'};
% sty.line.color = {'k';'k'};
sty.axes.box = 'on';
sty.legend.location = 'Best';

for i = 1:length(listshocks);
x.figure(listtitles{i},'subplot',[3,3],'style',sty,'range',startsim:endsim,'dateformat','YY:FP');

x.graph('Inflation, % QoQ','legend',false);
x.series({'q-o-q'},[s.(listshocks{i}).DLA_CPI]);

x.graph('Core Inflation, % QoQ','legend',false);
x.series('',[s.(listshocks{i}).DLA_CPIXFE]);

x.graph('Food Price Inflation, % QoQ','legend',false);
x.series('',[s.(listshocks{i}).DLA_CPIF]);

x.graph('Energy Price Inflation, % QoQ','legend',false);
x.series('',[s.(listshocks{i}).DLA_CPIE]);

x.graph('Nominal Interest Rate, % pa','legend',false);
x.series('',[s.(listshocks{i}).RS]);

x.graph('Nominal Exchange Rate Deprec, % QoQ','legend',false);
x.series({'q-o-q'},s.(listshocks{i}).DLA_S);

x.graph('Output Gap, %','legend',false);
x.series('',[s.(listshocks{i}).L_GDP_GAP]);

x.graph('RIR Gap, %','legend',false);
x.series({'RIR gap'}, s.(listshocks{i}).RR_GAP);

x.graph('RER Gap, %','legend',false);
x.series({'RER gap'},  s.(listshocks{i}).L_Z_GAP);

x.pagebreak();

end

%% Disinflationary Shock, 1%
% Creates a steady-state database (a database filled with steady-state
% values) and sets the target to be lower for 1% over the simulation
% horizon
d.disinfl = sstatedb(m,startsim-4:endsim+40);
d.disinfl.D4L_CPI_TAR(startsim+1:endsim+40) =  d.disinfl.D4L_CPI_TAR - 1;

% Sets a simulation plan where the target is taken from the database (lower
% for 1% in comparison to the initial value)
% simplan = plan(m,startsim+1:endsim+40);
% simplan = exogenize(simplan,'D4L_CPI_TAR',startsim+1:endsim+40);
% simplan = endogenize(simplan,'SHK_D4L_CPI_TAR',startsim+1:endsim+40);

simplan = Plan.forModel(m,startsim:endsim+40); 
simplan = exogenize(simplan,startsim+1:endsim+40,'D4L_CPI_TAR');
simplan = endogenize(simplan,startsim+1:endsim+40,'SHK_D4L_CPI_TAR');

% Simulates the disinflation
%s.disinfl = simulate(m, d.disinfl, startsim:endsim+40, 'plan', simplan);
%iris version 20211222
s.disinfl = simulate(m, d.disinfl, startsim:endsim+40, "Plan", simplan); % for new IRIS

s.disinfl = dboverlay(d.disinfl, s.disinfl);

% Makes graph for the disinflation
x.figure('1% Disinflation', 'subplot', [3,2], 'style', sty, 'range', startsim-2:endsim, 'dateformat', 'YY:P');
  x.graph('Inflation, percent','legend', false);
    x.series('',s.disinfl.DLA_CPI);
    x.highlight('', startsim-2:startsim-1);
  x.graph('Nominal Interest Rate, percent','legend',false);
    x.series('',[s.disinfl.RS]);
    x.highlight('', startsim-2:startsim-1);
  x.graph('Nominal Exchange Rate, 100*log KZT per USD','legend',false);
    x.series('',[s.disinfl.DLA_S]);
    x.highlight('', startsim-2:startsim-1);
  x.graph('Output Gap, percent','legend',false);
    x.series('',[s.disinfl.L_GDP_GAP]);
    x.highlight('', startsim-2:startsim-1);
  x.graph('Real Interest Rate Gap, percent','legend',false);
    x.series('',[s.disinfl.RR_GAP]);
    x.highlight('', startsim-2:startsim-1);
  x.graph('Real Exchange Rate Gap, percent','legend',false);
    x.series('',[s.disinfl.L_Z_GAP]);
    x.highlight('', startsim-2:startsim-1);
    
x.publish('Report_Shocks','display',false);