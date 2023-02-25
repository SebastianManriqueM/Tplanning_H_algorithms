%  <SW HEURÍSTICAS PARA O PLANEJAMENTO DA TRANSMISSÃO - METAHEURITICS TO SOLUTION THE TRANSMSSION EXPANSION PROBLEM (TEP)-V1.0 
%  THIS IS THE Minimum load cut Heuristic function, part of the software that uses different constructive heuristic Algorithms to solve the Transmission Expassion Problem >
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

%SW HEURÍSTICAS PARA O PLANEJAMENTO DA TRANSMISSÃO - THIS IS THE Minimum
%load cut Heuristic Algorithm
%   Sebastián de Jesús Manrique Machado
%   Estudante_Mestrado Em Engenharia Elétrica
%   UEL - 2014.
function [ pos_novo ] = hc_minimo_corte_c( num_linhas, nodo_i, nodo_j, theta_ij, Custo_ij, Lagrange, n_ij, n_ij_max )
%Minimum load cut Heuristic Algorithm Summary of this function goes here
%   Detailed explanation goes here
indice = zeros(num_linhas,1);
flag   = 1;

for i = 1 : num_linhas
    indice(i) = ( (theta_ij(nodo_i(i)) - theta_ij(nodo_j(i))) * (Lagrange(nodo_i(i)) - Lagrange(nodo_j(i))) ) / Custo_ij(i);
end

%||  Garantir Limites de adições de circuitos ||
%===============================================
while(flag)
    a = find( indice == max( indice ) );

    if ( n_ij(a(1)) >=  n_ij_max(a(1)) ) 
        flag = 1;
        indice(a(1)) = 0;
    else
        break;
    end
end

pos_novo = a(1);

clear indice;
clear flag;
clear i;
clear a;
end
%6 BARRAS
%** Sem incremento nos valores de theta em circuitos virtuais
% sem custo 310
% Ctos Add
%      0     0     0     0     1     0     0     0     2     0     0     0     0     2     2
% com custo 231
% Ctos Add
%      0     0     0     0     0     0     0     0     3     0     1     0     0     2     1

%** Com incremento nos valores de theta
% sem custo 310 igual
% Ctos Add
%      0     0     0     0     1     0     0     0     2     0     0     0     0     2     2
% com custo 200 ******muda
%Ctos Add
%     0     0     0     0     0     0     0     0     4     0     1     0     0     2     0