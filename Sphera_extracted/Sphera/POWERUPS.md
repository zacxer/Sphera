# Power-ups - Documentazione Tecnica

Questo documento descrive come funzionano tutti i power-up e le azioni a pagamento in Sphera.

---

## Sistema Monete (SEMPLIFICATO)

| Parametro | Valore |
|-----------|--------|
| Monete iniziali | 10 |
| Guadagno per livello | 2 base + stelle + difficoltà + bonus tempo (max ~10) |
| Rewarded AD | +25 monete |

**NOTA**: Tutti i power-up si pagano direttamente con le monete in partita.
Il negozio è solo informativo (mostra costi e descrizioni) + permette di guardare AD per monete.

---

## Azioni Base (Undo, Hint, Tubo Extra)

### 1. UNDO (Annulla)
**Costo**: 10 monete (quando esauriti i gratuiti)
**Gratuiti per livello**: 5

**Come funziona**:
1. Salva ogni mossa in `moveHistory` (array di `GameMove`)
2. `GameMove` contiene: `fromTubeIndex`, `toTubeIndex`, `ball`
3. Quando premi Undo:
   - Prende l'ultima mossa da `moveHistory`
   - Rimuove la pallina dal tubo destinazione
   - La rimette nel tubo sorgente
4. Decrementa `undoRemaining`

**Verifica se funziona**:
- [ ] Fai una mossa
- [ ] Premi Undo
- [ ] La pallina torna al tubo originale
- [ ] Il contatore `undoRemaining` diminuisce

---

### 2. HINT (Suggerimento)
**Costo**: 15 monete (quando esauriti i gratuiti)
**Gratuiti per livello**: 2

**Come funziona**:
1. Algoritmo cerca la "mossa migliore" tra tutte quelle possibili
2. Priorità:
   - Mossa che completa un tubo (massima priorità)
   - Mossa che aumenta palline consecutive
   - Mossa verso tubo con stesso colore
   - Mossa verso tubo vuoto (ultima risorsa)
3. Evidenzia:
   - Tubo SORGENTE: bordo giallo pulsante
   - Tubo DESTINAZIONE: bordo verde pulsante
   - Freccia sulla pallina da spostare
4. Auto-nascondimento dopo 3 secondi

**Verifica se funziona**:
- [ ] Premi Hint
- [ ] Un tubo diventa giallo (sorgente)
- [ ] Un tubo diventa verde (destinazione)
- [ ] La mossa suggerita è valida
- [ ] Dopo 3 secondi scompare

---

### 3. TUBO EXTRA
**Costo**: 20 monete
**Limite**: 1 per livello (`maxExtraTubes = 1`)

**Come funziona**:
1. Verifica `canAddExtraTube` (non ha già aggiunto il max)
2. Crea un nuovo `Tube` vuoto con tipo `.normal`
3. Lo aggiunge all'array `gameState.tubes`
4. Incrementa `extraTubesAdded`

**Verifica se funziona**:
- [ ] Premi Tubo +1
- [ ] Appare un nuovo tubo vuoto
- [ ] Il bottone diventa disabilitato (limite raggiunto)

---

## Power-ups Speciali

### 4. SHUFFLE (Rimescola)
**Costo**: 50 monete
**Icona**: `shuffle`
**Colore**: Arancione

**Come funziona**:
1. Raccoglie TUTTE le palline da TUTTI i tubi (esclude tubi locked)
2. Le mescola casualmente (`allBalls.shuffle()`)
3. Le ridistribuisce nei tubi rispettando:
   - Capacità massima di ogni tubo
   - Tubi locked esclusi
4. Resetta la history delle mosse

**Verifica se funziona**:
- [ ] Premi Shuffle
- [ ] Le palline cambiano posizione
- [ ] Nessun tubo supera la capacità
- [ ] I tubi locked restano invariati

---

### 5. COLOR BOMB (Bomba Colore) - PIÙ POTENTE
**Costo**: 150 monete (il più costoso - libera spazio!)
**Icona**: `flame.fill`
**Colore**: Rosso

**Come funziona**:
1. Mostra un SELETTORE con tutti i colori presenti nel gioco
2. Il giocatore sceglie un colore
3. **RIMUOVE COMPLETAMENTE** tutte le palline di quel colore da tutti i tubi
4. Le palline spariscono (libera spazio, a differenza della bacchetta che le sposta)

**Verifica se funziona**:
- [ ] Premi Color Bomb
- [ ] Appare selettore colori
- [ ] Scegli un colore (es. rosso)
- [ ] TUTTE le palline rosse spariscono completamente
- [ ] Se annulli, le monete NON vengono scalate

---

