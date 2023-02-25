function [ F_ij, investimento] = calcular_fluxo_ij( num_linhas, nodo_i, nodo_j, Yij_linha, n_ij0, n_ij, theta_i, Custo_ij )
%calcular_fluxo_ij Calcula fluxo pelas linhas do Modelo DC
%   Detailed explanation goes here
F_ij         = zeros(num_linhas,1);
investimento = 0;
for i = 1 :  num_linhas
    F_ij(i) = ( theta_i( nodo_i(i) ) - theta_i( nodo_j(i) ) ) * (Yij_linha(i) * (n_ij0(i) + n_ij(i)));
    investimento = investimento + (Custo_ij(i) * n_ij(i));
end

clear i;
end
