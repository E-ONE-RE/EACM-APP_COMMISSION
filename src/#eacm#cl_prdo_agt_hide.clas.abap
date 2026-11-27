CLASS /eacm/cl_prdo_agt_hide DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_sadl_exit_calc_element_read.
*  PRIVATE SECTION.
protected section.
private section.
ENDCLASS.



CLASS /EACM/CL_PRDO_AGT_HIDE IMPLEMENTATION.


METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    INSERT CONV string( 'ZCLPR' ) INTO TABLE et_requested_orig_elements.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.

    FIELD-SYMBOLS:
      <orig>                    TYPE any,
      <calc>                    TYPE any,
      <zclpr>                   TYPE any,
      <hide_anticipo>           TYPE any,
      <hide_altri>              TYPE any,
      <hide_agents_anticipi>    TYPE any,
      <hide_agents_provvigioni> TYPE any.

    LOOP AT ct_calculated_data ASSIGNING <calc>.
      READ TABLE it_original_data INDEX sy-tabix ASSIGNING <orig>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT 'ZCLPR' OF STRUCTURE <orig> TO <zclpr>.
      ASSIGN COMPONENT 'HIDEANTICIPO' OF STRUCTURE <calc> TO <hide_anticipo>.
      ASSIGN COMPONENT 'HIDEALTRICAMPI' OF STRUCTURE <calc> TO <hide_altri>.
      ASSIGN COMPONENT 'HIDEAGENTSANTICIPI'
        OF STRUCTURE <calc> TO <hide_agents_anticipi>.
      ASSIGN COMPONENT 'HIDEAGENTSPROVVIGIONI'
        OF STRUCTURE <calc> TO <hide_agents_provvigioni>.

      IF <zclpr> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      IF <zclpr> = 'ANTICIPI'.
        IF <hide_anticipo> IS ASSIGNED.
          <hide_anticipo> = abap_false.
        ENDIF.
        IF <hide_altri> IS ASSIGNED.
          <hide_altri> = abap_true.
        ENDIF.
        IF <hide_agents_anticipi> IS ASSIGNED.
          <hide_agents_anticipi> = abap_false.
        ENDIF.
        IF <hide_agents_provvigioni> IS ASSIGNED.
          <hide_agents_provvigioni> = abap_true.
        ENDIF.
      ELSE.
        IF <hide_anticipo> IS ASSIGNED.
          <hide_anticipo> = abap_true.
        ENDIF.
        IF <hide_altri> IS ASSIGNED.
          <hide_altri> = abap_false.
        ENDIF.
        IF <hide_agents_anticipi> IS ASSIGNED.
          <hide_agents_anticipi> = abap_true.
        ENDIF.
        IF <hide_agents_provvigioni> IS ASSIGNED.
          <hide_agents_provvigioni> = abap_false.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