### 6. UNDO ALL (Ricomincia)
**Costo**: 30 monete
**Icona**: `arrow.counterclockwise.circle.fill`
**Colore**: Blu

**Come funziona**:
1. All'inizio del livello, salva lo stato completo in `initialGameState`
2. Quando premi Undo All:
   - Ripristina `gameState.tubes` dallo stato iniziale
   - Resetta `gameState.moves` a 0
   - Pulisce `moveHistory`
   - NON resetta timer ed errori

**Verifica se funziona**:
- [ ] Fai alcune mosse
- [ ] Premi Undo All
- [ ] Tutte le palline tornano alla posizione iniziale
- [ ] Il contatore mosse torna a 0
- [ ] Il timer continua (non si resetta)

---

### 7. FREEZE TIMER (Blocca Timer)
**Costo**: 75 monete
**Icona**: `snowflake`
**Colore**: Ciano

**Come funziona**:
1. Imposta `isTimerFrozen = true`
2. Avvia un countdown di 30 secondi (`frozenTimeRemaining`)
3. Durante il freeze:
   - Il timer principale NON avanza
   - Mostra indicatore "❄️ 30s" nell'header
4. Quando scade:
   - `isTimerFrozen = false`
   - Il timer riprende

**Verifica se funziona**:
- [ ] Premi Freeze Timer
- [ ] Appare indicatore ❄️ con countdown
- [ ] Il timer principale si ferma
- [ ] Dopo 30 secondi riprende

---

### 8. MAGIC WAND (Bacchetta Magica)
**Costo**: 120 monete
**Icona**: `wand.and.stars`
**Colore**: Oro

**Come funziona** (v1.0.5):
1. **Verifica spazio**: controlla se c'è un tubo vuoto o se può aggiungerne uno
2. Se non c'è spazio (10 tubi tutti occupati) → mostra avviso "Devi liberare un tubo"
3. Mostra un SELETTORE con tutti i colori non ancora completi
4. Il giocatore sceglie quale colore completare
5. Trova/crea un tubo target:
   - Se c'è un tubo VUOTO → lo usa
   - Se NON c'è tubo vuoto E ci sono <10 tubi → **AGGIUNGE automaticamente il 10° tubo**
6. **MAGIA**: Raccoglie TUTTE le palline del colore scelto da TUTTI i tubi
   - **IGNORA le regole**: prende anche dal fondo dei tubi!
   - Non importa se le palline sono "bloccate" sotto altre
7. Mette tutte le palline nel tubo target (fino alla capacità)
8. Se ci sono 4+ palline dello stesso colore, il tubo si completa!

**Verifica se funziona**:
- [ ] Con tubo vuoto: seleziona colore → usa tubo vuoto esistente
- [ ] Senza tubo vuoto e <10 tubi: aggiunge automaticamente il 10° tubo
- [ ] Con 10 tubi tutti occupati: mostra avviso "Devi liberare un tubo"
- [ ] TUTTE le palline del colore spariscono dai tubi originali
- [ ] Se annulli, le monete NON vengono scalate

---

## Flusso Uso Power-up (SEMPLIFICATO)

```
1. Utente tocca bottone power-up
2. Se coins >= costo:
   → Per Shuffle/UndoAll/Freeze: scala monete e esegui subito
   → Per ColorBomb/MagicWand: mostra selettore colore
     - Se seleziona colore: scala monete e esegui
     - Se annulla: chiude senza scalare niente
3. Se coins < costo:
   → Bottone disabilitato (grigio)
```

**Badge sui bottoni**: Mostra sempre il costo in monete

---

## File Coinvolti

| File | Contenuto |
|------|-----------|
| `PowerUp.swift` | Enum `PowerUpType` con costi, icone, descrizioni |
| `GameViewModel.swift` | Logica di esecuzione di tutti i power-up |
| `SettingsManager.swift` | Persistenza conteggi e monete |
| `PowerUpViews.swift` | UI: barra, bottoni, shop, selettori colore |

---

## Debug Checklist

### Test Base
- [ ] Monete si decrementano correttamente
- [ ] Contatori power-up si decrementano
- [ ] Suono/vibrazione al click
- [ ] Bottoni disabilitati quando non utilizzabili

### Test Specifici
- [ ] Shuffle: non rompe il gioco
- [ ] Color Bomb: rimuove TUTTE le palline del colore
- [ ] Undo All: ripristina stato iniziale ESATTO
- [ ] Freeze: timer si ferma per 30s esatti
- [ ] Magic Wand: mostra selettore e completa colore scelto

### Test Annullamento
- [ ] Color Bomb: tocca fuori = power-up restituito
- [ ] Magic Wand: tocca fuori = power-up restituito

---

*Ultimo aggiornamento: 2026-01-06 (v1.0.5)*
