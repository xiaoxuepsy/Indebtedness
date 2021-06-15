%%==========================================================================
% This is the function part of codes for the reciprocity model proposed by Gao et al., 2021, The hidden cost of receiving favors: A theory of indebtedness
% This script should be used in combination with the main file:
% Reciprocity_model_main.m
% Detailed tutorials for package installation and computational modeling: https://dubioussentiments.wordpress.com/2014/07/09/matlab-object-oriented-model-fitting-tutorial/

%--------------------------------------------------------------------------
% Model Function
%--------------------------------------------------------------------------
%
% Here is the function for the reciprocity model proposed by Gao et al., 2021.  
% Functions can be completely flexible, but need to have the free parameter (xpar) 
% and data inputs and the model fit (sse here) as the output. 
% This is so fmincon can optimize the parameters for this function by
% minimizing the Sum of Squared Error (sse - for this example)
% This function needs to be in a separate file.  

function sse = Reciprocity_model_function(xpar, data)

global trialout %this allows trial to be saved to comp_model() object

% Model Parameters
Theta = xpar(1); % weight for self interest
Phi = xpar(2); % weight for communal concern
Kappa = xpar(3); % weight for how second-order belief reduce perceived care

% Parse Data
reciprocity = data(:,6); % The colume number for trial-by-trial reciprocity
cost = data(:,4); % The colume number for trial-by-trial co-player's cost
condition = data(:,3); % The colume number indicating repayment possible (1) and impossible (0) conditions

coplayer_endowment = 20;
self_endowment = 25;

%Model Initial Values
sse = 0; %sum of squared error

% This model is looping through every trial.  
for t = 1:length(reciprocity)
    E2 = cost(t)*condition(t);
    pCare = max((cost(t)- Kappa*E2)/coplayer_endowment,0);
    
    %make perdictions
    allR = [0:0.1:self_endowment];
    
    U = Theta*((self_endowment-allR)/self_endowment) - (1-Theta)*(Phi*((pCare*self_endowment-allR)/self_endowment).^2 + (1-Phi)*((E2-allR)/self_endowment).^2) ;
    [ma,I] = max(U);
    predreci(t) = (I-1)/10;
    % update sum of squared error (sse)
    sse = sse + ((predreci(t) - reciprocity(t))/self_endowment*100).^2;
    
SSE(t) = ((predreci(t) - reciprocity(t))/self_endowment*100).^2;
    
end

%Output results - can add this as a global variable later
trialout = [ones(t,1)*data(1,1) (1:t)', reciprocity, predreci(1:t)', SSE(1:t)'];

end % model
