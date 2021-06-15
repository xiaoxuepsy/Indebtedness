%%==========================================================================
% This is the function part of codes for help rejection model proposed by Gao et al., 2021, The hidden cost of receiving favors: A theory of indebtedness
% This script should be used in combination with the main file:
% Help_rejection_model_main.m
% Detailed tutorials for package installation and computational modeling: https://dubioussentiments.wordpress.com/2014/07/09/matlab-object-oriented-model-fitting-tutorial/
% The final winning model uses the kappa parameter estimated from reciprocity behaviors when participants have to accept help

%--------------------------------------------------------------------------
% Example Model Function
%--------------------------------------------------------------------------
%
% Here is an example function of a very simple linear model.  
% Functions can be completely flexible, but need to have the free parameter (xpar) 
% and data inputs and the model fit (sse here) as the output. 
% This is so fmincon can optimize the parameters for this function by
% minimizing the Sum of Squared Error (sse - for this example)
% This function needs to be in a separate file.  

function LogLike = Help_rejection_model_function(xpar, data)

global trialout %this allows trial to be saved to comp_model() object
global para

% Model Parameters
Theta = xpar(1); % weight for self interest
Phi = xpar(2); % weight for communal concern
beta = xpar(3);

sub_para  = para(para(:,1) == data(1,1),:);
Kappa = sub_para(2) ;

% Parse Data
cost = data(:,4); % The colume number for trial-by-trial co-player's cost
condition = data(:,3); % The colume number indicating repayment possible (1) and impossible (0) conditions
choice = data(:,7); % Participants' decisions of whether to reject help when they can decide
Pain_reduction = data(:,8); 

coplayer_endowment = 20;
self_endowment = 25;
Max_Pain_reduction = 16;

%Model Initial Values
LogLike = 0;
UA = zeros(length(choice),1);
UR = zeros(length(choice),1);
pA = zeros(length(choice),1);
pR = zeros(length(choice),1);

% This model is looping through every trial.  
for t = 1:length(choice)
    E2(t) = cost(t)*condition(t);
    pCare(t) = max((cost(t)- Kappa*E2(t))/coplayer_endowment,0);
    
    %make perdictions 
    UA(t)  = Theta*Pain_reduction(t)/Max_Pain_reduction + (1-Theta)*(Phi*pCare(t)-(1-abs(Phi))*E2(t)/self_endowment);
    UR(t) = 0;
    
    [pA(t), pR(t)] = SoftMax([UA(t),UR(t)],beta);
     
    if choice(t)==1
        LogLike = LogLike - log(pR(t));
    elseif choice(t)==0
        LogLike = LogLike - log(pA(t));
    end
    
    predict(t) = pR(t);
    
end

%Output results - can add this as a global variable later
trialout = [ones(t,1)*data(1,1) (1:t)', choice, Pain_reduction, E2(1:t)', pCare(1:t)',predict(1:t)' ];

end % model
