%  <SW HEURÍSTICAS PARA O PLANEJAMENTO DA TRANSMISSÃO - METAHEURITICS TO SOLUTION THE TRANSMSSION EXPANSION PROBLEM (TEP)-V1.0 
%  This is data read function, part of the software that uses different constructive heuristic Algorithms to solve the Transmission Expassion Problem >
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

%SW HEURÍSTICAS PARA O PLANEJAMENTO DA TRANSMISSÃO - THIS IS THE FILE TO
%READ THE DATA FILE (.XLSX)
%   Sebastián de Jesús Manrique Machado
%   Estudante_Mestrado Em Engenharia Elétrica
%   UEL - 2014.
function [nome_sis, num_linhas, num_barras, nodo_i, nodo_j, n_ij0, Yij_linha, Fij_max, Custo_ij, n_ij_max, Barra, Tipo_barra, g, d ] = ler_dados()
%||  Ler dados ||
%================
nome_sis   = input('Qual é o nome do sistema?: ','s'); %Sistema_006.xlsx 

Valrs_base = xlsread(nome_sis, 'Dados_sistema', 'B1:B2');            

num_linhas = uint16(Valrs_base(2));                                  %Convertir a valor inteiro sem signo
num_barras = uint16(Valrs_base(1));                                 %Convertir a valor inteiro sem signo
clear Valrs_base;

if(strcmp(nome_sis, 'Sistema_Colombia.xlsx'))
    Dados_barras = xlsread(nome_sis, 'Dados_sistema', 'A7:D99');
    Dados_linhas = xlsread(nome_sis, 'Dados_sistema', 'A104:G258');
    
else
    Dados_barras = xlsread(nome_sis, 'Dados_sistema', strcat( 'A7:D',num2str(num_barras+6) ));
    Dados_linhas = xlsread(nome_sis, 'Dados_sistema', strcat( 'A',num2str(num_barras+11),':G',num2str(num_linhas+10+num_barras) ));
end
%---------------------------------------------------------------------------------------------------------------------

nodo_i      = Dados_linhas(:,1);
nodo_j      = Dados_linhas(:,2);
n_ij0       = Dados_linhas(:,3);
Yij_linha   = 1./Dados_linhas(:,4);                            %Admitância Serie da Linha
Fij_max     = (1/100)*Dados_linhas(:,5);
Custo_ij    = Dados_linhas(:,6);
n_ij_max    = Dados_linhas(:,7);

Barra       = Dados_barras(:,1);
Tipo_barra  = Dados_barras(:,2);
g           = (1/100)*Dados_barras(:,3);
d           = (1/100)*Dados_barras(:,4);

clear Dados_barras;
clear Dados_linhas;
end
