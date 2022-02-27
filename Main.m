%% Main Document: Read functions
% Juan Felipe Herrera - MPhil Economics writing sample

% clear the environment
clear all;
clc; 
close all;
% Remember to set your path to the folder of the codes

% load the IRIS toolbox 
addpath ('C:\Program Files\MATLAB\IRIS-Toolbox-Release-20211222') % Edit your path
iris.startup('--tseries')

% 1. Make data
makedata;

% 2. Run the Kalman Filter
kalmanfilter;

% 3. Run the forecast of the model
forecast;