CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.
    METHODS validatetitle FOR VALIDATE ON SAVE
      IMPORTING keys FOR header~validatetitle.
    METHODS validateminonesubtask FOR VALIDATE ON SAVE
      IMPORTING keys FOR header~validateminonesubtask.
    METHODS setinitialstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR header~setinitialstatus.

    METHODS calculatetaskid FOR DETERMINE ON SAVE
      IMPORTING keys FOR header~calculatetaskid.

ENDCLASS.


CLASS lhc_Header IMPLEMENTATION.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD validateTitle.
    READ ENTITIES OF zzum_r_tasktp IN LOCAL MODE
         ENTITY Header
         FIELDS ( Title )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_result).
    IF lt_result IS NOT INITIAL.
      IF lt_result[ 1 ]-Title IS INITIAL.
        failed-header = VALUE #(  BASE failed-header
                                 ( %tky = lt_result[ 1 ]-%tky ) ).

        reported-header = VALUE #(
            ( %tky           = lt_result[ 1 ]-%tky
              %msg           = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'Task title cannot be empty' )
              %element-title = if_abap_behv=>mk-on ) ).

      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD validateMinOneSubtask.
    " 1. Read the Subtasks linked to the Tasks we are saving
    READ ENTITIES OF zzum_r_tasktp IN LOCAL MODE
         ENTITY Header
         BY \_Subtask  " Follow the association to get children
         FROM CORRESPONDING #( keys )
         RESULT DATA(lt_subtasks).

    " 2. Loop through the Tasks triggering this validation
    LOOP AT keys INTO DATA(ls_key).

      " 3. Check if this specific Task Key exists in the results (lt_subtasks)
      " The READ BY \_Subtask returns a table where each line is a Subtask.
      " If a Task has no Subtasks, it won't appear in lt_subtasks (or won't match).
      IF line_exists( lt_subtasks[ ParentUUID = ls_key-TaskUuid ] ).
        CONTINUE.
      ENDIF.

      " 4. Raise Error if no subtask found
      APPEND VALUE #( %tky = ls_key-%tky ) TO failed-header.

      APPEND VALUE #( %tky = ls_key-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                    text     = 'A Task must have at least one Subtask.' ) )
             TO reported-header.

    ENDLOOP.
  ENDMETHOD.
  METHOD SetInitialStatus.


    MODIFY ENTITIES OF zzum_r_tasktp IN LOCAL MODE
    ENTITY Header
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR ls_keys IN keys
                  ( %tky = ls_keys-%tky
                    OverallStatus = 'P' )
    ).

  ENDMETHOD.

  METHOD CalculateTaskID.

    READ ENTITIES OF zzum_r_tasktp IN LOCAL MODE
         ENTITY Header
         FIELDS ( TaskId )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_taskID).

    DELETE lt_taskid WHERE taskid IS NOT INITIAL.
    IF lt_taskid IS NOT INITIAL.

      SELECT SINGLE MAX( TaskId ) AS Max_taskID FROM zzum_i_task_head
      INTO @DATA(lv_maxID).

      SPLIT lv_maxid AT '-' INTO DATA(lv_TASK) DATA(lv_numb).

      lv_maxid = |{ lv_task }-{ lv_numb + 1 }|.

      MODIFY ENTITIES OF zzum_r_tasktp IN LOCAL MODE
      ENTITY Header
      UPDATE FIELDS ( TaskId )
      WITH VALUE #( FOR ls_taskid IN lt_taskid
                    ( %tky = ls_taskid-%tky
                      TaskId = lv_maxid )
      ).


    ENDIF.




  ENDMETHOD.

ENDCLASS.
