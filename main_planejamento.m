%  <SW HEURÍSTICAS PARA O PLANEJAMENTO DA TRANSMISSÃO - METAHEURITICS TO SOLUTION THE TRANSMSSION EXPANSION PROBLEM (TEP)-V1.0 
%  This is the main source of this software that uses different constructive heuristic Algorithms to solve the Transmission Expassion Problem >
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

%SW HEURÍSTICAS PARA O PLANEJAMENTO DA TRANSMISSÃO - THIS IS THE MAIN FILE
%   Sebastián de Jesús Manrique Machado
%   Estudante_Mestrado Em Engenharia Elétrica
%   UEL - 2014.
clear all; clc;
cont = 0;
tol  = 1e-6;
metodo = 0;
while(metodo == 0 || metodo > 4)
    metodo  = input('Qual Heurístico ? (ME=1, MCC=2, RM = 4): ');
end

%||  Ler dados ||
%================
[nome_sis, num_linhas, num_barras, nodo_i, nodo_j, n_ij0, Yij_linha, Fij_max, Custo_ij, n_ij_max, Barra, Tipo_barra, g, d ] = ler_dados();


n_ij      = zeros(num_linhas,1);  %[0; 0; 0; 0; 0; 0; 0; 0; 4; 0; 1; 0; 0; 2; 0];       %Número de linhas novas

alfa      = 100 * max(Custo_ij);
beq       = d;
tol_r     = zeros(num_barras,1); 

for i = 1 : num_barras
   tol_r(i) = tol;
end

