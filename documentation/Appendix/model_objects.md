{ALL}

# Model Objects

The following model objects and corresponding short codes are used in the database.

Short codes are used when referring to a model object by it's scripting path. The Type is used by other methods e.g. `WSDatabase.model_object_from_type_and_id`. The Description is the name found in the user interface, which is different from the Type in some important cases.

{::ICM}

| Type                          | Description | ShortCode |
| ----------------------------- | ----------- | --------- |
| Action List                   |             | ACTL      |
| Alert Definition List         |             | ADL       |
| Alert Instance List           |             | AIL       |
| Asset Group                   |             | AG        |
| Asset Network                 |             | ASSETNET  |
| Asset Network Template        |             | ASSETTMP  |
| Asset Validation              |             | ASSETVAL  |
| Assimilation                  |             | ASSIM     |
| Calibration                   |             | PDMC      |
| Collection Cost Estimator     |             | COST      |
| Collection Inference          |             | CINF      |
| Collection Network            |             | CNN       |
| Collection Network Template   |             | CNTMP     |
| Collection Validation         |             | VAL       |
| Custom Graph                  |             | CGDT      |
| Custom Report                 |             | CR        |
| Damage Calculation Results    |             | DMGCALC   |
| Damage Function               |             | DMGFUNC   |
| Dashboard                     |             | DASH      |
| Distribution Cost Estimator   |             | WCOST     |
| Distribution Inference        |             | WINF      |
| Distribution Network          |             | NWNET     |
| Distribution Network Template |             | WNTMP     |
| Distribution Validation       |             | WVAL      |
| Episode Collection            |             | EPC       |
| Flow Survey                   |             | FS        |
| Geo Explorer                  |             | NGX       |
| Graph                         |             | GDT       |
| Gridded Ground Model          |             | GGM       |
| Ground Infiltration           |             | IFN       |
| Ground Model                  |             | GM        |
| Infinity Configuration        |             | INFINITY  |
| Inflow                        |             | INF       |
| Initial Conditions 1D         |             | IC1D      |
| Initial Conditions 2D         |             | IC2D      |
| Initial Conditions Catchment  |             | ICCA      |
| Label List                    |             | LAB       |
| Layer List                    |             | LL        |
| Level                         |             | LEV       |
| Lifetime Estimator            |             | LIFEE     |
| Live Group                    |             | LG        |
| Manifest                      |             | MAN       |
| Manifest Deployment           |             | MAND      |
| Master Group                  |             | MASG      |
| Model Group                   |             | MODG      |
| Model Inference               |             | INFR      |
| Model Network                 |             | NNET      |
| Model Network Template        |             | NNT       |
| Model Validation              |             | ENV       |
| Observed Depth Event          |             | OBD       |
| Observed Flow Event           |             | OBF       |
| Observed Velocity Event       |             | OBV       |
| Pipe Sediment Data            |             | PSD       |
| Point Selection               |             | PTSEL     |
| Pollutant Graph               |             | PGR       |
| Print Layout                  |             | PTL       |
| Rainfall Event                |             | RAIN      |
| Regulator                     |             | REG       |
| Rehabilitation Planner        |             | REHABP    |
| Risk Analysis Run             |             | RAR       |
| Risk Assessment               |             | RISK      |
| Risk Calculation Results      |             | RISKCALC  |
| Run                           |             | RUN       |
| Selection List                |             | SEL       |
| Sim                           |             | SIM       |
| Sim Stats                     |             | STAT      |
| Statistics Template           |             | ST        |
| Stored Query                  |             | SQL       |
| Theme                         |             | THM       |
| Time Varying Data             |             | TVD       |
| Trade Waste                   |             | TW        |
| TSDB                          |             | TSDB      |
| TSDB Spatial                  |             | TSDBS     |
| UPM River Data                |             | UPMRD     |
| UPM Threshold                 |             | UPTHR     |
| Waste Water                   |             | WW        |
| Workspace                     |             | WKSP      |

