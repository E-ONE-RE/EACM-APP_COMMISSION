CLASS /eacm/cl_prdo_agt_hide DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_sadl_exit_calc_element_read.
*  PRIVATE SECTION.
ENDCLASS.



CLASS /EACM/CL_PRDO_AGT_HIDE IMPLEMENTATION.


METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    INSERT CONV string( 'ZCLPR' ) INTO TABLE et_requested_orig_elements.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.

    FIELD-SYMBOLS:
      <orig>          TYPE any,
      <calc>          TYPE any,
      <zclpr>         TYPE any,
      <hide_anticipo> TYPE any,
      <hide_altri>    TYPE any.

    LOOP AT ct_calculated_data ASSIGNING <calc>.
      READ TABLE it_original_data INDEX sy-tabix ASSIGNING <orig>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT 'ZCLPR' OF STRUCTURE <orig> TO <zclpr>.
      ASSIGN COMPONENT 'HIDEANTICIPO' OF STRUCTURE <calc> TO <hide_anticipo>.
      ASSIGN COMPONENT 'HIDEALTRICAMPI' OF STRUCTURE <calc> TO <hide_altri>.

IF <zclpr> IS NOT ASSIGNED
   OR <hide_anticipo> IS NOT ASSIGNED
   OR <hide_altri> IS NOT ASSIGNED.
  CONTINUE.
ENDIF.

      IF <zclpr> = 'ANTICIPI'.
        <hide_anticipo> = abap_false.
        <hide_altri>    = abap_true.
      ELSE.
        <hide_anticipo> = abap_true.
        <hide_altri>    = abap_false.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
