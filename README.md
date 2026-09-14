# 🧊 Cold-Chain Excursion & Shelf-Life Guard (CCSG)

A sample SAP application that tracks cold-chain temperature excursions and evaluates their impact on product shelf life.

Built using modern ABAP, RAP, CDS, ABAP Unit, and Clean Core principles on SAP BTP ABAP Environment.

![Platform](https://img.shields.io/badge/Platform-SAP%20BTP%20ABAP%20Environment-0A6E4F)
![Model](https://img.shields.io/badge/Model-ABAP%20Cloud%20(RAP)-0A6E4F)
![Language](https://img.shields.io/badge/Language-ABAP%20for%20Cloud%20Development-0A6E4F)
![Clean Core](https://img.shields.io/badge/Clean%20Core-Compliant-2E7D32)
![Tooling](https://img.shields.io/badge/IDE-Eclipse%20ADT-blue)

---

## Overview

Cold-chain failures are a common challenge in food and temperature-sensitive supply chains. A brief temperature spike may seem harmless, but repeated or prolonged excursions can reduce product shelf life and increase quality risk.

CCSG simulates this process.

The application collects temperature readings from refrigerated zones, identifies excursion events, calculates cumulative exposure using degree-minutes, and evaluates the impact on affected inventory batches. Quality teams can then review the event, assess risk, and record a disposition decision.

The project uses a layered architecture that separates business rules, persistence, analytics, and service exposure. The goal is to keep the core logic independent, testable, and easy to evolve.

---

## Business Scenario

A refrigerated storage zone has an expected operating temperature and an acceptable tolerance range.

Sensors periodically capture readings from the zone.

When readings remain above the defined threshold, CCSG identifies an excursion event and calculates its severity using cumulative degree-minutes.

```
Degree Minutes = (Temperature - Threshold) × Elapsed Time
```

Each excursion may impact one or more product batches.

Based on predefined shelf-life rules, the system estimates the reduction in remaining shelf life and helps support disposition decisions such as:

- Release
- Reduce Shelf Life
- Hold
- Scrap

The process is fully auditable from initial detection through final disposition.

---

## Architecture

```text
┌───────────────────────────────────────────────────────────────┐
│ OData V4 Service                                              │
│ Service Definition + Binding                                  │
└───────────────────────────────┬───────────────────────────────┘
                                │
┌───────────────────────────────▼───────────────────────────────┐
│ RAP Business Object                                           │
│ Actions, Validations, Determinations                          │
└───────────────────────────────┬───────────────────────────────┘
                                │
┌───────────────────────────────▼───────────────────────────────┐
│ Core Business Logic                                           │
│                                                               │
│ ZCL_CC_EXCURSION_DETECTOR                                     │
│ ZIF_CC_SHELFLIFE_MODEL                                        │
│ ZCL_CC_SL_MODEL_LINEAR                                        │
│ ZCL_CC_SL_MODEL_Q10                                           │
│ ZCL_CC_MODEL_FACTORY                                          │
│ ZCX_CC_ERROR                                                  │
└───────────────────────────────┬───────────────────────────────┘
                                │
┌───────────────────────────────▼───────────────────────────────┐
│ CDS Views / ABAP SQL / AMDP                                   │
│ Analytics and Reporting                                       │
└───────────────────────────────┬───────────────────────────────┘
                                │
┌───────────────────────────────▼───────────────────────────────┐
│ Data Model                                                    │
│                                                               │
│ ZDT_CC_TEMPLOG                                                │
│ ZDT_CC_EXC_HDR                                                │
│ ZDT_CC_EXC_BATCH                                              │
│ ZDT_CC_ZONE                                                   │
│ ZDT_CC_PRODRULE                                               │
└───────────────────────────────────────────────────────────────┘
```

---

## Technical Highlights

This project explores a number of modern SAP development concepts:

- Object-oriented ABAP
- ABAP Unit testing
- RAP business objects
- CDS view entities
- OData V4 services
- ABAP SQL and code pushdown
- Clean Core development
- Factory and Strategy design patterns
- Exception-based error handling
- Domain-driven business logic

---

## Current Scope

### Data Model

Implemented:

- `ZDT_CC_TEMPLOG` – Temperature sensor readings
- `ZDT_CC_EXC_HDR` – Excursion event header
- `ZDT_CC_EXC_BATCH` – Affected inventory batches
- `ZDT_CC_ZONE` – Refrigerated zone master data
- `ZDT_CC_PRODRULE` – Shelf-life calculation rules

### Business Logic

Implemented:

- `ZCX_CC_ERROR`
- `ZCL_CC_EXCURSION_DETECTOR`
- ABAP Unit tests

In Progress:

- `ZIF_CC_SHELFLIFE_MODEL`
- `ZCL_CC_SL_MODEL_LINEAR`
- `ZCL_CC_SL_MODEL_Q10`
- `ZCL_CC_MODEL_FACTORY`

Planned:

- RAP Business Object
- CDS Analytics Layer
- OData Service Layer
- KPI Reporting

---

## Design Principles

The project follows several design principles:

- Business logic remains independent of the UI layer
- Released SAP APIs only
- No modification of SAP standard objects
- Clear separation between persistence, services, and domain logic
- Test-first mindset using ABAP Unit
- Preference for readability and maintainability over clever code

---

## Getting Started

### Prerequisites

- SAP BTP ABAP Environment
- Eclipse with ABAP Development Tools (ADT)
- abapGit (optional)

### Import

Clone or download the repository and import the objects into a package of your choice.

The repository structure follows a standard ABAP source layout:

```text
README.md
src/
```

---

## Roadmap

### Completed

- Data model
- Exception framework
- Excursion detection engine
- ABAP Unit testing foundation

### In Progress

- Shelf-life calculation models
- Factory pattern implementation

### Planned

- CDS analytics
- RAP business object
- OData services
- KPI dashboards

---

## License

This repository is maintained as a personal project for experimentation, learning, and demonstration purposes.

Use the code and ideas at your own discretion.

---

*Built with SAP BTP ABAP Environment, Eclipse ADT, and modern ABAP development practices.*
