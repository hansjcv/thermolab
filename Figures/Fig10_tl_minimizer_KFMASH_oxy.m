clear,clf,addpath ../ ../Solutions ../EOS
run_name = 'KFMASH_2022_03_06_10x11_oxy';
T     = linspace(400,700,10) + 273.15;
P     = linspace(0.1,1.5,11)*1e9;
Cname = {'SiO2','Al2O3'       ,'FeO'   ,'MgO', 'K2O',    'H2O'};
Nsys  = [68     12.488    10.529  4.761  3.819  50]; % someone measured rock composition of a pelite
% Choose possible phases to consider in the equilibrium calculation (in the Gibbs minimization)
phs_name = {'Chlorite','Garnet','Biotite','Muscovite','Staurolite','Feldspar(C1)','Chloritoid',...
            'Cordierite','and,tc-ds55','sill,tc-ds55','ky,tc-ds55','H2O,tc-ds55','q,tc-ds55'};
td       = init_thermo(phs_name,Cname,'solution_models_KFMASH');
p        = props_generate(td);     % generate endmember proportions
[T2d,P2d] = ndgrid(T,P);
% Minimization refinement
for iPT = 1:length(T2d(:))
    [alph_all{iPT},Npc_all{iPT},pc_id_ref{iPT},p_ref{iPT},g_min{iPT}] = tl_minimizer(T2d(iPT),P2d(iPT),Nsys,phs_name,p,td);
    disp(iPT/length(T2d(:)))
end
save(['linprog_run_' run_name],'-v7.3');