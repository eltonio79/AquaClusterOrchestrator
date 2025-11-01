<!-- dfa0945d-6cd2-44ff-821f-1af9940c7475 86d69979-2cbc-471c-b12c-2035d44e1dda -->
# Cluster Pipeline Optimization and Validation Plan

## Stan obecny - Co zostało zrobione

### Business Features (Ukończone)

- **Pipeline orchestration** - `pipeline_runner.py` - kompletny orchestrator pipeline
- **Rule parsing** - `rule_parser.py` - parsowanie natural language rules (.rul files)
- **Cluster processing** - `cluster_processor.py` - 5 typów analiz (comparison, threshold, hazard, volume, ranking)
- **Visualization** - `visualizer.py` - cluster overlays, heatmaps, animations
- **Export** - `exporter.py` - CSV, GeoJSON, Markdown reports
- **Raster export** - `export_rasters.rb` - export 2D rasters z ICMExchange
- **6 existing rules** - depth_change_analysis, hazard_about_one, show_high_depths, volume_change_analysis, depth_worst_increase, elements_depth_delta_gt_0_005
- **Parameter optimizer** - `optimizer.py` - framework do optymalizacji parametrów clusteringu
- **Run comparison** - `compare_runs.py` - porównywanie wyników między iteracjami

### Maintenance Features (Ukończone)

- **Agent management** - `manage_agents.ps1` - start/stop/restart/list agents
- **Task delegation** - `delegate_task_to_agent.ps1` - system delegowania zadań między agentami
- **Log management** - `cleanup_agent_logs.ps1` - organizacja logów (active/processed)
- **Log monitoring** - `monitor_most_recent_agents_markdown_log.ps1` - tail logów agentów
- **Structured output** - `data/output/raster/db/grupa/run/sim_<id>/` - struktura katalogów
- **Terminal configuration** - Cmder integration dla VS Code/Cursor
- **Background execution** - `run_pipeline_background.ps1` - nieblokujące uruchamianie

---

## Zadania dla 4 Agentów

### Agent 1: Parameter Optimization Specialist

**Cel:** Automatyczna optymalizacja parametrów clusteringu dla wszystkich 6 rules

**Zadania:**

1. Uruchomić `optimizer.py --all-rules` dla wszystkich istniejących rules
2. Dla każdej rule:

   - Przetestować różne kombinacje parametrów (k_values, min_size, threshold, algorithms)
   - Zbierać quality metrics (silhouette, cohesion, separation, composite_score)
   - Zapisać najlepsze parametry do `data/output/experiments/<rule_name>_best_params.json`

3. Wygenerować raport porównawczy wszystkich optymalizacji
4. Zaktualizować pliki `.json` rules z najlepszymi parametrami

**Delegacja zadania:**

```powershell
.\scripts\delegate_task_to_agent.ps1 -TaskName "optimize_all_rules" -Instructions "Run optimizer.py --all-rules, save best parameters for each rule to data/output/experiments/, update rule .json files with optimized parameters" -ScriptPath "python scripts/optimizer.py" -ScriptArguments @("--all-rules", "--scripts-dir", "scripts", "--data-dir", "data/output")
```

**Oczekiwane rezultaty:**

- Pliki `data/output/experiments/<rule_name>_optimization_results.json` dla każdej rule
- Zaktualizowane pliki `.json` w `scripts/` z optymalnymi parametrami
- Raport `data/output/experiments/optimization_summary.md`

---

### Agent 2: Quality Validation Specialist  

**Cel:** Walidacja jakości wyników po optymalizacji

**Zadania:**

1. Dla każdej zoptymalizowanej rule:

   - Uruchomić pipeline z nowymi parametrami
   - Zweryfikować jakość klastrów (composite_score > threshold)
   - Sprawdzić czy wyniki są sensowne (liczba klastrów, area, metrics)
   - Porównać z poprzednimi wynikami (jeśli istnieją)

2. Wygenerować validation report:

   - Tabela porównawcza: rule_name, old_score, new_score, improvement
   - Lista rules wymagających ręcznej weryfikacji
   - Wykresy porównawcze (jeśli możliwe)

3. Zidentyfikować rules z regresją i zaproponować poprawki

**Delegacja zadania:**

```powershell
.\scripts\delegate_task_to_agent.ps1 -TaskName "validate_optimized_rules" -Instructions "For each optimized rule: run pipeline with new parameters, validate quality metrics, compare with previous results, generate validation report at data/output/experiments/validation_report.md"
```

**Oczekiwane rezultaty:**

- `data/output/experiments/validation_report.md` - raport walidacji
- `data/output/experiments/validation_results.json` - structured validation data
- Zaktualizowane wyniki w `data/output/results/<rule_name>/` dla każdej rule

---

### Agent 3: Automated Verification Agent

**Cel:** Automatyczna weryfikacja wyników po każdym uruchomieniu pipeline

**Zadania:**

1. Stworzyć skrypt `scripts/verify_pipeline_results.py`:

   - Sprawdza czy wszystkie wymagane pliki wyjściowe istnieją
   - Weryfikuje metryki jakości (minimalne wartości composite_score, cohesion)
   - Sprawdza poprawność struktur katalogów
   - Weryfikuje czy visualizations są wygenerowane
   - Waliduje GeoJSON/CSV exports

2. Integrować verification w `pipeline_runner.py` (automatyczne uruchamianie po każdym rule)
3. Generować verification log: `data/output/logs/active/verification_<timestamp>.md`
4. Alertować o nieudanych weryfikacjach (mark w manifest jako "verification_failed")

**Delegacja zadania:**

```powershell
.\scripts\delegate_task_to_agent.ps1 -TaskName "implement_auto_verification" -Instructions "Create scripts/verify_pipeline_results.py that automatically verifies pipeline output quality after each run. Integrate into pipeline_runner.py to run verification automatically. Generate verification logs in data/output/logs/active/"
```

