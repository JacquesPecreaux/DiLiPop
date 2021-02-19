function [delta, H1_abs, H2_abs] = evolve_normal_WENOv(phi, dx, dy, Vn)
%
% Finds the amount of evolution under a force in
% normal direction and using 2nd order accurate ENO scheme
%
% Author: Baris Sumengen  sumengen@ece.ucsb.edu
% http://vision.ece.ucsb.edu/~sumengen/
% Vectorize for speed by Jacques Pecreaux

global delta data_ext

delta = zeros(size(phi)+6);
data_ext = zeros(size(phi)+6);
data_ext(4:end-3,4:end-3) = phi;

global phi_x_minus phi_x_plus phi_y_minus phi_y_plus phi_x phi_y
% Calculate the derivatives (both + and -)
phi_x_minus = zeros(size(phi)+6);
phi_x_plus = zeros(size(phi)+6);
phi_y_minus = zeros(size(phi)+6);
phi_y_plus = zeros(size(phi)+6);
phi_x = zeros(size(phi)+6);
phi_y = zeros(size(phi)+6);

%% first scan the rows
phi_x_minus(4:(size(phi,1)+3),:)=der_WENO_minusvx(data_ext(4:(size(phi,1)+3),:), dx);
phi_x_plus(4:(size(phi,1)+3),:)=der_WENO_plusvx(data_ext(4:(size(phi,1)+3),:), dx);
phi_x(4:(size(phi,1)+3),:)=select_der_normal(Vn(4:(size(phi,1)+3),:), phi_x_minus(4:(size(phi,1)+3),:), phi_x_plus(4:(size(phi,1)+3),:));
% checked on June 16th
%%
if 0
    for i=1:size(phi,1)
        phi_x_minus(i+3,:) = der_WENO_minus(data_ext(i+3,:), dx);	
        phi_x_plus(i+3,:) = der_WENO_plus(data_ext(i+3,:), dx);	
        phi_x(i+3,:) = select_der_normal(Vn(i+3,:), phi_x_minus(i+3,:), phi_x_plus(i+3,:));
    end
end

%% then scan the columns
phi_y_minus(:,4:(size(phi,2)+3))=der_WENO_minusvy(data_ext(:,4:(size(phi,2)+3)), dy);
phi_y_plus(:,4:(size(phi,2)+3))=der_WENO_plusvy(data_ext(:,4:(size(phi,2)+3)), dy);
phi_y(:,4:(size(phi,2)+3))=select_der_normal(Vn(:,4:(size(phi,2)+3)), phi_y_minus(:,4:(size(phi,2)+3)), phi_y_plus(:,4:(size(phi,2)+3)));
% checked on June 16th
%%
if 0
    for j=1:size(phi,2)
        phi_y_minus(:,j+3) = der_WENO_minus(data_ext(:,j+3), dy);	
        phi_y_plus(:,j+3) = der_WENO_plus(data_ext(:,j+3), dy);	
        phi_y(:,j+3) = select_der_normal(Vn(:,j+3), phi_y_minus(:,j+3), phi_y_plus(:,j+3));
    end
end

%%
global abs_grad_phi H1_abs H2_abs

abs_grad_phi = sqrt(phi_x.^2 + phi_y.^2);

H1_abs = abs(Vn.*phi_x.^2 ./ (abs_grad_phi+dx*dx*(abs_grad_phi == 0)));
H2_abs = abs(Vn.*phi_y.^2 ./ (abs_grad_phi+dx*dx*(abs_grad_phi == 0)));
H1_abs = H1_abs(4:end-3,4:end-3);
H2_abs = H2_abs(4:end-3,4:end-3);

delta = Vn.*abs_grad_phi;
delta = delta(4:end-3,4:end-3);

