%%==========================================================================
% This is the main part of codes for reciprocity model proposed by Gao et al., 2021, The hidden cost of receiving favors: A theory of indebtedness
% This script should be used in combination with the function file:
% Reciprocity_model_function.m
% Detailed tutorials for package installation and computational modeling: https://dubioussentiments.wordpress.com/2014/07/09/matlab-object-oriented-model-fitting-tutorial/

%%==========================================================================
% Computational Model Class: comp_model
% 
% This object is used to fit a computational model to a multi-subject
% dataset.  The object uses the design_matrix() class to for the data set
% and has additional fields for the model and parameters for the model
% fitting procedure such as the parameter constraints, number of
% iterations, and type of estimation (e.g., maximum likelihood or least
% squares).
%==========================================================================


%==========================================================================
% Current Methods for comp_model (inherits from design_matrix class too)
%==========================================================================

%avg_aic - display average AIC value
%avg_bic - display average BIC value
%avg_params - display average parameter estimates
%comp_model - class constructor
%fit_model - estimate parameters using model
%plot - plot average model predictions across subjects
%summary - display summary table for model
%save - save object as .mat file
%write_tables - write out parameter estimates and trial-to-trial predictions to csv data frame.%


% Load data
basedir = './';
dat = importdata(fullfile(basedir, 'Study2_Model_data.txt'));
data = dat.data;

% Set optimization parameters for fmincon (OPTIONAL)
options = optimset(@fmincon);
options = optimset(options, 'TolX', 0.00001, 'TolFun', 0.00001, 'MaxFunEvals', 900000000, 'LargeScale','off');

%--------------------------------------------------------------------------
% Create class instance for example linear model
%--------------------------------------------------------------------------
%
% requires data frame, cell array of column names, and model name.  
% ModelName: must refer to function with the model on matlab path.  See
% example 'linear_model' function below.
%
% Can also specify additional parameters for model fitting.
% nStart: is the number of iterations to repeat model estimation, will pick
% the iteration with the best model fit.
% param_min: vector of lower bound of parameters
% param_max: vector of upper bound of parameters
% esttype: type of parameter estimation ('SSE' - minimize sum of squared
% error; 'LLE' - maximize log likelihood; 'LE' - maximize likelihood

lin = comp_model(data,dat.textdata,'Reciprocity_model_function','nStart',1000, 'param_min',[0, 0, 0], 'param_max', [1,1,1], 'esttype','SSE');

%   911x8 comp_model array with properties:
% 
%         model: 'linear_model'
%     param_min: [-5 -20]
%     param_max: [60 20]
%        nStart: 10
%       esttype: 'SSE'
%        params: []
%         trial: []
%           dat: [911x8 double]
%       varname: {'subj'  'group'  'sess'  'se_count'  'se_sum_intensity'  'any_action_taken'  'hamtot'  'bditot'}
%         fname: ''
%--------------------------------------------------------------------------
  

%--------------------------------------------------------------------------
% Fit Model to Data
%--------------------------------------------------------------------------
%
% once object has been created with all of the necessary setup parameters,
% the model can be fit to the data with following command.

lin = lin.fit_model();

%   911x8 comp_model array with properties:
% 
%         model: 'linear_model'
%     param_min: [-5 -20]
%     param_max: [60 20]
%        nStart: 10
%       esttype: 'SSE'
%        params: [77x6 double]
%         trial: [911x4 double]
%           dat: [911x8 double]
%       varname: {'subj'  'group'  'sess'  'se_count'  'se_sum_intensity'  'any_action_taken'  'hamtot'  'bditot'}
%         fname: ''
        
% This adds two new fields.
% Params: is the parameters estimated for each subject.  Rows are
% individual subjects. Columns are {'Subject', 'Estimated Parameters (specific to each model)', 'Model Fit', 'AIC', 'BIC'}
% trial: is the trial by trial data and predicted values for all subjects
% stacked together.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% View Results
%--------------------------------------------------------------------------
% The overall average results from the model can be quickly viewed using
% the summary() method.

summary(lin)

% Summary of Model: linear_model
% -----------------------------------------
% Average Parameters:	18.1073
% Average AIC:		35.8264
% Average BIC:		36.3802
% Average SSE:		-1.86
% Number of Subjects:	77
% -----------------------------------------
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Write out results to .csv file
%--------------------------------------------------------------------------

% The 'params' and 'trial' data frames can be written to separate .csv files

lin.write_tables(basedir)

%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Save Object to .mat file
%--------------------------------------------------------------------------

% The overall object instance can be saved as .mat file.  Helpful as
% sometimes model estimation can take a long time especially if using
% multiple iterations.

lin.save(basedir)

%--------------------------------------------------------------------------
% Plot Model
%--------------------------------------------------------------------------

% The average predicted values from the model can be quickly plotted, but
% must specifiy the columns to plot as these will be specific to the data
% set and model.  This method has some rudimentary options to customize the
% plot

% plot(lin, [3,4], 'title', 'Linear Model', 'xlabel','cost', 'ylabel', 'Average reciprocity', 'legend', {'Predicted','Observed'})

%[P,H,STATS] = signrank(get_aic(lin),get_aic(lin_expect))
 