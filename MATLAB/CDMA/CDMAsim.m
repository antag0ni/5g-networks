function [med_emp, var_emp, var_thr, pe_emp, pthr] = CDMAsim(N, Tb, Tc, MC)
    % CDMAsim: Simula il comportamento dell'interferenza MAI e della BER in CDMA.
    % 
    % INPUT:
    %   N   : Numero di utenti totali
    %   Tb  : Durata del bit [s]
    %   Tc  : Durata del chip [s]
    %   MC  : Numero di simulazioni Monte Carlo
    %
    % OUTPUT:
    %   med_emp : Media empirica dell'interferenza
    %   var_emp : Varianza empirica dell'interferenza
    %   var_thr : Varianza teorica dell'interferenza
    %   pe_emp  : Probabilità di errore empirica (BER)
    %   pthr    : Probabilità di errore teorica (Q-function)

    Lc = round(Tb / Tc); % Guadagno di processo (Spreading Factor)
    
    % Preallocazione delle variabili per efficienza
    interf = zeros(1, MC);
    err = zeros(1, MC);
    
    for m = 1:MC
        %% 1. Generazione delle sequenze di codice PN (Pseudo-Noise) {-1, +1}
        % C ha dimensione (N x Lc). Ogni riga rappresenta un utente.
        C = 2 * (rand(N, Lc) < 0.5) - 1;
        
        %% 2. Generazione del simbolo trasmesso dall'utente 1
        s1 = 2 * (rand < 0.5) - 1;
        utile = s1 * sqrt(Tb); % Componente di segnale utile al ricevitore
        
        %% 3. Calcolo dell'interferenza multi-utente (MAI)
        % Somma dei codici di tutti gli utenti tranne l'utente 1
        a = sum(C(2:end, :), 1);
        
        % Sequenza dell'utente 1 (desiderato)
        c1 = C(1, :);
        
        % Prodotto scalare e riscalatura per il filtro adattato (correlatore)
        interf(m) = (Tc / sqrt(Tb)) * (a * c1');
        
        %% 4. Decisione del ricevitore
        y = utile + interf(m);  % Segnale in uscita al filtro adattato
        hats1 = 2 * (y > 0) - 1; % Stimatore del simbolo (-1 o +1)
        
        % Conteggio errori
        err(m) = (hats1 ~= s1);
    end
    
    %% Calcolo delle statistiche empiriche e teoriche
    med_emp = mean(interf);
    var_emp = var(interf);
    
    % Varianza teorica del termine di interferenza MAI
    var_thr = Tc * (N - 1); 
    
    % BER Empirica e Teorica
    pe_emp = mean(err);
    pthr = qfunc(sqrt(Tb) / sqrt(var_thr));
end