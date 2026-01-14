CLASS zcl_zum_calculated_progress DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.

ENDCLASS.


CLASS zcl_zum_calculated_progress IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_tasktp TYPE STANDARD TABLE OF zzum_c_tasktp WITH DEFAULT KEY.

    IF it_original_data IS INITIAL.
      RETURN.
    ENDIF.

    lt_tasktp = CORRESPONDING #( it_original_data ).

    DATA lr_taskuuid TYPE RANGE OF sysuuid_x16.

    lr_taskuuid = VALUE #( FOR ls_row IN lt_tasktp
                           ( sign = 'I' option = 'EQ' low = ls_row-TaskUUID ) ).

    SELECT ParentUUID,
           Status
      FROM zzum_r_subtasktp
      WHERE ParentUUID IN @lr_taskuuid
      INTO TABLE @DATA(lt_subtask).
    IF lt_subtask IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_subtask_total) = 0.
    DATA(lv_subtask_completed) = 0.

    LOOP AT lt_tasktp ASSIGNING FIELD-SYMBOL(<fs_task>).
      lv_subtask_total = 0.
      lv_subtask_completed = 0.
      LOOP AT lt_subtask ASSIGNING FIELD-SYMBOL(<fs_subtask>) WHERE ParentUUID = <fs_task>-TaskUuid.
        lv_subtask_total += 1.
        IF <fs_subtask>-Status = 'C'.
          lv_subtask_completed += 1.
        ENDIF.
      ENDLOOP.
      IF lv_subtask_total > 0.
        <fs_task>-Progress = ( lv_subtask_completed * 100 ) / lv_subtask_total.
      ELSE.
        <fs_task>-Progress = 0.
      ENDIF.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_tasktp ).
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF iv_entity = 'ZZUM_C_TASKTP'.
      LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_req_calc_elem>).

        IF <fs_req_calc_elem> = 'PROGRESS'.
          APPEND 'TASKUUID' TO et_requested_orig_elements.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