disp('Inicio ----> SW HEURÍSTICAS PARA O PLANEJAMENTO DA TRANSMISSÃO');
disp(datestr(now));
%|| Iterações ||
%===============
 while(cont < 5 * num_linhas)
    
    %|| 1) Criar Matrizes do Modelo DC para Linprog ||
    %=================================================
    if( metodo == 1)
        %||  Criar Ctos_Ficticios ||
        [ n_ijf ]           = Ctos_Ficticios( num_linhas, Barra, nodo_i, nodo_j, n_ij0, n_ij );                %Ctos Ficticios para problemas ilhados.
        [ f,A,b,Aeq,lb,ub ] = M_Modelo_DC( num_linhas, num_barras, nodo_i, nodo_j, n_ij0, n_ij + n_ijf, Yij_linha, Fij_max, Barra, Tipo_barra, g, d, alfa, 0  ); % Chamada com Ficticios (1 para corte de carga)

    elseif( metodo == 2)
        %||  Criar Ctos_Ficticios ||
        [ n_ijf ]           = Ctos_Ficticios( num_linhas, Barra, nodo_i, nodo_j, n_ij0, n_ij );                %Ctos Ficticios para problemas ilhados.
        [ f,A,b,Aeq,lb,ub ] = M_Modelo_DC( num_linhas, num_barras, nodo_i, nodo_j, n_ij0, n_ij + n_ijf, Yij_linha, Fij_max, Barra, Tipo_barra, g, d, alfa, 1  ); % Chamada com Ficticios (1 para corte de carga)
        
    elseif( metodo == 3)
        %||  Criar Ctos_Ficticios ||
        [ n_ijf ]           = Ctos_Ficticios( num_linhas, Barra, nodo_i, nodo_j, n_ij0, n_ij );                %Ctos Ficticios para problemas ilhados.
        [ f,A,b,Aeq,lb,ub ] = M_Modelo_DC( num_linhas, num_barras, nodo_i, nodo_j, n_ij0, n_ij + n_ijf, Yij_linha, Fij_max, Barra, Tipo_barra, g, d, alfa, 1  ); % Chamada com Ficticios (1 para corte de carga)
        
    elseif(metodo == 4)
        [ f,A,b,Aeq,lb,ub ] = M_Modelo_DC( num_linhas, num_barras, nodo_i, nodo_j, n_ij0, n_ij, Yij_linha, Fij_max, Barra, Tipo_barra, g, d, alfa, 0  ); % Chamada Rede Marginal      
    end
            
    %|| 2) Solucionar PL com linprog ||
    %==================================
    [x, fval, exitflag, output, lambda] = linprog(f, A, b, Aeq, beq, lb, ub);

    %|| 3) Avaliar fatibilidade da configuração ||
    %=============================================    
     if( all(abs(x(2*num_barras+1:3*num_barras , 1)) <= tol_r) )
         break;
     end
    
    %|| 4) Aplicar Heurística ||
    %===========================
    if( metodo == 1)
        [ pos_novo ]   = hc_minimo_esforco( num_linhas, nodo_i, nodo_j, x(1:num_barras , 1), Custo_ij, Yij_linha, n_ij, n_ij_max );

    elseif( metodo == 2)
        [ pos_novo ]   = hc_minimo_corte_c( num_linhas, nodo_i, nodo_j, x(1:num_barras , 1), Custo_ij, lambda.eqlin, n_ij, n_ij_max );
        
    elseif( metodo == 3)
       [ pos_novo ]    = hc_minimo_corte_c( num_linhas, nodo_i, nodo_j, x(1:num_barras , 1), Custo_ij, lambda.eqlin, n_ij, n_ij_max );
       
    elseif(metodo == 4)
        [ pos_novo ]   = hc_R_Marginal( x, num_linhas, num_barras, nodo_i, nodo_j, n_ij0, n_ij, n_ij_max, Yij_linha, Fij_max, Barra, Tipo_barra, g, Custo_ij );
    end    
    
    %|| 5) Adicionar Cto_novo ||
    %===========================
    n_ij(pos_novo) = n_ij(pos_novo) + 1;                                                                    
    cont = cont + 1;
    
    disp('Iteração');
    disp(cont);
    disp('Cto novo');
    disp(pos_novo);
    disp('theta');
    disp(x(1:num_barras)');
 end

 
 f_fase2  = 1;
 Custo_f2 = Custo_ij;
 for i =1 : num_linhas
    if(n_ij(i) == 0)
        Custo_f2(i) = 0;
    end
 end
disp('Inicio FASE II!!');
 while( ~all(Custo_f2(1:num_linhas , 1) == zeros(num_linhas,1) ) )
     a = find( Custo_f2 == max( Custo_f2 ) );
     n_ij(a(1)) = n_ij(a(1)) - 1;
     [ f,A,b,Aeq,lb,ub ] = M_Modelo_DC( num_linhas, num_barras, nodo_i, nodo_j, n_ij0, n_ij, Yij_linha, Fij_max, Barra, Tipo_barra, g, d, alfa, 0  );
     [x, fval, exitflag, output, lambda] = linprog(f, A, b, Aeq, beq, lb, ub);
     
     if( (any(abs(x(2*num_barras+1:3*num_barras , 1)) >= tol_r))  )
         Custo_f2(a(1)) = 0;
         n_ij(a(1)) = n_ij(a(1)) + 1;
     end
     if (n_ij(a(1)) == 0)
         Custo_f2(a(1)) = 0;
     end
     %[ output_args ] = f2_minimo_esforco( num_linhas, );
 end
 
 
%|| Cálculo P_Linhas e Investimento ||
%=====================================
[ F_ij, investimento] = calcular_fluxo_ij( num_linhas, nodo_i, nodo_j, Yij_linha, n_ij0, n_ij, x(1:num_barras), Custo_ij );


%||  Imprimir arquivo de texto  ||
%=================================
%imprimir_res
imprimir_res( num_barras, n_ij0, n_ij , num_linhas, nodo_i, nodo_j, Custo_ij, investimento, nome_sis, cont, metodo );
disp('theta');
disp(x(1:num_barras)');
disp('Geração');
disp(x(num_barras+1:2*num_barras)');
disp('Corte');
disp(x(2*num_barras+1:3*num_barras)');
disp('Ctos Add');
disp(n_ij');
disp('Investimento');
disp(investimento');

disp('Fim ----> SW HEURÍSTICAS PARA O PLANEJAMENTO DA TRANSMISSÃO');
disp(datestr(now));