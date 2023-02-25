function [ n_ijf ] = Ctos_Ficticios( num_linhas, Barras, nodo_i, nodo_j, n_ij0, n_ij )
%Ctos_Ficticios Summary of this function goes here
%   Detailed explanation goes here
n_ijf = zeros(num_linhas,1);
for i = 1 : num_linhas
    
    if( (n_ij0(i) + n_ij(i)) < 1 )
        n_ijf(i) = 0.001;
    end
    
end

end

