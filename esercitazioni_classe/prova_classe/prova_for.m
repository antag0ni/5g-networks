% NOTA: differenza tra approccio vettoriale e ciclo for
% ---------------------------------------------------------
% Versione vettoriale (x=rand(1,N)<.5 ecc.):
%   - alloca in memoria 4 vettori di lunghezza N (x, c, y, err)
%   - occupazione di memoria O(N): cresce linearmente con N
%   - più veloce (MATLAB ottimizzato per operazioni vettoriali)
%   - con N molto grande (es. BER basse, N~10^7-10^8) puo' saturare la RAM
%
% Versione con ciclo for (x=rand<.5 ad ogni iterazione):
%   - x, c, y sono scalari, sovrascritti ad ogni iterazione
%   - occupazione di memoria O(1): costante, indipendente da N
%   - piu' lenta (overhead del ciclo ad ogni iterazione)
%   - preferibile quando N e' troppo grande per essere tenuto in memoria
%     tutto insieme, o quando il canale ha memoria (stato dipendente
%     dall'iterazione precedente)
% ---------------------------------------------------------

function prova_for(pe,N)
count=0;
for i=1:N
    % Bit in input (singolo bit, non stringa)
    x=rand<.5;
    % Simulo il canale (singolo bit di errore)
    c=rand<pe;
    % Bit in uscita
    y=xor(x,c);
    % Conto l'errore
    count=count+(x~=y);
end
% Stima della probabilità di errore
hatpe=count/N;
fprintf('Probabilità di errore = %g\n', pe);
fprintf('Stima della prob. di errore = %g\n', hatpe);
end