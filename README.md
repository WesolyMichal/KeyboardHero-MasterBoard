# Keyboard Hero (Płytka Master)

*Raport z projektu, v.1.0.1 (Data: 29.08.2026)*

**Autorzy:** Jakub Suder (JS), Michał Wesołowski (MW)  
**Kurs / Przedmiot:** MTM UEC2  

---

## 📋 Spis treści
1. [Repozytoria Git](#1-repozytoria-git)
2. [Wstęp](#2-wstęp)
3. [Jak grać (Instrukcja)](#3-jak-grać-instrukcja)
4. [Architektura (Master)](#4-architektura-master)
5. [Implementacja i Zasoby (Master)](#5-implementacja-i-zasoby-master)
6. [Konfiguracja sprzętu](#6-konfiguracja-sprzętu)

---

## 1. Repozytoria Git
* [KeyboardHero-MasterBoard](https://github.com/WesolyMichal/KeyboardHero-MasterBoard)
* [KeyboardHero-SlaveBoard](https://github.com/WesolyMichal/KeyboardHero-SlaveBoard)

---

## 2. Wstęp
Projekt inspirowany jest popularnymi grami rytmicznymi typu *Guitar Hero*, w których zadaniem gracza jest naciskanie odpowiednich klawiszy w rytm odtwarzanej muzyki. 

Implementacja została zrealizowana na **dwóch płytkach Basys3**, przy czym płytka **Master** odpowiada za obsługę klawiatury (PS/2), logikę gry oraz odtwarzanie melodii.

---

## 3. Jak grać (Instrukcja)

* **Jak grać w Keyboard Hero?**
* **Sterowanie nutami:** Aby zagrać nutę, naciśnij `SPACJĘ` (szarpnięcie struną) razem z jednym z przycisków od `1` do `6`.
* **Dopasowanie kolorów:** Przyciski `1-6` odpowiadają kolorom nut na ekranie.
* **Długie nuty:** Przytrzymaj odpowiedni przycisk dla długich nut aż do ich zakończenia.
* **Szarpnięcie / Strum:** Użyj strzałek `<` lub `>` w tym samym czasie, co przycisk nuty.
* **Nawigacja:** Do poruszania się między etapami gry używaj przycisku `ENTER` oraz `ESC`.

---

## 4. Architektura (Master)
* **Osoba odpowiedzialna:** Michał Wesołowski (MW)
* **Główne zadania:** Obsługa interfejsu klawiatury PS/2, silnik gry, generowanie dźwięku oraz wysyłanie danych przez UART do płytki Slave.
* **Rozprowadzenie zegara:** Generacja sygnału `clk40MHz` z wejściowego `clk100MHz` za pomocą modułu `clk_wiz`.

---

## 5. Implementacja i Zasoby (Master)

### 5.1. Wykorzystanie zasobów (`top_master_basys3`)
* **Slice LUTs:** 991
* **Slice Registers:** 665
* **F7 Muxes:** 47
* **F8 Muxes:** 15
* **Slice:** 330

### 5.2. Marginesy czasowe
* **WNS (Worst Negative Slack):** 1.234 ns
* **WHS (Worst Hold Slack):** 0.099 ns

---

## 6. Konfiguracja sprzętu
1. **Połączenie płytek:** Dwie zworek łączących obie płytki:
   * Masa (GND) z masą (GND).
   * Pin `JA1` z pinem `JA1`.
2. **Klawiatura:** Podłączona do portu USB-A płytki **MASTER**.
3. **Audio:** Wzmacniacz PMOD-AMP3 wpięty do złącza **JC** płytki **MASTER**.