{::/ICM}

{::WSPRO}

For example a Model Group is type 'Catchment Group', a Network is type 'Geometry'.

| Type                           | Description             | ShortCode |
| ------------------------------ | ----------------------- | --------- |
| Alt_Demand                     | Alternative Demand      | ALTDMD    |
| Baseline                       |                         | BLINE     |
| Baseline Explorer              |                         | BLINEEX   |
| Catchment Group                | Model Group             | CG        |
| Control                        |                         | CON       |
| Custom Report                  |                         | CR        |
| Custom Report Group            |                         | CRG       |
| Demand Diagram                 |                         | DDG       |
| Demand Diagram Group           |                         | DDGG      |
| Demand Scaling                 |                         | DSCL      |
| Demand Scaling Group           |                         | DSCLG     |
| Electricity Tariff             |                         | ETAR      |
| Electricity Tariff Group       |                         | ETARG     |
| Energy GHG Factors             |                         | EGHGF     |
| Energy GHG Factors Group       |                         | EGHGFG    |
| Engineering Validation         |                         | ENV       |
| Engineering Validation Group   |                         | ENVG      |
| Export Style                   |                         | ES        |
| Export Style Group             |                         | ESG       |
| FireFlowData                   |                         | FF        |
| FireFlowData Group             |                         | FFG       |
| Flushing Schedule              |                         | FSCH      |
| Flushing Schedule Group        |                         | FSCHG     |
| General Multi Run Config       |                         | GMRC      |
| General Multi Run Config Group |                         | GMRCG     |
| Geo Explorer                   |                         | GEOEX     |
| Geometry                       | Network                 | GMT       |
| Geometry Template              |                         | GMTTMPL   |
| Graph                          |                         | GDT       |
| Graph Group                    |                         | GDTG      |
| Gridded Ground Model           |                         | GGM       |
| Gridded Ground Model Group     |                         | GGMG      |
| Ground Model                   |                         | GM        |
| Ground Model Group             |                         | GMG       |
| Inference                      |                         | INF       |
| Inference Group                |                         | INFG      |
| IWL Switch Controller          |                         | IWLSC     |
| IWL Switch Controller Group    |                         | IWLSCG    |
| IWLive RunInfo                 |                         | IWLRI     |
| IWLive RunInfo Group           |                         | IWLRIG    |
| Label List                     |                         | LAB       |
| Label List Group               |                         | LABG      |
| Layer List                     |                         | LL        |
| Layer List Group               |                         | LLG       |
| Model 360 Cfg                  |                         | M360C     |
| Model 360 Cfg Group            |                         | M360CG    |
| Polygon                        |                         | POL       |
| Polygon Group                  |                         | POLG      |
| Report Cfg                     |                         | RC        |
| Report Cfg Group               |                         | RCG       |
| ResultsSelector                |                         | RESSEL    |
| ResultsSelector Group          |                         | RESSELG   |
| RTC Group                      |                         | RTCG      |
| RTC Scenario                   |                         | RTC       |
| Selection List                 |                         | SEL       |
| Selection List Group           |                         | SELG      |
| SoluteData                     |                         | SD        |
| SoluteData Group               |                         | SDG       |
| Stored Query                   |                         | SQL       |
| Stored Query Group             |                         | SQLQ      |
| Theme                          |                         | THM       |
| Theme Group                    |                         | THMG      |
| Warning Template               |                         | WT        |
| Warning Template Group         |                         | WTG       |
| Wesnet Live Data               | Live Data Configuration | WNLIVE    |
| Wesnet Run                     | Run                     | WNRUN     |
| Wesnet Run Group               | Run Group               | WNRUNG    |
| Wesnet Sim                     | Simulation              | WNSIM     |
| Workspace                      |                         | WKSP      |
| Workspace Group                |                         | WKSPG     |
| Zone Explorer                  |                         | ZONEEX    |

{::/WSPRO}
