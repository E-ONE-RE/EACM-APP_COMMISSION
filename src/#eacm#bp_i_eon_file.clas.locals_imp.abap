CLASS lcl_eon_file_save_buffer DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-DATA gt_files TYPE STANDARD TABLE OF /eacm/eon_file WITH EMPTY KEY.
ENDCLASS.

CLASS lcl_eon_file_save_buffer IMPLEMENTATION.
ENDCLASS.

CLASS LSC_/EACM/I_EON_FILE DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS LSC_/EACM/I_EON_FILE IMPLEMENTATION.
  METHOD save_modified.

    IF lcl_eon_file_save_buffer=>gt_files IS NOT INITIAL.
      INSERT /eacm/eon_file FROM TABLE @lcl_eon_file_save_buffer=>gt_files.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.

    CLEAR lcl_eon_file_save_buffer=>gt_files.

  ENDMETHOD.
ENDCLASS.

CLASS LHC_/EACM/I_EON_FILE DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR EonFile
      RESULT result.

    METHODS GenerateEnasarcoOnline
      FOR MODIFY
      IMPORTING keys FOR ACTION EonFile~GenerateEnasarcoOnline.

    METHODS buffer_download_file
      IMPORTING is_selection        TYPE /EACM/A_EON_PAR
                iv_filename         TYPE string
                it_file_lines       TYPE /eacm/cl_eon_generator=>tt_file_lines
      RETURNING VALUE(rv_file_uuid) TYPE sysuuid_x16.
ENDCLASS.

