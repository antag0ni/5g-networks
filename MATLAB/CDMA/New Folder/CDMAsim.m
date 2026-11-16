function [pMC,pTeoria] = CDMAsim(N,Tb,Tc,MC,N0)
% N = utenti totali; Tb = durata bit; Tc = durata chip.
% MC = prove Monte Carlo; N0 = parametro del rumore (zero lo spegne).
% Tb/Tc deve essere un intero positivo. N deve essere almeno uno.
% Utenti sincroni, ampiezza unitaria, firme rigenerate a ogni prova.

Lc = Tb/Tc;
errori = 0;

for prova = 1:MC
    s1 = 2*(rand < 0.5) - 1;
    utile = s1*sqrt(Tb);

    C = 2*(rand(N,Lc) < 0.5) - 1;
    a = sum(C(2:end,:),1);
    I = (Tc/sqrt(Tb))*(C(1,:)*a.');

    w = sqrt(N0/2)*randn;
    y = utile + I + w;
    s1_stimato = 2*(y >= 0) - 1;
    errori = errori + (s1_stimato ~= s1);
end

pMC = errori/MC;
varianza = (N-1)*Tc + N0/2;

if varianza == 0
    pTeoria = 0;
else
    % Teoria esatta con N=1; approssimazione gaussiana con interferenti.
    pTeoria = 0.5*erfc(sqrt(Tb/varianza)/sqrt(2));
end
end
