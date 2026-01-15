*"* use this source file for your ABAP unit test classes
CLASS ltcl_integration_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    CLASS-DATA go_environment TYPE REF TO if_cds_test_environment.

    " Run once before all tests: Setup the fake database
    CLASS-METHODS class_setup.
    " Run once after all tests: Clean up
    CLASS-METHODS class_teardown.

    " The specific test case
*    METHODS test_update_status FOR TESTING RAISING cx_static_check.
    METHODS test_create_task FOR TESTING RAISING cx_static_check.
    METHODS test_progress_calculation FOR TESTING RAISING cx_static_check.
    METHODS setup.
    METHODS teardown.
ENDCLASS.


CLASS ltcl_integration_test IMPLEMENTATION.
  METHOD class_setup.
    " create environment for the Root View
    go_environment = cl_cds_test_environment=>create(
      i_for_entity      = 'ZZUM_R_TASKTP'

      " Explicitly tell it to mock the DB tables (Active AND Draft)
      i_dependency_list = VALUE #(
        ( name = 'ZZUM_TASK_HEAD' type = 'TABLE' )
*        ( name = 'ZZUM_TASK_ITEM'     type = 'TABLE' ) " <--- YOUR DRAFT TABLE NAME HERE

      )
    ).
  ENDMETHOD.

  METHOD class_teardown.
    go_environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    go_environment->clear_doubles( ).
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
  ENDMETHOD.

*  METHOD test_update_status.
*    DATA lt_mock_data TYPE STANDARD TABLE OF zzum_task_head.
*    DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
*    lt_mock_data = VALUE #( ( task_uuid = lv_uuid overall_status = 'O' ) ).
*
*    go_environment->insert_test_data( i_data = lt_mock_data ).
*
*    MODIFY ENTITIES OF zzum_r_tasktp ENTITY Header
*           UPDATE FIELDS ( OverallStatus )
*           WITH VALUE #( ( TaskUuid       = lv_uuid
*                         OverallStatus = 'C' ) )
*           " TODO: variable is assigned but never used (ABAP cleaner)
*           FAILED DATA(lt_failed) REPORTED DATA(lt_reported).
*
*    cl_abap_unit_assert=>assert_initial( lt_failed ).
*
*    " --- 3. ASSERT: Read the data back to verify the change ---
*    READ ENTITIES OF zzum_r_tasktp
*         ENTITY Header
*         ALL FIELDS WITH VALUE #( ( TaskUuid = lv_uuid ) )
*         RESULT DATA(lt_result).
*
*    " Check if the status was actually updated in the 'DB'
*    READ TABLE lt_result INTO DATA(ls_result) INDEX 1.
*
*    cl_abap_unit_assert=>assert_equals( exp = 'C'
*                                        act = ls_result-OverallStatus
*                                        msg = 'Status should have been updated to COMPLETED' ).
*  ENDMETHOD.

  METHOD test_create_task.

    " --- 1. ARRANGE ---
    " Generate a fresh UUID for the new Task
    DATA(lv_new_uuid) = cl_system_uuid=>create_uuid_x16_static( ).

    " --- 2. ACT ---
    " Create just the Parent Header
    MODIFY ENTITIES OF zzum_r_tasktp
      ENTITY Header
      CREATE
      FIELDS ( TaskUUID Title OverallStatus )
      WITH VALUE #(
        ( %cid          = 'NewTaskCID'        " <--- REQUIRED: Content ID for the buffer
          TaskUUID      = lv_new_uuid         " We use the generated UUID
          Title         = 'Unit Test Task'    " <--- Value provided to pass 'validateTitle'
          OverallStatus = 'O' )
      )
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

    " --- DEBUGGING ---
    " If this fails, check ls_failed-header-cause
    " or ls_reported-header to see the validation message
    cl_abap_unit_assert=>assert_initial( ls_failed ).


    " --- 3. ASSERT ---
    " Read the Task back from the mock database to verify it was saved
    READ ENTITIES OF zzum_r_tasktp ENTITY Header
      ALL FIELDS WITH VALUE #( ( TaskUUID = lv_new_uuid ) )
      RESULT DATA(lt_result).

    " Check 1: Did we find the record?
    cl_abap_unit_assert=>assert_not_initial(
      act = lt_result
      msg = 'Task should have been created in the mock DB'
    ).

    " Check 2: Is the Title correct?
    READ TABLE lt_result INTO DATA(ls_result) INDEX 1.
    cl_abap_unit_assert=>assert_equals(
      exp = 'Unit Test Task'
      act = ls_result-Title
    ).

  ENDMETHOD.

  METHOD test_progress_calculation.
    " --- 1. ARRANGE ---
    " Create data with a specific status (e.g., COMPLETED)
    DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).

    DATA lt_db_data TYPE STANDARD TABLE OF zzum_task_head.
    lt_db_data = VALUE #(
      ( task_uuid = lv_uuid  overall_status = 'C' ) " C = Completed
    ).
    go_environment->insert_test_data( i_data = lt_db_data ).

    " --- 2. ACT ---
    " 2a. Read the data from the BO (Simulating the UI fetching data)
    READ ENTITIES OF zzum_r_tasktp ENTITY Header
      ALL FIELDS WITH VALUE #( ( TaskUuid = lv_uuid ) )
      RESULT DATA(lt_bo_data).

    " 2b. Convert BO data to the format your Calculation Class expects (Consumption View)
    DATA lt_calc_input TYPE STANDARD TABLE OF zzum_c_tasktp.
    lt_calc_input = CORRESPONDING #( lt_bo_data MAPPING TaskUuid = TaskUuid ).
    " ^ NOTE: Adjust Mapping above if your C-View names differ from R-View names

    " 2c. Instantiate and Call the Calculation Class
    DATA(lo_calc) = NEW zcl_zum_calculated_progress( ). " <--- Your Calc Class Name
    DATA lt_progress TYPE if_sadl_exit_calc_element_read=>tt_elements.

    APPEND 'PROGRESS' TO lt_progress.

    lo_calc->if_sadl_exit_calc_element_read~calculate(
      EXPORTING
        it_original_data           = lt_calc_input
        it_requested_calc_elements = lt_progress
      CHANGING
        ct_calculated_data         = lt_calc_input
    ).

    " --- 3. ASSERT ---
    READ TABLE lt_calc_input INTO DATA(ls_calculated) INDEX 1.

    " Verify that Status 'C' resulted in Progress 100
    cl_abap_unit_assert=>assert_equals(
      exp = 100
      act = ls_calculated-Progress
      msg = 'Status Completed (C) should result in 100% Progress'
    ).
  ENDMETHOD.

ENDCLASS.
