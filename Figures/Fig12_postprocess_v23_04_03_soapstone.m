clear,figure(1),clf,colormap jet,addpath ../,addpath ../Utilities/ ../Solutions/ ../EOS/
clear,colormap jet
runname  = 'soapstone_2022_02_14_n1500_nz15_full'; 
load(['linprog_run_' runname]);                                          % load linprog run data
molm      = molmass_fun(Cname);
solv_tol  = 100;
phs_modes = zeros(length(T2d(:)),length(phs_name));
for iPT = 1:length(T2d(:))    
    [pc_id,phi,Cwt,Npc,rho,mu,p_out,phiw] = postprocess_fun(T2d(iPT),P2d(iPT),td,alph_all{iPT},Npc_all{iPT},molm,p_all{iPT},pc_id_all{iPT},phs_name,solv_tol,'CORK','S14');    %     Cf(iPT) = Cwt(1,pc_id==1);
    fluid_id             =    strcmp(phs_name(pc_id),fluid);
    solid_id             =   ~strcmp(phs_name(pc_id),fluid);
    cwt_solid(:,iPT)     = Cwt(:,solid_id)*phiw(solid_id)/sum(Cwt(:,solid_id)*phiw(solid_id));
    cwt_fluid(:,iPT)     = Cwt(:,fluid_id)*phiw(fluid_id)/sum(Cwt(:,fluid_id)*phiw(fluid_id));  
    mu_tab(:,iPT)        = mu{fluid_id}{1}(1);
    rhos_tab(iPT)        = rho(solid_id)'*phi(solid_id)/sum(phi(solid_id));
    rhof_tab(iPT)        = rho(fluid_id)'*phi(fluid_id)/sum(phi(fluid_id));      
    phs_modes(iPT,pc_id) = phi;
    disp(iPT/length(T2d(:)))
end
Cs_tab = cwt_solid(strcmp(Cname,'C'),:);
Mg_tab = cwt_solid(strcmp(Cname,'Mg'),:);
Fe_tab = cwt_solid(strcmp(Cname,'Fe'),:);
Al_tab = cwt_solid(strcmp(Cname,'Al'),:);
Cf_tab = cwt_fluid(strcmp(Cname,'C'),:);
phi0 = 0.3;
Cs_im(1,:)  = Al_tab;
Cs_im(2,:)  = Mg_tab;
Cs_im(3,:)  = Fe_tab;
rhos   = rhos_tab;
rhos0  = rhos_tab(1);
for i = 1:size(Cs_im,1)
    Cs_im0 = Cs_im(i,1);
    phi_srho_sCs_im0 = (1 - phi0).*rhos0.*Cs_im0;
    phi_f(i,:)     = 1 - phi_srho_sCs_im0./(Cs_im(i,:).*rhos);
end
figure(1),plot(Cs_tab,phi_f(1,:),'o',Cs_tab,phi_f(2,:),'x',Cs_tab,phi_f(3,:),'*'),legend('Al','Mg','Fe')
solid_id    = find(~strcmp(phs_name,fluid));
solid_names = phs_name(solid_id);
vol_frac_solids = phs_modes(:,solid_id)./sum(phs_modes(:,solid_id),2);
solid_names = solid_names(sum(vol_frac_solids)>0);
vol_frac_solids = vol_frac_solids(:,sum(vol_frac_solids)>0);
figure(2),
subplot(211),area(Cs_tab,vol_frac_solids,'FaceColor','flat'),legend(solid_names),axis tight,axis square
set(gca,'FontSize',14)
subplot(212),plot(Cs_tab,Cf_tab,'*-','LineWidth',0.5),axis tight,axis square
xlabel('C solid')
ylabel('C fluid')
set(gca,'FontSize',14)
save(['lookup_' run_name], 'Cf_tab', 'Cs_tab', 'vol_frac_solids', 'solid_names', 'rhos_tab', 'rhof_tab', 'Mg_tab','mu_tab')