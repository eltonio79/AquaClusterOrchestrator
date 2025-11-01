<!-- 7a3f1b2c-8d4e-4f5a-9b6c-2e1d3f4a5b6c -->
# Agent Monitoring System - 7 Agents Plan

## Stan obecny - Co zostało zrobione

### Infrastructure Features (Ukończone)

- **Agent rules** - `.cursor/rules/30-36-*.mdc` - reguły dla 7 agentów monitorujących
- **Agent instructions** - `tasks/agents/01-07_*_AGENT.md` - szczegółowe instrukcje dla każdego agenta
- **Agent guidelines** - `tasks/agents/AGENT_GUIDELINES.md` - uniwersalne wytyczne dla wszystkich agentów
- **Startup script** - `scripts/start_agent.ps1` - centralizowany system uruchamiania agentów (delegation + direct execution)
- **Status tracking** - `scripts/update_agent_status.ps1` - system zarządzania statusem agentów
- **Status storage** - `data/output/config/agent_status.json` - centralne repozytorium statusu agentów
- **Monitoring dashboard** - `data/output/agent_monitor.html` - dynamiczny dashboard do monitorowania agentów
- **Git workflow** - `tasks/agents/GIT_WORKFLOW.md` - wytyczne dotyczące Git dla agentów
- **Cleanup integration** - `scripts/cleanup_agent.ps1` - zintegrowany cleanup agent z ochroną `.cursor/plans/`

### Documentation Features (Ukończone)

- **Agent README** - `tasks/agents/README.md` - dokumentacja systemu agentów
- **Individual agent docs** - 7 plików instrukcji dla każdego agenta
- **Universal guidelines** - `tasks/agents/AGENT_GUIDELINES.md` - best practices dla agentów

---

## Zadania dla 7 Agentów Monitorujących

### Agent 1: Raster Monitor Agent

**Cel:** Automatyczne monitorowanie nowych plików raster i uruchamianie pipeline

**Zadania:**

1. Monitorować katalogi rasterów (`data/output/rasters/`, `data/input/rasters/`)
2. Wykrywać nowe pliki `.tif` / `.png` / `.jpg`
3. Automatycznie uruchamiać pipeline dla nowych rasterów
4. Logować wszystkie zdarzenia do `data/output/logs/raster_monitor/`
5. Aktualizować status w `agent_status.json`

**Delegacja zadania:**

```powershell
.\scripts\start_agent.ps1 -AgentName "raster_monitor" -Instructions "Monitor for new raster files and automatically trigger pipeline execution"
```

**Oczekiwane rezultaty:**

- Skrypt `scripts/monitor_rasters.ps1` (lub Python equivalent)
- Logi monitorowania w `data/output/logs/raster_monitor/`
- Integracja z `pipeline_runner.py`

---

### Agent 2: Experiment Monitor Agent

**Cel:** Monitorowanie wyników optymalizacji i uruchamianie walidacji

**Zadania:**

1. Monitorować `data/output/experiments/` dla nowych plików `*_best_params.json`
2. Po wykryciu nowych parametrów uruchamiać `validate_optimized_rules.py`
3. Generować raporty porównawcze
4. Alertować o regresjach w wynikach
5. Logować wszystkie zdarzenia do `data/output/logs/experiment_monitor/`

**Delegacja zadania:**

```powershell
.\scripts\start_agent.ps1 -AgentName "experiment_monitor" -Instructions "Monitor optimization results and automatically trigger validation"
```

**Oczekiwane rezultaty:**

- Skrypt `scripts/monitor_experiments.ps1`
- Automatyczna walidacja po optymalizacji
- Raporty porównawcze w `data/output/experiments/validation_reports/`

---

### Agent 3: Cleanup Agent

**Cel:** Automatyczne czyszczenie i organizacja danych

**Zadania:**

1. Archiwizować stare logi (>7 dni) z `active/` do `processed/`
2. Archiwizować stare wyniki eksperymentów (>30 dni)
3. Usuwać pliki tymczasowe z `temp/` (>1 dzień)
4. Czyścić orphaned lock files
5. **CHRONIĆ**: `.cursor/plans/` - nigdy nie usuwać planów

**Delegacja zadania:**

```powershell
.\scripts\start_agent.ps1 -AgentName "cleanup" -Direct  # Już zaimplementowany
```

**Oczekiwane rezultaty:**

