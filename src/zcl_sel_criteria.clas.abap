CLASS zcl_sel_criteria DEFINITION
                       PUBLIC
                       FINAL
                       CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF select_option,
             name_short   TYPE rsscr_name,
             name_long    TYPE string,
             data_element TYPE ddobjname,
             values       TYPE REF TO data,
           END OF select_option.

    TYPES: BEGIN OF parameter,
             name_short   TYPE string,
             name_long    TYPE string,
             data_element TYPE ddobjname,
             value        TYPE REF TO data,
           END OF parameter.

    TYPES: rsparamsl_255_tab TYPE TABLE OF rsparamsl_255,
           parameter_tab     TYPE TABLE OF parameter,
           select_option_tab TYPE TABLE OF select_option.

    METHODS get_parameter
      IMPORTING
        iv_name      TYPE string
      EXPORTING
        ev_parameter TYPE any.

    METHODS get_select_option
      IMPORTING
        iv_name          TYPE string
      EXPORTING
        et_select_option TYPE ANY TABLE.

    METHODS get_parameter_list
      EXPORTING
        et_parameters TYPE parameter_tab.

    METHODS get_select_options_list
      EXPORTING
        et_select_options TYPE select_option_tab.

    METHODS transfer_sel_criteria_names
      IMPORTING
        it_names TYPE rsparamsl_255_tab.

    METHODS set_parameter
      IMPORTING
        iv_name_short       TYPE string
        iv_screen_parameter TYPE any.

    METHODS set_select_option
      IMPORTING
        iv_name_short            TYPE rsscr_name
        it_screen_select_options TYPE ANY TABLE.

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA: mt_select_options TYPE TABLE OF select_option,
          mt_parameters     TYPE TABLE OF parameter.

    METHODS get_data_element_default_name
      IMPORTING
        iv_data_element        TYPE ddobjname
      RETURNING
        VALUE(rv_default_name) TYPE deffdname.
ENDCLASS.



CLASS ZCL_SEL_CRITERIA IMPLEMENTATION.


  METHOD get_data_element_default_name.
    DATA ls_dd04v TYPE dd04v.

    CALL FUNCTION 'DDIF_DTEL_GET'
      EXPORTING
        name          = iv_data_element
*       STATE         = 'A'
        langu         = sy-langu
      IMPORTING
*       GOTSTATE      =
        dd04v_wa      = ls_dd04v
