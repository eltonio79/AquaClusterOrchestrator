# .monitor_lock.txt

Plik `.monitor_lock.txt` jest używany przez skrypt `monitor_most_recent_agents_markdown_log.ps1` do śledzenia, które logi agentów są aktualnie monitorowane przez uruchomione instancje skryptu monitorującego.

## Cel:
- Zapobiega wielokrotnemu monitorowaniu tego samego loga przez różne instancje skryptu
- Pozwala przełączać się między logami - kolejne uruchomienie skryptu monitoruje następny dostępny log
- Zawiera informacje o PID procesu PowerShell monitorującego log

## Lokalizacja:
- `data/output/logs/active/.monitor_lock.txt` - dla aktywnych logów

## Format:
Każda linia to JSON z informacjami o jednym monitorze:
```json
{
  "PID": 12345,
  "MonitoringFile": "C:\\path\\to\\agent_run_*.md",
  "Started": "2025-10-31T19:21:24.4572873+01:00"
}
```

## Automatyczne czyszczenie:
- Plik jest automatycznie czyszczony gdy monitor się kończy (Ctrl+C)
- Jeśli proces PowerShell umrze, lock jest ignorowany przy następnym uruchomieniu

