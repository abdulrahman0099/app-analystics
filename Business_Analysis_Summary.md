# Flood-It Game — Analytics Deep Dive
**Data source:** Firebase/GA4 export via BigQuery (`firebase-public-project.analytics_153293282`) · Jun 12 – Oct 3, 2018 (114 days)

## 1. The Business Problem
Growth is being spent inefficiently: **only 26.9% of new users (1,163 of 4,319) ever activate.** Nearly 3 in 4 acquired users are lost before they experience the core product. The decision this dashboard is built to support:

> **Where in the user journey is value leaking, and which single fix should be prioritized next — activation, difficulty balance, technical stability, or monetization?**

## 2. Method
Eight BigQuery summary exports were modeled as an analytical semantic model with 25 DAX measures (activation, engagement, completion, retention, monetization) and assembled into a 3-page Power BI report. No relationships were forced between tables — each source is an independent aggregated query (not a shared user-level grain), so the model is intentionally a set of standalone fact tables rather than a single star schema. This is noted on the dashboard itself.

## 3. Key Findings
| Theme | Finding | Implication |
|---|---|---|
| **Activation** | 26.9% activation rate | Biggest single leak in the funnel — worth the first fix |
| **Engagement** | DAU is stable (~450–550/day) with recurring spikes to 1,200+ on specific days | Spikes suggest push notifications or live-ops events drive short-term surges, not sustained lift — worth confirming against campaign calendar |
| **Difficulty** | Progressive completes at 76.6% vs. Quickplay at 55.8% (20.8pp gap); Quickplay retry rate is far lower relative to attempts | Quickplay may be tuned too hard or too disposable, causing users to abandon rather than retry |
| **Retention / tech health** | Users who *hit an app error* uninstall *less* (8.5%) than users with *no error* (18.2%); failures cluster in Android 2.62 and iOS 2.6.31 | Counterintuitive — errors aren't the top churn driver here (likely correlated with high engagement, not causation). Still, concentrate QA on the two worst versions |
| **Monetization** | Of users who run out of currency, only ~30% take a rewarded ad (354 of 1,193) | Rewarded-ad prompt at the "out of steps" moment is under-leveraged |
| **Screens** | `game_over` is the single most-viewed screen (357K views), ahead of the main menu | Frustration/failure is a bigger part of the experience than success — reinforces the difficulty-balance finding |

## 4. Recommendations (priority order)
1. **Fix activation first.** Map the exact activation definition to onboarding steps and A/B test a shorter first-session path.
2. **Rebalance Quickplay difficulty** — it's the higher-volume mode with the weaker completion rate; small tuning changes here move the most users.
3. **Prioritize QA on Android 2.62 / iOS 2.6.31** before treating "errors" as a general uninstall driver — the data says otherwise.
4. **Redesign the "out of steps" moment** to surface the rewarded-ad option more assertively; conversion has real headroom (30% → industry benchmarks often reach 45–60%).

## 5. The Dashboard
`AppAnalysis_PowerBI_Project.zip` — a Power BI Project containing the full data model (8 tables + 25 measures) and a 3-page report:
- **Executive Summary** — 5 headline KPI cards, DAU trend, key-signal callouts
- **Engagement & Gameplay Difficulty** — completion by mode, level-stage funnel by mode (with slicer), top screens by views
- **Retention, Technical Health & Monetization** — uninstall rate by error group, failures by app version, monetization funnel, conversion KPIs

See the chat message for how to open it.
