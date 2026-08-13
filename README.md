# Keyboard Hero: Master Board

Moduł Master Board pełni funkcję jednostki sterującej w projekcie Keyboard Hero. Odpowiada za obsługę interfejsu klawiatury PS/2, realizację logiki silnika gry, generowanie sygnałów audio oraz komunikację z płytką Slave za pośrednictwem magistrali UART.

## Spis treści
1. [Opis projektu](#opis-projektu)
2. [Architektura](#architektura)
3. [Specyfikacja komponentów](#specyfikacja-komponentów)
4. [Konfiguracja sprzętowa](#konfiguracja-sprzętowa)
5. [Rozprowadzenie zegara](#rozprowadzenie-zegara)

## Opis projektu
Projekt realizuje system gry zręcznościowej typu Guitar Hero w oparciu o układ FPGA. Płytka Master przetwarza sygnały wejściowe z klawiatury PS/2, weryfikuje trafienia w nuty zgodnie z logiką silnika gry oraz steruje odtwarzaniem melodii poprzez moduł audio PMOD AMP3. Stan rozgrywki jest przesyłany do płytki Slave w celu wizualizacji na monitorze VGA.

## Architektura
System opiera się na modułowej strukturze typu `top_master`. Główne bloki logiczne obejmują:

* **Button Decoder**: Synchronizacja i dekodowanie sygnałów z klawiatury PS/2.
* **Game Engine**: Logika obliczeniowa rozgrywki i weryfikacja poprawności trafień.
* **Song ROM**: Pamięć nieulotna przechowująca dane o sekwencjach nut.
* **Master FSM**: Maszyna stanów zarządzająca cyklem życia gry.
* **UART Mux**: Multipleksacja danych wysyłanych do modułu Slave.

## Specyfikacja komponentów

| Moduł | Funkcja |
| :--- | :--- |
| `Ps2Interface` | Obsługa fizycznego interfejsu klawiatury PS/2 |
| `Game Engine` | Przetwarzanie logiki gry i weryfikacja wkładu użytkownika |
| `Sound Top` | Obsługa interfejsu audio PMOD AMP3 |
| `Master FSM` | Sterowanie stanami systemu (start, pauza, koniec utworu) |

## Konfiguracja sprzętowa

Aby uruchomić system w trybie multiplayer, należy wykonać następujące połączenia:

### 1. Połączenia między płytkami (Master - Slave)
Płytki Basys3 muszą być połączone za pomocą dwóch przewodów typu jumper:
* **Masa (GND)**: Połącz pin GND na płytce Master z pinem GND na płytce Slave.
* **Linia danych (UART)**: Połącz pin JA1 na płytce Master z pinem JA1 na płytce Slave (połączenie sygnału transmisji szeregowej).

### 2. Urządzenia peryferyjne
* **Klawiatura**: Podłącz klawiaturę PS/2 (lub USB z obsługą protokołu PS/2) do portu USB-A płytki **Master**.
* **Audio**: Wzmacniacz PMOD AMP3 należy wpiąć w złącze JC płytki **Master**.
* **Wyświetlacz**: Monitor VGA musi zostać podłączony do portu VGA płytki **Slave**.

## Rozprowadzenie zegara
System wykorzystuje dwie domeny zegarowe generowane przez moduł `clk_wiz` (bazujące na sygnale wejściowym 100 MHz):
1. **100 MHz**: Zasilanie interfejsu PS/2 oraz bloku synchronizacji.
2. **40 MHz**: Obsługa logiki silnika gry, dekodera przycisków oraz modułów audio.

---
Autorzy: Jakub Suder (JS), Michał Wesołowski (MW)
Data ostatniej modyfikacji: 13.08.2026