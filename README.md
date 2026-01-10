# RAP_APPS_Practice
"RAP application" practices
# SAP RAP Task Manager

A cloud-ready ABAP RESTful Application Programming Model (RAP) application for managing tasks and subtasks. This project demonstrates a "Greenfield" implementation on SAP S/4HANA.

## Architectural Overview

* **Scenario:** Managed Implementation with Draft Capabilities.
* **Data Model:** * **Root:** Task Header (`ZZUM_R_TASKTP`)
    * **Child:** Task Items (`ZZUM_R_TASKITEMTP`)
* **Key Strategy:** UUID-based keys (Raw16) with Early Numbering.
* **Concurrency:** Optimistic Locking via ETag (`LocalLastChangedAt`).

## Features
* Create, Update, and Delete functionality for Tasks and Subtasks.
* Draft handling allows saving "work-in-progress" before final activation.
* Standard Admin data tracking (Created By/At, Changed By/At).
