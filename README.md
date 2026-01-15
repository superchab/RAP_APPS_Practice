# 📋 Task Manager Application (ABAP RAP)

A robust Task Management solution built using the **SAP RESTful Application Programming Model (RAP)**. This application allows users to manage hierarchical tasks (Headers and Subtasks), track status updates, and visualize progress dynamically.

Designed with **ABAP Cloud** principles and fully covered by **ABAP Unit Integration Tests**.

---

## ✨ Key Features

* **Task Lifecycle Management:** Create, Update, and Delete tasks with Draft capabilities (auto-save).
* **Hierarchical Structure:** Parent-Child relationship between **Tasks** and **Subtasks**.
* **Status Tracking:** Manage lifecycle status (`OPEN`, `COMPLETED`, etc.).
* **Dynamic Calculations:**
    * **Virtual Elements:** `Progress` field is calculated on-the-fly based on status (UI-only field).
    * **Side Effects:** Changing `OverallStatus` immediately triggers a UI refresh for the `Progress` bar.
* **Business Logic:**
    * **Validations:** Ensures mandatory fields (e.g., Title) are provided.
    * **Determinations:** Automatically generates human-readable Task IDs and timestamps.

---

## 🛠️ Technical Architecture

### 1. Data Model (CDS Views)
The application follows the VDM (Virtual Data Model) standard:
* **Basic Views:** `ZZUM_I_TASK_HEAD`, `ZZUM_I_TASK_ITEM` (Direct DB interface).
* **Transactional Views (Root):** `ZZUM_R_TASKTP`, `ZZUM_R_SUBTASKTP` (Behavior definition source).
* **Projection Views:** `ZZUM_C_TASKTP` (Consumption view for Fiori UI).

### 2. Database Layer
* **Active Tables:** `ZZUM_TASK_HEAD`, `ZZUM_TASK_ITEM`
* **Draft Tables:** `ZZUM_TASK_D`, `ZZUM_SUBTASK_D` (Managed by RAP framework)

### 3. Business Logic Classes
* **Behavior Implementation:** `ZBP_ZUM_R_TASKTP` (Handles validations, actions, and draft logic).
* **Virtual Element Calculation:** `ZCL_CALC_PROGRESS` (Calculates progress % for the UI).

---

## 🧪 Testing Strategy

This project enforces high code quality using **ABAP Unit** and the **CDS Test Double Framework**.

### Integration Tests (`ZCL_TEST_TASK_BO`)
We utilize the `CL_CDS_TEST_ENVIRONMENT` to mock the underlying database tables, allowing us to test the RAP Business Object in isolation without polluting the real database.

| Test Case | Description | Type |
| :--- | :--- | :--- |
| **`test_create_task`** | Verifies the "Create" operation. Checks that UUIDs are generated, default status is set, and mandatory Title validation passes. | **EML Integration** |
| **`test_update_status`** | Verifies the "Update" operation. Simulates a user changing `OverallStatus` from 'OPEN' to 'COMPLETED' and asserts the DB change. | **EML Integration** |
| **`test_calculation`** | (Optional) Verifies the `ZCL_CALC_PROGRESS` logic transforms Status into correct Integer percentage. | **Unit Test** |

---

## 🚀 How to Install

1.  **Clone the Repository:** Use **abapGit** to clone this repository into your SAP BTP or On-Premise system.
2.  **Activate Objects:** Activate all Dictionary objects, CDS Views, and Behavior Definitions.
3.  **Publish Service:**
    * Go to transaction `/IWFND/MAINT_SERVICE` (or Service Binding editor in ADT).
    * Publish the OData V4 Service Binding.
4.  **Run Tests:**
    * Open `ZBP_ZUM_R_TASKTP` or `ZCL_TEST_TASK_BO` in ADT.
    * Run as **ABAP Unit Test** (`Ctrl+Shift+F10`).

---

## 👨‍💻 Technologies Used

* **Language:** ABAP (Cloud Profile)
* **Framework:** RAP (RESTful Application Programming Model)
* **IDE:** Eclipse ADT (ABAP Development Tools)
* **Testing:** ABAP Unit, CDS Test Double Framework, EML (Entity Manipulation Language)
