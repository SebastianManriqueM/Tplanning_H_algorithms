%  <SW HEURÍSTICAS PARA O PLANEJAMENTO DA TRANSMISSÃO - METAHEURITICS TO SOLUTION THE TRANSMSSION EXPANSION PROBLEM (TEP)-V1.0 
%  This is the function creates the matriz to use with linprog, part of the software that uses different constructive heuristic Algorithms to solve the Transmission Expassion Problem >
%     Copyright (C) <2014>  <Sebastián de Jesús Manrique Machado>   <e-mail:sebajmanrique747@gmail.com>
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

%SW HEURÍSTICAS PARA O PLANEJAMENTO DA TRANSMISSÃO - THIS IS FILE THAT
%CREATES THE MATRIZ TO USE WITH LINPROG COMMAND
%   Sebastián de Jesús Manrique Machado
%   Estudante_Mestrado Em Engenharia Elétrica
%   UEL - 2014.

function [ f,A,b,Aeq,lb,ub ] = M_Modelo_Marginal( num_linhas, num_barras, nodo_i, nodo_j, n_ij0, n_ij, n_ij_max, Yij_linha, Fij_max, Barra, Tipo_barra, g, n_ij_bp, Custo_ij, F_ij  );
%M_Modelo_Marginal Summary of this function goes here
%   Variáveis [n_ij_pp, n_ij_p, f_ij, g_i]


%||  Construir funçaõ Obj ||
%===========================
   %Função objetivo sem custo das linhas para tirar não linearidade
f = zeros(1,3*num_linhas + num_barras);

for i = 1 : num_linhas
    f(i) = Custo_ij(i);
end
%---------------------------------------------------------------------------------------------------------------------


%||  Construir Restrição 1 (Primera Lei de Kirchoff)||
%=====================================================


%||  Construir Matriz B (parte de Aeq) ||
S_barras = zeros(num_barras,num_linhas);                                    %O tamanho desta matriz é igual ao número de barras

for i = 1 : num_linhas
    % Matriz de  Incidência
    S_barras( nodo_i(i), i ) = -1;
    S_barras( nodo_j(i), i ) = 1;
end

Aeq = [ zeros(num_barras, 2*num_linhas), S_barras, zeros(num_barras, num_barras)];
clear S_barras;


for i = 1 : num_barras
    %g_i
    if( g(i) ~= 0 )
        Aeq(Barra(i), 3*num_linhas + Barra(i))   = 1;
    end
end
%---------------------------------------------------------------------------------------------------------------------


%||  Construir Restrição 2 ( |F_ij|<= F_ij_max * (n_ij_p + n_ij_pp) )(A)||
%=========================================================================
%Ctos Saturados = 0 Para não considerar na R. Marginal
n_saturados = ones(num_linhas,1);
for i = 1 : num_linhas
    if( ((n_ij(i) + n_ij0(i))*Fij_max(i)) <= (abs(F_ij(i))+ 0.00001) )
        n_saturados(i) = 0;
    end
end

A = zeros(2*num_linhas,3*num_linhas + num_barras);
b = zeros(2*num_linhas,1);
for i = 1 : num_linhas
    %F_ij<= F_ij_max * (n_ij_p + n_ij_pp)
    A(i, i)              = -Fij_max(i);         %n_ij_pp
    A(i, 2*num_linhas+i) = 1;                   %F_ij
    
    if ( n_saturados(i) && (n_ij(i) + n_ij0(i) >= 1) )  %n_ij_p
        A(i, num_linhas+i)            = -Fij_max(i);
        A(num_linhas+i, num_linhas+i) = -Fij_max(i);
    end

    %-F_ij<= F_ij_max * (n_ij_p + n_ij_pp)
    A(num_linhas+i, i)              = -Fij_max(i);          %n_ij_pp
    A(num_linhas+i, 2*num_linhas+i) = -1;                   %F_ij

end


clear n_saturados;
%---------------------------------------------------------------------------------------------------------------------


%||  Construir Restrições 3, 4 e 5 ( n_ij, g_i, r_i ) (L, U)||
%=============================================================
lb  = zeros(3*num_linhas + num_barras, 1);
ub  = zeros(3*num_linhas + num_barras, 1);

% Sem n_ij para linprog (não faz parte deste problema)
maxF = max(Fij_max) * max(n_ij_max);

for i = 1 : num_linhas
    % Para n_ij_pp
    lb(i) = 0;
    ub(i) = n_ij_max(i);

    % Para n_ij_p
    lb(num_linhas+i) = 0;
    ub(num_linhas+i) = n_ij_bp(i);              % Zero quando não tem linha

    % Para f_ij
    lb(2*num_linhas + i) = -maxF;  
    ub(2*num_linhas + i) = maxF;
end

clear maxF;

for i = 1 : num_barras
   % Para g_i
    lb(3*num_linhas + i) = 0;  
    ub(3*num_linhas + i) = g(i); 
end

%---------------------------------------------------------------------------------------------------------------------

end

