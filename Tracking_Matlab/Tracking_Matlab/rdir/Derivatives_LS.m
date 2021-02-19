function [Der_small,dt] = Derivatives_LS(phi, dx, dy, alpha,accuracy, is_signed_distance,kappa_lambda,order)

%
% Jacques Pecreaux, pecreaux@mpi-cbg.de, May 23rd 2009
%
global Image_param;
%
if ~exist('kappa_lambda','var') || isempty(kappa_lambda)
    kappa_lambda=1;
end

if alpha <= 0 || alpha >= 1 
    error('alpha needs to be between 0 and 1!');
end
dt=1; % will be overwritten in ENO case
if order<=0
    Der_small=[];
    return
end
%%
vectorize_version=0;
	switch(accuracy)
		case 'ENO1'
			der_minus = @der_ENO1_minus;
		case 'ENO2'
			der_minusx = @der_ENO2_minusv;
            der_minusy = @der_ENO2_minusv;
            der_plusx=@der_ENO2_plusv;
            der_plusy=@der_ENO2_plusv;
            vectorize_version=1;
		case 'ENO3'
			der_minus = @der_ENO3_minus;
		case 'WENO'
			der_minusx = @der_WENO_minusvx;
            der_minusy = @der_WENO_minusvy;
            der_plusx= @der_WENO_plusvx;
            der_plusy= @der_WENO_plusvy;
            vectorize_version=1;
        case 'CENT4'    
            vectorize_version=1;
        case 'CWENO4'
			der_minusx = @(p1,p2,p3,p4) der_CWENO4_v_core(p1,p2,[],1);
            der_minusy = @(p1,p2,p3,p4) der_CWENO4_v_core(p1,p2,[],0);
            der_plusx=  @(p1,p2,p3,p4) der_CWENO4_v_core(p1,p2,[],1);
            der_plusy= @(p1,p2,p3,p4) der_CWENO4_v_core(p1,p2,[],0);
            vectorize_version=1;           
		otherwise
			error('Desired type of the accuracy is not correctly specified!');
    end
%%    
    global delta data_ext
    global Uphi Vphi
    
    if vectorize_version
%% init
                switch(accuracy)
                    case 'ENO2'
%                         dt = get_dt_vector(alpha, dx, dy, kappa_lambda, kappa_lambda);
%                         delta = zeros(size(phi)+4);
%                         data_ext = zeros(size(phi)+4);
                        shift=2;
                    case 'WENO'
                        shift=3;
                    case 'CENT4'
                        shift=3;
                    case 'CWENO4'
                        shift=3;
                end
                
                Der = zeros(size(phi,1)+2*shift,size(phi,2)+2*shift,14);
                data_ext = zeros(size(phi)+2*shift);
                data_ext((shift+1):(end-shift),(shift+1):(end-shift)) =phi;

%% computation        
        
        
        switch (accuracy)
            case {'ENO1' 'ENO2' 'ENO3' 'WENO' 'CWENO4'}
                    dt = get_dt_vector(alpha, dx, dy, kappa_lambda, kappa_lambda);
                    
                    Der((shift+1):(end-shift),:,1) =Image_param.rieman_solver_fct(der_minusx,der_plusx,data_ext((shift+1):(size(phi,1)+shift),:),dx);

