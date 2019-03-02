*&---------------------------------------------------------------------*
*& Report ZSEL_CRITERIA_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsel_criteria_test.

DATA gs_dd02l TYPE dd02l.

SELECT-OPTIONS: so_tname FOR gs_dd02l-tabname,
                so_tclas FOR gs_dd02l-tabclass.

PARAMETERS pa_mlang LIKE gs_dd02l-masterlang DEFAULT 'DE'.

CLASS lcl_selection_criteria DEFINITION CREATE PUBLIC FINAL.
  PUBLIC SECTION.
    METHODS constructor.

    METHODS get_object
      RETURNING
        VALUE(rr_sel_criteria) TYPE REF TO zcl_sel_criteria.

  PRIVATE SECTION.
    DATA mr_sel_criteria TYPE REF TO zcl_sel_criteria.

    METHODS identify_selection_criteria.

    METHODS transfer_parameters.

    METHODS transfer_select_options.
ENDCLASS.


CLASS lcl_selection_criteria IMPLEMENTATION.
  METHOD constructor.
    mr_sel_criteria = NEW zcl_sel_criteria( ).
    identify_selection_criteria( ).
    transfer_parameters( ).
    transfer_select_options( ).
  ENDMETHOD.

  METHOD identify_selection_criteria.
    DATA: lt_sel_table     TYPE TABLE OF rsparams,
          lt_sel_table_255 TYPE TABLE OF rsparamsl_255.

    CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
      EXPORTING
        curr_report         = sy-repid
*     IMPORTING
*       SP                  =
      TABLES
        selection_table     = lt_sel_table
        selection_table_255 = lt_sel_table_255
      EXCEPTIONS
        not_found           = 1
        no_report           = 2
        OTHERS              = 3.

    IF sy-subrc <> 0.
      RETURN. " error handling needed
    ENDIF.

    IF lt_sel_table_255 IS INITIAL.
      RETURN. " error handling needed
    ENDIF.

    mr_sel_criteria->transfer_sel_criteria_names( EXPORTING it_names = lt_sel_table_255 ).
  ENDMETHOD.

  METHOD transfer_parameters.
    mr_sel_criteria->get_parameter_list( IMPORTING et_parameters = DATA(lt_parameters) ).

    LOOP AT lt_parameters ASSIGNING FIELD-SYMBOL(<parameter>).
      " get access to parameter of selection screen
      ASSIGN (<parameter>-name_short) TO FIELD-SYMBOL(<screen_parameter>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      " transfer it to global class
      mr_sel_criteria->set_parameter( EXPORTING iv_name_short = <parameter>-name_short iv_screen_parameter = <screen_parameter> ).
    ENDLOOP.
  ENDMETHOD.


  METHOD transfer_select_options.
    mr_sel_criteria->get_select_options_list( IMPORTING et_select_options = DATA(lt_select_options) ).

    LOOP AT lt_select_options ASSIGNING FIELD-SYMBOL(<select_option>).
      " get access to select-option of selection screen
      DATA(lv_sel_opt_name) = | { <select_option>-name_short }[] |.
      ASSIGN (lv_sel_opt_name) TO FIELD-SYMBOL(<screen_select_option>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      " transfer it to global class
      mr_sel_criteria->set_select_option(
        EXPORTING
          iv_name_short            = <select_option>-name_short
          it_screen_select_options = <screen_select_option>
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_object.
    rr_sel_criteria = mr_sel_criteria.
  ENDMETHOD.
ENDCLASS.


INITIALIZATION.
  DATA ls_tname LIKE LINE OF so_tname.
  ls_tname = VALUE #( sign = 'I' option = 'EQ' low = 'T000' high = 'T005' ).
  APPEND ls_tname TO so_tname.
  ls_tname = VALUE #( sign = 'E' option = 'EQ' low = 'T002' high = space ).
  APPEND ls_tname TO so_tname.

  DATA ls_tclas LIKE LINE OF so_tclas.
  ls_tclas = VALUE #( sign = 'I' option = 'EQ' low = 'TRANSP' high = space ).
  APPEND ls_tclas TO so_tclas.


START-OF-SELECTION.
  " local helper with access to parameters and select-options
  DATA(lr_sel_criteria) = NEW lcl_selection_criteria( ).

  " demo application based on a global class
  DATA(lr_application) = NEW zcl_sel_criteria_test( ir_sel_criteria = lr_sel_criteria->get_object( ) ).
  lr_application->select_and_list( ).
