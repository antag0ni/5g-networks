% N=10; x=rand(1,N)<.5 (genero la sorgente)
% C=rand(1,N)<0.01 (genero il canale)
% y=xor(x,c) (stringa in uscita)
% err=not(x==y) (calcolo errore)
% hatpe=sum(err)/N (probabilità di errore stimata)

%N=1000; 

% probabilità di errore del canale
%pe=0.01; 

function prova(pe,N)
% Stringa in input
x=rand(1,N)<.5;
% Simulo il canale
c=rand(1,N)<pe;
% Stringa in uscita
y=xor(x,c);
% Stringa di errore
err=not(x==y);
% Stima della probabilità di errore
hatpe=sum(err)/N;

fprintf('Probabilità di errore = %f\n', pe);
fprintf('Stima della prob. di errore = %f\n', hatpe);
end