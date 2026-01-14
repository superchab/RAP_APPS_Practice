CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS ValidateDueDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~ValidateDueDate.
    METHODS SetHeaderStatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR Item~SetHeaderStatus.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD ValidateDueDate.
    READ ENTITIES OF zzum_r_tasktp IN LOCAL MODE
         ENTITY Item
         FIELDS ( DueDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_subtasks).
    IF lt_subtasks IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    LOOP AT lt_subtasks ASSIGNING FIELD-SYMBOL(<fs_subtask>) WHERE DueDate < lv_today OR DueDate IS INITIAL.

      failed-item = VALUE #( BASE failed-item
                             ( %tky = <fs_subtask>-%tky ) ).

      reported-item = VALUE #( BASE reported-item
                               ( %tky = <fs_subtask>-%tky
                                 %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                               text     = |Due date cannot be in the past| ) ) ).

    ENDLOOP.



  ENDMETHOD.

  METHOD SetHeaderStatus.
    READ ENTITIES OF zzum_r_tasktp IN LOCAL MODE
         ENTITY Item FIELDS ( ParentUUID )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_subtasks).
    IF lt_subtasks IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_task_head TYPE TABLE OF zzum_task_head.

    LOOP AT lt_subtasks ASSIGNING FIELD-SYMBOL(<fs_subtask>).

      lt_task_head = VALUE #( BASE lt_task_head
                              ( task_uuid = <fs_subtask>-ParentUUID ) ).

    ENDLOOP.

    SORT lt_task_head.
    DELETE ADJACENT DUPLICATES FROM lt_task_head COMPARING task_uuid.

    DATA lv_open_count TYPE int1.

    LOOP AT lt_task_head ASSIGNING FIELD-SYMBOL(<fs_task>).

      CLEAR lv_open_count.

      READ ENTITIES OF zzum_r_tasktp IN LOCAL MODE
           ENTITY Header BY \_Subtask
           FIELDS ( Status ) WITH VALUE #( ( %tky-TaskUUID = <fs_task>-task_uuid ) )
           RESULT DATA(lt_all_subtasks).

      LOOP AT lt_all_subtasks ASSIGNING <fs_subtask> WHERE Status <> 'C'.

        lv_open_count += 1.

      ENDLOOP.

      IF lv_open_count = 0.

        MODIFY ENTITIES OF zzum_r_tasktp IN LOCAL MODE
               ENTITY Header
               UPDATE FIELDS ( OverallStatus )
               WITH VALUE #( ( %tky-TaskUuid          = <fs_task>-task_uuid
                               OverallStatus          = 'C'
                               %control-OverallStatus = if_abap_behv=>mk-on ) ).

        reported-item = VALUE #(
            BASE reported-item
            ( %tky = lt_all_subtasks[ 1 ]-%tky
              %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                            text     = |All subtasks finished! Parent task marked as Completed.| ) ) ).
      ELSE.

        reported-item = VALUE #(
            BASE reported-item
            ( %tky = lt_all_subtasks[ 1 ]-%tky
              %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-information
                         text     = |Update saved. You still have { lv_open_count } open subtasks.| ) ) ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

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