%                     data_ext((shift+1):(end-shift),(shift+1):(end-shift)) =phi;
                    Der(:,(shift+1):(end-shift),2) =Image_param.rieman_solver_fct(der_minusy,der_plusy,data_ext(:,(shift+1):(size(phi,2)+shift)),dy);

                    if order>1

                        Der((shift+1):(end-shift),:,3) =Image_param.rieman_solver_fct(der_minusx,der_plusx,Der((shift+1):(size(phi,1)+shift),:,1),dx);

                        Der(:,(shift+1):(end-shift),4) =Image_param.rieman_solver_fct(der_minusy,der_plusy,Der(:,(shift+1):(size(phi,2)+shift),1),dy);

                        Der(:,(shift+1):(end-shift),5) =Image_param.rieman_solver_fct(der_minusy,der_plusy,Der(:,(shift+1):(size(phi,2)+shift),2),dy);
                    end

                    if order>2

                        Der((shift+1):(end-shift),:,6) =Image_param.rieman_solver_fct(der_minusx,der_plusx,Der((shift+1):(size(phi,1)+shift),:,3),dx);

                        Der(:,(shift+1):(end-shift),7) =Image_param.rieman_solver_fct(der_minusy,der_plusy,Der(:,(shift+1):(size(phi,2)+shift),3),dy);

                        Der(:,(shift+1):(end-shift),8) =Image_param.rieman_solver_fct(der_minusy,der_plusy,Der(:,(shift+1):(size(phi,2)+shift),4),dy);

                        Der(:,(shift+1):(end-shift),9) =Image_param.rieman_solver_fct(der_minusy,der_plusy,Der(:,(shift+1):(size(phi,2)+shift),5),dy);

                    end

                    if order>3

                        Der((shift+1):(end-shift),:,10) =Image_param.rieman_solver_fct(der_minusx,der_plusx,Der((shift+1):(size(phi,1)+shift),:,6),dx);

                        Der(:,(shift+1):(end-shift),11) =Image_param.rieman_solver_fct(der_minusy,der_plusy,Der(:,(shift+1):(size(phi,2)+shift),6),dy);

                        Der(:,(shift+1):(end-shift),12) =Image_param.rieman_solver_fct(der_minusy,der_plusy,Der(:,(shift+1):(size(phi,2)+shift),7),dy);

                        Der(:,(shift+1):(end-shift),13) = Image_param.rieman_solver_fct(der_minusy,der_plusy,Der(:,(shift+1):(size(phi,2)+shift),8),dy);

                        Der(:,(shift+1):(end-shift),14) = Image_param.rieman_solver_fct(der_minusy,der_plusy,Der(:,(shift+1):(size(phi,2)+shift),9),dy);

                    end

            case 'CENT4'
                    dx=1; % since this is also the spaces between point when discretizing
                    Der((shift+1):(end-shift),:,1) =derX_cent4(data_ext((shift+1):(size(phi,1)+shift),:),dx);
                    Der(:,(shift+1):(end-shift),2) =(derX_cent4(data_ext(:,(shift+1):(size(phi,2)+shift))',dy))';
                    if order>1
                        Der((shift+1):(end-shift),:,3) =derXX_cent4(data_ext((shift+1):(size(phi,1)+shift),:),dx);
                        Der(:,(shift+1):(end-shift),4) =(derX_cent4(Der(:,(shift+1):(size(phi,2)+shift),1)',dy))';
                        Der(:,(shift+1):(end-shift),5) =(derXX_cent4(data_ext(:,(shift+1):(size(phi,2)+shift))',dy))';
                    end
                    if order>2
                        Der((shift+1):(end-shift),:,6) =derXXX_cent4(data_ext((shift+1):(size(phi,1)+shift),:),dx);
                        Der(:,(shift+1):(end-shift),7) =(derX_cent4(Der(:,(shift+1):(size(phi,2)+shift),3)',dy))';
                        Der(:,(shift+1):(end-shift),8) =(derXX_cent4(Der(:,(shift+1):(size(phi,2)+shift),1)',dy))';
                        Der(:,(shift+1):(end-shift),9) =(derXXX_cent4(data_ext(:,(shift+1):(size(phi,2)+shift))',dy))';
                    end
                    if order>3
                        Der((shift+1):(end-shift),:,10) =derXXXX_cent4(data_ext((shift+1):(size(phi,1)+shift),:),dx);
                        Der(:,(shift+1):(end-shift),11) =(derX_cent4(Der(:,(shift+1):(size(phi,2)+shift),6)',dy))';
                        Der(:,(shift+1):(end-shift),12) =(derXX_cent4(Der(:,(shift+1):(size(phi,2)+shift),3)',dy))';
                        Der(:,(shift+1):(end-shift),13) =(derXXX_cent4(Der(:,(shift+1):(size(phi,2)+shift),1)',dy))';
                        Der(:,(shift+1):(end-shift),14) =(derXXXX_cent4(data_ext(:,(shift+1):(size(phi,2)+shift))',dy))';
                    end
%                     dt=[]; % empty dt create an error in reporting size
%                     of step
        end
        
%% reshape and output
        Der_small=Der((shift+1):(end-shift),(shift+1):(end-shift),:);

%%
    else
%%
        error('Derivatives ot implemented');
%%
    end
end
