CLASS zcl_sel_criteria_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        ir_sel_criteria TYPE REF TO zcl_sel_criteria.

    METHODS select_and_list.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mr_sel_criteria TYPE REF TO zcl_sel_criteria.

ENDCLASS.



CLASS ZCL_SEL_CRITERIA_TEST IMPLEMENTATION.


  METHOD constructor.
    mr_sel_criteria = ir_sel_criteria.
  ENDMETHOD.


  METHOD select_and_list.
    DATA: lt_sel_opt_tname TYPE RANGE OF tabname,
          lt_sel_opt_tclas TYPE RANGE OF tabclass,
          lv_param_mlang   TYPE masterlang.

    IF mr_sel_criteria IS INITIAL.
      RETURN.
    ENDIF.

    mr_sel_criteria->get_select_option( EXPORTING iv_name = 'TABNAME' IMPORTING et_select_option = lt_sel_opt_tname ).
    mr_sel_criteria->get_select_option( EXPORTING iv_name = 'SO_TCLAS' IMPORTING et_select_option = lt_sel_opt_tclas ).

    mr_sel_criteria->get_parameter( EXPORTING iv_name = 'PA_MLANG' IMPORTING ev_parameter = lv_param_mlang ).

    SELECT * FROM dd02l
             INTO TABLE @DATA(lt_dd02l)
             WHERE tabname IN @lt_sel_opt_tname
             AND   tabclass IN @lt_sel_opt_tclas
             AND   masterlang = @lv_param_mlang.

    IF sy-subrc <> 0.
      WRITE 'No data selected.' COLOR COL_NEGATIVE.
      RETURN.
    ENDIF.

    LOOP AT lt_dd02l INTO DATA(ls_dd02l).
      WRITE: / ls_dd02l-tabname COLOR COL_HEADING,
               ls_dd02l-as4local COLOR COL_HEADING,
               ls_dd02l-as4vers COLOR COL_HEADING,
               ls_dd02l-tabclass,
               ls_dd02l-masterlang.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