CLASS LHC_/EACM/I_EON_FILE IMPLEMENTATION.
  METHOD get_global_authorizations.

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%action-GenerateEnasarcoOnline = if_abap_behv=>mk-on.
      result-%action-GenerateEnasarcoOnline = if_abap_behv=>auth-allowed.
    ENDIF.

  ENDMETHOD.

  METHOD GenerateEnasarcoOnline.

    DATA(lo_generator) = NEW /eacm/cl_eon_generator( ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
      DATA lv_default_trimes TYPE c LENGTH 1.

      lv_default_trimes = COND #(
        WHEN lv_today+4(2) <= '03' THEN '1'
        WHEN lv_today+4(2) <= '06' THEN '2'
        WHEN lv_today+4(2) <= '09' THEN '3'
        ELSE '4' ).

      DATA(ls_selection) = VALUE /EACM/A_EON_PAR(
        bukrs        = <ls_key>-%param-Bukrs
        gjahr        = <ls_key>-%param-Gjahr
        trimes       = COND #( WHEN <ls_key>-%param-Trimes IS NOT INITIAL
                               THEN <ls_key>-%param-Trimes
                               ELSE lv_default_trimes )
        prot         = <ls_key>-%param-Prot
        ditta        = <ls_key>-%param-Ditta
        cf           = <ls_key>-%param-Cf
        firr         = xsdbool( <ls_key>-%param-Firr = abap_true )
        SplitCessati = xsdbool( <ls_key>-%param-SplitCessati = abap_true )
        zcdaz        = <ls_key>-%param-Zcdaz
        ztpag        = <ls_key>-%param-Ztpag ).

      IF ls_selection-firr = abap_true.
        ls_selection-trimes = '4'.
      ENDIF.

      lo_generator->generate(
        EXPORTING
          is_selection        = ls_selection
        IMPORTING
          et_file_lines       = DATA(lt_file_lines)
          et_cessati_lines    = DATA(lt_cessati_lines)
          et_messages         = DATA(lt_messages)
          ev_filename         = DATA(lv_filename)
          ev_cessati_filename = DATA(lv_cessati_filename) ).

      DATA(lv_has_error) = xsdbool( line_exists( lt_messages[ msgty = 'E' ] ) ).

      IF lv_has_error = abap_true.
        APPEND VALUE #(
          %cid = <ls_key>-%cid
          %action-GenerateEnasarcoOnline = if_abap_behv=>mk-on )
          TO failed-eonfile.

        LOOP AT lt_messages INTO DATA(ls_error_message) WHERE msgty = 'E'.
          APPEND VALUE #(
            %cid = <ls_key>-%cid
            %action-GenerateEnasarcoOnline = if_abap_behv=>mk-on
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = ls_error_message-text ) )
            TO reported-eonfile.
        ENDLOOP.

        CONTINUE.
      ENDIF.

      LOOP AT lt_messages INTO DATA(ls_warning_message) WHERE msgty <> 'E'.
        APPEND VALUE #(
          %cid = <ls_key>-%cid
          %action-GenerateEnasarcoOnline = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = SWITCH #( ls_warning_message-msgty
              WHEN 'W' THEN if_abap_behv_message=>severity-warning
              WHEN 'S' THEN if_abap_behv_message=>severity-success
              ELSE if_abap_behv_message=>severity-information )
            text = ls_warning_message-text ) )
          TO reported-eonfile.
      ENDLOOP.

      DATA(lv_file_uuid) = buffer_download_file(
        is_selection  = ls_selection
        iv_filename   = lv_filename
        it_file_lines = lt_file_lines ).

      IF lv_file_uuid IS INITIAL.
        APPEND VALUE #(
          %cid = <ls_key>-%cid
          %action-GenerateEnasarcoOnline = if_abap_behv=>mk-on )
          TO failed-eonfile.

        APPEND VALUE #(
          %cid = <ls_key>-%cid
          %action-GenerateEnasarcoOnline = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Errore durante il salvataggio del file { lv_filename } per il download.| ) )
          TO reported-eonfile.
        CONTINUE.
      ENDIF.

      IF lt_cessati_lines IS NOT INITIAL.
        DATA(lv_cessati_file_uuid) = buffer_download_file(
          is_selection  = ls_selection
          iv_filename   = lv_cessati_filename
          it_file_lines = lt_cessati_lines ).

        IF lv_cessati_file_uuid IS INITIAL.
          APPEND VALUE #(
            %cid = <ls_key>-%cid
            %action-GenerateEnasarcoOnline = if_abap_behv=>mk-on )
            TO failed-eonfile.

          APPEND VALUE #(
            %cid = <ls_key>-%cid
            %action-GenerateEnasarcoOnline = if_abap_behv=>mk-on
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Errore durante il salvataggio del file cessati { lv_cessati_filename } per il download.| ) )
            TO reported-eonfile.
          CONTINUE.
        ENDIF.

      ENDIF.

      APPEND VALUE #(
        %cid = <ls_key>-%cid
        %action-GenerateEnasarcoOnline = if_abap_behv=>mk-on
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-success
          text     = 'Elaborazione terminata con successo.' ) )
        TO reported-eonfile.
    ENDLOOP.

  ENDMETHOD.

  METHOD buffer_download_file.

    DATA(lv_file_content) = concat_lines_of(
      table = it_file_lines
      sep   = cl_abap_char_utilities=>cr_lf ).

    IF it_file_lines IS NOT INITIAL.
      lv_file_content = |{ lv_file_content }{ cl_abap_char_utilities=>cr_lf }|.
    ENDIF.

    DATA(lv_file_xstring) = xco_cp=>string( lv_file_content
      )->as_xstring( xco_cp_character=>code_page->utf_8
      )->value.

    TRY.
        rv_file_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        CLEAR rv_file_uuid.
        RETURN.
    ENDTRY.

    DATA ls_file TYPE /eacm/eon_file.
    ls_file-file_uuid     = rv_file_uuid.
    ls_file-created_by    = cl_abap_context_info=>get_user_technical_name( ).
    ls_file-created_at    = utclong_current( ).
    ls_file-bukrs         = is_selection-bukrs.
    ls_file-zcdaz         = is_selection-zcdaz.
    ls_file-ztpag         = is_selection-ztpag.
    ls_file-prot          = is_selection-prot.
    ls_file-ditta         = is_selection-ditta.
    ls_file-cf            = is_selection-cf.
    ls_file-gjahr         = is_selection-gjahr.
    ls_file-trimes        = is_selection-trimes.
    ls_file-firr          = xsdbool( is_selection-firr = abap_true ).
    ls_file-split_cessati = xsdbool( is_selection-SplitCessati = abap_true ).
    ls_file-file_name     = CONV #( iv_filename ).
    ls_file-mime_type     = `text/plain; charset=utf-8`.
    ls_file-file_size     = xstrlen( lv_file_xstring ).
    ls_file-file_content  = lv_file_xstring.

    APPEND ls_file TO lcl_eon_file_save_buffer=>gt_files.

  ENDMETHOD.
ENDCLASS.




