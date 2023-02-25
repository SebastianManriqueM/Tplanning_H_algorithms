function imprimir_res( num_barras, n_ij0, n_ij , num_linhas, nodo_i, nodo_j, Custo_ij, investimento, nome_sis, cont, metodo )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%------------------------------------------------
%|||||||    Impresão dados de Entrada    |||||||
%------------------------------------------------
tex=fopen(['Resultado_Heurística_', nome_sis,'-', num2str(metodo), '.txt'],'w');                  %Abro arquivo de texto
fprintf(tex, '========================================\r\n');
fprintf(tex, '|||||   DADOS BÁSICOS DE ENTRADA   |||||\r\n');
fprintf(tex, '========================================\r\n\r\n');
fprintf(tex,strcat('\r\tData: ', datestr(now), '\r\n\r\n'));
fprintf(tex,strcat('\r\tNome do sistema: ', nome_sis,'\r\n') );
fprintf(tex,strcat('\r\tMétodo Usado: ', num2str(metodo),'\r\n') );
fprintf(tex,strcat('\r\tBarras= ', num2str(num_barras), '\r\t', '\r\n') );
fprintf(tex,strcat('\r\tNumero de Linhas: ', num2str(num_linhas),'\r\n\r\n') );
fprintf(tex,strcat( '\r\tITERAÇÕES =  ', num2str(cont), '\r\n\r\n\r\n' ));
%:::::::::::::::::::::::::::::::::::::::::::::::::::

%------------------------------------------------
%|||||||    Impresão Resultados Linhas    |||||||
%------------------------------------------------


fprintf(tex, '=================================\r\n');
fprintf(tex, '|||||   RESULTADOS LINHAS   |||||\r\n');
fprintf(tex, '=================================\r\n\r\n');
fprintf(tex, 'Bus i\r\tBus j\r\tn_ij novo\r\tn_ij inicial\r\tCosto \r\n\r\n' );

for i = 1 : num_linhas
    fprintf(tex,'%3.1f\r\t %3.1f\r\t %3.1f\r\t\r\t %3.1f\r\t\r\t %3.1f \r\n',nodo_i(i), nodo_j(i), n_ij(i), n_ij0(i), Custo_ij(i) );
end

fprintf(tex,strcat('\r\n\r\n\r\tINVESTIMENTO TOTAL: ', num2str(investimento),'\r\n\r\n') );
fprintf(tex,strcat('\r\n\r\tNUMERO DE LINHAS NOVAS: ', num2str(sum(n_ij)),'\r\n\r\n') );

fclose(tex);
