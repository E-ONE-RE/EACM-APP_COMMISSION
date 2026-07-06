CLASS /eacm/cl_create_nr_prvg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.



CLASS /EACM/CL_CREATE_NR_PRVG IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA lt_interval TYPE cl_numberrange_intervals=>nr_interval.
    DATA ls_interval TYPE cl_numberrange_intervals=>nr_nriv_line.

    ls_interval-nrrangenr  = '01'.
    ls_interval-toyear     = ''.          " nessun anno fiscale
    ls_interval-fromnumber = '0000000001'.
    ls_interval-tonumber   = '9999999999'.
    ls_interval-nrlevel    = '0000000000'.
    ls_interval-externind  = ''.      " internal numbering
    ls_interval-procind    = 'I'.     " Insert

    APPEND ls_interval TO lt_interval.

    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            object    = '/EACM/PRVG'
            subobject = ''
            interval  = lt_interval
          IMPORTING
            error     = DATA(lv_error)
            error_inf = DATA(ls_error)
            error_iv  = DATA(lt_error_iv)
            warning   = DATA(lv_warning)
        ).

        IF lv_error = abap_true.
          out->write( 'Errore nella creazione intervallo' ).
          out->write( ls_error ).
          out->write( lt_error_iv ).
        ELSEIF lv_warning = abap_true.
          out->write( 'Intervallo creato con warning' ).
        ELSE.
          out->write( 'Intervallo 01 creato correttamente per /EACM/PRVG' ).
        ENDIF.

      CATCH cx_number_ranges INTO DATA(lx_nr).
        out->write( lx_nr->get_text( ) ).
    ENDTRY.


*DATA lt_intervals TYPE cl_numberrange_intervals=>nr_interval.
*
*cl_numberrange_intervals=>read(
*  EXPORTING
*    object    = '/EACM/PRVG'
*    subobject = ''
*  IMPORTING
*    interval  = lt_intervals
*).
*
*out->write( lt_intervals ).

DATA lt_intervals TYPE cl_numberrange_intervals=>nr_interval.

TRY.
    cl_numberrange_intervals=>read(
      EXPORTING
        object    = '/EACM/PRVG'
        subobject = ''
      IMPORTING
        interval  = lt_intervals
    ).

  CATCH cx_nr_object_not_found
        cx_nr_subobject
        cx_number_ranges INTO DATA(lx_error).

    out->write( lx_error->get_text( ) ).

ENDTRY.

  ENDMETHOD.
ENDCLASS.
