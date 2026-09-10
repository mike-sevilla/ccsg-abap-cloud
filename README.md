# 🧊 Cold-Chain Excursion & Shelf-Life Guard (CCSG)

> A full-stack **ABAP Cloud** demo application built on the **ABAP RESTful Application Programming Model (RAP)**, following **Clean Core** and **Clean ABAP** principles — developed on the SAP BTP ABAP Environment using ABAP Development Tools (ADT) in Eclipse.

![Platform](https://img.shields.io/badge/Platform-SAP%20BTP%20ABAP%20Environment-0A6E4F)
![Model](https://img.shields.io/badge/Model-ABAP%20Cloud%20(RAP)-0A6E4F)
![Language](https://img.shields.io/badge/Language-ABAP%20for%20Cloud%20Development-0A6E4F)
![Clean Core](https://img.shields.io/badge/Clean%20Core-Compliant-2E7D32)
![Tooling](https://img.shields.io/badge/IDE-Eclipse%20ADT-blue)

---

## 📖 Overview

**CCSG** is a self-directed learning project that models a real food-manufacturing problem: **cold-chain temperature excursions and their impact on product shelf life.**

Refrigerated zones (cold rooms, blast chillers, shipping trailers) continuously stream temperature readings. When a zone runs **above threshold for too long**, that's an **excursion** — and the cumulative time-temperature exposure (**degree-minutes**) shortens the shelf life of the affected batches. Quality then assesses the impact and dispositions the stock (**Release / Reduce Shelf-Life / Hold / Scrap**) with a full audit trail.

The project is deliberately **calculation- and time-series-heavy** to exercise core ABAP, then wraps that engine in a genuine **RAP state machine**, a layered **CDS** model, and **code pushdown** via AMDP — making it a compact but complete showcase of modern SAP backend development.

---

## 🏗️ Architecture

```
┌───────────────────────────────────────────────────────────────┐
│  OData V4 Service  (Service Definition + Binding)             │
│  ZSD_CC_EXCURSION  →  ZUI_CC_EXCURSION                        │
└───────────────────────────────┬───────────────────────────────┘
                                │  read / actions
┌───────────────────────────────▼───────────────────────────────┐
│  RAP Business Object — UNMANAGED  (the state machine)        │
│  BDEF ZI_CC_EXCURSION → behavior pool ZBP_I_CC_EXCURSION      │
│  actions: acknowledge / assessImpact / disposition /          │
│           close / reopen  + validations + determinations      │
│  custom saver: number range + lock object                    │
└───────────────────────────────┬───────────────────────────────┘
                                │  calls
┌───────────────────────────────▼───────────────────────────────┐
│  CORE ABAP ENGINE  (pure OO ABAP)                            │
│  ZCL_CC_EXCURSION_DETECTOR  (time-series → excursions)       │
│  ZIF_CC_SHELFLIFE_MODEL + Q10/Linear models + Factory        │
│  ZCL_CC_IMPORT (CSV parser)   ZCX_CC_ERROR (exceptions)      │
└───────────────────────────────┬───────────────────────────────┘
                                │
┌───────────────────────────────▼───────────────────────────────┐
│  CDS + ABAP SQL / AMDP                                        │
│  ZI_CC_EXCURSION / ZC_CC_EXCURSION / ZC_CC_EXCURSION_KPI      │
│  ZCL_CC_ANALYTICS (AMDP recurrence ranking — code pushdown)  │
└───────────────────────────────┬───────────────────────────────┘
                                │
┌───────────────────────────────▼───────────────────────────────┐
│  Own Z Tables (Clean Core)                                   │
│  ZDT_CC_TEMPLOG · ZDT_CC_EXC_HDR · ZDT_CC_EXC_BATCH          │
│  ZDT_CC_ZONE · ZDT_CC_PRODRULE                               │
│  SAP master data reached only via released CDS views          │
└───────────────────────────────────────────────────────────────┘
```

---

## 🧩 Business Scenario

A cold-storage zone has a **target temperature** and a **tolerance**. Sensors log a reading every few minutes.

1. A run of consecutive readings above threshold is detected as an **excursion**.
2. Its severity = the integral of *(temperature − threshold) × minutes* → **degree-minutes**.
3. Each excursion opens a **case**; affected batches are attached.
4. A **shelf-life model** recomputes each batch's expiry date (SLED).
5. Quality **dispositions** the stock and **closes** the case — fully audited (FDA/USDA traceability context).

**State machine:** `NEW → ACKNOWLEDGED → ASSESSED → DISPOSITIONED → CLOSED` (with `REOPEN`).

---

## 🛠️ Skills & Technologies Demonstrated

| Area | What this project shows |
|------|-------------------------|
| **Core ABAP (modern 7.5+)** | Internal-table processing, control-break logic, `REDUCE`/`FOR`, table expressions, string templates, `utclong` date/time math |
| **Object-Oriented Design** | Interfaces, polymorphism, factory pattern, dependency injection for testability |
| **Class-Based Exceptions** | `ZCX_CC_ERROR` using `CX_STATIC_CHECK` + `IF_T100_MESSAGE` with free-text messaging |
| **ABAP CDS** | View entities, associations, composition, aggregations, parameters, access control (DCL) |
| **RAP (unmanaged)** | Behavior definition, actions/validations/determinations, EML, number ranges, locking, custom saver |
| **ABAP SQL & Code Pushdown** | Joins, aggregations, window functions, **AMDP** (SQLScript) for recurrence analytics |
| **OData V4** | Service definition & binding, metadata, action exposure |
| **Clean Core / ABAP Cloud** | Released-API-only model, own namespace, `ABAP for Cloud Development` language version |
| **Testing & Quality** | ABAP Unit tests with test doubles, ABAP Test Cockpit (ATC) with Clean Core variant |
| **AI-Assisted Development** | SAP **Joule for Developers** for code explanation, test generation, and verification |

---

## 📦 Object Inventory

### Data Model (ABAP Dictionary)
- `ZDT_CC_TEMPLOG` — sensor temperature readings (time series)
- `ZDT_CC_EXC_HDR` — excursion case header (RAP root)
- `ZDT_CC_EXC_BATCH` — affected batches (RAP child / composition)
- `ZDT_CC_ZONE` — cold-storage zone master (threshold, category)
- `ZDT_CC_PRODRULE` — product-category shelf-life rules (drives the model factory)

### Core Engine (planned/in progress)
- `ZCX_CC_ERROR` — class-based exception
- `ZCL_CC_EXCURSION_DETECTOR` — excursion + degree-minute calculation
- `ZIF_CC_SHELFLIFE_MODEL`, `ZCL_CC_SL_MODEL_Q10`, `ZCL_CC_SL_MODEL_LINEAR`, `ZCL_CC_MODEL_FACTORY`
- `ZCL_CC_IMPORT` — CSV sensor-payload parser
- `ZCL_CC_ANALYTICS` — AMDP recurrence ranking

### CDS / RAP / Service (planned)
- `ZI_CC_EXCURSION` / `ZC_CC_EXCURSION` / `ZC_CC_EXCURSION_KPI` / `ZI_CC_TEMP_TREND`
- `ZI_CC_EXCURSION` behavior (unmanaged) + `ZBP_I_CC_EXCURSION`
- `ZSD_CC_EXCURSION` service definition + `ZUI_CC_EXCURSION` binding

---

## 🚀 Getting Started

### Prerequisites
- **SAP BTP ABAP Environment** (trial or licensed) with `ABAP for Cloud Development`
- **Eclipse** with **ABAP Development Tools (ADT)**
- **abapGit** ADT plugin ([`https://eclipse.abapgit.org/updatesite/`](https://eclipse.abapgit.org/updatesite/))

### Import via abapGit
1. In Eclipse ADT, open **Window → Show View → Other → abapGit Repositories**.
2. Click the green **+** to link a new repository.
3. Paste this repo's URL and select/create a target package (e.g. `ZPKG_CC_DEMO`).
4. Check **Pull after link** to import all objects.
5. Activate the objects (mass-activate the package).

> ℹ️ Master data (material, plant, batch) is **never re-stored** here — it is reached only through **released SAP CDS interface views** (`I_Product`, `I_Plant`, `I_BatchTP`), in keeping with Clean Core.

---

## 🎯 Learning Goals

This project is built as a hands-on companion to the **SAP Certified – Backend Developer – ABAP Cloud** certification, exercising the full syllabus by *building*, not memorizing:

- ✅ Core ABAP programming (largest exam weighting)
- ✅ ABAP Core Data Services & data modeling
- ✅ ABAP RESTful Application Programming Model (RAP)
- ✅ ABAP SQL & code pushdown
- ✅ Object-oriented design
- ✅ Clean Core extensibility & ABAP Cloud
- ✅ AI-assisted development with Joule for Developers

---

## 🧱 Clean Core / Clean ABAP Principles

- **No modification** of SAP standard objects — own namespace only.
- **Released APIs only** — enforced by `ABAP for Cloud Development` language version.
- **No direct SELECT** from standard tables — associations to released CDS views instead.
- Business logic lives **only** in the behavior handler and core engine — never in CDS or UI.
- `strict(2)` behavior definition; modern constructor expressions (`VALUE`, `FOR`, `REDUCE`, `COND`).
- Every validation/action populates `failed`/`reported` — no silent failures.

---

## 📄 License

This is a personal, educational project. Provided as-is for learning and demonstration purposes.

---

*Built with modern ABAP Cloud on SAP BTP · Developed in Eclipse ADT · Version-controlled with abapGit* 🚀
