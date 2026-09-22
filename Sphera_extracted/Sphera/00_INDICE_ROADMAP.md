# 📋 BALL SORT PUZZLE - ROADMAP IMPLEMENTAZIONE

## 🎮 Stato Attuale
Il gioco base è **COMPLETO** e funzionante con:
- ✅ 50+ livelli
- ✅ Grafica glass/riflessi bellissima
- ✅ Sistema di progressione
- ✅ Impostazioni (suoni, musica, vibrazione)
- ✅ Statistiche
- ✅ Annulla/Suggerisci

---

## 📁 STRUTTURA FILE PROMPT

```
prompts/
├── FASE_1_TUBI_SPECIALI.md      ← Tubi ghiacciati, alti, portali, rotanti
├── FASE_2_POWER_UPS.md          ← Bacchetta, bomba, shuffle, undo
├── FASE_3_FORME_MULTIPLE.md     ← Cubi, piramidi, stelle, diamanti
├── FASE_4_MODALITA_EXTRA.md     ← Daily Challenge, Endless, Speed Run
├── FASE_5_COMBO_E_SPECIALI.md   ← Sistema combo, palline rainbow/bomba/gold
├── FASE_6_STORIA_PERSONAGGIO.md ← Lumi, cutscene, customization
└── (FASE_7_MULTIPLAYER.md)      ← Da fare per ultimo
```

---

## 🚦 ORDINE DI IMPLEMENTAZIONE CONSIGLIATO

### 🟢 PRIORITÀ ALTA (Differenziazione immediata)

| # | Fase | File | Tempo Stimato | Impatto |
|---|------|------|---------------|---------|
| 1 | Tubi Speciali | `FASE_1_TUBI_SPECIALI.md` | 2-3 ore | ⭐⭐⭐⭐⭐ |
| 2 | Power-Ups | `FASE_2_POWER_UPS.md` | 2-3 ore | ⭐⭐⭐⭐ |
| 3 | Forme Multiple | `FASE_3_FORME_MULTIPLE.md` | 3-4 ore | ⭐⭐⭐⭐⭐ |

### 🟡 PRIORITÀ MEDIA (Retention & Engagement)

| # | Fase | File | Tempo Stimato | Impatto |
|---|------|------|---------------|---------|
| 4 | Modalità Extra | `FASE_4_MODALITA_EXTRA.md` | 4-5 ore | ⭐⭐⭐⭐ |
| 5 | Combo & Speciali | `FASE_5_COMBO_E_SPECIALI.md` | 2-3 ore | ⭐⭐⭐ |

### 🟠 PRIORITÀ BASSA (Polish & Extra)

| # | Fase | File | Tempo Stimato | Impatto |
|---|------|------|---------------|---------|
| 6 | Storia | `FASE_6_STORIA_PERSONAGGIO.md` | 4-5 ore | ⭐⭐⭐ |
| 7 | Multiplayer | (Da creare) | 8-10 ore | ⭐⭐⭐⭐ |

---

## 📝 COME USARE I PROMPT

### Metodo 1: Tutto in una volta
```
1. Apri Claude Code
2. Copia-incolla l'intero contenuto del file FASE_X
3. Attendi che implementi tutto
4. Testa e correggi eventuali bug
5. Passa alla fase successiva
```

### Metodo 2: Passo passo (Consigliato)
```
1. Apri Claude Code
2. Dai il file FASE_X
3. Chiedi di implementare UNA feature alla volta
   Es: "Inizia implementando solo il Tubo Ghiacciato"
4. Testa quella feature
5. Procedi con la prossima
```

### Metodo 3: Bug fixing
```
Se qualcosa non funziona:
1. Descrivi il problema specifico
2. Includi eventuali errori
3. Claude Code correggerà
```

---

## ⚠️ REGOLE IMPORTANTI PER CLAUDE CODE

Includi SEMPRE all'inizio di ogni prompt:

