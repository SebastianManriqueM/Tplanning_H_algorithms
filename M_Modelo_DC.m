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

function [ f,A,b,Aeq,lb,ub ] = M_Modelo_DC( num_linhas, num_barras, nodo_i, nodo_j, n_ij0, n_ij, Yij_linha, Fij_max, Barra, Tipo_barra, g, d, alfa, flag_ang  )
%M_Modelo_DC Summary of this function goes here
%   Variáveis [theta_i, g_i, r_i]


%||  Construir funçaõ Obj ||
%===========================
   %Função objetivo sem custo das linhas para tirar não linearidade
f = zeros(1,3*num_barras);

for i = 1 : num_barras
    f(2*num_barras + i) = alfa;
end
%---------------------------------------------------------------------------------------------------------------------


%||  Construir Restrição 1 (b*Theta + g + r = d)(Aeq)||
%======================================================


%||  Construir Matriz B (parte de Aeq) ||
B_barras = zeros(num_barras,num_barras);                                    %O tamanho desta matriz é igual ao número de barras

for i = 1 : num_linhas
    % Elementos fora da diagonal
    B_barras( nodo_i(i), nodo_j(i) ) = Yij_linha(i) * ( n_ij0(i) + n_ij(i) );
    B_barras( nodo_j(i), nodo_i(i) ) = B_barras( nodo_i(i), nodo_j(i) );
    
    % Elementos da diagonal
    B_barras( nodo_i(i), nodo_i(i) ) = B_barras( nodo_i(i), nodo_i(i) ) - Yij_linha(i) * ( n_ij0(i) + n_ij(i) );
    B_barras( nodo_j(i), nodo_j(i) ) = B_barras( nodo_j(i), nodo_j(i) ) - Yij_linha(i) * ( n_ij0(i) + n_ij(i) );
end

Aeq = [ B_barras, zeros(num_barras, 2*num_barras)];                %Zeros -->n_ij, ones g_i e r_i
clear B_barras;

for i = 1 : num_barras
    %g_i
    if( g(i) ~= 0 )
        Aeq(Barra(i), num_barras + Barra(i))   = 1;
    end
    %r_i
        Aeq(Barra(i), 2*num_barras + Barra(i)) = 1;
end
%---------------------------------------------------------------------------------------------------------------------


%||  Construir Restrição 2 ( |Theta|<= fhi_i_max )(A)||
%======================================================
cont = 1;
aux  = zeros(1, num_linhas);
for i = 1 : num_linhas
   if( (n_ij0(i) + n_ij(i)) > 0 )                           %Colocar restrição somente nas linhas existentes
       aux(cont) = i;
       cont      = cont + 1;
   end
end
cont = cont - 1;
M_theta = zeros(2*cont, num_barras);
aux     = uint16(aux);
b       = zeros(cont,1);
for i = 1 : cont
    a                                  = aux(i);
    %Theta <= fhi_i
    M_theta(i, nodo_i(a))              = 1;
    M_theta(i, nodo_j(a))              = -1;
    if ( flag_ang && n_ij(i) == 1e-3 )                                          %Para aplicar na Heurística de minimos cortes de carga
        b(i)                           = (100 * Fij_max(a)) / Yij_linha(a);
    else
        b(i)                           = Fij_max(a) / Yij_linha(a);
    end

    %-Theta <= fhi_i
    M_theta(cont + i, nodo_i(a)) = -1;
    M_theta(cont + i, nodo_j(a)) = 1;
    b(cont + i)                  = b(i);

end

A       = [M_theta , zeros(2*cont, 2*num_barras)];

clear M_theta;
clear cont;
clear aux;
clear a;
%---------------------------------------------------------------------------------------------------------------------


%||  Construir Restrições 3, 4 e 5 ( n_ij, g_i, r_i ) (L, U)||
%=============================================================
lb  = zeros(3*num_barras, 1);
ub  = zeros(3*num_barras, 1);

% Sem n_ij para linprog (não faz parte deste problema)

for i = 1 : num_barras
    % Para Theta_i
    if(Tipo_barra(i) == 3)
        lb(i) = 0;
        ub(i) = 0; 
    else
        lb(i) = -pi();              %-pi
        ub(i) = pi();               %pi
    end
    
    % Para g_i
    lb(num_barras + i) = 0;  
    ub(num_barras + i) = g(i);

    % Para r_i
    lb(2*num_barras + i) = 0;  
    ub(2*num_barras + i) = d(i);
end

%---------------------------------------------------------------------------------------------------------------------

end

