function [Ans_Fluxo, Ans_Theta, Ans_Geracao, Ans_Corte_Carga, Ans_Custo, Ans_Nij_Add] = Fluxo_Hibrido (Nij_Add, Geracao, Barras, Demanda, Fij_Max, Ni, Nj, Nij_Base, Nij_Max, Num_Barras, Num_Linhas, Tipo_Barra, Xij, Custo)

Numero_Circuitos_Existentes = 0; %Valor Inicial

for i = 1:Num_Linhas %Conta quantos circuitos existem na configuração atual (base)
    if Nij_Base (i) ~= 0
        Numero_Circuitos_Existentes = Numero_Circuitos_Existentes + 1; %Incremente
    end
end

%% Montagem das restrições da 1a. lei de Kirchhoff
Aeq = zeros (Numero_Circuitos_Existentes + Num_Barras,3*Num_Linhas+3*Num_Barras); %[Aeq]*x = Beq
Beq = zeros (Numero_Circuitos_Existentes + Num_Barras,1);

for i = 1:Num_Barras      %Constroi as restricoes
    for j = 1: Num_Linhas %Varredura nos dados de linha
        if Ni(j) == i     %Verifica se Ni é da barra procurada
            if Nij_Base (j) ~= 0 %Verifica se o circuito está na configuração corrente
            Aeq (i,j) = 1;
            end
            Aeq (i,j+Num_Linhas) = 1; %Os circuitos artificiais sempre serão considereados
        end
        if Nj(j) == i     %Verifica se Nj é da barra procurada
            if Nij_Base (j) ~= 0
            Aeq (i,j) = -1;
            end
            Aeq (i,j+Num_Linhas) = -1;  %Os circuitos artificiais sempre serão considereados           
        end
    end
    Aeq(i,(i+2*Num_Linhas))              = - 1; %Referente aos geradores
    Aeq(i,(i+2*Num_Linhas+2*Num_Barras)) = - 1; %Referente ao corte de carga 
    Beq(i)                             = - Demanda (i);
end

%% Montagem das restrições da 2a. lei de Kirchhoff

%Verifica a quantidade de circuitos existentes na configuração base
        
for i = 1:Numero_Circuitos_Existentes
    if Nij_Base(i) ~= 0
        Aeq(i+Num_Barras,i) = 1;
        Nij_eq = Nij_Base(i); %Número de circuitos na configuração atual
        Aeq(i+Num_Barras, Ni(i)+2*Num_Linhas+Num_Barras) = - inv(Xij(i))*Nij_eq; %Referente a theta_i
        Aeq(i+Num_Barras, Nj(i)+2*Num_Linhas+Num_Barras) = + inv(Xij(i))*Nij_eq; %Referente a theta_j
    end
end

%% Restrições físicas e operativas

% X = linprog(f,A,b,Aeq,beq,LB,UB) defines a set of lower and upper
%     bounds on the design variables, X, so that the solution is in
%     the range LB <= X <= UB. Use empty matrices for LB and UB
%     if no bounds exist. Set LB(i) = -Inf if X(i) is unbounded below; 
%     set UB(i) = Inf if X(i) is unbounded above.

LB = zeros (3*Num_Linhas+3*Num_Barras,1);
UB = zeros (3*Num_Linhas+3*Num_Barras,1);

for i = 1:Num_Linhas %Restrição de fluxo na linha
        Nij_eq = Nij_Base(i); %Restrição de fluxo para a configuração base
        LB(i)  = - Nij_eq * Fij_Max (i);
        UB(i)  = -LB(i);
        LB(i+Num_Linhas)  = - 1e5; %Restrição fraca de fluxo para os circuitos adicionais
        UB(i+Num_Linhas)  =   1e5;
end

for i = 1:Num_Barras %Restrição de capacidade de geração
    LB (i+2*Num_Linhas) = 0;
    UB (i+2*Num_Linhas) = Geracao(i);
end

for i = 1:Num_Barras % theta limitado em -pi/2 e pi/2
    LB (2*Num_Linhas+Num_Barras+i) = -pi/2;
    UB (2*Num_Linhas+Num_Barras+i) =  pi/2; 
end

for i = 1:Num_Barras %Coloca a Barra SLACK
    if Tipo_Barra (i) == 3
    LB (2*Num_Linhas+Num_Barras+i) = 0; %SLACK
    UB (2*Num_Linhas+Num_Barras+i) = 0;
%     disp ('Slack');
%     disp (i);
    break
    end;
end

for i = 1:Num_Linhas % Restrição do número máximo de linhas
    UB (2*Num_Linhas+3*Num_Barras + i,1) = Nij_Max (i);
end

A = zeros ( 2*Num_Linhas, 3*Num_Linhas+3*Num_Barras);
B = zeros ( 2*Num_Linhas, 1);
contador = 1;

for i = 1:Num_Linhas %Referente a restrição do módulo do limite do fluxo (+) 
        A (contador,i+Num_Linhas) = 1;
        A (contador,i+2*Num_Linhas+3*Num_Barras) = -1*Fij_Max (i);
        contador = contador + 1;
end

for i = 1:Num_Linhas %Referente a restrição do módulo do limite do fluxo (-)
        A (contador,i+Num_Linhas) = -1;
        A (contador,i+2*Num_Linhas+3*Num_Barras) =- Fij_Max (i);
        contador = contador + 1;
end     
        
%% Função objetivo
% min f'*x    subject fto:   A*x <= b 

f = zeros (3*Num_Linhas+3*Num_Barras,1);
for i = 1:Num_Linhas
   f(i+2*Num_Linhas+3*Num_Barras) =  Custo (i);
end

[X FO] = linprog (f,A,B,Aeq,Beq,LB,UB);

Ans_Fluxo       = X(1:2*Num_Linhas);
Ans_Geracao     = X(2*Num_Linhas+1:2*Num_Linhas+Num_Barras);
Ans_Theta       = X(2*Num_Linhas+Num_Barras+1:2*Num_Linhas+2*Num_Barras);
Ans_Corte_Carga = X(2*Num_Linhas+2*Num_Barras+1:2*Num_Linhas+3*Num_Barras);
Ans_Nij_Add     = X(2*Num_Linhas+3*Num_Barras+1:3*Num_Linhas+3*Num_Barras);

Custo_Linhas = 0; 
for i = 1:Num_Linhas
   Custo_Linhas =  Custo_Linhas + Ans_Nij_Add(i)*Custo(i);
end
Ans_Custo       = Custo_Linhas;
end