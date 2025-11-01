# Agent Task Delegation System

## Jak to działa

System delegowania zadań pozwala jednemu agentowi w Cursor przekazać zadanie do innego agenta.

## Struktura

Zadania są zapisywane w folderze `tasks/` jako pliki JSON:
- Format: `task_<TaskName>_<GUID>.json`
- Każdy plik zawiera:
  - `TaskId` - unikalny identyfikator
  - `TaskName` - nazwa zadania
  - `Status` - pending/completed/failed
  - `Instructions` - instrukcje dla drugiego agenta
  - `ScriptPath` - opcjonalna ścieżka do skryptu
  - `Result` - wynik wykonania

## Użycie

### Agent 1 (delegujący):
```powershell
.\scripts\delegate_task_to_agent.ps1 -TaskName "cleanup_logs" -Instructions "Run cleanup_agent_logs.ps1 and report how many logs were moved" -ScriptPath ".\scripts\cleanup_agent_logs.ps1"
```

### Agent 2 (wykonujący):
1. Otwórz chat z agentem
2. Powiedz: "Sprawdź folder tasks/ i wykonaj zadania pending"
3. Lub: "Przeczytaj zadanie z pliku tasks/task_cleanup_logs_<GUID>.json i wykonaj je"

## Przykładowe zadania

- Cleanup logs
- Generate reports  
- Process data
- Run tests
- Backup files

## Format zadania

```json
{
  "TaskId": "guid",
  "TaskName": "cleanup_logs",
  "Status": "pending",
  "Instructions": "Run cleanup script",
  "ScriptPath": ".\\scripts\\cleanup_agent_logs.ps1",
  "Created": "2025-10-31T...",
  "Priority": "normal"
}
```

