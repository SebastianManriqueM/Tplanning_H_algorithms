function [ pos_novo ] = hc_R_Marginal( x, num_linhas, num_barras, nodo_i, nodo_j, n_ij0, n_ij, n_ij_max, Yij_linha, Fij_max, Barra, Tipo_barra, g, Custo_ij )
%hc_R_Marginal Summary of this function goes here
%   Detailed explanation goes here

%|| Cálculo P_Linhas e Investimento ||
%=====================================
[ F_ij, investimento] = calcular_fluxo_ij( num_linhas, nodo_i, nodo_j, Yij_linha, n_ij0, n_ij, x(1:num_barras), zeros(num_linhas,1) );


%|| Cálculo Parâmetros Rede Marginal ||
%======================================
g_rm    = abs(g - x(num_barras+1:2*num_barras));
beq     = x(2*num_barras+1:3*num_barras);                    %Equivale a d_rm (Demanda_Rede_Marginal = r_i (corte))
n_ij_bp = zeros(num_linhas,1);
for i = 1 : num_linhas
    if(n_ij0(i) + n_ij(i) > 0)
        n_ij_bp(i) = 1 - ( abs(F_ij(i)) / (Fij_max(i)*(n_ij0(i) + n_ij(i))) );
    end
end
n_ij_bp = abs(n_ij_bp);
    

%|| 1) Criar Matrizes do Modelo da Rede Marginal para Linprog ||
%===============================================================
[ f,A,b,Aeq,lb,ub ] = M_Modelo_Marginal( num_linhas, num_barras, nodo_i, nodo_j, n_ij0, n_ij, n_ij_max, Yij_linha, Fij_max, Barra, Tipo_barra, g_rm, n_ij_bp, Custo_ij, F_ij  );


%|| 2) Solucionar PL com linprog ||
%==================================
[x_rm, fval_rm, exitflag_rm, output_rm, lambda_rm] = linprog(f, A, b, Aeq, beq, lb, ub);

flag = 1;
while(flag)
    a = find( abs(x_rm( 1 : num_linhas)) == max( abs(x_rm(1 : num_linhas) )) );

    if ( n_ij(a(1)) >=  n_ij_max(a(1)) ) 
        flag       = 1;
        x_rm(a(1)) = 0;
    else
        break;
    end
end

pos_novo = a(1);


clear g_rm;
clear d_rm;
clear n_ij_bp;
clear n_saturados;
clear f;
clear A;
clear Aeq;
clear b;
clear beq;
clear lb;
clear ub;
clear flag;

clear x_rm;
clear fval_rm;
clear exitflag_rm;
clear output_rm;
clear lambda_rm;
end

