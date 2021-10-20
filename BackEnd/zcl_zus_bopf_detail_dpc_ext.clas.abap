class ZCL_ZUS_BOPF_DETAIL_DPC_EXT definition
  public
  inheriting from ZCL_ZUS_BOPF_DETAIL_DPC
  create public .

public section.
protected section.

  methods BOPFSET_GET_ENTITYSET
    redefinition .
  methods HIERARCHYSET_GET_ENTITYSET
    redefinition .
  methods TABLESET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZUS_BOPF_DETAIL_DPC_EXT IMPLEMENTATION.


  METHOD bopfset_get_entityset.
**TRY.
*CALL METHOD SUPER->BOPFSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
    DATA: lv_bo_name TYPE /bobf/obm_objt-name,
          lv_bo_desc TYPE /bobf/obm_objt-description.

    LOOP AT it_filter_select_options INTO DATA(ls_select_option).
      READ TABLE ls_select_option-select_options INTO DATA(ls_select_option_value) INDEX 1.
      CASE ls_select_option-property.
        WHEN 'BO_NAME'.
          lv_bo_name = ls_select_option_value-low.
          REPLACE ALL OCCURRENCES OF '*' IN lv_bo_name WITH space.
          TRANSLATE lv_bo_name TO UPPER CASE.
          CONCATENATE '%' lv_bo_name '%' INTO lv_bo_name.
        WHEN 'DESCRIPTION'.
          lv_bo_desc = ls_select_option_value-low.
          REPLACE ALL OCCURRENCES OF '*' IN lv_bo_desc WITH space.
          CONCATENATE '%' lv_bo_desc '%' INTO lv_bo_desc.
      ENDCASE.
    ENDLOOP.

    IF lv_bo_name IS NOT INITIAL AND lv_bo_desc IS NOT INITIAL.
      SELECT bo_key, name, description
        FROM /bobf/obm_objt
        INTO TABLE @et_entityset
       WHERE langu = @sy-langu
         AND ( name LIKE @lv_bo_name
         OR description LIKE @lv_bo_desc )
         AND extension EQ @abap_false
       ORDER BY name.
    ELSEIF lv_bo_name IS NOT INITIAL.
      SELECT bo_key, name, description
        FROM /bobf/obm_objt
        INTO TABLE @et_entityset
       WHERE langu = @sy-langu
         AND name LIKE @lv_bo_name
         AND extension EQ @abap_false
       ORDER BY name.
    ELSEIF lv_bo_desc IS NOT INITIAL.
      SELECT bo_key, name, description
        FROM /bobf/obm_objt
        INTO TABLE @et_entityset
       WHERE langu = @sy-langu
         AND description LIKE @lv_bo_desc
         AND extension EQ @abap_false
       ORDER BY name.
    ELSE.
      SELECT bo_key, name, description
        FROM /bobf/obm_objt
        INTO TABLE @et_entityset
       WHERE langu = @sy-langu
         AND extension EQ @abap_false
       ORDER BY name.
    ENDIF.

  ENDMETHOD.


  METHOD hierarchyset_get_entityset.
**TRY.
*CALL METHOD SUPER->HIERARCHYSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.

    DATA :
*      lo_config_helper TYPE REF TO /bobf/cl_bopf_config_helper,
*      lo_conf          TYPE REF TO /bobf/if_frw_configuration,
      lv_bo_name TYPE /bobf/obm_name,
      lv_bo_key  TYPE /bobf/obm_bo_key.
*      es_entity        TYPE zcl_zus_bopf_detail_mpc=>ts_hierarchy,
*      lt_assoc         TYPE /bobf/t_confro_assoc.

    LOOP AT it_filter_select_options INTO DATA(ls_select_option).
      READ TABLE ls_select_option-select_options INTO DATA(ls_select_option_value) INDEX 1.
      CASE ls_select_option-property.
        WHEN 'Name'.
          lv_bo_name = ls_select_option_value-low.
      ENDCASE.
    ENDLOOP.


*    CALL METHOD /bobf/cl_frw_factory=>get_configuration
*      EXPORTING
*        iv_bo_key   = lv_bo_key
*      RECEIVING
*        eo_instance = lo_conf.
*
*    CALL METHOD lo_conf->get_bo
*      IMPORTING
*        es_obj = DATA(ls_obj).
*
*    CALL METHOD /bobf/cl_bopf_config_helper=>_get_instance
*      RECEIVING
*        eo_instance = lo_config_helper.
*
*    CALL METHOD lo_config_helper->get_conf_associations
*      EXPORTING
*        io_bo_conf  = lo_conf
*        iv_node_key = ls_obj-root_node_key
*      IMPORTING
*        et_assoc    = lt_assoc[].

    IF lv_bo_name IS NOT INITIAL.
      SELECT SINGLE bo_key
        FROM /bobf/obm_bo
        INTO @lv_bo_key
       WHERE bo_name = @lv_bo_name
         AND extension EQ @abap_false
         AND bo_deleted EQ @abap_false.
      IF lv_bo_key IS NOT INITIAL.
        CALL METHOD zcl_get_hierarchy=>get_hier
          EXPORTING
            iv_bo_key = lv_bo_key
          IMPORTING
            et_hier   = et_entityset.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD tableset_get_entityset.
**TRY.
*CALL METHOD SUPER->TABLESET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.

    DATA: lv_table   TYPE dd03l-tabname,
          lt_catalog TYPE lvc_t_fcat,
          es_entity  TYPE zcl_zus_bopf_detail_mpc=>ts_table.

    READ TABLE it_filter_select_options INTO DATA(ls_sel_op) WITH KEY property = 'Tablename'.
    IF sy-subrc EQ 0.
      READ TABLE ls_sel_op-select_options INTO DATA(ls_sel) INDEX 1.
      IF sy-subrc EQ 0.
        lv_table = ls_sel-low.
        TRANSLATE lv_table TO UPPER CASE.
      ENDIF.
    ENDIF.


    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = lv_table
      CHANGING
        ct_fieldcat            = lt_catalog
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

    DELETE lt_catalog WHERE fieldname = 'MANDT'.

    LOOP AT lt_catalog ASSIGNING FIELD-SYMBOL(<fs_catalog>).
      es_entity-tablename = lv_table.
      es_entity-field = <fs_catalog>-fieldname.
      IF <fs_catalog>-scrtext_l IS NOT INITIAL.
        es_entity-description = <fs_catalog>-scrtext_l.
      ELSEIF <fs_catalog>-scrtext_m IS NOT INITIAL.
        es_entity-description = <fs_catalog>-scrtext_m.
      ELSEIF <fs_catalog>-scrtext_s IS NOT INITIAL.
        es_entity-description = <fs_catalog>-scrtext_s.
      ELSEIF <fs_catalog>-reptext IS NOT INITIAL.
        es_entity-description = <fs_catalog>-reptext.
      ENDIF.
      es_entity-type = <fs_catalog>-datatype.
      es_entity-len = <fs_catalog>-intlen.
      APPEND es_entity TO et_entityset.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
