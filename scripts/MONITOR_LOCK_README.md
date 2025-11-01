# .monitor_lock.txt

Plik .monitor_lock.txt jest uÅ¼ywany przez skrypt monitor_most_recent_agents_markdown_log.ps1 do Å›ledzenia, ktÃ³re logi agentÃ³w sÄ… aktualnie monitorowane przez uruchomione instancje skryptu monitorujÄ…cego.

## Cel:
- Zapobiega wielokrotnemu monitorowaniu tego samego loga przez rÃ³Å¼ne instancje skryptu
- Pozwala przeÅ‚Ä…czaÄ‡ siÄ™ miÄ™dzy logami - kolejne uruchomienie skryptu monitoruje nastÄ™pny dostÄ™pny log
- Zawiera informacje o PID procesu PowerShell monitorujÄ…cego log

## Lokalizacja:
- data/output/logs/active/.monitor_lock.txt - dla aktywnych logÃ³w

## Format:
KaÅ¼da linia to JSON z informacjami o jednym monitorze:
`json
{
  "PID": 12345,
  "MonitoringFile": "C:\\path\\to\\agent_run_*.md",
  "Started": "2025-10-31T19:21:24.4572873+01:00"
}
`

## Automatyczne czyszczenie:
- Plik jest automatycznie czyszczony gdy monitor siÄ™ koÅ„czy (Ctrl+C)
- JeÅ›li proces PowerShell umrze, lock jest ignorowany przy nastÄ™pnym uruchomieniu