*       TPARA_WA      =
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.

    IF sy-subrc <> 0.
    ENDIF.

    rv_default_name = ls_dd04v-deffdname.
  ENDMETHOD.


  METHOD get_parameter.
    DATA lv_component TYPE string VALUE 'name_short'.

    TRY.
        DATA(lr_reference) = mt_parameters[ (lv_component) = iv_name ]-value.
      CATCH cx_sy_itab_line_not_found.
        IF lv_component = 'name_short'.
          lv_component = 'name_long'.
        ELSE.
          RETURN.
        ENDIF.
        RETRY.
    ENDTRY.

    IF lr_reference IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN lr_reference->* TO FIELD-SYMBOL(<class_parameter>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ev_parameter = <class_parameter>.
  ENDMETHOD.


  METHOD get_parameter_list.
    et_parameters = mt_parameters.
  ENDMETHOD.


  METHOD get_select_option.
    DATA lv_component TYPE string VALUE 'name_short'.

    TRY.
        DATA(lr_reference) = mt_select_options[ (lv_component) = iv_name ]-values.
      CATCH cx_sy_itab_line_not_found.
        IF lv_component = 'name_short'.
          lv_component = 'name_long'.
        ELSE.
          RETURN.
        ENDIF.
        RETRY.
    ENDTRY.

    IF lr_reference IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN lr_reference->* TO FIELD-SYMBOL(<class_select_option>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    et_select_option = <class_select_option>.
  ENDMETHOD.


  METHOD get_select_options_list.
    et_select_options = mt_select_options.
  ENDMETHOD.


  METHOD set_parameter.
    DATA lr_value TYPE REF TO data.
    DATA(lr_description) = cl_abap_elemdescr=>describe_by_data( iv_screen_parameter ).

    TRY.
        ASSIGN mt_parameters[ name_short = iv_name_short ] TO FIELD-SYMBOL(<parameters>).
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    <parameters>-data_element = lr_description->get_relative_name( ).
    <parameters>-name_long = get_data_element_default_name( iv_data_element = <parameters>-data_element ).
    CREATE DATA lr_value LIKE iv_screen_parameter.
    ASSIGN lr_value->* TO FIELD-SYMBOL(<class_parameter>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    <class_parameter> = iv_screen_parameter.
    <parameters>-value = lr_value.
  ENDMETHOD.


  METHOD set_select_option.
    DATA: lt_components           TYPE abap_component_tab,
          ls_component            TYPE LINE OF abap_component_tab,
          lr_struct_descr         TYPE REF TO cl_abap_structdescr,
          lr_table_descr          TYPE REF TO cl_abap_tabledescr,
          lr_data_descr           TYPE REF TO cl_abap_datadescr,
          lr_values               TYPE REF TO data,
          lr_screen_select_option TYPE REF TO data.

    TRY.
        ASSIGN mt_select_options[ name_short = iv_name_short ] TO FIELD-SYMBOL(<select_options>).
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    DATA(lr_description) = cl_abap_elemdescr=>describe_by_name( 'TVARV_SIGN' ).
    ls_component-name = 'SIGN'.
    ls_component-type ?= lr_description.
    INSERT ls_component INTO TABLE lt_components.

    lr_description = cl_abap_elemdescr=>describe_by_name( 'TVARV_OPTI' ).
    ls_component-name = 'OPTION'.
    ls_component-type ?= lr_description.
    INSERT ls_component INTO TABLE lt_components.

    " create a line of screen select-options dynamically
    CREATE DATA lr_screen_select_option LIKE LINE OF it_screen_select_options.
    ASSIGN lr_screen_select_option->* TO FIELD-SYMBOL(<screen_select_option>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " access component "LOW" to detect data element
    ASSIGN COMPONENT 'LOW' OF STRUCTURE <screen_select_option> TO FIELD-SYMBOL(<low>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lr_description = cl_abap_elemdescr=>describe_by_data( <low> ).
    <select_options>-data_element = lr_description->get_relative_name( ).
    MOVE 'LOW' TO ls_component-name.
    ls_component-type ?= lr_description.
    INSERT ls_component INTO TABLE lt_components.

    MOVE 'HIGH' TO ls_component-name.
    ls_component-type ?= lr_description.
    INSERT ls_component INTO TABLE lt_components.

    " create if possible a longer name to identify the select-options
    <select_options>-name_long = get_data_element_default_name( iv_data_element = <select_options>-data_element ).

    " create select-option table of class dynamically
    lr_struct_descr ?= cl_abap_structdescr=>create( lt_components ).
    lr_data_descr ?= lr_struct_descr.
    lr_table_descr ?= cl_abap_tabledescr=>create( lr_data_descr ).
    CREATE DATA lr_values TYPE HANDLE lr_table_descr.
    ASSIGN lr_values->* TO FIELD-SYMBOL(<class_select_option>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " copy select-option table content from screen to class
    <class_select_option> = it_screen_select_options.
    <select_options>-values = lr_values.
  ENDMETHOD.


  METHOD transfer_sel_criteria_names.
    LOOP AT it_names INTO DATA(ls_sel_table_255).
      IF ls_sel_table_255-kind = 'P'.
        IF line_exists( mt_parameters[ name_short = ls_sel_table_255-selname ] ).
          CONTINUE.
        ELSE.
          APPEND INITIAL LINE TO mt_parameters ASSIGNING FIELD-SYMBOL(<parameter>).
          IF sy-subrc <> 0.
            " error
          ELSE.
            <parameter>-name_short = ls_sel_table_255-selname.
          ENDIF.
        ENDIF.
      ELSEIF ls_sel_table_255-kind = 'S'.
        IF line_exists( mt_select_options[ name_short = ls_sel_table_255-selname ] ).
          CONTINUE.
        ELSE.
          APPEND INITIAL LINE TO mt_select_options ASSIGNING FIELD-SYMBOL(<select_option>).
          IF sy-subrc <> 0.
            " error
          ELSE.
            <select_option>-name_short = ls_sel_table_255-selname.
          ENDIF.
        ENDIF.
      ELSE.
        " error
      ENDIF.
    ENDLOOP.

    SORT mt_parameters BY name_short ASCENDING.
    SORT mt_select_options BY name_short ASCENDING.
  ENDMETHOD.
ENDCLASS.
