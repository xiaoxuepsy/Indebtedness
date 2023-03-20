%%==========================================================================
% This is the function part of codes for the neural utility model in Gao et al., 2021, The hidden cost of receiving favors: A theory of indebtedness
% This script should be used in combination with the main file:
% Neural_utility_model_main.m
% Detailed tutorials for package installation and computational modeling: https://dubioussentiments.wordpress.com/2014/07/09/matlab-object-oriented-model-fitting-tutorial/

%--------------------------------------------------------------------------
% Model Function
%--------------------------------------------------------------------------
%
% Here is an example function of a very simple linear model.  
% Functions can be completely flexible, but need to have the free parameter (xpar) 
% and data inputs and the model fit (sse here) as the output. 
% This is so fmincon can optimize the parameters for this function by
% minimizing the Sum of Squared Error (sse - for this example)
% This function needs to be in a separate file.  

function sse = Neural_utility_model(xpar, data)

global trialout %this allows trial to be saved to comp_model() object

% Model Parameters
Theta = xpar(1); % weight for greedy
Phi = xpar(2); % weight for Communal concern

% Parse Data
reciprocity = data(:,6); % The colume number for trial-by-trial reciprocity
cost = data(:,5);  % The colume number for trial-by-trial co-player's cost
condition = data(:,4); % The colume number indicating repayment possible (1) and impossible (0) conditions


E2_pre = data(:,8); % The colume number for brain predicted (cross validated) trial-by-trial E2
PCare_pre = data(:,7); % The colume number for brain predicted (cross validated) trial-by-trial perceived care (Re-scaled to 0-25)

%Model Initial Values
sse = 0; %sum of squared error

% This model is looping through every trial.  
for t = 1:length(reciprocity)

    %make perdictions
    allR = [0:0.1:25];
    
    U = Theta*((25-allR)/25) - (1-Theta)*(Phi*((PCare_pre(t)-allR)/25).^2 + (1-Phi)*((E2_pre(t)-allR)/25).^2) ;
    [ma,I] = max(U);
    predreci(t) = (I-1)/10;
    % update sum of squared error (sse)
    sse = sse + ((predreci(t) - reciprocity(t))/25*100).^2;
    
SSE(t) = ((predreci(t) - reciprocity(t))/25*100).^2;
    
end

%Output results - can add this as a global variable later
trialout = [ones(t,1)*data(1,1) (1:t)', reciprocity, predreci(1:t)', SSE(1:t)'];

end % model
