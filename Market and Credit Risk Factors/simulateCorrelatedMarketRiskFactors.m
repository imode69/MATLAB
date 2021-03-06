% Simulate market risk factors, based on the correlation structure of the market risk factors, the specified model (Lognormal,
% Mean-reverting, Lognormal mean-reverting), and the confidence level (e.g.
% 0.95 for performing PCA principal component analysis)
function [] = simulateCorrelatedMarketRiskFactors(ci, num_of_simulation_years, calcParms, simulate)
    % load all input risk factors
    input_risk_factors = loadAllFilesInPathIntoStruct('mat files\input market risk factors');    
    input_risk_factors = cell2mat(input_risk_factors)'; % num_of_observations (row) X num_of_riskfactors (col)
    
    % calculate input parms for the chosen model
    [returns, parms] = calcParms(input_risk_factors);
    
    % calc correlation matrix
    C = corrcoef(returns);

    [PCA_eigenvalues, PCA_eigenvectors] = PCA(C,ci);
    
    % synthesise correlated observations for all risk factors
    [num_of_observations num_of_risk_factors] = size(input_risk_factors);
    returns_t = ones(1,num_of_risk_factors); % return for all risk factors at time t - init to all 1 (could be something else)
    num_of_iterations = floor(252 * num_of_simulation_years);
    for t=1:num_of_iterations % 252 simulation days in a year
        %%%%%%% For testing against Razor, the following line should be
        %%%%%%% replaced by the normally distributed random sequence
        %%%%%%% generated by Razor
        num_of_PCA_eigenvalues = length(PCA_eigenvalues);
        wts = randn(1,num_of_PCA_eigenvalues); % a row vector w(t) of uncorrelated normally distributed rv
        zts = generateCorrelatedNormalRvs(wts, PCA_eigenvalues, PCA_eigenvectors)
        
        % generate daily simulations according to model chosen
        returns_t = simulate(returns_t, zts, parms);
    end
    
end