```
REGOLE DA SEGUIRE:
1. NON modificare la grafica esistente (glass, riflessi, glow)
2. NON ricreare file che funzionano già
3. Mantieni la retrocompatibilità con i livelli esistenti
4. I livelli 1-15 devono rimanere "facili" (solo palline normali)
5. Aggiungi commenti al codice per le parti nuove
6. Testa che il build compili senza errori
```

---

## 🔧 DIPENDENZE TRA FASI

```
FASE 1 (Tubi) ──────────────────────────────────────┐
                                                    │
FASE 2 (Power-Ups) ─────────────────────────────────┼──→ FASE 4 (Modalità)
                                                    │
FASE 3 (Forme) ─────────────────────────────────────┘
                                                    
FASE 5 (Combo) ←── Può essere fatto in parallelo
                                                    
FASE 6 (Storia) ←── Indipendente, può essere fatto quando vuoi

FASE 7 (Multiplayer) ←── Richiede TUTTE le fasi precedenti
```

---

## 📊 RIEPILOGO FEATURE PER FASE

### FASE 1: Tubi Speciali
- 🧊 Tubo Ghiacciato (countdown per sbloccare pallina)
- ⬆️ Tubo Alto (6 palline invece di 4)
- 🔒 Tubo Bloccato (si sblocca con condizioni)
- 🌀 Tubo Portale (collegato a un altro tubo)
- 🔄 Tubo Rotante (inverte palline periodicamente)

### FASE 2: Power-Ups
- 🪄 Bacchetta Magica (cambia colore a 1 pallina)
- 💣 Bomba Colore (elimina tutte le palline di 1 colore)
- 🔀 Shuffle (rimescola tutto)
- ⏱️ Freeze Time (blocca timer)
- ↩️ Super Undo (reset livello)

### FASE 3: Forme Multiple
- ⚫ Pallina (esistente)
- 🟦 Cubo
- 🔺 Piramide
- ⭐ Stella
- 💎 Diamante
- Nuova regola: completare = stesso colore + stessa forma

### FASE 4: Modalità Extra
- 📅 Daily Challenge (1 puzzle/giorno, classifica globale)
- ♾️ Endless Mode (infinito, 3 vite, high score)
- ⏱️ Speed Run (10 livelli, timer globale)

### FASE 5: Combo & Speciali
- 🔥 Sistema Combo (x1.2 → x3.0 per completamenti rapidi)
- 🌈 Pallina Rainbow (jolly)
- 💣 Pallina Bomba (countdown)
- ⭐ Pallina Dorata (punti x2)
- 🧊 Pallina Congelata (tap per sbloccare)

### FASE 6: Storia & Personaggio
- 🧙‍♂️ Lumi (protagonista)
- 🎬 Cutscene tra capitoli
- 👕 Customization (outfit, cappelli, pet)
- 📈 Sistema XP/Level up
- 🏆 Rewards sbloccabili

---

## 🎯 OBIETTIVO FINALE

Un gioco che si distingue dalla concorrenza per:

1. **Meccaniche uniche** - Forme + Tubi speciali
2. **Profondità strategica** - Combo system
3. **Longevità** - Daily + Endless + 50+ livelli
4. **Engagement** - Storia + Personaggio
5. **Social** - Multiplayer (futuro)

---

## 💰 MONETIZZAZIONE (Suggerimenti)

Da implementare DOPO le feature:

1. **Ads rewarded** - Guarda video per power-ups
2. **Remove Ads** - Acquisto una tantum
3. **Power-Up Packs** - IAP per power-ups
4. **Premium Pass** - Sblocca tutti i costumi
5. **Hint Subscription** - Suggerimenti illimitati

---

## 📞 SUPPORTO

Se hai problemi con un prompt:
1. Descrivi cosa non funziona
2. Copia l'errore esatto
3. Specifica quale FASE stavi implementando

Buon sviluppo! 🚀