**Oczekiwane rezultaty:**

- `scripts/verify_pipeline_results.py` - moduł weryfikacji
- Zintegrowana weryfikacja w `pipeline_runner.py`
- Verification logs dla każdego uruchomienia
- Updated manifest z verification status

---

### Agent 4: Maintenance and Organization Specialist

**Cel:** Maintenance, organizacja danych i dokumentacja

**Zadania:**

1. **Cleanup i organizacja:**

   - Przeniesienie starych logów z `active/` do `processed/`
   - Archiwizacja starych wyników eksperymentów (>30 dni)
   - Organizacja plików w `data/output/raster/` według struktury
   - Cleanup temporary files

2. **Dokumentacja:**

   - Zaktualizować `README.md` z informacją o optymalizacji parametrów
   - Stworzyć `docs/OPTIMIZATION_GUIDE.md` - jak używać optimizer
   - Zaktualizować `docs/` z wynikami optymalizacji

3. **Git management:**

   - Commit zoptymalizowanych parametrów rules
   - Stworzyć tag dla wersji "optimized-parameters"
   - Update `paths.txt` po zmianach struktury

4. **Monitoring improvements:**

   - Sprawdzić czy wszystkie agenty działają poprawnie
   - Zweryfikować czy task delegation działa
   - Sprawdzić czy log monitoring nie ma problemów

**Delegacja zadania:**

```powershell
.\scripts\delegate_task_to_agent.ps1 -TaskName "maintenance_cleanup" -Instructions "Clean up old logs, organize data/output structure, update documentation, commit optimized parameters to git with tag 'optimized-parameters', update paths.txt"
```

**Oczekiwane rezultaty:**

- Zaktualizowana dokumentacja
- Zorganizowane pliki w `data/output/`
- Git commit z tagiem
- Aktualny `paths.txt`

---

## Workflow Execution Plan

### Faza 1: Optymalizacja (Agent 1)

1. Agent 1 uruchamia `optimizer.py --all-rules`
2. Dla każdej rule testuje kombinacje parametrów
3. Zapisuje najlepsze parametry
4. Aktualizuje pliki `.json` rules

### Faza 2: Walidacja (Agent 2) - równolegle po Faza 1

1. Agent 2 czeka na zakończenie Agent 1
2. Uruchamia pipeline dla każdej zoptymalizowanej rule
3. Porównuje wyniki z poprzednimi
4. Generuje validation report

### Faza 3: Automatyzacja (Agent 3) - równolegle z Faza 2

1. Agent 3 implementuje verification module
2. Integruje z pipeline_runner.py
3. Testuje na przykładowych rules

### Faza 4: Maintenance (Agent 4) - po Faza 1,2,3

1. Agent 4 wykonuje cleanup
2. Aktualizuje dokumentację
3. Commituje zmiany do git

---

## Metryki sukcesu

- **Optymalizacja:** Wszystkie 6 rules ma zoptymalizowane parametry w `data/output/experiments/`
- **Walidacja:** Composite score > 0.5 dla wszystkich rules (lub wyjaśnione regresje)
- **Automatyzacja:** Verification działa automatycznie dla każdego rule w pipeline
- **Dokumentacja:** README i OPTIMIZATION_GUIDE są zaktualizowane

---

## Pliki kluczowe do modyfikacji

- `scripts/optimizer.py` - użycie przez Agent 1
- `scripts/pipeline_runner.py` - integracja verification przez Agent 3
- `scripts/verify_pipeline_results.py` - nowy plik (Agent 3)
- `scripts/*.json` - aktualizacja parametrów (Agent 1)
- `README.md` - aktualizacja dokumentacji (Agent 4)
- `data/output/experiments/` - wyniki optymalizacji (Agent 1, 2)

---

## Notatki

- Agenty mogą działać równolegle tam gdzie to możliwe (Agent 2 i 3 mogą startować razem)
- Agent 1 powinien zakończyć się przed Agent 2 (Agent 2 potrzebuje wyników optymalizacji)
- Agent 4 powinien zakończyć się na końcu (potrzebuje wyników z Agent 1,2,3)
- Wszystkie wyniki powinny być commitowane do git z tagiem

### To-dos

- [x] Agent 1: Uruchomić optimizer.py --all-rules dla wszystkich 6 rules, zapisać najlepsze parametry do data/output/experiments/, zaktualizować pliki .json rules
- [x] Agent 1: Wygenerować raport porównawczy optymalizacji (data/output/experiments/optimization_summary.md)
- [x] Agent 2: Uruchomić pipeline dla każdej zoptymalizowanej rule, zweryfikować quality metrics, porównać z poprzednimi wynikami
- [x] Agent 2: Wygenerować validation report (data/output/experiments/validation_report.md) z tabelą porównawczą i listą rules wymagających ręcznej weryfikacji
- [x] Agent 3: Stworzyć scripts/verify_pipeline_results.py - moduł automatycznej weryfikacji wyników pipeline (sprawdza pliki wyjściowe, metryki jakości, struktury katalogów)
- [x] Agent 3: Zintegrować verification w pipeline_runner.py (automatyczne uruchamianie po każdym rule), generować verification logs w data/output/logs/active/
- [x] Agent 4: Wykonać cleanup i organizację (przeniesienie starych logów, archiwizacja wyników eksperymentów, organizacja plików w data/output/raster/)
- [x] Agent 4: Zaktualizować dokumentację (README.md, stworzyć docs/OPTIMIZATION_GUIDE.md), zaktualizować paths.txt
- [x] Agent 4: Commit zoptymalizowanych parametrów do git z tagiem optimized-parameters