- ✅ `scripts/cleanup_agent.ps1` - **ZREALIZOWANY**
- Logi cleanup w `data/output/logs/cleanup/`
- Ochrona `.cursor/plans/` przed usunięciem

---

### Agent 4: Validation Agent

**Cel:** Automatyczna walidacja jakości wyników pipeline

**Zadania:**

1. Automatycznie weryfikować wyniki po każdym uruchomieniu pipeline
2. Używać `verify_pipeline_results.py` do sprawdzania metryk jakości
3. Generować validation reports
4. Alertować o problemach z jakością wyników
5. Integrować z `pipeline_runner.py` dla automatycznej weryfikacji

**Delegacja zadania:**

```powershell
.\scripts\start_agent.ps1 -AgentName "validation" -Instructions "Automatically validate pipeline results quality and generate reports"
```

**Oczekiwane rezultaty:**

- Skrypt `scripts/validation_agent.ps1`
- Integracja z `pipeline_runner.py`
- Validation logs w `data/output/logs/validation/`

---

### Agent 5: Git Tracking Agent

**Cel:** Automatyczne commity do git po udanych uruchomieniach

**Zadania:**

1. Monitorować udane uruchomienia pipeline
2. Automatycznie commitować wyniki do git z odpowiednimi wiadomościami
3. Tworzyć tagi dla ważnych wersji
4. Śledzić zmiany w plikach konfiguracyjnych
5. Używać struktur commit messages zgodnie z `AGENT_GUIDELINES.md`

**Delegacja zadania:**

```powershell
.\scripts\start_agent.ps1 -AgentName "git_tracking" -Instructions "Automatically commit successful pipeline runs to git with proper messages"
```

**Oczekiwane rezultaty:**

- Skrypt `scripts/git_tracking_agent.ps1`
- Automatyczne commity z opisowymi wiadomościami
- Tagi dla wersji w git

---

### Agent 6: Health Check Agent

**Cel:** Monitorowanie zdrowia systemu i wszystkich agentów

**Zadania:**

1. Sprawdzać status wszystkich agentów w `agent_status.json`
2. Wykrywać zawieszonych agentów (zombie processes)
3. Wykrywać problemy z dyskiem/przestrzenią
4. Sprawdzać dostępność kluczowych skryptów
5. Generować health reports do `data/output/logs/health_check/`
6. Alertować o problemach

**Delegacja zadania:**

```powershell
.\scripts\start_agent.ps1 -AgentName "health_check" -Instructions "Monitor system health and all agents, generate health reports"
```

**Oczekiwane rezultaty:**

- Skrypt `scripts/health_check_agent.ps1`
- Health reports w `data/output/logs/health_check/`
- Integracja z dashboardem `agent_monitor.html`

---

### Agent 7: Results Analyzer Agent

**Cel:** Analiza wyników i generowanie insights

**Zadania:**

1. Analizować wyniki z wszystkich agentów
2. Generować insights i rekomendacje
3. Porównywać wyniki między iteracjami
4. Tworzyć summary reports
5. Identyfikować trendy i wzorce
6. Logować analizy do `data/output/logs/results_analyzer/`

**Delegacja zadania:**

```powershell
.\scripts\start_agent.ps1 -AgentName "results_analyzer" -Instructions "Analyze results from all agents and generate insights and recommendations"
```

**Oczekiwane rezultaty:**

- Skrypt `scripts/results_analyzer_agent.ps1`
- Analysis reports w `data/output/logs/results_analyzer/`
- Insights i rekomendacje w markdown format

---

## Workflow Execution Plan

### Faza 1: Infrastructure Setup (Ukończona)

1. ✅ Utworzono reguły `.cursor/rules/30-36-*.mdc`
2. ✅ Utworzono instrukcje w `tasks/agents/01-07_*_AGENT.md`
3. ✅ Utworzono `scripts/start_agent.ps1`
4. ✅ Utworzono `scripts/update_agent_status.ps1`
5. ✅ Utworzono `data/output/config/agent_status.json`
6. ✅ Utworzono `data/output/agent_monitor.html`
7. ✅ Zintegrowano `scripts/cleanup_agent.ps1`

### Faza 2: Core Monitoring Agents (W trakcie)

1. **Agent 1: Raster Monitor** - implementacja `monitor_rasters.ps1`
2. **Agent 2: Experiment Monitor** - implementacja `monitor_experiments.ps1`
3. **Agent 4: Validation Agent** - implementacja `validation_agent.ps1`

### Faza 3: Support Agents (Do zrobienia)

1. **Agent 5: Git Tracking** - implementacja `git_tracking_agent.ps1`
2. **Agent 6: Health Check** - implementacja `health_check_agent.ps1`
3. **Agent 7: Results Analyzer** - implementacja `results_analyzer_agent.ps1`

### Faza 4: Integration and Testing (Do zrobienia)

1. Integracja wszystkich agentów z systemem status tracking
2. Testowanie koordynacji między agentami
3. Testowanie dashboardu monitorowania
4. Dokumentacja końcowa

---

## Metryki sukcesu

- **Infrastructure:** Wszystkie 7 reguł `.mdc` istnieją i działają
- **Core Agents:** Agent 1, 2, 4 działają i monitorują odpowiednie zasoby
- **Support Agents:** Agent 5, 6, 7 działają i wspierają główne workflow
- **Status Tracking:** Wszyscy agenci aktualizują status w `agent_status.json`
- **Dashboard:** Dashboard pokazuje aktualny status wszystkich agentów
- **Logs:** Wszyscy agenci logują do odpowiednich katalogów
- **Git Integration:** Agent 5 automatycznie commituje udane uruchomienia

---

## Pliki kluczowe do modyfikacji

- `scripts/monitor_rasters.ps1` - **DO UTWORZENIA** (Agent 1)
- `scripts/monitor_experiments.ps1` - **DO UTWORZENIA** (Agent 2)
- `scripts/cleanup_agent.ps1` - ✅ **ZREALIZOWANY** (Agent 3)
- `scripts/validation_agent.ps1` - **DO UTWORZENIA** (Agent 4)
- `scripts/git_tracking_agent.ps1` - **DO UTWORZENIA** (Agent 5)
- `scripts/health_check_agent.ps1` - **DO UTWORZENIA** (Agent 6)
- `scripts/results_analyzer_agent.ps1` - **DO UTWORZENIA** (Agent 7)
- `scripts/pipeline_runner.py` - integracja z Agent 1, 4
- `scripts/validate_optimized_rules.py` - integracja z Agent 2
- `data/output/config/agent_status.json` - status tracking dla wszystkich agentów
- `data/output/agent_monitor.html` - dashboard monitorowania

---

## Notatki

- Agenty mogą działać równolegle (Agent 1, 2, 4 mogą startować razem)
- Agent 3 (Cleanup) działa niezależnie na harmonogramie
- Agent 6 (Health Check) monitoruje wszystkich innych agentów
- Agent 5 (Git Tracking) działa po udanych uruchomieniach innych agentów
- Agent 7 (Results Analyzer) analizuje wyniki od wszystkich agentów
- Wszystkie agenty muszą aktualizować status w `agent_status.json`
- `.cursor/plans/` jest chroniony przed usunięciem przez cleanup scripts

### To-dos

- [x] Utworzyć reguły `.cursor/rules/30-36-*.mdc` dla 7 agentów
- [x] Utworzyć instrukcje `tasks/agents/01-07_*_AGENT.md`
- [x] Utworzyć `scripts/start_agent.ps1` z supportem dla delegation i direct execution
- [x] Utworzyć `scripts/update_agent_status.ps1` do zarządzania statusem
- [x] Utworzyć `data/output/config/agent_status.json` dla status storage
- [x] Utworzyć `data/output/agent_monitor.html` dashboard
- [x] Zaimplementować `scripts/cleanup_agent.ps1` (Agent 3)
- [x] Dodać ochronę `.cursor/plans/` w cleanup scripts
- [ ] Zaimplementować `scripts/monitor_rasters.ps1` (Agent 1)
- [ ] Zaimplementować `scripts/monitor_experiments.ps1` (Agent 2)
- [ ] Zaimplementować `scripts/validation_agent.ps1` (Agent 4)
- [ ] Zaimplementować `scripts/git_tracking_agent.ps1` (Agent 5)
- [ ] Zaimplementować `scripts/health_check_agent.ps1` (Agent 6)
- [ ] Zaimplementować `scripts/results_analyzer_agent.ps1` (Agent 7)
- [ ] Zintegrować Agent 1 z `pipeline_runner.py`
- [ ] Zintegrować Agent 2 z `validate_optimized_rules.py`
- [ ] Zintegrować Agent 4 z `pipeline_runner.py` dla automatycznej weryfikacji
- [ ] Przetestować koordynację między wszystkimi agentami
- [ ] Zaktualizować dokumentację z przykładami użycia wszystkich agentów

