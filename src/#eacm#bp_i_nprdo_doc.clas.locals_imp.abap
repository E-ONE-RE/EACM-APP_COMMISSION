*CLASS lcl_buffer DEFINITION.
*  PUBLIC SECTION.
*    TYPES: BEGIN OF ty_document_key_map,
*             zclpr     TYPE /eacm/prdo-zclpr,
*             bukrs     TYPE /eacm/prdo-bukrs,
*             vkorg     TYPE /eacm/prdo-vkorg,
*             vtweg     TYPE /eacm/prdo-vtweg,
*             old_vbeln TYPE /eacm/prdo-vbeln,
*             old_gjahr TYPE /eacm/prdo-gjahr,
*             new_vbeln TYPE /eacm/prdo-vbeln,
*             new_gjahr TYPE /eacm/prdo-gjahr,
*           END OF ty_document_key_map.
*
*    TYPES: BEGIN OF ty_create_document_key,
*             pid   TYPE sysuuid_x16,
*             zclpr TYPE /eacm/prdo-zclpr,
*             bukrs TYPE /eacm/prdo-bukrs,
*             vkorg TYPE /eacm/prdo-vkorg,
*             vtweg TYPE /eacm/prdo-vtweg,
*             vbeln TYPE /eacm/prdo-vbeln,
*             gjahr TYPE /eacm/prdo-gjahr,
*             kunrg TYPE /eacm/prdo-kunrg,
*             fkdat TYPE /eacm/prdo-fkdat,
*             waerk TYPE /eacm/prdo-waerk,
*           END OF ty_create_document_key.
*
*    TYPES: BEGIN OF ty_create_position_key,
*             pid   TYPE sysuuid_x16,
*             zclpr TYPE /eacm/prdo-zclpr,
*             bukrs TYPE /eacm/prdo-bukrs,
*             vkorg TYPE /eacm/prdo-vkorg,
*             vtweg TYPE /eacm/prdo-vtweg,
*             vbeln TYPE /eacm/prdo-vbeln,
*             gjahr TYPE /eacm/prdo-gjahr,
*             posnr TYPE /eacm/prdo-posnr,
*           END OF ty_create_position_key.
*
*    TYPES: BEGIN OF ty_create_agent_key,
*             pid   TYPE sysuuid_x16,
*             zclpr TYPE /eacm/prdo-zclpr,
*             bukrs TYPE /eacm/prdo-bukrs,
*             vkorg TYPE /eacm/prdo-vkorg,
*             vtweg TYPE /eacm/prdo-vtweg,
*             vbeln TYPE /eacm/prdo-vbeln,
*             gjahr TYPE /eacm/prdo-gjahr,
*             posnr TYPE /eacm/prdo-posnr,
*             zidag TYPE /eacm/prdo-zidag,
*             zcdaz TYPE /eacm/prdo-zcdaz,
*           END OF ty_create_agent_key.
*
*    CLASS-DATA mt_create_document_key TYPE STANDARD TABLE OF ty_create_document_key.
*    CLASS-DATA mt_create_position_key TYPE STANDARD TABLE OF ty_create_position_key.
*    CLASS-DATA mt_create_agent_key    TYPE STANDARD TABLE OF ty_create_agent_key.
*    CLASS-DATA mt_create_position TYPE STANDARD TABLE OF /eacm/prdo.
*    CLASS-DATA mt_create_agent    TYPE STANDARD TABLE OF /eacm/prdo.
*    CLASS-DATA mt_update_document TYPE STANDARD TABLE OF /eacm/prdo.
*    CLASS-DATA mt_update_position TYPE STANDARD TABLE OF /eacm/prdo.
*    CLASS-DATA mt_update_agent    TYPE STANDARD TABLE OF /eacm/prdo.
*    CLASS-DATA mt_delete_document TYPE STANDARD TABLE OF /eacm/prdo.
*    CLASS-DATA mt_delete_position TYPE STANDARD TABLE OF /eacm/prdo.
*    CLASS-DATA mt_delete_agent    TYPE STANDARD TABLE OF /eacm/prdo.
*    CLASS-DATA mt_document_key_map TYPE STANDARD TABLE OF ty_document_key_map.
*ENDCLASS.
***********************************************************************
***********************************************************************
*CLASS lhc_Document DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR Document RESULT result.
*
*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE Document.
*
*    METHODS precheck_create FOR PRECHECK
*      IMPORTING entities FOR CREATE Document.
*
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE Document.
*
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE Document.
*
*    METHODS read FOR READ
*      IMPORTING keys FOR READ Document RESULT result.
*
*    METHODS lock FOR LOCK
*      IMPORTING keys FOR LOCK Document.
*
*    METHODS rba_Positions FOR READ
*      IMPORTING keys_rba FOR READ Document\_Positions FULL result_requested RESULT result LINK association_links.
*
*    METHODS cba_Positions FOR MODIFY
*      IMPORTING entities_cba FOR CREATE Document\_Positions.
*
*ENDCLASS.
*****
* CLASS lhc_Document IMPLEMENTATION.
*  METHOD get_instance_authorizations.
*    result = VALUE #( FOR key IN keys
*      (
*        %tky    = key-%tky
*        %update = if_abap_behv=>auth-allowed
*        %delete = if_abap_behv=>auth-allowed
*      ) ).
*  ENDMETHOD.
*
*  METHOD precheck_create.
*    LOOP AT entities INTO DATA(document).
*      DATA(zclpr_upper) = to_upper( CONV string( document-Zclpr ) ).
*      CONDENSE zclpr_upper NO-GAPS.
*
*      IF zclpr_upper = 'SB' AND document-Vbeln IS INITIAL.
*        APPEND VALUE #( %cid = document-%cid ) TO failed-document.
*        APPEND VALUE #(
*          %cid           = document-%cid
*          %element-Vbeln = if_abap_behv=>mk-on
*          %msg           = new_message_with_text(
*            severity = if_abap_behv_message=>severity-error
*            text     = 'Per Cod.Class.Comm SB, il documento è obbligatorio.' )
*        ) TO reported-document.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD create.
*    DATA(today) = cl_abap_context_info=>get_system_date( ).
*    DATA(default_gjahr) = CONV gjahr( today+0(4) ).
*
*    LOOP AT entities INTO DATA(document).
*      DATA(zclpr_upper) = to_upper( CONV string( document-Zclpr ) ).
*      CONDENSE zclpr_upper NO-GAPS.
*
*      IF zclpr_upper = 'SB' AND document-Vbeln IS INITIAL.
*        APPEND VALUE #( %cid = document-%cid ) TO failed-document.
*        APPEND VALUE #(
*          %cid           = document-%cid
*          %element-Vbeln = if_abap_behv=>mk-on
*          %msg           = new_message_with_text(
*            severity = if_abap_behv_message=>severity-error
*            text     = 'Per Cod.Class.Comm SB, il documento è obbligatorio.' )
*        ) TO reported-document.
*        CONTINUE.
*      ENDIF.
*
*      TRY.
*          DATA(pid) = cl_system_uuid=>create_uuid_x16_static( ).
*          DATA(uuid_c32) = cl_system_uuid=>create_uuid_c32_static( ).
*          DATA(preliminary_vbeln) = COND vbeln(
*            WHEN document-Vbeln IS INITIAL THEN CONV vbeln( |D{ uuid_c32+0(9) }| )
*            ELSE |{ document-Vbeln ALPHA = IN }| ).
*          DATA(preliminary_gjahr) = COND gjahr(
*            WHEN document-Gjahr IS INITIAL THEN default_gjahr
*            ELSE document-Gjahr ).
*
*          APPEND VALUE #(
*            %cid = document-%cid
*            %pid = pid
*            %key = VALUE #(
*              BASE document-%key
*              Vbeln = preliminary_vbeln
*              Gjahr = preliminary_gjahr )
*          ) TO mapped-document.
*
*          APPEND VALUE #(
*            pid   = pid
*            zclpr = document-Zclpr
*            bukrs = document-Bukrs
*            vkorg = document-Vkorg
*            vtweg = document-Vtweg
*            vbeln = preliminary_vbeln
*            gjahr = preliminary_gjahr
*            kunrg = document-Kunrg
*            fkdat = document-Fkdat
**            waerk = document-Waerk
*          ) TO lcl_buffer=>mt_create_document_key.
*
*        CATCH cx_uuid_error INTO DATA(uuid_error).
*          APPEND VALUE #( %cid = document-%cid ) TO failed-document.
*          APPEND VALUE #(
*            %cid = document-%cid
*            %msg = new_message_with_text(
*              severity = if_abap_behv_message=>severity-error
*              text     = uuid_error->get_text( ) )
*          ) TO reported-document.
*      ENDTRY.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD update.
*    LOOP AT entities INTO DATA(document).
*      APPEND VALUE /eacm/prdo(
*        zclpr = document-Zclpr
*        bukrs = document-Bukrs
*        vkorg = document-Vkorg
*        vtweg = document-Vtweg
*        vbeln = document-Vbeln
*        gjahr = document-Gjahr
*        fkdat = document-Fkdat
**        waerk = document-Waerk
**        zwaer = document-Waerk
*      ) TO lcl_buffer=>mt_update_document.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD delete.
*    LOOP AT keys INTO DATA(document_key).
*      APPEND VALUE /eacm/prdo(
*        zclpr = document_key-Zclpr
*        bukrs = document_key-Bukrs
*        vkorg = document_key-Vkorg
*        vtweg = document_key-Vtweg
*        vbeln = document_key-Vbeln
*        gjahr = document_key-Gjahr
*      ) TO lcl_buffer=>mt_delete_document.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD read.
*    IF keys IS INITIAL.
*      SELECT FROM /eacm/prdo AS z
*        FIELDS z~zclpr,
*               z~bukrs,
*               z~vkorg,
*               z~vtweg,
*               z~vbeln,
*               z~gjahr,
*               MIN( z~kunrg ) AS kunrg,
*               MAX( z~fkdat ) AS fkdat,
*               z~waerk,
*               z~zwaer,
*               MAX( z~local_last_changed_at ) AS locallastchangedat
*        WHERE z~posnr <> '000000'
*          AND z~zstre <> 'D'
*          AND z~zmodi <> 'D'
*        GROUP BY z~zclpr,
*                 z~bukrs,
*                 z~vkorg,
*                 z~vtweg,
*                 z~vbeln,
*                 z~gjahr,
*                 z~waerk,
*                 z~zwaer
*        INTO TABLE @DATA(all_documents).
*
*      result = VALUE #( FOR all_document IN all_documents
*        (
*          Zclpr              = all_document-zclpr
*          Bukrs              = all_document-bukrs
*          Vkorg              = all_document-vkorg
*          Vtweg              = all_document-vtweg
*          Vbeln              = all_document-vbeln
*          Gjahr              = all_document-gjahr
*          Kunrg              = all_document-kunrg
*          Fkdat              = all_document-fkdat
*          Waerk              = all_document-waerk
*          LocalLastChangedAt = all_document-locallastchangedat
*        ) ).
*      RETURN.
*    ENDIF.
*
*    SELECT FROM /eacm/prdo AS z
*      INNER JOIN @keys AS k
*        ON  z~zclpr = k~Zclpr
*        AND z~bukrs = k~Bukrs
*        AND z~vkorg = k~Vkorg
*        AND z~vtweg = k~Vtweg
*        AND z~vbeln = k~Vbeln
*        AND z~gjahr = k~Gjahr
*      FIELDS z~zclpr,
*             z~bukrs,
*             z~vkorg,
*             z~vtweg,
*             z~vbeln,
*             z~gjahr,
*             MIN( z~kunrg ) AS kunrg,
*             MAX( z~fkdat ) AS fkdat,
*             z~waerk,
*             z~zwaer,
*             MAX( z~local_last_changed_at ) AS locallastchangedat
*      WHERE z~posnr <> '000000'
*        AND z~zstre <> 'D'
*        AND z~zmodi <> 'D'
*      GROUP BY z~zclpr,
*               z~bukrs,
*               z~vkorg,
*               z~vtweg,
*               z~vbeln,
*               z~gjahr,
*               z~waerk,
*               z~zwaer
*      INTO TABLE @DATA(documents).
*
*    result = VALUE #( FOR key_document IN documents
*      (
*        Zclpr              = key_document-zclpr
*        Bukrs              = key_document-bukrs
*        Vkorg              = key_document-vkorg
*        Vtweg              = key_document-vtweg
*        Vbeln              = key_document-vbeln
*        Gjahr              = key_document-gjahr
*        Kunrg              = key_document-kunrg
*        Fkdat              = key_document-fkdat
*        Waerk              = key_document-waerk
*        LocalLastChangedAt = key_document-locallastchangedat
*      ) ).
*  ENDMETHOD.
*
*  METHOD lock.
*  ENDMETHOD.
*
*  METHOD rba_Positions.
*    IF keys_rba IS INITIAL.
*      RETURN.
*    ENDIF.
*
*    CLEAR result.
*    CLEAR association_links.
*
*    IF line_exists( keys_rba[ %is_draft = if_abap_behv=>mk-on ] ).
*      SELECT FROM /EACM/PRDO_POS_D AS z
*        INNER JOIN @keys_rba AS k
*          ON  z~zclpr = k~Zclpr
*          AND z~bukrs = k~Bukrs
*          AND z~vkorg = k~Vkorg
*          AND z~vtweg = k~Vtweg
*          AND z~vbeln = k~Vbeln
*          AND z~gjahr = k~Gjahr
*        FIELDS z~zclpr,
*               z~bukrs,
*               z~vkorg,
*               z~vtweg,
*               z~vbeln,
*               z~gjahr,
*               z~posnr,
*               z~material,
*               z~materialdescription,
*               z~waerk,
*               z~quantity,
*               z~locallastchangedat
*        INTO TABLE @DATA(draft_positions).
*
*      LOOP AT draft_positions INTO DATA(draft_position).
*        READ TABLE keys_rba INTO DATA(draft_key)
*          WITH KEY Zclpr = draft_position-zclpr
*                   Bukrs = draft_position-bukrs
*                   Vkorg = draft_position-vkorg
*                   Vtweg = draft_position-vtweg
*                   Vbeln = draft_position-vbeln
*                   Gjahr = draft_position-gjahr.
*
*        IF sy-subrc = 0.
*          APPEND VALUE #(
*            source-%tky = draft_key-%tky
*            target-%tky = VALUE #(
*              %is_draft = if_abap_behv=>mk-on
*              Zclpr     = draft_position-zclpr
*              Bukrs     = draft_position-bukrs
*              Vkorg     = draft_position-vkorg
*              Vtweg     = draft_position-vtweg
*              Vbeln     = draft_position-vbeln
*              Gjahr     = draft_position-gjahr
*              Posnr     = draft_position-posnr
*            )
*          ) TO association_links.
*        ENDIF.
*
*        IF result_requested = abap_true.
*          DATA(draft_material) = draft_position-material.
*          DATA(draft_materialdescription) = draft_position-materialdescription.
*          DATA(draft_waerk) = draft_position-waerk.
*          DATA(draft_quantity) = draft_position-quantity.
*
*          IF ( draft_material IS INITIAL OR draft_materialdescription IS INITIAL OR draft_waerk IS INITIAL OR draft_quantity IS INITIAL )
*            AND ( draft_position-vbeln IS INITIAL OR draft_position-vbeln(1) = 'D' ).
*            SELECT SINGLE z~arktx,
*                          z~Zdesc AS description
*              FROM /eacm/zpr08 AS z
*              WHERE z~bukrs  = @draft_position-bukrs
*                AND z~zclpr = @draft_position-zclpr
*                AND z~posnr  = @draft_position-posnr
*              INTO @DATA(draft_zpr08_position).
*
*            IF sy-subrc = 0.
*              IF draft_material IS INITIAL.
*                draft_material = CONV /eacm/prdo-matnr( draft_zpr08_position-arktx ).
*              ENDIF.
*
*              IF draft_materialdescription IS INITIAL.
*                draft_materialdescription = CONV /eacm/prdo-maktx( draft_zpr08_position-description ).
*              ENDIF.
*
*              IF draft_quantity IS INITIAL.
*                draft_quantity = 1.
*              ENDIF.
*            ENDIF.
*          ELSEIF ( draft_material IS INITIAL OR draft_materialdescription IS INITIAL OR draft_waerk IS INITIAL OR draft_quantity IS INITIAL )
*            AND draft_position-vbeln IS NOT INITIAL.
*            SELECT SINGLE z~matnr,          "#EC WARNOK
*                          z~maktx,
*                          z~waerk,
*                          z~menge
*              FROM /eacm/prdo AS z
*              WHERE z~zclpr = @draft_position-zclpr
*                AND z~bukrs = @draft_position-bukrs
*                AND z~vkorg = @draft_position-vkorg
*                AND z~vtweg = @draft_position-vtweg
*                AND z~vbeln = @draft_position-vbeln
*                AND z~gjahr = @draft_position-gjahr
*                AND z~posnr = @draft_position-posnr
*                AND z~zstre <> 'D'
*                AND z~zmodi <> 'D'
*              INTO @DATA(draft_zprdo_position).
*
*            IF sy-subrc = 0.
*              IF draft_material IS INITIAL.
*                draft_material = draft_zprdo_position-matnr.
*              ENDIF.
*
*              IF draft_materialdescription IS INITIAL.
*                draft_materialdescription = draft_zprdo_position-maktx.
*              ENDIF.
*
*              IF draft_waerk IS INITIAL.
*                draft_waerk = draft_zprdo_position-waerk.
*              ENDIF.
*
*              IF draft_quantity IS INITIAL.
*                draft_quantity = draft_zprdo_position-menge.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*
*          APPEND VALUE #(
*            %is_draft          = if_abap_behv=>mk-on
*            Zclpr              = draft_position-zclpr
*            Bukrs              = draft_position-bukrs
*            Vkorg              = draft_position-vkorg
*            Vtweg              = draft_position-vtweg
*            Vbeln              = draft_position-vbeln
*            Gjahr              = draft_position-gjahr
*            Posnr              = draft_position-posnr
*            Material           = draft_material
*            MaterialDescription = draft_materialdescription
*            Waerk              = draft_waerk
*            Quantity           = draft_quantity
*            LocalLastChangedAt = draft_position-locallastchangedat
*          ) TO result.
*        ENDIF.
*      ENDLOOP.
*
*      IF association_links IS NOT INITIAL OR result IS NOT INITIAL.
*        RETURN.
*      ENDIF.
*    ENDIF.
*
*    SELECT FROM /eacm/prdo AS z
*      INNER JOIN @keys_rba AS k
*        ON  z~zclpr = k~Zclpr
*        AND z~bukrs = k~Bukrs
*        AND z~vkorg = k~Vkorg
*        AND z~vtweg = k~Vtweg
*        AND z~vbeln = k~Vbeln
*        AND z~gjahr = k~Gjahr
*      FIELDS z~zclpr,
*             z~bukrs,
*             z~vkorg,
*             z~vtweg,
*             z~vbeln,
*             z~gjahr,
*             z~posnr,
*             MIN( z~matnr ) AS material,
*             MIN( z~maktx ) AS materialdescription,
*             z~waerk,
*             z~zwaer,
*             MAX( z~menge ) AS quantity,
*             MAX( z~local_last_changed_at ) AS locallastchangedat
*      WHERE z~posnr <> '000000'
*        AND z~zstre <> 'D'
*        AND z~zmodi <> 'D'
*      GROUP BY z~zclpr,
*               z~bukrs,
*               z~vkorg,
*               z~vtweg,
*               z~vbeln,
*               z~gjahr,
*               z~posnr,
*               z~waerk,
*               z~zwaer
*      INTO TABLE @DATA(active_positions).
*
*    LOOP AT active_positions INTO DATA(active_position).
*      READ TABLE keys_rba INTO DATA(active_key)
*        WITH KEY Zclpr = active_position-zclpr
*                 Bukrs = active_position-bukrs
*                 Vkorg = active_position-vkorg
*                 Vtweg = active_position-vtweg
*                 Vbeln = active_position-vbeln
*                 Gjahr = active_position-gjahr.
*
*      IF sy-subrc = 0.
*        APPEND VALUE #(
*          source-%tky = active_key-%tky
*          target-%tky = VALUE #(
*            %is_draft = if_abap_behv=>mk-off
*            Zclpr     = active_position-zclpr
*            Bukrs     = active_position-bukrs
*            Vkorg     = active_position-vkorg
*            Vtweg     = active_position-vtweg
*            Vbeln     = active_position-vbeln
*            Gjahr     = active_position-gjahr
*            Posnr     = active_position-posnr
*          )
*        ) TO association_links.
*      ENDIF.
*
*      IF result_requested = abap_true.
*        APPEND VALUE #(
*          %is_draft          = if_abap_behv=>mk-off
*          Zclpr              = active_position-zclpr
*          Bukrs              = active_position-bukrs
*          Vkorg              = active_position-vkorg
*          Vtweg              = active_position-vtweg
*          Vbeln              = active_position-vbeln
*          Gjahr              = active_position-gjahr
*          Posnr              = active_position-posnr
*          Material           = active_position-material
*          MaterialDescription = active_position-materialdescription
*          Waerk              = active_position-waerk
*          Quantity           = active_position-quantity
*          LocalLastChangedAt = active_position-locallastchangedat
*        ) TO result.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD cba_Positions.
*    LOOP AT entities_cba INTO DATA(document).
*
*      SELECT MAX( posnr )
*        FROM /eacm/prdo
*        WHERE zclpr = @document-Zclpr
*          AND bukrs = @document-Bukrs
*          AND vkorg = @document-Vkorg
*          AND vtweg = @document-Vtweg
*          AND vbeln = @document-Vbeln
*          AND gjahr = @document-Gjahr
*        INTO @DATA(max_posnr).
*
*      SELECT MAX( posnr )
*        FROM /EACM/PRDO_POS_D
*        WHERE zclpr = @document-Zclpr
*          AND bukrs = @document-Bukrs
*          AND vkorg = @document-Vkorg
*          AND vtweg = @document-Vtweg
*          AND vbeln = @document-Vbeln
*          AND gjahr = @document-Gjahr
*        INTO @DATA(max_draft_posnr).
*
*      IF max_draft_posnr > max_posnr.
*        max_posnr = max_draft_posnr.
*      ENDIF.
*
*      LOOP AT lcl_buffer=>mt_create_position INTO DATA(buffered_position)
*        WHERE zclpr = document-Zclpr
*          AND bukrs = document-Bukrs
*          AND vkorg = document-Vkorg
*          AND vtweg = document-Vtweg
*          AND vbeln = document-Vbeln
*          AND gjahr = document-Gjahr.
*        IF buffered_position-posnr > max_posnr.
*          max_posnr = buffered_position-posnr.
*        ENDIF.
*      ENDLOOP.
*
*      LOOP AT document-%target INTO DATA(position).
*        TRY.
*            DATA(position_pid) = cl_system_uuid=>create_uuid_x16_static( ).
*            DATA(posnr) = VALUE /eacm/prdo-posnr( ).
*            DATA(position_material) = VALUE /eacm/prdo-matnr( ).
*            DATA(position_material_description) = VALUE /eacm/prdo-maktx( ).
*            DATA(position_quantity) = VALUE /eacm/prdo-menge( ).
*            DATA(position_fkdat) = VALUE /eacm/prdo-fkdat( ).
*            DATA(position_waerk) = VALUE /eacm/prdo-waerk( ).
*
*            DATA(posnr_number) = CONV i( max_posnr ) + 10.
*
*            posnr = CONV /eacm/prdo-posnr( |{ posnr_number WIDTH = 6 PAD = '0' ALIGN = RIGHT }| ).
*            position_material = position-Material.
*            position_material_description = position-MaterialDescription.
*            position_quantity = position-Quantity.
*            position_waerk = position-Waerk.
*
*            max_posnr = posnr.
*
*            APPEND VALUE #(
*              %cid  = position-%cid
*              %pid  = position_pid
*              Zclpr = document-Zclpr
*              Bukrs = document-Bukrs
*              Vkorg = document-Vkorg
*              Vtweg = document-Vtweg
*              Vbeln = document-Vbeln
*              Gjahr = document-Gjahr
*              Posnr = posnr
*            ) TO mapped-position.
*
*            APPEND VALUE #(
*              pid   = position_pid
*              zclpr = document-Zclpr
*              bukrs = document-Bukrs
*              vkorg = document-Vkorg
*              vtweg = document-Vtweg
*              vbeln = document-Vbeln
*              gjahr = document-Gjahr
*              posnr = posnr
*            ) TO lcl_buffer=>mt_create_position_key.
*
*            IF position-Waerk IS NOT INITIAL.
*              position_waerk = position-Waerk.
*            ENDIF.
*
*
*            APPEND VALUE /eacm/prdo(
*              zclpr = document-Zclpr
*              bukrs = document-Bukrs
*              vkorg = document-Vkorg
*              vtweg = document-Vtweg
*              vbeln = document-Vbeln
*              gjahr = document-Gjahr
*              posnr = posnr
*              matnr = position_material
*              maktx = position_material_description
*              menge = position_quantity
*              fkdat = position_fkdat
*              waerk = position_waerk
*              zwaer = position_waerk
*            ) TO lcl_buffer=>mt_create_position.
*
*          CATCH cx_uuid_error INTO DATA(uuid_error).
*            APPEND VALUE #( %cid = position-%cid ) TO failed-position.
*            APPEND VALUE #(
*              %cid = position-%cid
*              %msg = new_message_with_text(
*                severity = if_abap_behv_message=>severity-error
*                text     = uuid_error->get_text( ) )
*            ) TO reported-position.
*        ENDTRY.
*
*      ENDLOOP.
*
*    ENDLOOP.
*
*  ENDMETHOD.
*ENDCLASS.
***********************************************************************
***********************************************************************
*CLASS lhc_Position DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE Position.
*
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE Position.
*
*    METHODS read FOR READ
*      IMPORTING keys FOR READ Position RESULT result.
*
*    METHODS rba_Agents FOR READ
*      IMPORTING keys_rba FOR READ Position\_Agents FULL result_requested RESULT result LINK association_links.
*
*    METHODS rba_Document FOR READ
*      IMPORTING keys_rba FOR READ Position\_Document FULL result_requested RESULT result LINK association_links.
*
*    METHODS cba_Agents FOR MODIFY
*      IMPORTING entities_cba FOR CREATE Position\_Agents.
*
*    METHODS SetPositionDefaults FOR DETERMINE ON MODIFY
*      IMPORTING keys FOR Position~SetPositionDefaults.
*
*ENDCLASS.
***********************************************************************
*CLASS lhc_Position IMPLEMENTATION.
*
*  METHOD SetPositionDefaults.
*    READ ENTITIES OF /EACM/I_PRDO_DOC IN LOCAL MODE
*      ENTITY Position
*        FIELDS ( Material MaterialDescription Waerk Quantity )
*        WITH CORRESPONDING #( keys )
*      RESULT DATA(positions).
*
*    LOOP AT positions INTO DATA(position).
*      DATA(position_material) = VALUE /eacm/prdo-matnr( ).
*      DATA(position_material_description) = VALUE /eacm/prdo-maktx( ).
*      DATA(position_waerk) = VALUE /eacm/prdo-waerk( ).
*      DATA(position_quantity) = VALUE /eacm/prdo-menge( ).
*
*      READ TABLE lcl_buffer=>mt_create_position INTO DATA(buffered_position)
*        WITH KEY zclpr = position-Zclpr
*                 bukrs = position-Bukrs
*                 vkorg = position-Vkorg
*                 vtweg = position-Vtweg
*                 vbeln = position-Vbeln
*                 gjahr = position-Gjahr
*                 posnr = position-Posnr.
*
*      IF sy-subrc = 0.
*        position_material = buffered_position-matnr.
*        position_material_description = buffered_position-maktx.
*        position_waerk = buffered_position-waerk.
*        position_quantity = buffered_position-menge.
*      ELSE.
*        SELECT SINGLE material,                     "#EC CI_NOORDER
*                      materialdescription,
*                      waerk,
*                      quantity
*          FROM /EACM/PRDO_POS_D
*          WHERE zclpr = @position-Zclpr
*            AND bukrs = @position-Bukrs
*            AND vkorg = @position-Vkorg
*            AND vtweg = @position-Vtweg
*             AND vbeln = @position-Vbeln
*            AND gjahr = @position-Gjahr
*            AND posnr = @position-Posnr
*          INTO @DATA(draft_position_data).
*
*        IF sy-subrc = 0.
*          position_material = draft_position_data-material.
*          position_material_description = draft_position_data-materialdescription.
*          position_waerk = draft_position_data-waerk.
*          position_quantity = draft_position_data-quantity.
*        ENDIF.
*      ENDIF.
*
*      IF ( position_material IS INITIAL OR position_material_description IS INITIAL OR position_waerk IS INITIAL OR position_quantity IS INITIAL )
*        AND ( position-Vbeln IS INITIAL OR position-Vbeln(1) = 'D' ).
*        SELECT SINGLE z~arktx,
*                      z~Zdesc AS description
*          FROM /eacm/zpr08 AS z
*          WHERE z~bukrs = @position-Bukrs
*            AND z~zclpr = @position-Zclpr
*          INTO @DATA(zpr08_position).
*
*        IF sy-subrc = 0.
*          IF position_material IS INITIAL.
*            position_material = CONV /eacm/prdo-matnr( zpr08_position-arktx ).
*          ENDIF.
*
*          IF position_material_description IS INITIAL.
*            position_material_description = CONV /eacm/prdo-maktx( zpr08_position-description ).
*          ENDIF.
*
*          IF position_quantity IS INITIAL.
*            position_quantity = 1.
*          ENDIF.
*        ENDIF.
*      ELSEIF ( position_material IS INITIAL OR position_material_description IS INITIAL OR position_waerk IS INITIAL OR position_quantity IS INITIAL )
*        AND position-Vbeln IS NOT INITIAL.
*        SELECT SINGLE matnr,                    "#EC CI_NOORDER
*                      maktx,
*                      waerk,
*                      menge
*          FROM /eacm/prdo
*          WHERE zclpr = @position-Zclpr
*            AND bukrs = @position-Bukrs
*            AND vkorg = @position-Vkorg
*            AND vtweg = @position-Vtweg
*            AND vbeln = @position-Vbeln
*            AND gjahr = @position-Gjahr
*            AND posnr = @position-Posnr
*            AND zstre <> 'D'
*            AND zmodi <> 'D'
*          INTO @DATA(active_position_data).
*
*        IF sy-subrc = 0.
*          IF position_material IS INITIAL.
*            position_material = active_position_data-matnr.
*          ENDIF.
*
*          IF position_material_description IS INITIAL.
*            position_material_description = active_position_data-maktx.
*          ENDIF.
*
*          IF position_waerk IS INITIAL.
*            position_waerk = active_position_data-waerk.
*          ENDIF.
*
*          IF position_quantity IS INITIAL.
*            position_quantity = active_position_data-menge.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
*      IF position_material IS INITIAL
*        AND position_material_description IS INITIAL
*        AND position_waerk IS INITIAL
*        AND position_quantity IS INITIAL.
*        CONTINUE.
*      ENDIF.
*
*      MODIFY ENTITIES OF /EACM/I_PRDO_DOC IN LOCAL MODE
*        ENTITY Position
*        UPDATE FIELDS ( Material MaterialDescription Waerk Quantity )
*        WITH VALUE #(
*          (
*            %tky               = position-%tky
*            Material           = position_material
*            MaterialDescription = position_material_description
*            Waerk              = position_waerk
*            Quantity           = position_quantity
*          )
*        )
*        FAILED DATA(update_failed)
*        REPORTED DATA(update_reported).
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD update.
*
*  LOOP AT entities INTO DATA(position).
*
*    APPEND VALUE /eacm/prdo(
*      zclpr = position-Zclpr
*      bukrs = position-Bukrs
*      vkorg = position-Vkorg
*      vtweg = position-Vtweg
*      vbeln = position-Vbeln
*      gjahr = position-Gjahr
*      posnr = position-Posnr
*      matnr = position-Material
*      maktx = position-MaterialDescription
*      waerk = position-Waerk
*      zwaer = position-Waerk
*      menge = position-Quantity
*    ) TO lcl_buffer=>mt_update_position.
*
*  ENDLOOP.
*  ENDMETHOD.
*
*  METHOD delete.
*    LOOP AT keys INTO DATA(position_key).
*      APPEND VALUE /eacm/prdo(
*        zclpr = position_key-Zclpr
*        bukrs = position_key-Bukrs
*        vkorg = position_key-Vkorg
*        vtweg = position_key-Vtweg
*        vbeln = position_key-Vbeln
*        gjahr = position_key-Gjahr
*        posnr = position_key-Posnr
*      ) TO lcl_buffer=>mt_delete_position.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD read.
*    IF keys IS INITIAL.
*      RETURN.
*    ENDIF.
*
*    IF line_exists( keys[ %is_draft = if_abap_behv=>mk-on ] ).
*      LOOP AT keys INTO DATA(draft_position_key).
*        IF draft_position_key-%is_draft <> if_abap_behv=>mk-on.
*          CONTINUE.
*        ENDIF.
*
*        SELECT SINGLE zclpr,                    "#EC CI_NOORDER
*                      bukrs,
*                      vkorg,
*                      vtweg,
*                      vbeln,
*                      gjahr,
*                      posnr,
*                      material,
*                      materialdescription,
*                      waerk,
*                      quantity,
*                      locallastchangedat
*          FROM /EACM/PRDO_POS_D
*          WHERE zclpr = @draft_position_key-Zclpr
*            AND bukrs = @draft_position_key-Bukrs
*            AND vkorg = @draft_position_key-Vkorg
*            AND vtweg = @draft_position_key-Vtweg
*            AND vbeln = @draft_position_key-Vbeln
*            AND gjahr = @draft_position_key-Gjahr
*            AND posnr = @draft_position_key-Posnr
*          INTO @DATA(draft_position).
*
*        IF sy-subrc <> 0.
*          READ TABLE lcl_buffer=>mt_create_position INTO DATA(buffered_position)
*            WITH KEY zclpr = draft_position_key-Zclpr
*                     bukrs = draft_position_key-Bukrs
*                     vkorg = draft_position_key-Vkorg
*                     vtweg = draft_position_key-Vtweg
*                     vbeln = draft_position_key-Vbeln
*                     gjahr = draft_position_key-Gjahr
*                     posnr = draft_position_key-Posnr.
*
*          IF sy-subrc = 0.
*            APPEND VALUE #(
*              %is_draft          = if_abap_behv=>mk-on
*              Zclpr              = buffered_position-zclpr
*              Bukrs              = buffered_position-bukrs
*              Vkorg              = buffered_position-vkorg
*              Vtweg              = buffered_position-vtweg
*              Vbeln              = buffered_position-vbeln
*              Gjahr              = buffered_position-gjahr
*              Posnr              = buffered_position-posnr
*              Material           = buffered_position-matnr
*              MaterialDescription = buffered_position-maktx
*              Waerk              = buffered_position-waerk
*              Quantity           = buffered_position-menge
*              LocalLastChangedAt = buffered_position-local_last_changed_at
*            ) TO result.
*          ENDIF.
*
*          CONTINUE.
*        ENDIF.
*
*        DATA(draft_material) = draft_position-material.
*        DATA(draft_materialdescription) = draft_position-materialdescription.
*        DATA(draft_waerk) = draft_position-waerk.
*        DATA(draft_quantity) = draft_position-quantity.
*
*        IF ( draft_material IS INITIAL OR draft_materialdescription IS INITIAL OR draft_waerk IS INITIAL OR draft_quantity IS INITIAL )
*          AND ( draft_position-vbeln IS INITIAL OR draft_position-vbeln(1) = 'D' ).
*          SELECT SINGLE z~arktx,
*                        z~Zdesc AS description
*            FROM /eacm/zpr08 AS z
*            WHERE z~bukrs = @draft_position-bukrs
*              AND z~zclpr = @draft_position-zclpr
*              AND z~posnr = @draft_position-posnr
*            INTO @DATA(draft_zpr08_position).
*
*          IF sy-subrc = 0.
*            IF draft_material IS INITIAL.
*              draft_material = CONV /eacm/prdo-matnr( draft_zpr08_position-arktx ).
*            ENDIF.
*
*            IF draft_materialdescription IS INITIAL.
*              draft_materialdescription = CONV /eacm/prdo-maktx( draft_zpr08_position-description ).
*            ENDIF.
*
*            IF draft_quantity IS INITIAL.
*              draft_quantity = 1.
*            ENDIF.
*          ENDIF.
*        ELSEIF ( draft_material IS INITIAL OR draft_materialdescription IS INITIAL OR draft_waerk IS INITIAL OR draft_quantity IS INITIAL )
*          AND draft_position-vbeln IS NOT INITIAL.
*          SELECT SINGLE z~matnr,                        "#EC CI_NOORDER
*                        z~maktx,
*                        z~waerk,
*                        z~menge
*            FROM /eacm/prdo AS z
*            WHERE z~zclpr = @draft_position-zclpr
*              AND z~bukrs = @draft_position-bukrs
*              AND z~vkorg = @draft_position-vkorg
*              AND z~vtweg = @draft_position-vtweg
*              AND z~vbeln = @draft_position-vbeln
*              AND z~gjahr = @draft_position-gjahr
*              AND z~posnr = @draft_position-posnr
*              AND z~zstre <> 'D'
*              AND z~zmodi <> 'D'
*            INTO @DATA(draft_zprdo_position).
*
*          IF sy-subrc = 0.
*            IF draft_material IS INITIAL.
*              draft_material = draft_zprdo_position-matnr.
*            ENDIF.
*
*            IF draft_materialdescription IS INITIAL.
*              draft_materialdescription = draft_zprdo_position-maktx.
*            ENDIF.
*
*            IF draft_waerk IS INITIAL.
*              draft_waerk = draft_zprdo_position-waerk.
*            ENDIF.
*
*            IF draft_quantity IS INITIAL.
*              draft_quantity = draft_zprdo_position-menge.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
*        APPEND VALUE #(
*          %is_draft          = if_abap_behv=>mk-on
*          Zclpr              = draft_position-zclpr
*          Bukrs              = draft_position-bukrs
*          Vkorg              = draft_position-vkorg
*          Vtweg              = draft_position-vtweg
*          Vbeln              = draft_position-vbeln
*          Gjahr              = draft_position-gjahr
*          Posnr              = draft_position-posnr
*          Material           = draft_material
*          MaterialDescription = draft_materialdescription
*          Waerk              = draft_waerk
*          Quantity           = draft_quantity
*          LocalLastChangedAt = draft_position-locallastchangedat
*        ) TO result.
*      ENDLOOP.
*
*      IF result IS NOT INITIAL.
*        RETURN.
*      ENDIF.
*    ENDIF.
*
*    LOOP AT keys INTO DATA(active_position_key).
*      SELECT FROM /eacm/prdo AS z
*        FIELDS z~zclpr,
*               z~bukrs,
*               z~vkorg,
*               z~vtweg,
*               z~vbeln,
*               z~gjahr,
*               z~posnr,
*               MIN( z~matnr ) AS material,
*               MIN( z~maktx ) AS materialdescription,
*               z~waerk,
*               MAX( z~menge ) AS quantity,
*               MAX( z~local_last_changed_at ) AS locallastchangedat
*        WHERE z~zclpr = @active_position_key-Zclpr
*          AND z~bukrs = @active_position_key-Bukrs
*          AND z~vkorg = @active_position_key-Vkorg
*          AND z~vtweg = @active_position_key-Vtweg
*          AND z~vbeln = @active_position_key-Vbeln
*          AND z~gjahr = @active_position_key-Gjahr
*          AND z~posnr = @active_position_key-Posnr
*          AND z~posnr <> '000000'
*          AND z~zstre <> 'D'
*          AND z~zmodi <> 'D'
*        GROUP BY z~zclpr,
*                 z~bukrs,
*                 z~vkorg,
*                 z~vtweg,
*                 z~vbeln,
*                 z~gjahr,
*                 z~posnr,
*                 z~waerk
*        INTO TABLE @DATA(active_positions).
*
*      LOOP AT active_positions INTO DATA(active_position).
*        APPEND VALUE #(
*          Zclpr              = active_position-zclpr
*          Bukrs              = active_position-bukrs
*          Vkorg              = active_position-vkorg
*          Vtweg              = active_position-vtweg
*          Vbeln              = active_position-vbeln
*          Gjahr              = active_position-gjahr
*          Posnr              = active_position-posnr
*          Material           = active_position-material
*          MaterialDescription = active_position-materialdescription
*          Waerk              = active_position-waerk
*          Quantity           = active_position-quantity
*          LocalLastChangedAt = active_position-locallastchangedat
*        ) TO result.
*      ENDLOOP.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD rba_Document.
*    LOOP AT keys_rba INTO DATA(position_key).
*      APPEND VALUE #(
*        source-%tky = position_key-%tky
*        target-%tky = VALUE #(
*          %is_draft = position_key-%is_draft
*          Zclpr     = position_key-Zclpr
*          Bukrs     = position_key-Bukrs
*          Vkorg     = position_key-Vkorg
*          Vtweg     = position_key-Vtweg
*          Vbeln     = position_key-Vbeln
*          Gjahr     = position_key-Gjahr
*        )
*      ) TO association_links.
*
*      IF result_requested = abap_true.
*        APPEND VALUE #(
*          %is_draft = position_key-%is_draft
*          Zclpr     = position_key-Zclpr
*          Bukrs     = position_key-Bukrs
*          Vkorg     = position_key-Vkorg
*          Vtweg     = position_key-Vtweg
*          Vbeln     = position_key-Vbeln
*          Gjahr     = position_key-Gjahr
*        ) TO result.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD rba_Agents.
*    IF keys_rba IS INITIAL.
*      RETURN.
*    ENDIF.
*
*    CLEAR result.
*    CLEAR association_links.
*
*    IF line_exists( keys_rba[ %is_draft = if_abap_behv=>mk-on ] ).
*      SELECT FROM /EACM/PRDO_AGT_D AS z
*        INNER JOIN @keys_rba AS k
*          ON  z~zclpr = k~Zclpr
*          AND z~bukrs = k~Bukrs
*          AND z~vkorg = k~Vkorg
*          AND z~vtweg = k~Vtweg
*          AND z~vbeln = k~Vbeln
*          AND z~gjahr = k~Gjahr
*          AND z~posnr = k~Posnr
*        FIELDS z~zclpr AS zclpr,
*               z~bukrs AS bukrs,
*               z~vkorg AS vkorg,
*               z~vtweg AS vtweg,
*               z~vbeln AS vbeln,
*               z~gjahr AS gjahr,
*               z~posnr AS posnr,
*               z~zidag AS zidag,
*                z~zcdaz AS zcdaz,
*                z~ziman AS ziman,
*                z~zimar AS zimar,
*                z~zpcpr AS zpcpr,
*                z~zimpp AS zimpp,
*                z~zimco AS zimco,
*                z~zimpu AS zimpu,
**               z~zwaer,
*                z~kunrg AS kunrg,
*                z~budat AS budat,
*                z~zwaer AS zwaer,
*                z~kurrf AS kurrf,
*                z~ztpag AS ztpag,
*                z~zstre AS zstre,
*                z~zmodi AS zmodi,
*                z~zcamd AS zcamd,
*                z~zdtmd AS zdtmd,
*                z~zormd AS zormd,
*                z~zdest AS zdest,
*                z~unitmeasure AS unitmeasure,
*                z~documentdate AS documentdate,
*               z~locallastchangedat AS locallastchangedat
*        INTO TABLE @DATA(draft_agents).
*
*      LOOP AT draft_agents INTO DATA(draft_agent).
*        READ TABLE keys_rba INTO DATA(draft_key)
*          WITH KEY Zclpr = draft_agent-zclpr
*                   Bukrs = draft_agent-bukrs
*                   Vkorg = draft_agent-vkorg
*                   Vtweg = draft_agent-vtweg
*                   Vbeln = draft_agent-vbeln
*                   Gjahr = draft_agent-gjahr
*                   Posnr = draft_agent-posnr.
*
*        IF sy-subrc = 0.
*          APPEND VALUE #(
*            source-%tky = draft_key-%tky
*            target-%tky = VALUE #(
*              %is_draft = if_abap_behv=>mk-on
*              Zclpr     = draft_agent-zclpr
*              Bukrs     = draft_agent-bukrs
*              Vkorg     = draft_agent-vkorg
*              Vtweg     = draft_agent-vtweg
*              Vbeln     = draft_agent-vbeln
*              Gjahr     = draft_agent-gjahr
*              Posnr     = draft_agent-posnr
*              Zidag     = draft_agent-zidag
*              Zcdaz     = draft_agent-zcdaz
*            )
*          ) TO association_links.
*        ENDIF.
*
*        IF result_requested = abap_true.
*          APPEND VALUE #(
*            %is_draft          = if_abap_behv=>mk-on
*            Zclpr              = draft_agent-zclpr
*            Bukrs              = draft_agent-bukrs
*            Vkorg              = draft_agent-vkorg
*            Vtweg              = draft_agent-vtweg
*            Vbeln              = draft_agent-vbeln
*            Gjahr              = draft_agent-gjahr
*            Posnr              = draft_agent-posnr
*            Zidag              = draft_agent-zidag
*            Zcdaz              = draft_agent-zcdaz
*            Ziman              = draft_agent-ziman
*            Zimar              = draft_agent-zimar
*            Zpcpr              = draft_agent-zpcpr
*            Zimpp              = draft_agent-zimpp
*            Zimco              = draft_agent-zimco
*            Zimpu              = draft_agent-zimpu
*            Zwaer              = draft_agent-zwaer
*            Kunrg              = draft_agent-kunrg
*            Budat              = draft_agent-budat
*            Kurrf              = draft_agent-kurrf
*            Ztpag              = draft_agent-ztpag
*            Zstre              = draft_agent-zstre
*            Zmodi              = draft_agent-zmodi
*            Zcamd              = draft_agent-zcamd
*            Zdtmd              = draft_agent-zdtmd
*            Zormd              = draft_agent-zormd
*            Zdest              = draft_agent-zdest
*            UnitMeasure        = draft_agent-unitmeasure
*            DocumentDate       = draft_agent-documentdate
*            LocalLastChangedAt = draft_agent-locallastchangedat
*          ) TO result.
*        ENDIF.
*      ENDLOOP.
*
*      IF association_links IS NOT INITIAL OR result IS NOT INITIAL.
*        RETURN.
*      ENDIF.
*    ENDIF.
*
*    SELECT FROM /eacm/prdo AS z
*      INNER JOIN @keys_rba AS k
*        ON  z~zclpr = k~Zclpr
*        AND z~bukrs = k~Bukrs
*        AND z~vkorg = k~Vkorg
*        AND z~vtweg = k~Vtweg
*        AND z~vbeln = k~Vbeln
*        AND z~gjahr = k~Gjahr
*        AND z~posnr = k~Posnr
*      FIELDS z~zclpr,
*             z~bukrs,
*             z~vkorg,
*             z~vtweg,
*             z~vbeln,
*             z~gjahr,
*             z~posnr,
*             z~zidag,
*             z~zcdaz,
*             z~ziman,
*             z~zimar,
*             z~zpcpr,
*             z~zimpp,
*             z~zimco,
*             z~zimpu,
*             z~zwaer,
*             z~kunrg,
*             z~budat,
*             z~kurrf,
*             z~ztpag,
*             z~zstre,
*             z~zmodi,
*             z~zcamd,
*             z~zdtmd,
*             z~zormd,
*             z~zdest,
*             z~menge,
*             z~zutmx,
*             z~fkdat,
*             z~waerk,
*             z~local_last_changed_at
*       WHERE z~posnr <> '000000'
*         AND z~zstre <> 'D'
*         AND z~zmodi <> 'D'
*       INTO TABLE @DATA(active_agents).
*
*    LOOP AT active_agents INTO DATA(active_agent).
*      READ TABLE keys_rba INTO DATA(active_key)
*        WITH KEY Zclpr = active_agent-zclpr
*                 Bukrs = active_agent-bukrs
*                 Vkorg = active_agent-vkorg
*                 Vtweg = active_agent-vtweg
*                 Vbeln = active_agent-vbeln
*                 Gjahr = active_agent-gjahr
*                 Posnr = active_agent-posnr.
*
*      IF sy-subrc = 0.
*        APPEND VALUE #(
*          source-%tky = active_key-%tky
*          target-%tky = VALUE #(
*            %is_draft = if_abap_behv=>mk-off
*            Zclpr     = active_agent-zclpr
*            Bukrs     = active_agent-bukrs
*            Vkorg     = active_agent-vkorg
*            Vtweg     = active_agent-vtweg
*            Vbeln     = active_agent-vbeln
*            Gjahr     = active_agent-gjahr
*            Posnr     = active_agent-posnr
*            Zidag     = active_agent-zidag
*            Zcdaz     = active_agent-zcdaz
*          )
*        ) TO association_links.
*      ENDIF.
*
*      IF result_requested = abap_true.
*        APPEND VALUE #(
*          %is_draft          = if_abap_behv=>mk-off
*          Zclpr              = active_agent-zclpr
*          Bukrs              = active_agent-bukrs
*          Vkorg              = active_agent-vkorg
*          Vtweg              = active_agent-vtweg
*          Vbeln              = active_agent-vbeln
*          Gjahr              = active_agent-gjahr
*          Posnr              = active_agent-posnr
*          Zidag              = active_agent-zidag
*          Zcdaz              = active_agent-zcdaz
*          Ziman              = active_agent-ziman
*          Zimar              = active_agent-zimar
*          Zpcpr              = active_agent-zpcpr
*          Zimpp              = active_agent-zimpp
*          Zimco              = active_agent-zimco
*          Zimpu              = active_agent-zimpu
*          Zwaer              = active_agent-zwaer
*          Kunrg              = active_agent-kunrg
*          Budat              = active_agent-budat
*          Kurrf              = active_agent-kurrf
*          Ztpag              = active_agent-ztpag
*          Zstre              = active_agent-zstre
*          Zmodi              = active_agent-zmodi
*          Zcamd              = active_agent-zcamd
*          Zdtmd              = active_agent-zdtmd
*          Zormd              = active_agent-zormd
*          Zdest              = active_agent-zdest
*          UnitMeasure        = active_agent-zutmx
*          DocumentDate       = active_agent-fkdat
*          LocalLastChangedAt = active_agent-local_last_changed_at
*        ) TO result.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD cba_Agents.
*    LOOP AT entities_cba INTO DATA(position).
*      LOOP AT position-%target INTO DATA(agent).
*        TRY.
*            DATA(agent_pid) = cl_system_uuid=>create_uuid_x16_static( ).
*
*            DATA(zcdaz) = agent-Zcdaz.
*
*            IF zcdaz IS NOT INITIAL.
*              zcdaz = |{ zcdaz ALPHA = IN }|.
*            ENDIF.
*
*            SELECT MAX( zidag )
*              FROM /eacm/prdo
*              WHERE zclpr = @position-Zclpr
*                AND bukrs = @position-Bukrs
*                AND vkorg = @position-Vkorg
*                AND vtweg = @position-Vtweg
*                AND vbeln = @position-Vbeln
*                AND gjahr = @position-Gjahr
*                AND posnr = @position-Posnr
*              INTO @DATA(max_zidag).
*
*            SELECT MAX( zidag )
*              FROM /EACM/PRDO_AGT_D
*              WHERE zclpr = @position-Zclpr
*                AND bukrs = @position-Bukrs
*                AND vkorg = @position-Vkorg
*                AND vtweg = @position-Vtweg
*                AND vbeln = @position-Vbeln
*                AND gjahr = @position-Gjahr
*                AND posnr = @position-Posnr
*              INTO @DATA(max_draft_zidag).
*
*            IF max_draft_zidag > max_zidag.
*              max_zidag = max_draft_zidag.
*            ENDIF.
*
*            LOOP AT lcl_buffer=>mt_create_agent INTO DATA(buffered_agent)
*              WHERE zclpr = position-Zclpr
*                AND bukrs = position-Bukrs
*                AND vkorg = position-Vkorg
*                AND vtweg = position-Vtweg
*                AND vbeln = position-Vbeln
*                AND gjahr = position-Gjahr
*                AND posnr = position-Posnr.
*              IF buffered_agent-zidag > max_zidag.
*                max_zidag = buffered_agent-zidag.
*              ENDIF.
*            ENDLOOP.
*
*            DATA(zidag_number) = CONV i( max_zidag ) + 1.
*            DATA(zidag) = CONV /eacm/zidag( |{ zidag_number WIDTH = 4 PAD = '0' ALIGN = RIGHT }| ).
*            DATA(position_material) = VALUE /eacm/prdo-matnr( ).
*            DATA(position_material_description) = VALUE /eacm/prdo-maktx( ).
*            DATA(position_quantity) = VALUE /eacm/prdo-menge( ).
*            DATA(position_unitmeasure) = VALUE /eacm/prdo-zutmx( ).
*            DATA(position_fkdat) = VALUE /eacm/prdo-fkdat( ).
*            DATA(position_waerk) = VALUE /eacm/prdo-waerk( ).
*
*            READ TABLE lcl_buffer=>mt_create_position INTO DATA(create_position)
*              WITH KEY zclpr = position-Zclpr
*                       bukrs = position-Bukrs
*                       vkorg = position-Vkorg
*                       vtweg = position-Vtweg
*                       vbeln = position-Vbeln
*                       gjahr = position-Gjahr
*                       posnr = position-Posnr.
*
*            IF sy-subrc = 0.
*              position_material = create_position-matnr.
*              position_material_description = create_position-maktx.
*              position_quantity = create_position-menge.
*              position_unitmeasure = create_position-zutmx.
*              position_fkdat = create_position-fkdat.
*              position_waerk = create_position-waerk.
*            ELSE.
*              SELECT SINGLE matnr,                      "#EC CI_NOORDER
*                            maktx,
*                            menge,
*                            zutmx,
*                            fkdat,
*                            waerk
*                FROM /eacm/prdo
*                WHERE zclpr = @position-Zclpr
*                  AND bukrs = @position-Bukrs
*                  AND vkorg = @position-Vkorg
*                  AND vtweg = @position-Vtweg
*                  AND vbeln = @position-Vbeln
*                  AND gjahr = @position-Gjahr
*                  AND posnr = @position-Posnr
*                  AND zstre <> 'D'
*                  AND zmodi <> 'D'
*                INTO @DATA(active_position_data).
*
*              IF sy-subrc = 0.
*                position_material = active_position_data-matnr.
*                position_material_description = active_position_data-maktx.
*                position_quantity = active_position_data-menge.
*                position_unitmeasure = active_position_data-zutmx.
*                position_fkdat = active_position_data-fkdat.
*                position_waerk = active_position_data-waerk.
*              ELSE.
*                SELECT SINGLE material,                     "#EC CI_NOORDER
*                              materialdescription,
*                              waerk,
*                              quantity
*                  FROM /EACM/PRDO_POS_D
*                  WHERE zclpr = @position-Zclpr
*                    AND bukrs = @position-Bukrs
*                    AND vkorg = @position-Vkorg
*                    AND vtweg = @position-Vtweg
*                    AND vbeln = @position-Vbeln
*                    AND gjahr = @position-Gjahr
*                    AND posnr = @position-Posnr
*                  INTO @DATA(draft_position_data).
*
*                IF sy-subrc = 0.
*                  position_material = draft_position_data-material.
*                  position_material_description = draft_position_data-materialdescription.
*                  position_waerk = draft_position_data-waerk.
*                  position_quantity = draft_position_data-quantity.
*                ENDIF.
*
*IF position_waerk IS INITIAL.
*  READ ENTITIES OF /EACM/I_PRDO_DOC IN LOCAL MODE
*    ENTITY Position
*      FIELDS ( Waerk )
*      WITH VALUE #(
*        (
*          %is_draft = if_abap_behv=>mk-on
*          Zclpr = position-Zclpr
*          Bukrs = position-Bukrs
*          Vkorg = position-Vkorg
*          Vtweg = position-Vtweg
*          Vbeln = position-Vbeln
*          Gjahr = position-Gjahr
*          Posnr = position-Posnr
*        )
*      )
*      RESULT DATA(read_positions).
*
*  READ TABLE read_positions INTO DATA(read_position) INDEX 1.
*
*  IF sy-subrc = 0.
*    position_waerk = read_position-Waerk.
*  ENDIF.
*ENDIF.
*
*                IF ( position_material IS INITIAL OR position_material_description IS INITIAL OR position_unitmeasure IS INITIAL OR position_waerk IS INITIAL OR position_quantity IS INITIAL )
*                  AND ( position-Vbeln IS INITIAL OR position-Vbeln(1) = 'D' ).
*                  SELECT SINGLE z~arktx,
*                                z~Zdesc AS description
*                    FROM /eacm/zpr08 AS z
*                    WHERE z~bukrs = @position-Bukrs
*                      AND z~zclpr = @position-Zclpr
*                      AND z~posnr = @position-Posnr
*                    INTO @DATA(agent_zpr08_position).
*
*                  IF sy-subrc = 0.
*                    IF position_material IS INITIAL.
*                      position_material = CONV /eacm/prdo-matnr( agent_zpr08_position-arktx ).
*                    ENDIF.
*
*                    IF position_material_description IS INITIAL.
*                      position_material_description = CONV /eacm/prdo-maktx( agent_zpr08_position-description ).
*                    ENDIF.
*
*                    IF position_quantity IS INITIAL.
*                      position_quantity = 1.
*                    ENDIF.
*                  ENDIF.
*                ELSEIF ( position_material IS INITIAL OR position_material_description IS INITIAL OR position_unitmeasure IS INITIAL OR position_waerk IS INITIAL OR position_quantity IS INITIAL )
*                  AND position-Vbeln IS NOT INITIAL.
*                  SELECT SINGLE matnr,                  "#EC CI_NOORDER
*                                maktx,
*                                menge,
*                                zutmx,
*                                fkdat,
*                                waerk
*                    FROM /eacm/prdo
*                    WHERE zclpr = @position-Zclpr
*                      AND bukrs = @position-Bukrs
*                      AND vkorg = @position-Vkorg
*                      AND vtweg = @position-Vtweg
*                      AND vbeln = @position-Vbeln
*                      AND gjahr = @position-Gjahr
*                      AND posnr = @position-Posnr
*                      AND zstre <> 'D'
*                      AND zmodi <> 'D'
*                    INTO @DATA(agent_position_data).
*
*                  IF sy-subrc = 0.
*                    IF position_material IS INITIAL.
*                      position_material = agent_position_data-matnr.
*                    ENDIF.
*
*                    IF position_material_description IS INITIAL.
*                      position_material_description = agent_position_data-maktx.
*                    ENDIF.
*
*                    IF position_quantity IS INITIAL.
*                      position_quantity = agent_position_data-menge.
*                    ENDIF.
*
*                    IF position_unitmeasure IS INITIAL.
*                      position_unitmeasure = agent_position_data-zutmx.
*                    ENDIF.
*
*                    IF position_fkdat IS INITIAL.
*                      position_fkdat = agent_position_data-fkdat.
*                    ENDIF.
*
*                    IF position_waerk IS INITIAL.
*                      position_waerk = agent_position_data-waerk.
*                    ENDIF.
*                  ENDIF.
*                ENDIF.
*              ENDIF.
*            ENDIF.
*
*            IF agent-DocumentDate IS NOT INITIAL.
*              position_fkdat = agent-DocumentDate.
*            ENDIF.
*
*            DATA(agent_ziman) = agent-Ziman.
*
*            IF agent-ZPCPR IS NOT INITIAL.
*agent-ZIMCO = agent-ZIMPP * agent-ZPCPR / 100.
*            ENDIF.
*
*            DATA(agent_zpcpr) = agent-Zpcpr.
*            DATA(agent_zimpp) = agent-Zimpp.
*            DATA(agent_zimco) = agent-Zimco.
*
*            IF ( agent_zpcpr IS INITIAL AND agent_zimpp IS NOT INITIAL )
*              OR ( agent_zpcpr IS NOT INITIAL AND agent_zimpp IS INITIAL ).
*              APPEND VALUE #( %cid = agent-%cid ) TO failed-agent.
*              APPEND VALUE #(
*                %cid           = agent-%cid
*                %element-Zpcpr = if_abap_behv=>mk-on
*                %element-Zimpp = if_abap_behv=>mk-on
*                %element-Zimco = if_abap_behv=>mk-on
*                %msg           = new_message_with_text(
*                  severity = if_abap_behv_message=>severity-error
*                  text     = 'Inserire % Prov e Base di Calcolo insieme, oppure solo Importo Provvigione.' )
*              ) TO reported-agent.
*              CONTINUE.
*            ENDIF.
*
*            IF agent_zpcpr IS NOT INITIAL
*              AND agent_zimpp IS NOT INITIAL.
*              agent_zimco = agent_zimpp * agent_zpcpr / 100.
*            ENDIF.
*
*            APPEND VALUE #(
*              %cid  = agent-%cid
*              %pid  = agent_pid
*              Zclpr = position-Zclpr
*              Bukrs = position-Bukrs
*              Vkorg = position-Vkorg
*              Vtweg = position-Vtweg
*              Vbeln = position-Vbeln
*              Gjahr = position-Gjahr
*              Posnr = position-Posnr
*              Zidag = zidag
*              Zcdaz = zcdaz
*            ) TO mapped-agent.
*
*            APPEND VALUE #(
*              pid   = agent_pid
*              zclpr = position-Zclpr
*              bukrs = position-Bukrs
*              vkorg = position-Vkorg
*              vtweg = position-Vtweg
*              vbeln = position-Vbeln
*              gjahr = position-Gjahr
*              posnr = position-Posnr
*              zidag = zidag
*              zcdaz = zcdaz
*            ) TO lcl_buffer=>mt_create_agent_key.
*
*            APPEND VALUE /eacm/prdo(
*              zclpr   = position-Zclpr
*              bukrs   = position-Bukrs
*              vkorg   = position-Vkorg
*              vtweg   = position-Vtweg
*              vbeln   = position-Vbeln
*              gjahr   = position-Gjahr
*              posnr   = position-Posnr
*              zidag   = zidag
*              zcdaz   = zcdaz
*              matnr   = position_material
*              maktx   = position_material_description
*              menge   = position_quantity
*              ziman   = agent_ziman
*              zimar   = agent-Zimar
*              zpcpr   = agent_zpcpr
*              zimpp   = agent_zimpp
*              zimco   = agent_zimco
*              zimpu   = COND #( WHEN agent_zpcpr IS INITIAL THEN agent-Zimpu )
*              waerk   = position_waerk
*              zwaer   = COND #( WHEN agent-Zwaer IS NOT INITIAL THEN agent-Zwaer ELSE position_waerk )
*              kunrg   = agent-Kunrg
*              budat   = agent-Budat
*              kurrf   = agent-Kurrf
*              ztpag   = agent-Ztpag
*              zdest   = agent-Zdest
*              zutmx   = position_unitmeasure
*              fkdat   = position_fkdat
*            ) TO lcl_buffer=>mt_create_agent.
*
*          CATCH cx_uuid_error INTO DATA(uuid_error).
*            APPEND VALUE #( %cid = agent-%cid ) TO failed-agent.
*            APPEND VALUE #(
*              %cid = agent-%cid
*              %msg = new_message_with_text(
*                severity = if_abap_behv_message=>severity-error
*                text     = uuid_error->get_text( ) )
*            ) TO reported-agent.
*        ENDTRY.
*      ENDLOOP.
*    ENDLOOP.
*  ENDMETHOD.
*ENDCLASS.
***********************************************************************
***********************************************************************
*CLASS lhc_Agent DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE Agent.
*
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE Agent.
*
*    METHODS read FOR READ
*      IMPORTING keys FOR READ Agent RESULT result.
*
*    METHODS rba_Document FOR READ
*      IMPORTING keys_rba FOR READ Agent\_Document FULL result_requested RESULT result LINK association_links.
*
*    METHODS rba_Position FOR READ
*      IMPORTING keys_rba FOR READ Agent\_Position FULL result_requested RESULT result LINK association_links.
*
*    METHODS CalculateZimco
*  FOR DETERMINE ON MODIFY
*  IMPORTING keys FOR Agent~CalculateZimco.
*
*ENDCLASS.
***********************************************************************
*CLASS lhc_Agent IMPLEMENTATION.
*
*METHOD update.
*
*LOOP AT entities INTO DATA(agent).
*
*    DATA(agent_ziman) = agent-Ziman.
*
*            IF agent-ZPCPR IS NOT INITIAL.
*agent-ZIMCO = agent-ZIMPP * agent-ZPCPR / 100.
*            ENDIF.
*
*    DATA(agent_zpcpr) = agent-Zpcpr.
*    DATA(agent_zimpp) = agent-Zimpp.
*    DATA(agent_zimco) = agent-Zimco.
*
*    IF ( agent_zpcpr IS INITIAL AND agent_zimpp IS NOT INITIAL )
*      OR ( agent_zpcpr IS NOT INITIAL AND agent_zimpp IS INITIAL ).
*      APPEND VALUE #( %tky = agent-%tky ) TO failed-agent.
*      APPEND VALUE #(
*        %tky           = agent-%tky
*        %element-Zpcpr = if_abap_behv=>mk-on
*        %element-Zimpp = if_abap_behv=>mk-on
*        %element-Zimco = if_abap_behv=>mk-on
*        %msg           = new_message_with_text(
*          severity = if_abap_behv_message=>severity-error
*          text     = 'Inserire % Prov e Base di Calcolo insieme, oppure solo Importo Provvigione.' )
*      ) TO reported-agent.
*      CONTINUE.
*    ENDIF.
*
*    IF agent_zpcpr IS NOT INITIAL
*      AND agent_zimpp IS NOT INITIAL.
*      agent_zimco = agent_zimpp * agent_zpcpr / 100.
*    ENDIF.
*
*    APPEND VALUE /eacm/prdo(
*      zclpr = agent-Zclpr
*      bukrs = agent-Bukrs
*      vkorg = agent-Vkorg
*      vtweg = agent-Vtweg
*      vbeln = agent-Vbeln
*      gjahr = agent-Gjahr
*      posnr = agent-Posnr
*      zidag = agent-Zidag
*      zcdaz = agent-Zcdaz
*      ziman = agent_ziman
*      zimar = agent-Zimar
*      zpcpr = agent_zpcpr
*      zimpp = agent_zimpp
*      zimco = agent_zimco
*      zimpu = agent-Zimpu
*      zwaer = agent-Zwaer
*      kunrg = agent-Kunrg
*      budat = agent-Budat
*      kurrf = agent-Kurrf
*      ztpag = agent-Ztpag
*      zdest = agent-Zdest
*    ) TO lcl_buffer=>mt_update_agent.
*
*  ENDLOOP.
*
*  ENDMETHOD.
*
*  METHOD delete.
*    LOOP AT keys INTO DATA(agent_key).
*      APPEND VALUE /eacm/prdo(
*        zclpr = agent_key-Zclpr
*        bukrs = agent_key-Bukrs
*        vkorg = agent_key-Vkorg
*        vtweg = agent_key-Vtweg
*        vbeln = agent_key-Vbeln
*        gjahr = agent_key-Gjahr
*        posnr = agent_key-Posnr
*        zidag = agent_key-Zidag
*        zcdaz = agent_key-Zcdaz
*      ) TO lcl_buffer=>mt_delete_agent.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD read.
*    IF keys IS INITIAL.
*      RETURN.
*    ENDIF.
*
*    SELECT FROM /eacm/prdo AS z
*      INNER JOIN @keys AS k
*        ON  z~zclpr = k~Zclpr
*        AND z~bukrs = k~Bukrs
*        AND z~vkorg = k~Vkorg
*        AND z~vtweg = k~Vtweg
*        AND z~vbeln = k~Vbeln
*        AND z~gjahr = k~Gjahr
*        AND z~posnr = k~Posnr
*        AND z~zidag = k~Zidag
*        AND z~zcdaz = k~Zcdaz
*      FIELDS z~zclpr,
*             z~bukrs,
*             z~vkorg,
*             z~vtweg,
*             z~vbeln,
*             z~gjahr,
*             z~posnr,
*             z~zidag,
*             z~zcdaz,
*             z~ziman,
*             z~zimar,
*             z~zpcpr,
*             z~zimpp,
*             z~zimco,
*             z~zimpu,
*             z~zwaer,
*             z~kunrg,
*             z~budat,
*             z~kurrf,
*             z~ztpag,
*             z~zstre,
*             z~zmodi,
*             z~zcamd,
*             z~zdtmd,
*             z~zormd,
*             z~zdest,
*             z~menge,
*             z~zutmx,
*             z~fkdat,
*             z~waerk,
*             z~local_last_changed_at
*       WHERE z~posnr <> '000000'
*         AND z~zstre <> 'D'
*         AND z~zmodi <> 'D'
*       INTO TABLE @DATA(agents).
*
*    result = VALUE #( FOR agent IN agents
*      (
*        Zclpr              = agent-zclpr
*        Bukrs              = agent-bukrs
*        Vkorg              = agent-vkorg
*        Vtweg              = agent-vtweg
*        Vbeln              = agent-vbeln
*        Gjahr              = agent-gjahr
*        Posnr              = agent-posnr
*        Zidag              = agent-zidag
*        Zcdaz              = agent-zcdaz
*        Ziman              = agent-ziman
*        Zimar              = agent-zimar
*        Zpcpr              = agent-zpcpr
*        Zimpp              = agent-zimpp
*        Zimco              = agent-zimco
*        Zimpu              = agent-zimpu
*        Zwaer              = agent-zwaer
*        Kunrg              = agent-kunrg
*        Budat              = agent-budat
*        Kurrf              = agent-kurrf
*        Ztpag              = agent-ztpag
*        Zstre              = agent-zstre
*        Zmodi              = agent-zmodi
*        Zcamd              = agent-zcamd
*        Zdtmd              = agent-zdtmd
*        Zormd              = agent-zormd
*        Zdest              = agent-zdest
*        UnitMeasure        = agent-zutmx
*        DocumentDate       = agent-fkdat
*        LocalLastChangedAt = agent-local_last_changed_at
*      ) ).
*  ENDMETHOD.
*
*  METHOD rba_Position.
*    LOOP AT keys_rba INTO DATA(agent_key).
*      APPEND VALUE #(
*        source-%tky = agent_key-%tky
*        target-%tky = VALUE #(
*          %is_draft = agent_key-%is_draft
*          Zclpr     = agent_key-Zclpr
*          Bukrs     = agent_key-Bukrs
*          Vkorg     = agent_key-Vkorg
*          Vtweg     = agent_key-Vtweg
*          Vbeln     = agent_key-Vbeln
*          Gjahr     = agent_key-Gjahr
*          Posnr     = agent_key-Posnr
*        )
*      ) TO association_links.
*
*      IF result_requested = abap_true.
*        APPEND VALUE #(
*          %is_draft = agent_key-%is_draft
*          Zclpr     = agent_key-Zclpr
*          Bukrs     = agent_key-Bukrs
*          Vkorg     = agent_key-Vkorg
*          Vtweg     = agent_key-Vtweg
*          Vbeln     = agent_key-Vbeln
*          Gjahr     = agent_key-Gjahr
*          Posnr     = agent_key-Posnr
*        ) TO result.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD rba_Document.
*    LOOP AT keys_rba INTO DATA(agent_key).
*      APPEND VALUE #(
*        source-%tky = agent_key-%tky
*        target-%tky = VALUE #(
*          %is_draft = agent_key-%is_draft
*          Zclpr     = agent_key-Zclpr
*          Bukrs     = agent_key-Bukrs
*          Vkorg     = agent_key-Vkorg
*          Vtweg     = agent_key-Vtweg
*          Vbeln     = agent_key-Vbeln
*          Gjahr     = agent_key-Gjahr
*        )
*      ) TO association_links.
*
*      IF result_requested = abap_true.
*        APPEND VALUE #(
*          %is_draft = agent_key-%is_draft
*          Zclpr     = agent_key-Zclpr
*          Bukrs     = agent_key-Bukrs
*          Vkorg     = agent_key-Vkorg
*          Vtweg     = agent_key-Vtweg
*          Vbeln     = agent_key-Vbeln
*          Gjahr     = agent_key-Gjahr
*        ) TO result.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*
*  METHOD CalculateZimco.
*
*  READ ENTITIES OF /EACM/I_PRDO_DOC IN LOCAL MODE
*    ENTITY Agent
*    FIELDS ( ZIMPP ZPCPR )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_agents).
*
*  LOOP AT lt_agents ASSIGNING FIELD-SYMBOL(<agent>).
*
*    IF <agent>-ZPCPR IS NOT INITIAL.
*      <agent>-ZIMCO = <agent>-ZIMPP * <agent>-ZPCPR / 100.
*    ELSE.
*      CLEAR <agent>-ZIMCO.
*    ENDIF.
*
*  ENDLOOP.
*
*  MODIFY ENTITIES OF /EACM/I_PRDO_DOC IN LOCAL MODE
*    ENTITY Agent
*    UPDATE FIELDS ( ZIMCO )
*    WITH VALUE #(
*      FOR ls_agent IN lt_agents
*      (
*        %tky  = ls_agent-%tky
*        ZIMCO = ls_agent-ZIMCO
*      )
*    )
*    FAILED DATA(lt_failed)
*    REPORTED DATA(lt_reported).
*
*ENDMETHOD.
*
*
*
*
*
*
*
*
*
*
*
*ENDCLASS.
***********************************************************************
***********************************************************************
*CLASS lsc_I_PRDO_DOC DEFINITION INHERITING FROM cl_abap_behavior_saver.
*  PROTECTED SECTION.
*
*    METHODS finalize REDEFINITION.
*
*    METHODS check_before_save REDEFINITION.
*
*    METHODS adjust_numbers REDEFINITION.
*
*    METHODS save REDEFINITION.
*
*    METHODS cleanup REDEFINITION.
*
*    METHODS cleanup_finalize REDEFINITION.
*
*ENDCLASS.
*
*CLASS lsc_I_PRDO_DOC IMPLEMENTATION.
*
* METHOD finalize.
*  ENDMETHOD.
*
*  METHOD check_before_save.
*    DATA documents_to_check TYPE STANDARD TABLE OF lcl_buffer=>ty_create_document_key.
*
*    documents_to_check = lcl_buffer=>mt_create_document_key.
*
*    LOOP AT lcl_buffer=>mt_create_position_key INTO DATA(create_position_key).
*      APPEND VALUE #(
*        zclpr = create_position_key-zclpr
*        bukrs = create_position_key-bukrs
*        vkorg = create_position_key-vkorg
*        vtweg = create_position_key-vtweg
*        vbeln = create_position_key-vbeln
*        gjahr = create_position_key-gjahr
*      ) TO documents_to_check.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_create_agent_key INTO DATA(create_agent_key).
*      APPEND VALUE #(
*        zclpr = create_agent_key-zclpr
*        bukrs = create_agent_key-bukrs
*        vkorg = create_agent_key-vkorg
*        vtweg = create_agent_key-vtweg
*        vbeln = create_agent_key-vbeln
*        gjahr = create_agent_key-gjahr
*      ) TO documents_to_check.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_update_position INTO DATA(update_position).
*      APPEND VALUE #(
*        zclpr = update_position-zclpr
*        bukrs = update_position-bukrs
*        vkorg = update_position-vkorg
*        vtweg = update_position-vtweg
*        vbeln = update_position-vbeln
*        gjahr = update_position-gjahr
*      ) TO documents_to_check.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_update_agent INTO DATA(update_agent).
*      APPEND VALUE #(
*        zclpr = update_agent-zclpr
*        bukrs = update_agent-bukrs
*        vkorg = update_agent-vkorg
*        vtweg = update_agent-vtweg
*        vbeln = update_agent-vbeln
*        gjahr = update_agent-gjahr
*      ) TO documents_to_check.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_delete_position INTO DATA(delete_position).
*      APPEND VALUE #(
*        zclpr = delete_position-zclpr
*        bukrs = delete_position-bukrs
*        vkorg = delete_position-vkorg
*        vtweg = delete_position-vtweg
*        vbeln = delete_position-vbeln
*        gjahr = delete_position-gjahr
*      ) TO documents_to_check.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_delete_agent INTO DATA(delete_agent).
*      APPEND VALUE #(
*        zclpr = delete_agent-zclpr
*        bukrs = delete_agent-bukrs
*        vkorg = delete_agent-vkorg
*        vtweg = delete_agent-vtweg
*        vbeln = delete_agent-vbeln
*        gjahr = delete_agent-gjahr
*      ) TO documents_to_check.
*    ENDLOOP.
*
*    SORT documents_to_check BY zclpr bukrs vkorg vtweg vbeln gjahr.
*    DELETE ADJACENT DUPLICATES FROM documents_to_check
*      COMPARING zclpr bukrs vkorg vtweg vbeln gjahr.
*
*    LOOP AT documents_to_check INTO DATA(document_to_check).
*      IF line_exists( lcl_buffer=>mt_delete_document[
*           zclpr = document_to_check-zclpr
*           bukrs = document_to_check-bukrs
*           vkorg = document_to_check-vkorg
*           vtweg = document_to_check-vtweg
*           vbeln = document_to_check-vbeln
*           gjahr = document_to_check-gjahr ] ).
*        CONTINUE.
*      ENDIF.
*
*      DATA(has_agent) = abap_false.
*
*      LOOP AT lcl_buffer=>mt_create_agent INTO DATA(create_agent)
*        WHERE zclpr = document_to_check-zclpr
*          AND bukrs = document_to_check-bukrs
*          AND vkorg = document_to_check-vkorg
*          AND vtweg = document_to_check-vtweg
*          AND vbeln = document_to_check-vbeln
*          AND gjahr = document_to_check-gjahr
*          AND posnr <> '000000'
*          AND zidag IS NOT INITIAL
*          AND zcdaz IS NOT INITIAL.
*        has_agent = abap_true.
*        EXIT.
*      ENDLOOP.
*
*      IF has_agent = abap_false.
*        SELECT SINGLE zidag
*          FROM /EACM/PRDO_AGT_D
*          WHERE zclpr = @document_to_check-zclpr
*            AND bukrs = @document_to_check-bukrs
*            AND vkorg = @document_to_check-vkorg
*            AND vtweg = @document_to_check-vtweg
*            AND vbeln = @document_to_check-vbeln
*            AND gjahr = @document_to_check-gjahr
*            AND posnr <> '000000'
*            AND zidag <> ''
*            AND zcdaz <> ''
*          INTO @DATA(draft_zidag).
*
*        IF sy-subrc = 0.
*          has_agent = abap_true.
*        ENDIF.
*      ENDIF.
*
*      IF has_agent = abap_false.
*        SELECT zclpr,
*               bukrs,
*               vkorg,
*               vtweg,
*               vbeln,
*               gjahr,
*               posnr,
*               zidag,
*               zcdaz
*          FROM /eacm/prdo
*            WHERE zclpr = @document_to_check-zclpr
*              AND bukrs = @document_to_check-bukrs
*              AND vkorg = @document_to_check-vkorg
*              AND vtweg = @document_to_check-vtweg
*              AND vbeln = @document_to_check-vbeln
*              AND gjahr = @document_to_check-gjahr
*              AND posnr <> '000000'
*              AND zidag <> ''
*              AND zcdaz <> ''
*              AND zstre <> 'D'
*              AND zmodi <> 'D'
*          INTO TABLE @DATA(active_agents).
*
*        LOOP AT active_agents INTO DATA(active_agent).          "#EC CI_NOORDER
*          IF line_exists( lcl_buffer=>mt_delete_position[
*               zclpr = active_agent-zclpr
*               bukrs = active_agent-bukrs
*               vkorg = active_agent-vkorg
*               vtweg = active_agent-vtweg
*               vbeln = active_agent-vbeln
*               gjahr = active_agent-gjahr
*               posnr = active_agent-posnr ] ).
*            CONTINUE.
*          ENDIF.
*
*          IF line_exists( lcl_buffer=>mt_delete_agent[
*               zclpr = active_agent-zclpr
*               bukrs = active_agent-bukrs
*               vkorg = active_agent-vkorg
*               vtweg = active_agent-vtweg
*               vbeln = active_agent-vbeln
*               gjahr = active_agent-gjahr
*               posnr = active_agent-posnr
*               zidag = active_agent-zidag
*               zcdaz = active_agent-zcdaz ] ).
*            CONTINUE.
*          ENDIF.
*
*          has_agent = abap_true.
*          EXIT.                                           "#EC CI_NOORDER
*        ENDLOOP.                                          "#EC CI_NOORDER
*      ENDIF.
*
*      IF has_agent = abap_false.
*        APPEND VALUE #(
*          %pid  = document_to_check-pid
*          Zclpr = document_to_check-zclpr
*          Bukrs = document_to_check-bukrs
*          Vkorg = document_to_check-vkorg
*          Vtweg = document_to_check-vtweg
*          Vbeln = document_to_check-vbeln
*          Gjahr = document_to_check-gjahr
*        ) TO failed-document.
*
*        APPEND VALUE #(
*          %pid  = document_to_check-pid
*          Zclpr = document_to_check-zclpr
*          Bukrs = document_to_check-bukrs
*          Vkorg = document_to_check-vkorg
*          Vtweg = document_to_check-vtweg
*          Vbeln = document_to_check-vbeln
*          Gjahr = document_to_check-gjahr
*          %msg  = new_message_with_text(
*            severity = if_abap_behv_message=>severity-error
*            text     = 'Inserire almeno un agente prima del salvataggio.' )
*        ) TO reported-document.
*      ENDIF.
*
*      DATA(document_currency) = VALUE /eacm/prdo-zwaer( ).
*      DATA(document_date) = VALUE /eacm/prdo-fkdat( ).
*      DATA(has_currency_conflict) = abap_false.
*      DATA(has_date_conflict) = abap_false.
*      DATA(has_document_date_update) = abap_false.
*
*      LOOP AT lcl_buffer=>mt_create_position INTO DATA(create_position_currency)
*        WHERE zclpr = document_to_check-zclpr
*          AND bukrs = document_to_check-bukrs
*          AND vkorg = document_to_check-vkorg
*          AND vtweg = document_to_check-vtweg
*          AND vbeln = document_to_check-vbeln
*          AND gjahr = document_to_check-gjahr.
*        IF create_position_currency-waerk IS NOT INITIAL.
*          IF document_currency IS INITIAL.
*            document_currency = create_position_currency-waerk.
*          ELSEIF document_currency <> create_position_currency-waerk.
*            has_currency_conflict = abap_true.
*          ENDIF.
*        ENDIF.
*
*        IF create_position_currency-fkdat IS NOT INITIAL.
*          IF document_date IS INITIAL.
*            document_date = create_position_currency-fkdat.
*          ELSEIF document_date <> create_position_currency-fkdat.
*            has_date_conflict = abap_true.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*
*      LOOP AT lcl_buffer=>mt_create_agent INTO DATA(create_agent_check)
*        WHERE zclpr = document_to_check-zclpr
*          AND bukrs = document_to_check-bukrs
*          AND vkorg = document_to_check-vkorg
*          AND vtweg = document_to_check-vtweg
*          AND vbeln = document_to_check-vbeln
*          AND gjahr = document_to_check-gjahr.
*        IF create_agent_check-zwaer IS NOT INITIAL.
*          IF document_currency IS INITIAL.
*            document_currency = create_agent_check-zwaer.
*          ELSEIF document_currency <> create_agent_check-zwaer.
*            has_currency_conflict = abap_true.
*          ENDIF.
*        ENDIF.
*
*        IF create_agent_check-fkdat IS NOT INITIAL.
*          IF document_date IS INITIAL.
*            document_date = create_agent_check-fkdat.
*          ELSEIF document_date <> create_agent_check-fkdat.
*            has_date_conflict = abap_true.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*
*      LOOP AT lcl_buffer=>mt_update_position INTO DATA(update_position_currency)
*        WHERE zclpr = document_to_check-zclpr
*          AND bukrs = document_to_check-bukrs
*          AND vkorg = document_to_check-vkorg
*          AND vtweg = document_to_check-vtweg
*          AND vbeln = document_to_check-vbeln
*          AND gjahr = document_to_check-gjahr.
*        IF update_position_currency-waerk IS NOT INITIAL.
*          IF document_currency IS INITIAL.
*            document_currency = update_position_currency-waerk.
*          ELSEIF document_currency <> update_position_currency-waerk.
*            has_currency_conflict = abap_true.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*
*      LOOP AT lcl_buffer=>mt_create_document_key INTO DATA(create_document_date)
*        WHERE zclpr = document_to_check-zclpr
*          AND bukrs = document_to_check-bukrs
*          AND vkorg = document_to_check-vkorg
*          AND vtweg = document_to_check-vtweg
*          AND vbeln = document_to_check-vbeln
*          AND gjahr = document_to_check-gjahr.
*        IF create_document_date-fkdat IS NOT INITIAL.
*          IF document_date IS INITIAL.
*            document_date = create_document_date-fkdat.
*          ELSEIF document_date <> create_document_date-fkdat.
*            has_date_conflict = abap_true.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*
*      LOOP AT lcl_buffer=>mt_update_document INTO DATA(update_document_date)
*        WHERE zclpr = document_to_check-zclpr
*          AND bukrs = document_to_check-bukrs
*          AND vkorg = document_to_check-vkorg
*          AND vtweg = document_to_check-vtweg
*          AND vbeln = document_to_check-vbeln
*          AND gjahr = document_to_check-gjahr.
*        has_document_date_update = abap_true.
*
*        IF update_document_date-fkdat IS NOT INITIAL.
*          IF document_date IS INITIAL.
*            document_date = update_document_date-fkdat.
*          ELSEIF document_date <> update_document_date-fkdat.
*            has_date_conflict = abap_true.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*
*      SELECT posnr,
*             zidag,
*             zcdaz,
*             fkdat,
*             zwaer
*        FROM /eacm/prdo
*        WHERE zclpr = @document_to_check-zclpr
*          AND bukrs = @document_to_check-bukrs
*          AND vkorg = @document_to_check-vkorg
*          AND vtweg = @document_to_check-vtweg
*          AND vbeln = @document_to_check-vbeln
*          AND gjahr = @document_to_check-gjahr
*          AND posnr <> '000000'
*          AND zstre <> 'D'
*          AND zmodi <> 'D'
*        INTO TABLE @DATA(document_active_rows).
*
*      LOOP AT document_active_rows INTO DATA(document_active_row).
*        IF line_exists( lcl_buffer=>mt_delete_position[
*             zclpr = document_to_check-zclpr
*             bukrs = document_to_check-bukrs
*             vkorg = document_to_check-vkorg
*             vtweg = document_to_check-vtweg
*             vbeln = document_to_check-vbeln
*             gjahr = document_to_check-gjahr
*             posnr = document_active_row-posnr ] )
*          OR line_exists( lcl_buffer=>mt_delete_agent[
*             zclpr = document_to_check-zclpr
*             bukrs = document_to_check-bukrs
*             vkorg = document_to_check-vkorg
*             vtweg = document_to_check-vtweg
*             vbeln = document_to_check-vbeln
*             gjahr = document_to_check-gjahr
*             posnr = document_active_row-posnr
*             zidag = document_active_row-zidag
*             zcdaz = document_active_row-zcdaz ] ).
*          CONTINUE.
*        ENDIF.
*
*        IF NOT line_exists( lcl_buffer=>mt_update_position[
*             zclpr = document_to_check-zclpr
*             bukrs = document_to_check-bukrs
*             vkorg = document_to_check-vkorg
*             vtweg = document_to_check-vtweg
*             vbeln = document_to_check-vbeln
*             gjahr = document_to_check-gjahr
*             posnr = document_active_row-posnr ] )
*          AND document_active_row-zwaer IS NOT INITIAL.
*          IF document_currency IS INITIAL.
*            document_currency = document_active_row-zwaer.
*          ELSEIF document_currency <> document_active_row-zwaer.
*            has_currency_conflict = abap_true.
*          ENDIF.
*        ENDIF.
*
*        IF has_document_date_update = abap_false
*          AND document_active_row-fkdat IS NOT INITIAL.
*          IF document_date IS INITIAL.
*            document_date = document_active_row-fkdat.
*          ELSEIF document_date <> document_active_row-fkdat.
*            has_date_conflict = abap_true.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*
*      IF has_currency_conflict = abap_true
*        OR has_date_conflict = abap_true.
*        APPEND VALUE #(
*          %pid  = document_to_check-pid
*          Zclpr = document_to_check-zclpr
*          Bukrs = document_to_check-bukrs
*          Vkorg = document_to_check-vkorg
*          Vtweg = document_to_check-vtweg
*          Vbeln = document_to_check-vbeln
*          Gjahr = document_to_check-gjahr
*        ) TO failed-document.
*      ENDIF.
*
*      IF has_currency_conflict = abap_true.
*        APPEND VALUE #(
*          %pid  = document_to_check-pid
*          Zclpr = document_to_check-zclpr
*          Bukrs = document_to_check-bukrs
*          Vkorg = document_to_check-vkorg
*          Vtweg = document_to_check-vtweg
*          Vbeln = document_to_check-vbeln
*          Gjahr = document_to_check-gjahr
*          %msg  = new_message_with_text(
*            severity = if_abap_behv_message=>severity-error
*            text     = 'Il documento non puo contenere piu valute. Allineare WAERK/ZWAER.' )
*        ) TO reported-document.
*      ENDIF.
*
*      IF has_date_conflict = abap_true.
*        APPEND VALUE #(
*          %pid           = document_to_check-pid
*          Zclpr          = document_to_check-zclpr
*          Bukrs          = document_to_check-bukrs
*          Vkorg          = document_to_check-vkorg
*          Vtweg          = document_to_check-vtweg
*          Vbeln          = document_to_check-vbeln
*          Gjahr          = document_to_check-gjahr
*          %element-Fkdat = if_abap_behv=>mk-on
*          %msg           = new_message_with_text(
*            severity = if_abap_behv_message=>severity-error
*            text     = 'Il documento non puo contenere date documento diverse.' )
*        ) TO reported-document.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD adjust_numbers.
*    DATA mapped_documents LIKE mapped-document.
*    DATA mapped_positions LIKE mapped-position.
*    DATA mapped_agents    LIKE mapped-agent.
*    DATA document_keys TYPE STANDARD TABLE OF lcl_buffer=>ty_create_document_key.
*    DATA position_keys TYPE STANDARD TABLE OF lcl_buffer=>ty_create_position_key.
*    DATA agent_keys    TYPE STANDARD TABLE OF lcl_buffer=>ty_create_agent_key.
*    DATA lv_number TYPE cl_numberrange_runtime=>nr_number.
*    DATA lv_vbeln  TYPE vbeln.
*    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
*    DATA(lv_gjahr) = CONV gjahr( lv_today+0(4) ).
*
*    mapped_documents = mapped-document.
*    mapped_positions = mapped-position.
*    mapped_agents = mapped-agent.
*    document_keys = lcl_buffer=>mt_create_document_key.
*    position_keys = lcl_buffer=>mt_create_position_key.
*    agent_keys = lcl_buffer=>mt_create_agent_key.
*    CLEAR mapped-document.
*    CLEAR mapped-position.
*    CLEAR mapped-agent.
*    CLEAR lcl_buffer=>mt_document_key_map.
*
*    IF document_keys IS INITIAL.
*      LOOP AT mapped_documents INTO DATA(mapped_document).
*        APPEND VALUE #(
*          pid   = mapped_document-%pid
*          zclpr = mapped_document-%tmp-Zclpr
*          bukrs = mapped_document-%tmp-Bukrs
*          vkorg = mapped_document-%tmp-Vkorg
*          vtweg = mapped_document-%tmp-Vtweg
*          vbeln = mapped_document-%tmp-Vbeln
*          gjahr = mapped_document-%tmp-Gjahr
*        ) TO document_keys.
*      ENDLOOP.
*    ENDIF.
*
*    IF position_keys IS INITIAL.
*      LOOP AT mapped_positions INTO DATA(mapped_position).
*        APPEND VALUE #(
*          pid   = mapped_position-%pid
*          zclpr = mapped_position-%tmp-Zclpr
*          bukrs = mapped_position-%tmp-Bukrs
*          vkorg = mapped_position-%tmp-Vkorg
*          vtweg = mapped_position-%tmp-Vtweg
*          vbeln = mapped_position-%tmp-Vbeln
*          gjahr = mapped_position-%tmp-Gjahr
*          posnr = mapped_position-%tmp-Posnr
*        ) TO position_keys.
*      ENDLOOP.
*    ENDIF.
*
*    IF agent_keys IS INITIAL.
*      LOOP AT mapped_agents INTO DATA(mapped_agent).
*        APPEND VALUE #(
*          pid   = mapped_agent-%pid
*          zclpr = mapped_agent-%tmp-Zclpr
*          bukrs = mapped_agent-%tmp-Bukrs
*          vkorg = mapped_agent-%tmp-Vkorg
*          vtweg = mapped_agent-%tmp-Vtweg
*          vbeln = mapped_agent-%tmp-Vbeln
*          gjahr = mapped_agent-%tmp-Gjahr
*          posnr = mapped_agent-%tmp-Posnr
*          zidag = mapped_agent-%tmp-Zidag
*          zcdaz = mapped_agent-%tmp-Zcdaz
*        ) TO agent_keys.
*      ENDLOOP.
*    ENDIF.
*
*    LOOP AT document_keys INTO DATA(document_key).
*      DATA(lv_final_gjahr) = COND gjahr(
*        WHEN document_key-gjahr IS INITIAL THEN lv_gjahr
*        ELSE document_key-gjahr ).
*
*      IF document_key-vbeln IS NOT INITIAL
*        AND document_key-vbeln(1) <> 'D'.
*        lv_vbeln = |{ document_key-vbeln ALPHA = IN }|.
*      ELSE.
*        TRY.
*            cl_numberrange_runtime=>number_get(
*              EXPORTING
*                object      = '/EACM/PRVG'
*                nr_range_nr = '01'
*              IMPORTING
*                number      = lv_number
*            ).
*
*            DATA(lv_number_text) = CONV string( lv_number ).
*            CONDENSE lv_number_text NO-GAPS.
*
*            DATA(lv_number_length) = strlen( lv_number_text ).
*            IF lv_number_length > 10.
*              DATA(lv_offset) = lv_number_length - 10.
*              lv_number_text = substring( val = lv_number_text off = lv_offset len = 10 ).
*            ENDIF.
*
*            lv_vbeln = lv_number_text.
*            lv_vbeln = |{ lv_vbeln ALPHA = IN }|.
*
*          CATCH cx_number_ranges INTO DATA(number_error).
*            APPEND VALUE #(
*              %msg = new_message_with_text(
*                severity = if_abap_behv_message=>severity-error
*                text     = number_error->get_text( ) )
*            ) TO reported-document.
*            CONTINUE.
*        ENDTRY.
*      ENDIF.
*
*      APPEND VALUE #(
*        %pre-%pid       = document_key-pid
*        %pre-%tmp-Zclpr = document_key-zclpr
*        %pre-%tmp-Bukrs = document_key-bukrs
*        %pre-%tmp-Vkorg = document_key-vkorg
*        %pre-%tmp-Vtweg = document_key-vtweg
*        %pre-%tmp-Vbeln = document_key-vbeln
*        %pre-%tmp-Gjahr = document_key-gjahr
*        %key-Zclpr      = document_key-zclpr
*        %key-Bukrs      = document_key-bukrs
*        %key-Vkorg      = document_key-vkorg
*        %key-Vtweg      = document_key-vtweg
*        %key-Vbeln      = lv_vbeln
*        %key-Gjahr      = lv_final_gjahr
*      ) TO mapped-document.
*
*      APPEND VALUE #(
*        zclpr     = document_key-zclpr
*        bukrs     = document_key-bukrs
*        vkorg     = document_key-vkorg
*        vtweg     = document_key-vtweg
*        old_vbeln = document_key-vbeln
*        old_gjahr = document_key-gjahr
*        new_vbeln = lv_vbeln
*        new_gjahr = lv_final_gjahr
*      ) TO lcl_buffer=>mt_document_key_map.
*    ENDLOOP.
*
*    LOOP AT position_keys INTO DATA(position_key).
*      READ TABLE lcl_buffer=>mt_document_key_map INTO DATA(position_key_map)
*        WITH KEY zclpr     = position_key-zclpr
*                 bukrs     = position_key-bukrs
*                 vkorg     = position_key-vkorg
*                 vtweg     = position_key-vtweg
*                 old_vbeln = position_key-vbeln
*                 old_gjahr = position_key-gjahr.
*
*      DATA(position_vbeln) = COND vbeln(
*        WHEN sy-subrc = 0 THEN position_key_map-new_vbeln
*        ELSE position_key-vbeln ).
*      DATA(position_gjahr) = COND gjahr(
*        WHEN sy-subrc = 0 THEN position_key_map-new_gjahr
*        ELSE position_key-gjahr ).
*
*      APPEND VALUE #(
*        %pre-%pid       = position_key-pid
*        %pre-%tmp-Zclpr = position_key-zclpr
*        %pre-%tmp-Bukrs = position_key-bukrs
*        %pre-%tmp-Vkorg = position_key-vkorg
*        %pre-%tmp-Vtweg = position_key-vtweg
*        %pre-%tmp-Vbeln = position_key-vbeln
*        %pre-%tmp-Gjahr = position_key-gjahr
*        %pre-%tmp-Posnr = position_key-posnr
*        %key-Zclpr      = position_key-zclpr
*        %key-Bukrs      = position_key-bukrs
*        %key-Vkorg      = position_key-vkorg
*        %key-Vtweg      = position_key-vtweg
*        %key-Vbeln      = position_vbeln
*        %key-Gjahr      = position_gjahr
*        %key-Posnr      = position_key-posnr
*      ) TO mapped-position.
*    ENDLOOP.
*
*    LOOP AT agent_keys INTO DATA(agent_key).
*      READ TABLE lcl_buffer=>mt_document_key_map INTO DATA(agent_key_map)
*        WITH KEY zclpr     = agent_key-zclpr
*                 bukrs     = agent_key-bukrs
*                 vkorg     = agent_key-vkorg
*                 vtweg     = agent_key-vtweg
*                 old_vbeln = agent_key-vbeln
*                 old_gjahr = agent_key-gjahr.
*
*      DATA(agent_vbeln) = COND vbeln(
*        WHEN sy-subrc = 0 THEN agent_key_map-new_vbeln
*        ELSE agent_key-vbeln ).
*      DATA(agent_gjahr) = COND gjahr(
*        WHEN sy-subrc = 0 THEN agent_key_map-new_gjahr
*        ELSE agent_key-gjahr ).
*
*      APPEND VALUE #(
*        %pre-%pid       = agent_key-pid
*        %pre-%tmp-Zclpr = agent_key-zclpr
*        %pre-%tmp-Bukrs = agent_key-bukrs
*        %pre-%tmp-Vkorg = agent_key-vkorg
*        %pre-%tmp-Vtweg = agent_key-vtweg
*        %pre-%tmp-Vbeln = agent_key-vbeln
*        %pre-%tmp-Gjahr = agent_key-gjahr
*        %pre-%tmp-Posnr = agent_key-posnr
*        %pre-%tmp-Zidag = agent_key-zidag
*        %pre-%tmp-Zcdaz = agent_key-zcdaz
*        %key-Zclpr      = agent_key-zclpr
*        %key-Bukrs      = agent_key-bukrs
*        %key-Vkorg      = agent_key-vkorg
*        %key-Vtweg      = agent_key-vtweg
*        %key-Vbeln      = agent_vbeln
*        %key-Gjahr      = agent_gjahr
*        %key-Posnr      = agent_key-posnr
*        %key-Zidag      = agent_key-zidag
*        %key-Zcdaz      = agent_key-zcdaz
*      ) TO mapped-agent.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD save.
*    GET TIME STAMP FIELD DATA(now).
*    DATA system_time TYPE syuzeit.
**    GET TIME FIELD system_time.
*    DATA(system_date) = cl_abap_context_info=>get_system_date( ).
*    DATA(user_name) = cl_abap_context_info=>get_user_technical_name( ).
*
*    LOOP AT lcl_buffer=>mt_document_key_map INTO DATA(key_map).
*      LOOP AT lcl_buffer=>mt_create_position ASSIGNING FIELD-SYMBOL(<create_position>)
*        WHERE zclpr = key_map-zclpr
*          AND bukrs = key_map-bukrs
*          AND vkorg = key_map-vkorg
*          AND vtweg = key_map-vtweg
*          AND vbeln = key_map-old_vbeln
*          AND gjahr = key_map-old_gjahr.
*        <create_position>-vbeln = key_map-new_vbeln.
*        <create_position>-gjahr = key_map-new_gjahr.
*      ENDLOOP.
*
*      LOOP AT lcl_buffer=>mt_create_agent ASSIGNING FIELD-SYMBOL(<create_agent>)
*        WHERE zclpr = key_map-zclpr
*          AND bukrs = key_map-bukrs
*          AND vkorg = key_map-vkorg
*          AND vtweg = key_map-vtweg
*          AND vbeln = key_map-old_vbeln
*          AND gjahr = key_map-old_gjahr.
*        <create_agent>-vbeln = key_map-new_vbeln.
*        <create_agent>-gjahr = key_map-new_gjahr.
*      ENDLOOP.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_create_document_key INTO DATA(create_document_key)
*      WHERE fkdat IS NOT INITIAL.
*      DATA(create_document_vbeln) = create_document_key-vbeln.
*      DATA(create_document_gjahr) = create_document_key-gjahr.
*
*      READ TABLE lcl_buffer=>mt_document_key_map INTO DATA(create_document_key_map)
*        WITH KEY zclpr     = create_document_key-zclpr
*                 bukrs     = create_document_key-bukrs
*                 vkorg     = create_document_key-vkorg
*                 vtweg     = create_document_key-vtweg
*                 old_vbeln = create_document_key-vbeln
*                 old_gjahr = create_document_key-gjahr.
*
*      IF sy-subrc = 0.
*        create_document_vbeln = create_document_key_map-new_vbeln.
*        create_document_gjahr = create_document_key_map-new_gjahr.
*      ENDIF.
*
*      LOOP AT lcl_buffer=>mt_create_position ASSIGNING FIELD-SYMBOL(<create_position_date>)
*        WHERE zclpr = create_document_key-zclpr
*          AND bukrs = create_document_key-bukrs
*          AND vkorg = create_document_key-vkorg
*          AND vtweg = create_document_key-vtweg
*          AND vbeln = create_document_vbeln
*          AND gjahr = create_document_gjahr.
*        <create_position_date>-fkdat = create_document_key-fkdat.
*      ENDLOOP.
*
*      LOOP AT lcl_buffer=>mt_create_agent ASSIGNING FIELD-SYMBOL(<create_agent_date>)
*        WHERE zclpr = create_document_key-zclpr
*          AND bukrs = create_document_key-bukrs
*          AND vkorg = create_document_key-vkorg
*          AND vtweg = create_document_key-vtweg
*          AND vbeln = create_document_vbeln
*          AND gjahr = create_document_gjahr.
*        <create_agent_date>-fkdat = create_document_key-fkdat.
*      ENDLOOP.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_create_agent INTO DATA(create_agent).
*      IF create_agent-posnr IS INITIAL
*        OR create_agent-posnr = '000000'
*        OR create_agent-zidag IS INITIAL
*        OR create_agent-zcdaz IS INITIAL.
*        CONTINUE.
*      ENDIF.
*
*      IF create_agent-created_by IS INITIAL.
*        create_agent-created_by = user_name.
*      ENDIF.
*
*      IF create_agent-created_at IS INITIAL.
*        create_agent-created_at = now.
*      ENDIF.
*
*      create_agent-changed_by = user_name.
*      create_agent-changed_at = now.
*      create_agent-local_last_changed_at = now.
*      create_agent-zstre = space.
*      create_agent-zmodi = space.
*
*      IF create_agent-zaucr IS INITIAL.
*        create_agent-zaucr = user_name.
*      ENDIF.
*
*      IF create_agent-zdtcr IS INITIAL.
*        create_agent-zdtcr = system_date.
*      ENDIF.
*
*      IF create_agent-zorcr IS INITIAL.
*        create_agent-zorcr = system_time.
*      ENDIF.
*
*      MODIFY /eacm/prdo FROM @create_agent.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_update_position INTO DATA(update_position).
*      UPDATE /eacm/prdo SET
*        matnr = @update_position-matnr,
*        maktx = @update_position-maktx,
*        waerk = @update_position-waerk,
*        zwaer = @update_position-waerk,
*        menge = @update_position-menge,
*        changed_by = @user_name,
*        changed_at = @now,
*        local_last_changed_at = @now
*      WHERE zclpr = @update_position-zclpr
*        AND bukrs = @update_position-bukrs
*        AND vkorg = @update_position-vkorg
*        AND vtweg = @update_position-vtweg
*        AND vbeln = @update_position-vbeln
*        AND gjahr = @update_position-gjahr
*        AND posnr = @update_position-posnr
*        AND zstre <> 'D'
*        AND zmodi <> 'D'.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_update_agent INTO DATA(update_agent).
*      SELECT SINGLE *
*        FROM /eacm/prdo
*        WHERE zclpr = @update_agent-zclpr
*          AND bukrs = @update_agent-bukrs
*          AND vkorg = @update_agent-vkorg
*          AND vtweg = @update_agent-vtweg
*          AND vbeln = @update_agent-vbeln
*          AND gjahr = @update_agent-gjahr
*          AND posnr = @update_agent-posnr
*          AND zidag = @update_agent-zidag
*          AND zcdaz = @update_agent-zcdaz
*          AND zstre <> 'D'
*          AND zmodi <> 'D'
*        INTO @DATA(current_agent).
*
*      IF sy-subrc <> 0.
*        CONTINUE.
*      ENDIF.
*
*      UPDATE /eacm/prdo SET
*        zmodi = 'D',
*        zstre = 'D',
*        zcamd = @user_name,
*        zdtmd = @system_date,
*        zormd = @system_time,
*        changed_by = @user_name,
*        changed_at = @now,
*        local_last_changed_at = @now
*      WHERE zclpr = @update_agent-zclpr
*        AND bukrs = @update_agent-bukrs
*        AND vkorg = @update_agent-vkorg
*        AND vtweg = @update_agent-vtweg
*        AND vbeln = @update_agent-vbeln
*        AND gjahr = @update_agent-gjahr
*        AND posnr = @update_agent-posnr
*        AND zidag = @update_agent-zidag
*        AND zcdaz = @update_agent-zcdaz.
*
*      SELECT MAX( zidag )
*        FROM /eacm/prdo
*        WHERE zclpr = @update_agent-zclpr
*          AND bukrs = @update_agent-bukrs
*          AND vkorg = @update_agent-vkorg
*          AND vtweg = @update_agent-vtweg
*          AND vbeln = @update_agent-vbeln
*          AND gjahr = @update_agent-gjahr
*          AND posnr = @update_agent-posnr
*          AND zcdaz = @update_agent-zcdaz
*        INTO @DATA(max_update_zidag).
*
*      DATA(new_update_agent) = current_agent.
*      DATA(new_zidag_number) = CONV i( max_update_zidag ) + 1.
*      new_update_agent-zidag = CONV /eacm/zidag( |{ new_zidag_number WIDTH = 4 PAD = '0' ALIGN = RIGHT }| ).
*      new_update_agent-ziman = update_agent-ziman.
*      new_update_agent-zimar = update_agent-zimar.
*      new_update_agent-zpcpr = update_agent-zpcpr.
*      new_update_agent-zimpp = update_agent-zimpp.
*      new_update_agent-zimco = update_agent-zimco.
*      IF update_agent-zpcpr IS NOT INITIAL.
*        CLEAR new_update_agent-zimpu.
*      ELSEIF update_agent-zimpu IS NOT INITIAL.
*        new_update_agent-zimpu = update_agent-zimpu.
*      ENDIF.
*      IF update_agent-zwaer IS NOT INITIAL.
*        new_update_agent-zwaer = update_agent-zwaer.
*      ENDIF.
*      new_update_agent-kunrg = update_agent-kunrg.
*      IF update_agent-budat IS NOT INITIAL.
*        new_update_agent-budat = update_agent-budat.
*      ENDIF.
*      IF update_agent-kurrf IS NOT INITIAL.
*        new_update_agent-kurrf = update_agent-kurrf.
*      ENDIF.
*      IF update_agent-ztpag IS NOT INITIAL.
*        new_update_agent-ztpag = update_agent-ztpag.
*      ENDIF.
*      new_update_agent-zdest = update_agent-zdest.
*      new_update_agent-zmodi = 'M'.
*      new_update_agent-zstre = space.
*      new_update_agent-zcamd = user_name.
*      new_update_agent-zdtmd = system_date.
*      new_update_agent-zormd = system_time.
*      new_update_agent-changed_by = user_name.
*      new_update_agent-changed_at = now.
*      new_update_agent-local_last_changed_at = now.
*
*      INSERT /eacm/prdo FROM @new_update_agent.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_update_document INTO DATA(update_document).
*      UPDATE /eacm/prdo SET
*        fkdat = @update_document-fkdat,
*        waerk = @update_document-waerk,
*        changed_by = @user_name,
*        changed_at = @now,
*        local_last_changed_at = @now
*      WHERE zclpr = @update_document-zclpr
*        AND bukrs = @update_document-bukrs
*        AND vkorg = @update_document-vkorg
*        AND vtweg = @update_document-vtweg
*        AND vbeln = @update_document-vbeln
*        AND gjahr = @update_document-gjahr
*        AND posnr <> '000000'
*        AND zstre <> 'D'
*        AND zmodi <> 'D'.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_delete_agent INTO DATA(delete_agent).
*      UPDATE /eacm/prdo SET
*        zmodi = 'D',
*        zstre = 'D',
*        zcamd = @user_name,
*        zdtmd = @system_date,
*        zormd = @system_time,
*        changed_by = @user_name,
*        changed_at = @now,
*        local_last_changed_at = @now
*      WHERE zclpr = @delete_agent-zclpr
*        AND bukrs = @delete_agent-bukrs
*        AND vkorg = @delete_agent-vkorg
*        AND vtweg = @delete_agent-vtweg
*        AND vbeln = @delete_agent-vbeln
*        AND gjahr = @delete_agent-gjahr
*        AND posnr = @delete_agent-posnr
*        AND zidag = @delete_agent-zidag
*        AND zcdaz = @delete_agent-zcdaz
*        AND zstre <> 'D'
*        AND zmodi <> 'D'.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_delete_position INTO DATA(delete_position).
*      UPDATE /eacm/prdo SET
*        zmodi = 'D',
*        zstre = 'D',
*        zcamd = @user_name,
*        zdtmd = @system_date,
*        zormd = @system_time,
*        changed_by = @user_name,
*        changed_at = @now,
*        local_last_changed_at = @now
*      WHERE zclpr = @delete_position-zclpr
*        AND bukrs = @delete_position-bukrs
*        AND vkorg = @delete_position-vkorg
*        AND vtweg = @delete_position-vtweg
*        AND vbeln = @delete_position-vbeln
*        AND gjahr = @delete_position-gjahr
*        AND posnr = @delete_position-posnr
*        AND zstre <> 'D'
*        AND zmodi <> 'D'.
*    ENDLOOP.
*
*    LOOP AT lcl_buffer=>mt_delete_document INTO DATA(delete_document).
*      UPDATE /eacm/prdo SET
*        zmodi = 'D',
*        zstre = 'D',
*        zcamd = @user_name,
*        zdtmd = @system_date,
*        zormd = @system_time,
*        changed_by = @user_name,
*        changed_at = @now,
*        local_last_changed_at = @now
*      WHERE zclpr = @delete_document-zclpr
*        AND bukrs = @delete_document-bukrs
*        AND vkorg = @delete_document-vkorg
*        AND vtweg = @delete_document-vtweg
*        AND vbeln = @delete_document-vbeln
*        AND gjahr = @delete_document-gjahr
*        AND zstre <> 'D'
*        AND zmodi <> 'D'.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD cleanup.
*    CLEAR lcl_buffer=>mt_create_document_key.
*    CLEAR lcl_buffer=>mt_create_position_key.
*    CLEAR lcl_buffer=>mt_create_agent_key.
*    CLEAR lcl_buffer=>mt_create_position.
*    CLEAR lcl_buffer=>mt_create_agent.
*    CLEAR lcl_buffer=>mt_update_document.
*    CLEAR lcl_buffer=>mt_update_position.
*    CLEAR lcl_buffer=>mt_update_agent.
*    CLEAR lcl_buffer=>mt_delete_document.
*    CLEAR lcl_buffer=>mt_delete_position.
*    CLEAR lcl_buffer=>mt_delete_agent.
*    CLEAR lcl_buffer=>mt_document_key_map.
*  ENDMETHOD.
*
*  METHOD cleanup_finalize.
*    CLEAR lcl_buffer=>mt_create_document_key.
*    CLEAR lcl_buffer=>mt_create_position_key.
*    CLEAR lcl_buffer=>mt_create_agent_key.
*    CLEAR lcl_buffer=>mt_create_position.
*    CLEAR lcl_buffer=>mt_create_agent.
*    CLEAR lcl_buffer=>mt_update_document.
*    CLEAR lcl_buffer=>mt_update_position.
*    CLEAR lcl_buffer=>mt_update_agent.
*    CLEAR lcl_buffer=>mt_delete_document.
*    CLEAR lcl_buffer=>mt_delete_position.
*    CLEAR lcl_buffer=>mt_delete_agent.
*    CLEAR lcl_buffer=>mt_document_key_map.
*  ENDMETHOD.
*
*ENDCLASS.

CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_document_key_map,
             zclpr     TYPE /eacm/prdo-zclpr,
             bukrs     TYPE /eacm/prdo-bukrs,
             vkorg     TYPE /eacm/prdo-vkorg,
             vtweg     TYPE /eacm/prdo-vtweg,
             old_vbeln TYPE /eacm/prdo-vbeln,
             old_gjahr TYPE /eacm/prdo-gjahr,
             new_vbeln TYPE /eacm/prdo-vbeln,
             new_gjahr TYPE /eacm/prdo-gjahr,
           END OF ty_document_key_map.

    TYPES: BEGIN OF ty_create_document_key,
             pid   TYPE sysuuid_x16,
             zclpr TYPE /eacm/prdo-zclpr,
             bukrs TYPE /eacm/prdo-bukrs,
             vkorg TYPE /eacm/prdo-vkorg,
             vtweg TYPE /eacm/prdo-vtweg,
             vbeln TYPE /eacm/prdo-vbeln,
             gjahr TYPE /eacm/prdo-gjahr,
             kunrg TYPE /eacm/prdo-kunrg,
             fkdat TYPE /eacm/prdo-fkdat,
             waerk TYPE /eacm/prdo-waerk,
           END OF ty_create_document_key.

    TYPES: BEGIN OF ty_create_position_key,
             pid   TYPE sysuuid_x16,
             zclpr TYPE /eacm/prdo-zclpr,
             bukrs TYPE /eacm/prdo-bukrs,
             vkorg TYPE /eacm/prdo-vkorg,
             vtweg TYPE /eacm/prdo-vtweg,
             vbeln TYPE /eacm/prdo-vbeln,
             gjahr TYPE /eacm/prdo-gjahr,
             posnr TYPE /eacm/prdo-posnr,
           END OF ty_create_position_key.

    TYPES: BEGIN OF ty_create_agent_key,
             pid   TYPE sysuuid_x16,
             zclpr TYPE /eacm/prdo-zclpr,
             bukrs TYPE /eacm/prdo-bukrs,
             vkorg TYPE /eacm/prdo-vkorg,
             vtweg TYPE /eacm/prdo-vtweg,
             vbeln TYPE /eacm/prdo-vbeln,
             gjahr TYPE /eacm/prdo-gjahr,
             posnr TYPE /eacm/prdo-posnr,
             zidag TYPE /eacm/prdo-zidag,
             zcdaz TYPE /eacm/prdo-zcdaz,
           END OF ty_create_agent_key.

    CLASS-DATA mt_create_document_key TYPE STANDARD TABLE OF ty_create_document_key.
    CLASS-DATA mt_create_position_key TYPE STANDARD TABLE OF ty_create_position_key.
    CLASS-DATA mt_create_agent_key    TYPE STANDARD TABLE OF ty_create_agent_key.
    CLASS-DATA mt_create_position TYPE STANDARD TABLE OF /eacm/prdo.
    CLASS-DATA mt_create_agent    TYPE STANDARD TABLE OF /eacm/prdo.
    CLASS-DATA mt_update_document TYPE STANDARD TABLE OF /eacm/prdo.
    CLASS-DATA mt_update_position TYPE STANDARD TABLE OF /eacm/prdo.
    CLASS-DATA mt_update_agent    TYPE STANDARD TABLE OF /eacm/prdo.
    CLASS-DATA mt_delete_document TYPE STANDARD TABLE OF /eacm/prdo.
    CLASS-DATA mt_delete_position TYPE STANDARD TABLE OF /eacm/prdo.
    CLASS-DATA mt_delete_agent    TYPE STANDARD TABLE OF /eacm/prdo.
    CLASS-DATA mt_document_key_map TYPE STANDARD TABLE OF ty_document_key_map.
ENDCLASS.
**********************************************************************
**********************************************************************
CLASS lhc_Document DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Document RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Document.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE Document.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Document.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Document.

    METHODS read FOR READ
      IMPORTING keys FOR READ Document RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Document.

    METHODS rba_Positions FOR READ
      IMPORTING keys_rba FOR READ Document\_Positions FULL result_requested RESULT result LINK association_links.

    METHODS cba_Positions FOR MODIFY
      IMPORTING entities_cba FOR CREATE Document\_Positions.

ENDCLASS.
****
 CLASS lhc_Document IMPLEMENTATION.
  METHOD get_instance_authorizations.
    result = VALUE #( FOR key IN keys
      (
        %tky    = key-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed
      ) ).
  ENDMETHOD.

  METHOD precheck_create.
    LOOP AT entities INTO DATA(document).
      DATA(zclpr_upper) = to_upper( CONV string( document-Zclpr ) ).
      CONDENSE zclpr_upper NO-GAPS.

      IF zclpr_upper = 'SB' AND document-Vbeln IS INITIAL.
        APPEND VALUE #( %cid = document-%cid ) TO failed-document.
        APPEND VALUE #(
          %cid           = document-%cid
          %element-Vbeln = if_abap_behv=>mk-on
          %msg           = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Per Cod.Class.Comm SB, il documento è obbligatorio.' )
        ) TO reported-document.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD create.
    DATA(today) = cl_abap_context_info=>get_system_date( ).
    DATA(default_gjahr) = CONV gjahr( today+0(4) ).

    LOOP AT entities INTO DATA(document).
      DATA(zclpr_upper) = to_upper( CONV string( document-Zclpr ) ).
      CONDENSE zclpr_upper NO-GAPS.

      IF zclpr_upper = 'SB' AND document-Vbeln IS INITIAL.
        APPEND VALUE #( %cid = document-%cid ) TO failed-document.
        APPEND VALUE #(
          %cid           = document-%cid
          %element-Vbeln = if_abap_behv=>mk-on
          %msg           = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Per Cod.Class.Comm SB, il documento è obbligatorio.' )
        ) TO reported-document.
        CONTINUE.
      ENDIF.

      TRY.
          DATA(pid) = cl_system_uuid=>create_uuid_x16_static( ).
          DATA(uuid_c32) = cl_system_uuid=>create_uuid_c32_static( ).
          DATA(preliminary_vbeln) = COND vbeln(
            WHEN document-Vbeln IS INITIAL THEN CONV vbeln( |D{ uuid_c32+0(9) }| )
            ELSE |{ document-Vbeln ALPHA = IN }| ).
          DATA(preliminary_gjahr) = COND gjahr(
            WHEN document-Gjahr IS INITIAL THEN default_gjahr
            ELSE document-Gjahr ).

          APPEND VALUE #(
            %cid = document-%cid
            %pid = pid
            %key = VALUE #(
              BASE document-%key
              Vbeln = preliminary_vbeln
              Gjahr = preliminary_gjahr )
          ) TO mapped-document.

          APPEND VALUE #(
            pid   = pid
            zclpr = document-Zclpr
            bukrs = document-Bukrs
            vkorg = document-Vkorg
            vtweg = document-Vtweg
            vbeln = preliminary_vbeln
            gjahr = preliminary_gjahr
            kunrg = document-Kunrg
            fkdat = document-Fkdat
*            waerk = document-Waerk
          ) TO lcl_buffer=>mt_create_document_key.

        CATCH cx_uuid_error INTO DATA(uuid_error).
          APPEND VALUE #( %cid = document-%cid ) TO failed-document.
          APPEND VALUE #(
            %cid = document-%cid
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = uuid_error->get_text( ) )
          ) TO reported-document.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities INTO DATA(document).
      APPEND VALUE /eacm/prdo(
        zclpr = document-Zclpr
        bukrs = document-Bukrs
        vkorg = document-Vkorg
        vtweg = document-Vtweg
        vbeln = document-Vbeln
        gjahr = document-Gjahr
        fkdat = document-Fkdat
*        waerk = document-Waerk
*        zwaer = document-Waerk
      ) TO lcl_buffer=>mt_update_document.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(document_key).
      APPEND VALUE /eacm/prdo(
        zclpr = document_key-Zclpr
        bukrs = document_key-Bukrs
        vkorg = document_key-Vkorg
        vtweg = document_key-Vtweg
        vbeln = document_key-Vbeln
        gjahr = document_key-Gjahr
      ) TO lcl_buffer=>mt_delete_document.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS INITIAL.
      SELECT FROM /eacm/prdo AS z
        FIELDS z~zclpr,
               z~bukrs,
               z~vkorg,
               z~vtweg,
               z~vbeln,
               z~gjahr,
               MIN( z~kunrg ) AS kunrg,
               MAX( z~fkdat ) AS fkdat,
               z~waerk,
               z~zwaer,
               MAX( z~local_last_changed_at ) AS locallastchangedat
        WHERE z~posnr <> '000000'
          AND z~zstre <> 'D'
          AND z~zmodi <> 'D'
        GROUP BY z~zclpr,
                 z~bukrs,
                 z~vkorg,
                 z~vtweg,
                 z~vbeln,
                 z~gjahr,
                 z~waerk,
                 z~zwaer
        INTO TABLE @DATA(all_documents).

      result = VALUE #( FOR all_document IN all_documents
        (
          Zclpr              = all_document-zclpr
          Bukrs              = all_document-bukrs
          Vkorg              = all_document-vkorg
          Vtweg              = all_document-vtweg
          Vbeln              = all_document-vbeln
          Gjahr              = all_document-gjahr
          Kunrg              = all_document-kunrg
          Fkdat              = all_document-fkdat
          Waerk              = all_document-waerk
          LocalLastChangedAt = all_document-locallastchangedat
        ) ).
      RETURN.
    ENDIF.

    SELECT FROM /eacm/prdo AS z
      INNER JOIN @keys AS k
        ON  z~zclpr = k~Zclpr
        AND z~bukrs = k~Bukrs
        AND z~vkorg = k~Vkorg
        AND z~vtweg = k~Vtweg
        AND z~vbeln = k~Vbeln
        AND z~gjahr = k~Gjahr
      FIELDS z~zclpr,
             z~bukrs,
             z~vkorg,
             z~vtweg,
             z~vbeln,
             z~gjahr,
             MIN( z~kunrg ) AS kunrg,
             MAX( z~fkdat ) AS fkdat,
             z~waerk,
             z~zwaer,
             MAX( z~local_last_changed_at ) AS locallastchangedat
      WHERE z~posnr <> '000000'
        AND z~zstre <> 'D'
        AND z~zmodi <> 'D'
      GROUP BY z~zclpr,
               z~bukrs,
               z~vkorg,
               z~vtweg,
               z~vbeln,
               z~gjahr,
               z~waerk,
               z~zwaer
      INTO TABLE @DATA(documents).

    result = VALUE #( FOR key_document IN documents
      (
        Zclpr              = key_document-zclpr
        Bukrs              = key_document-bukrs
        Vkorg              = key_document-vkorg
        Vtweg              = key_document-vtweg
        Vbeln              = key_document-vbeln
        Gjahr              = key_document-gjahr
        Kunrg              = key_document-kunrg
        Fkdat              = key_document-fkdat
        Waerk              = key_document-waerk
        LocalLastChangedAt = key_document-locallastchangedat
      ) ).
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Positions.
    IF keys_rba IS INITIAL.
      RETURN.
    ENDIF.

    CLEAR result.
    CLEAR association_links.

    IF line_exists( keys_rba[ %is_draft = if_abap_behv=>mk-on ] ).
      SELECT FROM /EACM/PRDO_POS_D AS z
        INNER JOIN @keys_rba AS k
          ON  z~zclpr = k~Zclpr
          AND z~bukrs = k~Bukrs
          AND z~vkorg = k~Vkorg
          AND z~vtweg = k~Vtweg
          AND z~vbeln = k~Vbeln
          AND z~gjahr = k~Gjahr
        FIELDS z~zclpr,
               z~bukrs,
               z~vkorg,
               z~vtweg,
               z~vbeln,
               z~gjahr,
               z~posnr,
               z~material,
               z~materialdescription,
               z~waerk,
               z~quantity,
               z~locallastchangedat
        INTO TABLE @DATA(draft_positions).

      LOOP AT draft_positions INTO DATA(draft_position).
        READ TABLE keys_rba INTO DATA(draft_key)
          WITH KEY Zclpr = draft_position-zclpr
                   Bukrs = draft_position-bukrs
                   Vkorg = draft_position-vkorg
                   Vtweg = draft_position-vtweg
                   Vbeln = draft_position-vbeln
                   Gjahr = draft_position-gjahr.

        IF sy-subrc = 0.
          APPEND VALUE #(
            source-%tky = draft_key-%tky
            target-%tky = VALUE #(
              %is_draft = if_abap_behv=>mk-on
              Zclpr     = draft_position-zclpr
              Bukrs     = draft_position-bukrs
              Vkorg     = draft_position-vkorg
              Vtweg     = draft_position-vtweg
              Vbeln     = draft_position-vbeln
              Gjahr     = draft_position-gjahr
              Posnr     = draft_position-posnr
            )
          ) TO association_links.
        ENDIF.

        IF result_requested = abap_true.
          DATA(draft_material) = draft_position-material.
          DATA(draft_materialdescription) = draft_position-materialdescription.
          DATA(draft_waerk) = draft_position-waerk.
          DATA(draft_quantity) = draft_position-quantity.

          IF ( draft_material IS INITIAL OR draft_materialdescription IS INITIAL OR draft_waerk IS INITIAL OR draft_quantity IS INITIAL )
            AND ( draft_position-vbeln IS INITIAL OR draft_position-vbeln(1) = 'D' ).
            SELECT SINGLE z~arktx,
                          z~Zdesc AS description
              FROM /eacm/zpr08 AS z
              WHERE z~bukrs  = @draft_position-bukrs
                AND z~zclpr = @draft_position-zclpr
                AND z~posnr  = @draft_position-posnr
              INTO @DATA(draft_zpr08_position).

            IF sy-subrc = 0.
              IF draft_material IS INITIAL.
                draft_material = CONV /eacm/prdo-matnr( draft_zpr08_position-arktx ).
              ENDIF.

              IF draft_materialdescription IS INITIAL.
                draft_materialdescription = CONV /eacm/prdo-maktx( draft_zpr08_position-description ).
              ENDIF.

              IF draft_quantity IS INITIAL.
                draft_quantity = 1.
              ENDIF.
            ENDIF.
          ELSEIF ( draft_material IS INITIAL OR draft_materialdescription IS INITIAL OR draft_waerk IS INITIAL OR draft_quantity IS INITIAL )
            AND draft_position-vbeln IS NOT INITIAL.
            SELECT SINGLE z~matnr,          "#EC WARNOK
                          z~maktx,
                          z~waerk,
                          z~menge
              FROM /eacm/prdo AS z
              WHERE z~zclpr = @draft_position-zclpr
                AND z~bukrs = @draft_position-bukrs
                AND z~vkorg = @draft_position-vkorg
                AND z~vtweg = @draft_position-vtweg
                AND z~vbeln = @draft_position-vbeln
                AND z~gjahr = @draft_position-gjahr
                AND z~posnr = @draft_position-posnr
                AND z~zstre <> 'D'
                AND z~zmodi <> 'D'
              INTO @DATA(draft_zprdo_position).

            IF sy-subrc = 0.
              IF draft_material IS INITIAL.
                draft_material = draft_zprdo_position-matnr.
              ENDIF.

              IF draft_materialdescription IS INITIAL.
                draft_materialdescription = draft_zprdo_position-maktx.
              ENDIF.

              IF draft_waerk IS INITIAL.
                draft_waerk = draft_zprdo_position-waerk.
              ENDIF.

              IF draft_quantity IS INITIAL.
                draft_quantity = draft_zprdo_position-menge.
              ENDIF.
            ENDIF.
          ENDIF.

          APPEND VALUE #(
            %is_draft          = if_abap_behv=>mk-on
            Zclpr              = draft_position-zclpr
            Bukrs              = draft_position-bukrs
            Vkorg              = draft_position-vkorg
            Vtweg              = draft_position-vtweg
            Vbeln              = draft_position-vbeln
            Gjahr              = draft_position-gjahr
            Posnr              = draft_position-posnr
            Material           = draft_material
            MaterialDescription = draft_materialdescription
            Waerk              = draft_waerk
            Quantity           = draft_quantity
            LocalLastChangedAt = draft_position-locallastchangedat
          ) TO result.
        ENDIF.
      ENDLOOP.

      IF association_links IS NOT INITIAL OR result IS NOT INITIAL.
        RETURN.
      ENDIF.
    ENDIF.

    SELECT FROM /eacm/prdo AS z
      INNER JOIN @keys_rba AS k
        ON  z~zclpr = k~Zclpr
        AND z~bukrs = k~Bukrs
        AND z~vkorg = k~Vkorg
        AND z~vtweg = k~Vtweg
        AND z~vbeln = k~Vbeln
        AND z~gjahr = k~Gjahr
      FIELDS z~zclpr,
             z~bukrs,
             z~vkorg,
             z~vtweg,
             z~vbeln,
             z~gjahr,
             z~posnr,
             MIN( z~matnr ) AS material,
             MIN( z~maktx ) AS materialdescription,
             z~waerk,
             z~zwaer,
             MAX( z~menge ) AS quantity,
             MAX( z~local_last_changed_at ) AS locallastchangedat
      WHERE z~posnr <> '000000'
        AND z~zstre <> 'D'
        AND z~zmodi <> 'D'
      GROUP BY z~zclpr,
               z~bukrs,
               z~vkorg,
               z~vtweg,
               z~vbeln,
               z~gjahr,
               z~posnr,
               z~waerk,
               z~zwaer
      INTO TABLE @DATA(active_positions).

    LOOP AT active_positions INTO DATA(active_position).
      READ TABLE keys_rba INTO DATA(active_key)
        WITH KEY Zclpr = active_position-zclpr
                 Bukrs = active_position-bukrs
                 Vkorg = active_position-vkorg
                 Vtweg = active_position-vtweg
                 Vbeln = active_position-vbeln
                 Gjahr = active_position-gjahr.

      IF sy-subrc = 0.
        APPEND VALUE #(
          source-%tky = active_key-%tky
          target-%tky = VALUE #(
            %is_draft = if_abap_behv=>mk-off
            Zclpr     = active_position-zclpr
            Bukrs     = active_position-bukrs
            Vkorg     = active_position-vkorg
            Vtweg     = active_position-vtweg
            Vbeln     = active_position-vbeln
            Gjahr     = active_position-gjahr
            Posnr     = active_position-posnr
          )
        ) TO association_links.
      ENDIF.

      IF result_requested = abap_true.
        APPEND VALUE #(
          %is_draft          = if_abap_behv=>mk-off
          Zclpr              = active_position-zclpr
          Bukrs              = active_position-bukrs
          Vkorg              = active_position-vkorg
          Vtweg              = active_position-vtweg
          Vbeln              = active_position-vbeln
          Gjahr              = active_position-gjahr
          Posnr              = active_position-posnr
          Material           = active_position-material
          MaterialDescription = active_position-materialdescription
          Waerk              = active_position-waerk
          Quantity           = active_position-quantity
          LocalLastChangedAt = active_position-locallastchangedat
        ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD cba_Positions.
    LOOP AT entities_cba INTO DATA(document).

      SELECT MAX( posnr )
        FROM /eacm/prdo
        WHERE zclpr = @document-Zclpr
          AND bukrs = @document-Bukrs
          AND vkorg = @document-Vkorg
          AND vtweg = @document-Vtweg
          AND vbeln = @document-Vbeln
          AND gjahr = @document-Gjahr
        INTO @DATA(max_posnr).

      SELECT MAX( posnr )
        FROM /EACM/PRDO_POS_D
        WHERE zclpr = @document-Zclpr
          AND bukrs = @document-Bukrs
          AND vkorg = @document-Vkorg
          AND vtweg = @document-Vtweg
          AND vbeln = @document-Vbeln
          AND gjahr = @document-Gjahr
        INTO @DATA(max_draft_posnr).

      IF max_draft_posnr > max_posnr.
        max_posnr = max_draft_posnr.
      ENDIF.

      LOOP AT lcl_buffer=>mt_create_position INTO DATA(buffered_position)
        WHERE zclpr = document-Zclpr
          AND bukrs = document-Bukrs
          AND vkorg = document-Vkorg
          AND vtweg = document-Vtweg
          AND vbeln = document-Vbeln
          AND gjahr = document-Gjahr.
        IF buffered_position-posnr > max_posnr.
          max_posnr = buffered_position-posnr.
        ENDIF.
      ENDLOOP.

      LOOP AT document-%target INTO DATA(position).
        TRY.
            DATA(position_pid) = cl_system_uuid=>create_uuid_x16_static( ).
            DATA(posnr) = VALUE /eacm/prdo-posnr( ).
            DATA(position_material) = VALUE /eacm/prdo-matnr( ).
            DATA(position_material_description) = VALUE /eacm/prdo-maktx( ).
            DATA(position_quantity) = VALUE /eacm/prdo-menge( ).
            DATA(position_fkdat) = VALUE /eacm/prdo-fkdat( ).
            DATA(position_waerk) = VALUE /eacm/prdo-waerk( ).

            DATA(posnr_number) = CONV i( max_posnr ) + 10.

            posnr = CONV /eacm/prdo-posnr( |{ posnr_number WIDTH = 6 PAD = '0' ALIGN = RIGHT }| ).
            position_material = position-Material.
            position_material_description = position-MaterialDescription.
            position_quantity = position-Quantity.
            position_waerk = position-Waerk.

            max_posnr = posnr.

            APPEND VALUE #(
              %cid  = position-%cid
              %pid  = position_pid
              Zclpr = document-Zclpr
              Bukrs = document-Bukrs
              Vkorg = document-Vkorg
              Vtweg = document-Vtweg
              Vbeln = document-Vbeln
              Gjahr = document-Gjahr
              Posnr = posnr
            ) TO mapped-position.

            APPEND VALUE #(
              pid   = position_pid
              zclpr = document-Zclpr
              bukrs = document-Bukrs
              vkorg = document-Vkorg
              vtweg = document-Vtweg
              vbeln = document-Vbeln
              gjahr = document-Gjahr
              posnr = posnr
            ) TO lcl_buffer=>mt_create_position_key.

            IF position-Waerk IS NOT INITIAL.
              position_waerk = position-Waerk.
            ENDIF.


            APPEND VALUE /eacm/prdo(
              zclpr = document-Zclpr
              bukrs = document-Bukrs
              vkorg = document-Vkorg
              vtweg = document-Vtweg
              vbeln = document-Vbeln
              gjahr = document-Gjahr
              posnr = posnr
              matnr = position_material
              maktx = position_material_description
              menge = position_quantity
              fkdat = position_fkdat
              waerk = position_waerk
              zwaer = position_waerk
            ) TO lcl_buffer=>mt_create_position.

          CATCH cx_uuid_error INTO DATA(uuid_error).
            APPEND VALUE #( %cid = position-%cid ) TO failed-position.
            APPEND VALUE #(
              %cid = position-%cid
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = uuid_error->get_text( ) )
            ) TO reported-position.
        ENDTRY.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
**********************************************************************
**********************************************************************
CLASS lhc_Position DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Position.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Position.

    METHODS read FOR READ
      IMPORTING keys FOR READ Position RESULT result.

    METHODS rba_Agents FOR READ
      IMPORTING keys_rba FOR READ Position\_Agents FULL result_requested RESULT result LINK association_links.

    METHODS rba_Document FOR READ
      IMPORTING keys_rba FOR READ Position\_Document FULL result_requested RESULT result LINK association_links.

    METHODS cba_Agents FOR MODIFY
      IMPORTING entities_cba FOR CREATE Position\_Agents.

    METHODS SetPositionDefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Position~SetPositionDefaults.

ENDCLASS.
**********************************************************************
CLASS lhc_Position IMPLEMENTATION.

  METHOD SetPositionDefaults.
    READ ENTITIES OF /EACM/I_PRDO_DOC IN LOCAL MODE
      ENTITY Position
        FIELDS ( Material MaterialDescription Waerk Quantity )
        WITH CORRESPONDING #( keys )
      RESULT DATA(positions).

    LOOP AT positions INTO DATA(position).
      DATA(position_material) = VALUE /eacm/prdo-matnr( ).
      DATA(position_material_description) = VALUE /eacm/prdo-maktx( ).
      DATA(position_waerk) = VALUE /eacm/prdo-waerk( ).
      DATA(position_quantity) = VALUE /eacm/prdo-menge( ).

      READ TABLE lcl_buffer=>mt_create_position INTO DATA(buffered_position)
        WITH KEY zclpr = position-Zclpr
                 bukrs = position-Bukrs
                 vkorg = position-Vkorg
                 vtweg = position-Vtweg
                 vbeln = position-Vbeln
                 gjahr = position-Gjahr
                 posnr = position-Posnr.

      IF sy-subrc = 0.
        position_material = buffered_position-matnr.
        position_material_description = buffered_position-maktx.
        position_waerk = buffered_position-waerk.
        position_quantity = buffered_position-menge.
      ELSE.
        SELECT SINGLE material,                     "#EC CI_NOORDER
                      materialdescription,
                      waerk,
                      quantity
          FROM /EACM/PRDO_POS_D
          WHERE zclpr = @position-Zclpr
            AND bukrs = @position-Bukrs
            AND vkorg = @position-Vkorg
            AND vtweg = @position-Vtweg
             AND vbeln = @position-Vbeln
            AND gjahr = @position-Gjahr
            AND posnr = @position-Posnr
          INTO @DATA(draft_position_data).

        IF sy-subrc = 0.
          position_material = draft_position_data-material.
          position_material_description = draft_position_data-materialdescription.
          position_waerk = draft_position_data-waerk.
          position_quantity = draft_position_data-quantity.
        ENDIF.
      ENDIF.

      IF ( position_material IS INITIAL OR position_material_description IS INITIAL OR position_waerk IS INITIAL OR position_quantity IS INITIAL )
        AND ( position-Vbeln IS INITIAL OR position-Vbeln(1) = 'D' ).
        SELECT SINGLE z~arktx,
                      z~Zdesc AS description
          FROM /eacm/zpr08 AS z
          WHERE z~bukrs = @position-Bukrs
            AND z~zclpr = @position-Zclpr
          INTO @DATA(zpr08_position).

        IF sy-subrc = 0.
          IF position_material IS INITIAL.
            position_material = CONV /eacm/prdo-matnr( zpr08_position-arktx ).
          ENDIF.

          IF position_material_description IS INITIAL.
            position_material_description = CONV /eacm/prdo-maktx( zpr08_position-description ).
          ENDIF.

          IF position_quantity IS INITIAL.
            position_quantity = 1.
          ENDIF.
        ENDIF.
      ELSEIF ( position_material IS INITIAL OR position_material_description IS INITIAL OR position_waerk IS INITIAL OR position_quantity IS INITIAL )
        AND position-Vbeln IS NOT INITIAL.
        SELECT SINGLE matnr,                    "#EC CI_NOORDER
                      maktx,
                      waerk,
                      menge
          FROM /eacm/prdo
          WHERE zclpr = @position-Zclpr
            AND bukrs = @position-Bukrs
            AND vkorg = @position-Vkorg
            AND vtweg = @position-Vtweg
            AND vbeln = @position-Vbeln
            AND gjahr = @position-Gjahr
            AND posnr = @position-Posnr
            AND zstre <> 'D'
            AND zmodi <> 'D'
          INTO @DATA(active_position_data).

        IF sy-subrc = 0.
          IF position_material IS INITIAL.
            position_material = active_position_data-matnr.
          ENDIF.

          IF position_material_description IS INITIAL.
            position_material_description = active_position_data-maktx.
          ENDIF.

          IF position_waerk IS INITIAL.
            position_waerk = active_position_data-waerk.
          ENDIF.

          IF position_quantity IS INITIAL.
            position_quantity = active_position_data-menge.
          ENDIF.
        ENDIF.
      ENDIF.

      IF position_material IS INITIAL
        AND position_material_description IS INITIAL
        AND position_waerk IS INITIAL
        AND position_quantity IS INITIAL.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF /EACM/I_PRDO_DOC IN LOCAL MODE
        ENTITY Position
        UPDATE FIELDS ( Material MaterialDescription Waerk Quantity )
        WITH VALUE #(
          (
            %tky               = position-%tky
            Material           = position_material
            MaterialDescription = position_material_description
            Waerk              = position_waerk
            Quantity           = position_quantity
          )
        )
        FAILED DATA(update_failed)
        REPORTED DATA(update_reported).
    ENDLOOP.
  ENDMETHOD.

  METHOD update.

  LOOP AT entities INTO DATA(position).

    SELECT SINGLE zstre
      FROM /eacm/prdo
      WHERE zclpr = @position-Zclpr
        AND bukrs = @position-Bukrs
        AND vkorg = @position-Vkorg
        AND vtweg = @position-Vtweg
        AND vbeln = @position-Vbeln
        AND gjahr = @position-Gjahr
        AND posnr = @position-Posnr
        AND zstre <> 'D'
        AND zmodi <> 'D'
      INTO @DATA(position_zstre).

    IF sy-subrc = 0 AND position_zstre = 'C'.
      APPEND VALUE #( %tky = position-%tky ) TO failed-position.
      APPEND VALUE #(
        %tky = position-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'Stato C: consentito solo inserimento righe' )
      ) TO reported-position.
      CONTINUE.
    ENDIF.

    APPEND VALUE /eacm/prdo(
      zclpr = position-Zclpr
      bukrs = position-Bukrs
      vkorg = position-Vkorg
      vtweg = position-Vtweg
      vbeln = position-Vbeln
      gjahr = position-Gjahr
      posnr = position-Posnr
      matnr = position-Material
      maktx = position-MaterialDescription
      waerk = position-Waerk
      zwaer = position-Waerk
      menge = position-Quantity
    ) TO lcl_buffer=>mt_update_position.

  ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(position_key).

      SELECT SINGLE zstre
        FROM /eacm/prdo
        WHERE zclpr = @position_key-Zclpr
          AND bukrs = @position_key-Bukrs
          AND vkorg = @position_key-Vkorg
          AND vtweg = @position_key-Vtweg
          AND vbeln = @position_key-Vbeln
          AND gjahr = @position_key-Gjahr
          AND posnr = @position_key-Posnr
          AND zstre <> 'D'
          AND zmodi <> 'D'
        INTO @DATA(position_delete_zstre).

      IF sy-subrc = 0 AND position_delete_zstre = 'C'.
        APPEND VALUE #( %tky = position_key-%tky ) TO failed-position.
        APPEND VALUE #(
          %tky = position_key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Stato C: consentito solo inserimento righe' )
        ) TO reported-position.
        CONTINUE.
      ENDIF.

      APPEND VALUE /eacm/prdo(
        zclpr = position_key-Zclpr
        bukrs = position_key-Bukrs
        vkorg = position_key-Vkorg
        vtweg = position_key-Vtweg
        vbeln = position_key-Vbeln
        gjahr = position_key-Gjahr
        posnr = position_key-Posnr
      ) TO lcl_buffer=>mt_delete_position.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    IF line_exists( keys[ %is_draft = if_abap_behv=>mk-on ] ).
      LOOP AT keys INTO DATA(draft_position_key).
        IF draft_position_key-%is_draft <> if_abap_behv=>mk-on.
          CONTINUE.
        ENDIF.

        SELECT SINGLE zclpr,                    "#EC CI_NOORDER
                      bukrs,
                      vkorg,
                      vtweg,
                      vbeln,
                      gjahr,
                      posnr,
                      material,
                      materialdescription,
                      waerk,
                      quantity,
                      locallastchangedat
          FROM /EACM/PRDO_POS_D
          WHERE zclpr = @draft_position_key-Zclpr
            AND bukrs = @draft_position_key-Bukrs
            AND vkorg = @draft_position_key-Vkorg
            AND vtweg = @draft_position_key-Vtweg
            AND vbeln = @draft_position_key-Vbeln
            AND gjahr = @draft_position_key-Gjahr
            AND posnr = @draft_position_key-Posnr
          INTO @DATA(draft_position).

        IF sy-subrc <> 0.
          READ TABLE lcl_buffer=>mt_create_position INTO DATA(buffered_position)
            WITH KEY zclpr = draft_position_key-Zclpr
                     bukrs = draft_position_key-Bukrs
                     vkorg = draft_position_key-Vkorg
                     vtweg = draft_position_key-Vtweg
                     vbeln = draft_position_key-Vbeln
                     gjahr = draft_position_key-Gjahr
                     posnr = draft_position_key-Posnr.

          IF sy-subrc = 0.
            APPEND VALUE #(
              %is_draft          = if_abap_behv=>mk-on
              Zclpr              = buffered_position-zclpr
              Bukrs              = buffered_position-bukrs
              Vkorg              = buffered_position-vkorg
              Vtweg              = buffered_position-vtweg
              Vbeln              = buffered_position-vbeln
              Gjahr              = buffered_position-gjahr
              Posnr              = buffered_position-posnr
              Material           = buffered_position-matnr
              MaterialDescription = buffered_position-maktx
              Waerk              = buffered_position-waerk
              Quantity           = buffered_position-menge
              LocalLastChangedAt = buffered_position-local_last_changed_at
            ) TO result.
          ENDIF.

          CONTINUE.
        ENDIF.

        DATA(draft_material) = draft_position-material.
        DATA(draft_materialdescription) = draft_position-materialdescription.
        DATA(draft_waerk) = draft_position-waerk.
        DATA(draft_quantity) = draft_position-quantity.

        IF ( draft_material IS INITIAL OR draft_materialdescription IS INITIAL OR draft_waerk IS INITIAL OR draft_quantity IS INITIAL )
          AND ( draft_position-vbeln IS INITIAL OR draft_position-vbeln(1) = 'D' ).
          SELECT SINGLE z~arktx,
                        z~Zdesc AS description
            FROM /eacm/zpr08 AS z
            WHERE z~bukrs = @draft_position-bukrs
              AND z~zclpr = @draft_position-zclpr
              AND z~posnr = @draft_position-posnr
            INTO @DATA(draft_zpr08_position).

          IF sy-subrc = 0.
            IF draft_material IS INITIAL.
              draft_material = CONV /eacm/prdo-matnr( draft_zpr08_position-arktx ).
            ENDIF.

            IF draft_materialdescription IS INITIAL.
              draft_materialdescription = CONV /eacm/prdo-maktx( draft_zpr08_position-description ).
            ENDIF.

            IF draft_quantity IS INITIAL.
              draft_quantity = 1.
            ENDIF.
          ENDIF.
        ELSEIF ( draft_material IS INITIAL OR draft_materialdescription IS INITIAL OR draft_waerk IS INITIAL OR draft_quantity IS INITIAL )
          AND draft_position-vbeln IS NOT INITIAL.
          SELECT SINGLE z~matnr,                        "#EC CI_NOORDER
                        z~maktx,
                        z~waerk,
                        z~menge
            FROM /eacm/prdo AS z
            WHERE z~zclpr = @draft_position-zclpr
              AND z~bukrs = @draft_position-bukrs
              AND z~vkorg = @draft_position-vkorg
              AND z~vtweg = @draft_position-vtweg
              AND z~vbeln = @draft_position-vbeln
              AND z~gjahr = @draft_position-gjahr
              AND z~posnr = @draft_position-posnr
              AND z~zstre <> 'D'
              AND z~zmodi <> 'D'
            INTO @DATA(draft_zprdo_position).

          IF sy-subrc = 0.
            IF draft_material IS INITIAL.
              draft_material = draft_zprdo_position-matnr.
            ENDIF.

            IF draft_materialdescription IS INITIAL.
              draft_materialdescription = draft_zprdo_position-maktx.
            ENDIF.

            IF draft_waerk IS INITIAL.
              draft_waerk = draft_zprdo_position-waerk.
            ENDIF.

            IF draft_quantity IS INITIAL.
              draft_quantity = draft_zprdo_position-menge.
            ENDIF.
          ENDIF.
        ENDIF.

        APPEND VALUE #(
          %is_draft          = if_abap_behv=>mk-on
          Zclpr              = draft_position-zclpr
          Bukrs              = draft_position-bukrs
          Vkorg              = draft_position-vkorg
          Vtweg              = draft_position-vtweg
          Vbeln              = draft_position-vbeln
          Gjahr              = draft_position-gjahr
          Posnr              = draft_position-posnr
          Material           = draft_material
          MaterialDescription = draft_materialdescription
          Waerk              = draft_waerk
          Quantity           = draft_quantity
          LocalLastChangedAt = draft_position-locallastchangedat
        ) TO result.
      ENDLOOP.

      IF result IS NOT INITIAL.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT keys INTO DATA(active_position_key).
      SELECT FROM /eacm/prdo AS z
        FIELDS z~zclpr,
               z~bukrs,
               z~vkorg,
               z~vtweg,
               z~vbeln,
               z~gjahr,
               z~posnr,
               MIN( z~matnr ) AS material,
               MIN( z~maktx ) AS materialdescription,
               z~waerk,
               MAX( z~menge ) AS quantity,
               MAX( z~local_last_changed_at ) AS locallastchangedat
        WHERE z~zclpr = @active_position_key-Zclpr
          AND z~bukrs = @active_position_key-Bukrs
          AND z~vkorg = @active_position_key-Vkorg
          AND z~vtweg = @active_position_key-Vtweg
          AND z~vbeln = @active_position_key-Vbeln
          AND z~gjahr = @active_position_key-Gjahr
          AND z~posnr = @active_position_key-Posnr
          AND z~posnr <> '000000'
          AND z~zstre <> 'D'
          AND z~zmodi <> 'D'
        GROUP BY z~zclpr,
                 z~bukrs,
                 z~vkorg,
                 z~vtweg,
                 z~vbeln,
                 z~gjahr,
                 z~posnr,
                 z~waerk
        INTO TABLE @DATA(active_positions).

      LOOP AT active_positions INTO DATA(active_position).
        APPEND VALUE #(
          Zclpr              = active_position-zclpr
          Bukrs              = active_position-bukrs
          Vkorg              = active_position-vkorg
          Vtweg              = active_position-vtweg
          Vbeln              = active_position-vbeln
          Gjahr              = active_position-gjahr
          Posnr              = active_position-posnr
          Material           = active_position-material
          MaterialDescription = active_position-materialdescription
          Waerk              = active_position-waerk
          Quantity           = active_position-quantity
          LocalLastChangedAt = active_position-locallastchangedat
        ) TO result.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Document.
    LOOP AT keys_rba INTO DATA(position_key).
      APPEND VALUE #(
        source-%tky = position_key-%tky
        target-%tky = VALUE #(
          %is_draft = position_key-%is_draft
          Zclpr     = position_key-Zclpr
          Bukrs     = position_key-Bukrs
          Vkorg     = position_key-Vkorg
          Vtweg     = position_key-Vtweg
          Vbeln     = position_key-Vbeln
          Gjahr     = position_key-Gjahr
        )
      ) TO association_links.

      IF result_requested = abap_true.
        APPEND VALUE #(
          %is_draft = position_key-%is_draft
          Zclpr     = position_key-Zclpr
          Bukrs     = position_key-Bukrs
          Vkorg     = position_key-Vkorg
          Vtweg     = position_key-Vtweg
          Vbeln     = position_key-Vbeln
          Gjahr     = position_key-Gjahr
        ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Agents.
    IF keys_rba IS INITIAL.
      RETURN.
    ENDIF.

    CLEAR result.
    CLEAR association_links.

    IF line_exists( keys_rba[ %is_draft = if_abap_behv=>mk-on ] ).
      SELECT FROM /EACM/PRDO_AGT_D AS z
        INNER JOIN @keys_rba AS k
          ON  z~zclpr = k~Zclpr
          AND z~bukrs = k~Bukrs
          AND z~vkorg = k~Vkorg
          AND z~vtweg = k~Vtweg
          AND z~vbeln = k~Vbeln
          AND z~gjahr = k~Gjahr
          AND z~posnr = k~Posnr
        FIELDS z~zclpr AS zclpr,
               z~bukrs AS bukrs,
               z~vkorg AS vkorg,
               z~vtweg AS vtweg,
               z~vbeln AS vbeln,
               z~gjahr AS gjahr,
               z~posnr AS posnr,
               z~zidag AS zidag,
                z~zcdaz AS zcdaz,
                z~ziman AS ziman,
                z~zimar AS zimar,
                z~zpcpr AS zpcpr,
                z~zimpp AS zimpp,
                z~zimco AS zimco,
                z~zimpu AS zimpu,
*               z~zwaer,
                z~kunrg AS kunrg,
                z~budat AS budat,
                z~zwaer AS zwaer,
                z~kurrf AS kurrf,
                z~ztpag AS ztpag,
                z~zstre AS zstre,
                z~zmodi AS zmodi,
                z~zcamd AS zcamd,
                z~zdtmd AS zdtmd,
                z~zormd AS zormd,
                z~zdest AS zdest,
                z~unitmeasure AS unitmeasure,
                z~documentdate AS documentdate,
               z~locallastchangedat AS locallastchangedat
        INTO TABLE @DATA(draft_agents).

      LOOP AT draft_agents INTO DATA(draft_agent).
        READ TABLE keys_rba INTO DATA(draft_key)
          WITH KEY Zclpr = draft_agent-zclpr
                   Bukrs = draft_agent-bukrs
                   Vkorg = draft_agent-vkorg
                   Vtweg = draft_agent-vtweg
                   Vbeln = draft_agent-vbeln
                   Gjahr = draft_agent-gjahr
                   Posnr = draft_agent-posnr.

        IF sy-subrc = 0.
          APPEND VALUE #(
            source-%tky = draft_key-%tky
            target-%tky = VALUE #(
              %is_draft = if_abap_behv=>mk-on
              Zclpr     = draft_agent-zclpr
              Bukrs     = draft_agent-bukrs
              Vkorg     = draft_agent-vkorg
              Vtweg     = draft_agent-vtweg
              Vbeln     = draft_agent-vbeln
              Gjahr     = draft_agent-gjahr
              Posnr     = draft_agent-posnr
              Zidag     = draft_agent-zidag
              Zcdaz     = draft_agent-zcdaz
            )
          ) TO association_links.
        ENDIF.

        IF result_requested = abap_true.
          APPEND VALUE #(
            %is_draft          = if_abap_behv=>mk-on
            Zclpr              = draft_agent-zclpr
            Bukrs              = draft_agent-bukrs
            Vkorg              = draft_agent-vkorg
            Vtweg              = draft_agent-vtweg
            Vbeln              = draft_agent-vbeln
            Gjahr              = draft_agent-gjahr
            Posnr              = draft_agent-posnr
            Zidag              = draft_agent-zidag
            Zcdaz              = draft_agent-zcdaz
            Ziman              = draft_agent-ziman
            Zimar              = draft_agent-zimar
            Zpcpr              = draft_agent-zpcpr
            Zimpp              = draft_agent-zimpp
            Zimco              = draft_agent-zimco
            Zimpu              = draft_agent-zimpu
            Zwaer              = draft_agent-zwaer
            Kunrg              = draft_agent-kunrg
            Budat              = draft_agent-budat
            Kurrf              = draft_agent-kurrf
            Ztpag              = draft_agent-ztpag
            Zstre              = draft_agent-zstre
            Zmodi              = draft_agent-zmodi
            Zcamd              = draft_agent-zcamd
            Zdtmd              = draft_agent-zdtmd
            Zormd              = draft_agent-zormd
            Zdest              = draft_agent-zdest
            UnitMeasure        = draft_agent-unitmeasure
            DocumentDate       = draft_agent-documentdate
            LocalLastChangedAt = draft_agent-locallastchangedat
          ) TO result.
        ENDIF.
      ENDLOOP.

      IF association_links IS NOT INITIAL OR result IS NOT INITIAL.
        RETURN.
      ENDIF.
    ENDIF.

    SELECT FROM /eacm/prdo AS z
      INNER JOIN @keys_rba AS k
        ON  z~zclpr = k~Zclpr
        AND z~bukrs = k~Bukrs
        AND z~vkorg = k~Vkorg
        AND z~vtweg = k~Vtweg
        AND z~vbeln = k~Vbeln
        AND z~gjahr = k~Gjahr
        AND z~posnr = k~Posnr
      FIELDS z~zclpr,
             z~bukrs,
             z~vkorg,
             z~vtweg,
             z~vbeln,
             z~gjahr,
             z~posnr,
             z~zidag,
             z~zcdaz,
             z~ziman,
             z~zimar,
             z~zpcpr,
             z~zimpp,
             z~zimco,
             z~zimpu,
             z~zwaer,
             z~kunrg,
             z~budat,
             z~kurrf,
             z~ztpag,
             z~zstre,
             z~zmodi,
             z~zcamd,
             z~zdtmd,
             z~zormd,
             z~zdest,
             z~menge,
             z~zutmx,
             z~fkdat,
             z~waerk,
             z~local_last_changed_at
       WHERE z~posnr <> '000000'
         AND z~zstre <> 'D'
         AND z~zmodi <> 'D'
       INTO TABLE @DATA(active_agents).

    LOOP AT active_agents INTO DATA(active_agent).
      READ TABLE keys_rba INTO DATA(active_key)
        WITH KEY Zclpr = active_agent-zclpr
                 Bukrs = active_agent-bukrs
                 Vkorg = active_agent-vkorg
                 Vtweg = active_agent-vtweg
                 Vbeln = active_agent-vbeln
                 Gjahr = active_agent-gjahr
                 Posnr = active_agent-posnr.

      IF sy-subrc = 0.
        APPEND VALUE #(
          source-%tky = active_key-%tky
          target-%tky = VALUE #(
            %is_draft = if_abap_behv=>mk-off
            Zclpr     = active_agent-zclpr
            Bukrs     = active_agent-bukrs
            Vkorg     = active_agent-vkorg
            Vtweg     = active_agent-vtweg
            Vbeln     = active_agent-vbeln
            Gjahr     = active_agent-gjahr
            Posnr     = active_agent-posnr
            Zidag     = active_agent-zidag
            Zcdaz     = active_agent-zcdaz
          )
        ) TO association_links.
      ENDIF.

      IF result_requested = abap_true.
        APPEND VALUE #(
          %is_draft          = if_abap_behv=>mk-off
          Zclpr              = active_agent-zclpr
          Bukrs              = active_agent-bukrs
          Vkorg              = active_agent-vkorg
          Vtweg              = active_agent-vtweg
          Vbeln              = active_agent-vbeln
          Gjahr              = active_agent-gjahr
          Posnr              = active_agent-posnr
          Zidag              = active_agent-zidag
          Zcdaz              = active_agent-zcdaz
          Ziman              = active_agent-ziman
          Zimar              = active_agent-zimar
          Zpcpr              = active_agent-zpcpr
          Zimpp              = active_agent-zimpp
          Zimco              = active_agent-zimco
          Zimpu              = active_agent-zimpu
          Zwaer              = active_agent-zwaer
          Kunrg              = active_agent-kunrg
          Budat              = active_agent-budat
          Kurrf              = active_agent-kurrf
          Ztpag              = active_agent-ztpag
          Zstre              = active_agent-zstre
          Zmodi              = active_agent-zmodi
          Zcamd              = active_agent-zcamd
          Zdtmd              = active_agent-zdtmd
          Zormd              = active_agent-zormd
          Zdest              = active_agent-zdest
          UnitMeasure        = active_agent-zutmx
          DocumentDate       = active_agent-fkdat
          LocalLastChangedAt = active_agent-local_last_changed_at
        ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD cba_Agents.
    LOOP AT entities_cba INTO DATA(position).
      LOOP AT position-%target INTO DATA(agent).
        TRY.
            DATA(agent_pid) = cl_system_uuid=>create_uuid_x16_static( ).

            DATA(zcdaz) = agent-Zcdaz.

            IF zcdaz IS NOT INITIAL.
              zcdaz = |{ zcdaz ALPHA = IN }|.
            ENDIF.

            SELECT MAX( zidag )
              FROM /eacm/prdo
              WHERE zclpr = @position-Zclpr
                AND bukrs = @position-Bukrs
                AND vkorg = @position-Vkorg
                AND vtweg = @position-Vtweg
                AND vbeln = @position-Vbeln
                AND gjahr = @position-Gjahr
                AND posnr = @position-Posnr
              INTO @DATA(max_zidag).

            SELECT MAX( zidag )
              FROM /EACM/PRDO_AGT_D
              WHERE zclpr = @position-Zclpr
                AND bukrs = @position-Bukrs
                AND vkorg = @position-Vkorg
                AND vtweg = @position-Vtweg
                AND vbeln = @position-Vbeln
                AND gjahr = @position-Gjahr
                AND posnr = @position-Posnr
              INTO @DATA(max_draft_zidag).

            IF max_draft_zidag > max_zidag.
              max_zidag = max_draft_zidag.
            ENDIF.

            LOOP AT lcl_buffer=>mt_create_agent INTO DATA(buffered_agent)
              WHERE zclpr = position-Zclpr
                AND bukrs = position-Bukrs
                AND vkorg = position-Vkorg
                AND vtweg = position-Vtweg
                AND vbeln = position-Vbeln
                AND gjahr = position-Gjahr
                AND posnr = position-Posnr.
              IF buffered_agent-zidag > max_zidag.
                max_zidag = buffered_agent-zidag.
              ENDIF.
            ENDLOOP.

            DATA(zidag_number) = CONV i( max_zidag ) + 1.
            DATA(zidag) = CONV /eacm/zidag( |{ zidag_number WIDTH = 4 PAD = '0' ALIGN = RIGHT }| ).
            DATA(position_material) = VALUE /eacm/prdo-matnr( ).
            DATA(position_material_description) = VALUE /eacm/prdo-maktx( ).
            DATA(position_quantity) = VALUE /eacm/prdo-menge( ).
            DATA(position_unitmeasure) = VALUE /eacm/prdo-zutmx( ).
            DATA(position_fkdat) = VALUE /eacm/prdo-fkdat( ).
            DATA(position_waerk) = VALUE /eacm/prdo-waerk( ).

            READ TABLE lcl_buffer=>mt_create_position INTO DATA(create_position)
              WITH KEY zclpr = position-Zclpr
                       bukrs = position-Bukrs
                       vkorg = position-Vkorg
                       vtweg = position-Vtweg
                       vbeln = position-Vbeln
                       gjahr = position-Gjahr
                       posnr = position-Posnr.

            IF sy-subrc = 0.
              position_material = create_position-matnr.
              position_material_description = create_position-maktx.
              position_quantity = create_position-menge.
              position_unitmeasure = create_position-zutmx.
              position_fkdat = create_position-fkdat.
              position_waerk = create_position-waerk.
            ELSE.
              SELECT SINGLE matnr,                      "#EC CI_NOORDER
                            maktx,
                            menge,
                            zutmx,
                            fkdat,
                            waerk
                FROM /eacm/prdo
                WHERE zclpr = @position-Zclpr
                  AND bukrs = @position-Bukrs
                  AND vkorg = @position-Vkorg
                  AND vtweg = @position-Vtweg
                  AND vbeln = @position-Vbeln
                  AND gjahr = @position-Gjahr
                  AND posnr = @position-Posnr
                  AND zstre <> 'D'
                  AND zmodi <> 'D'
                INTO @DATA(active_position_data).

              IF sy-subrc = 0.
                position_material = active_position_data-matnr.
                position_material_description = active_position_data-maktx.
                position_quantity = active_position_data-menge.
                position_unitmeasure = active_position_data-zutmx.
                position_fkdat = active_position_data-fkdat.
                position_waerk = active_position_data-waerk.
              ELSE.
                SELECT SINGLE material,                     "#EC CI_NOORDER
                              materialdescription,
                              waerk,
                              quantity
                  FROM /EACM/PRDO_POS_D
                  WHERE zclpr = @position-Zclpr
                    AND bukrs = @position-Bukrs
                    AND vkorg = @position-Vkorg
                    AND vtweg = @position-Vtweg
                    AND vbeln = @position-Vbeln
                    AND gjahr = @position-Gjahr
                    AND posnr = @position-Posnr
                  INTO @DATA(draft_position_data).

                IF sy-subrc = 0.
                  position_material = draft_position_data-material.
                  position_material_description = draft_position_data-materialdescription.
                  position_waerk = draft_position_data-waerk.
                  position_quantity = draft_position_data-quantity.
                ENDIF.

IF position_waerk IS INITIAL.
  READ ENTITIES OF /EACM/I_PRDO_DOC IN LOCAL MODE
    ENTITY Position
      FIELDS ( Waerk )
      WITH VALUE #(
        (
          %is_draft = if_abap_behv=>mk-on
          Zclpr = position-Zclpr
          Bukrs = position-Bukrs
          Vkorg = position-Vkorg
          Vtweg = position-Vtweg
          Vbeln = position-Vbeln
          Gjahr = position-Gjahr
          Posnr = position-Posnr
        )
      )
      RESULT DATA(read_positions).

  READ TABLE read_positions INTO DATA(read_position) INDEX 1.

  IF sy-subrc = 0.
    position_waerk = read_position-Waerk.
  ENDIF.
ENDIF.

                IF ( position_material IS INITIAL OR position_material_description IS INITIAL OR position_unitmeasure IS INITIAL OR position_waerk IS INITIAL OR position_quantity IS INITIAL )
                  AND ( position-Vbeln IS INITIAL OR position-Vbeln(1) = 'D' ).
                  SELECT SINGLE z~arktx,
                                z~Zdesc AS description
                    FROM /eacm/zpr08 AS z
                    WHERE z~bukrs = @position-Bukrs
                      AND z~zclpr = @position-Zclpr
                      AND z~posnr = @position-Posnr
                    INTO @DATA(agent_zpr08_position).

                  IF sy-subrc = 0.
                    IF position_material IS INITIAL.
                      position_material = CONV /eacm/prdo-matnr( agent_zpr08_position-arktx ).
                    ENDIF.

                    IF position_material_description IS INITIAL.
                      position_material_description = CONV /eacm/prdo-maktx( agent_zpr08_position-description ).
                    ENDIF.

                    IF position_quantity IS INITIAL.
                      position_quantity = 1.
                    ENDIF.
                  ENDIF.
                ELSEIF ( position_material IS INITIAL OR position_material_description IS INITIAL OR position_unitmeasure IS INITIAL OR position_waerk IS INITIAL OR position_quantity IS INITIAL )
                  AND position-Vbeln IS NOT INITIAL.
                  SELECT SINGLE matnr,                  "#EC CI_NOORDER
                                maktx,
                                menge,
                                zutmx,
                                fkdat,
                                waerk
                    FROM /eacm/prdo
                    WHERE zclpr = @position-Zclpr
                      AND bukrs = @position-Bukrs
                      AND vkorg = @position-Vkorg
                      AND vtweg = @position-Vtweg
                      AND vbeln = @position-Vbeln
                      AND gjahr = @position-Gjahr
                      AND posnr = @position-Posnr
                      AND zstre <> 'D'
                      AND zmodi <> 'D'
                    INTO @DATA(agent_position_data).

                  IF sy-subrc = 0.
                    IF position_material IS INITIAL.
                      position_material = agent_position_data-matnr.
                    ENDIF.

                    IF position_material_description IS INITIAL.
                      position_material_description = agent_position_data-maktx.
                    ENDIF.

                    IF position_quantity IS INITIAL.
                      position_quantity = agent_position_data-menge.
                    ENDIF.

                    IF position_unitmeasure IS INITIAL.
                      position_unitmeasure = agent_position_data-zutmx.
                    ENDIF.

                    IF position_fkdat IS INITIAL.
                      position_fkdat = agent_position_data-fkdat.
                    ENDIF.

                    IF position_waerk IS INITIAL.
                      position_waerk = agent_position_data-waerk.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

            IF agent-DocumentDate IS NOT INITIAL.
              position_fkdat = agent-DocumentDate.
            ENDIF.

            DATA(agent_ziman) = agent-Ziman.

            IF agent-ZPCPR IS NOT INITIAL.
agent-ZIMCO = agent-ZIMPP * agent-ZPCPR / 100.
            ENDIF.

            DATA(agent_zpcpr) = agent-Zpcpr.
            DATA(agent_zimpp) = agent-Zimpp.
            DATA(agent_zimco) = agent-Zimco.

            IF ( agent_zpcpr IS INITIAL AND agent_zimpp IS NOT INITIAL )
              OR ( agent_zpcpr IS NOT INITIAL AND agent_zimpp IS INITIAL ).
              APPEND VALUE #( %cid = agent-%cid ) TO failed-agent.
              APPEND VALUE #(
                %cid           = agent-%cid
                %element-Zpcpr = if_abap_behv=>mk-on
                %element-Zimpp = if_abap_behv=>mk-on
                %element-Zimco = if_abap_behv=>mk-on
                %msg           = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text     = 'Inserire % Prov e Base di Calcolo insieme, oppure solo Importo Provvigione.' )
              ) TO reported-agent.
              CONTINUE.
            ENDIF.

            IF agent_zpcpr IS NOT INITIAL
              AND agent_zimpp IS NOT INITIAL.
              agent_zimco = agent_zimpp * agent_zpcpr / 100.
            ENDIF.

            APPEND VALUE #(
              %cid  = agent-%cid
              %pid  = agent_pid
              Zclpr = position-Zclpr
              Bukrs = position-Bukrs
              Vkorg = position-Vkorg
              Vtweg = position-Vtweg
              Vbeln = position-Vbeln
              Gjahr = position-Gjahr
              Posnr = position-Posnr
              Zidag = zidag
              Zcdaz = zcdaz
            ) TO mapped-agent.

            APPEND VALUE #(
              pid   = agent_pid
              zclpr = position-Zclpr
              bukrs = position-Bukrs
              vkorg = position-Vkorg
              vtweg = position-Vtweg
              vbeln = position-Vbeln
              gjahr = position-Gjahr
              posnr = position-Posnr
              zidag = zidag
              zcdaz = zcdaz
            ) TO lcl_buffer=>mt_create_agent_key.

            APPEND VALUE /eacm/prdo(
              zclpr   = position-Zclpr
              bukrs   = position-Bukrs
              vkorg   = position-Vkorg
              vtweg   = position-Vtweg
              vbeln   = position-Vbeln
              gjahr   = position-Gjahr
              posnr   = position-Posnr
              zidag   = zidag
              zcdaz   = zcdaz
              matnr   = position_material
              maktx   = position_material_description
              menge   = position_quantity
              ziman   = agent_ziman
              zimar   = agent-Zimar
              zpcpr   = agent_zpcpr
              zimpp   = agent_zimpp
              zimco   = agent_zimco
              zimpu   = COND #( WHEN agent_zpcpr IS INITIAL THEN agent-Zimpu )
              waerk   = position_waerk
              zwaer   = COND #( WHEN agent-Zwaer IS NOT INITIAL THEN agent-Zwaer ELSE position_waerk )
              kunrg   = agent-Kunrg
              budat   = agent-Budat
              kurrf   = agent-Kurrf
              ztpag   = agent-Ztpag
              zdest   = agent-Zdest
              zutmx   = position_unitmeasure
              fkdat   = position_fkdat
            ) TO lcl_buffer=>mt_create_agent.

          CATCH cx_uuid_error INTO DATA(uuid_error).
            APPEND VALUE #( %cid = agent-%cid ) TO failed-agent.
            APPEND VALUE #(
              %cid = agent-%cid
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = uuid_error->get_text( ) )
            ) TO reported-agent.
        ENDTRY.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
**********************************************************************
**********************************************************************
CLASS lhc_Agent DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Agent.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Agent.

    METHODS read FOR READ
      IMPORTING keys FOR READ Agent RESULT result.

    METHODS rba_Document FOR READ
      IMPORTING keys_rba FOR READ Agent\_Document FULL result_requested RESULT result LINK association_links.

    METHODS rba_Position FOR READ
      IMPORTING keys_rba FOR READ Agent\_Position FULL result_requested RESULT result LINK association_links.

    METHODS CalculateZimco
  FOR DETERMINE ON MODIFY
  IMPORTING keys FOR Agent~CalculateZimco.

ENDCLASS.
**********************************************************************
CLASS lhc_Agent IMPLEMENTATION.

METHOD update.

LOOP AT entities INTO DATA(agent).

    SELECT SINGLE zstre
      FROM /eacm/prdo
      WHERE zclpr = @agent-Zclpr
        AND bukrs = @agent-Bukrs
        AND vkorg = @agent-Vkorg
        AND vtweg = @agent-Vtweg
        AND vbeln = @agent-Vbeln
        AND gjahr = @agent-Gjahr
        AND posnr = @agent-Posnr
        AND zidag = @agent-Zidag
        AND zcdaz = @agent-Zcdaz
        AND zstre <> 'D'
        AND zmodi <> 'D'
      INTO @DATA(agent_zstre).

    IF sy-subrc = 0 AND agent_zstre = 'C'.
      APPEND VALUE #( %tky = agent-%tky ) TO failed-agent.
      APPEND VALUE #(
        %tky = agent-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'Stato C: consentito solo inserimento agenti.' )
      ) TO reported-agent.
      CONTINUE.
    ENDIF.

    DATA(agent_ziman) = agent-Ziman.

            IF agent-ZPCPR IS NOT INITIAL.
agent-ZIMCO = agent-ZIMPP * agent-ZPCPR / 100.
            ENDIF.

    DATA(agent_zpcpr) = agent-Zpcpr.
    DATA(agent_zimpp) = agent-Zimpp.
    DATA(agent_zimco) = agent-Zimco.

    IF ( agent_zpcpr IS INITIAL AND agent_zimpp IS NOT INITIAL )
      OR ( agent_zpcpr IS NOT INITIAL AND agent_zimpp IS INITIAL ).
      APPEND VALUE #( %tky = agent-%tky ) TO failed-agent.
      APPEND VALUE #(
        %tky           = agent-%tky
        %element-Zpcpr = if_abap_behv=>mk-on
        %element-Zimpp = if_abap_behv=>mk-on
        %element-Zimco = if_abap_behv=>mk-on
        %msg           = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'Inserire % Prov e Base di Calcolo insieme, oppure solo Importo Provvigione.' )
      ) TO reported-agent.
      CONTINUE.
    ENDIF.

    IF agent_zpcpr IS NOT INITIAL
      AND agent_zimpp IS NOT INITIAL.
      agent_zimco = agent_zimpp * agent_zpcpr / 100.
    ENDIF.

    APPEND VALUE /eacm/prdo(
      zclpr = agent-Zclpr
      bukrs = agent-Bukrs
      vkorg = agent-Vkorg
      vtweg = agent-Vtweg
      vbeln = agent-Vbeln
      gjahr = agent-Gjahr
      posnr = agent-Posnr
      zidag = agent-Zidag
      zcdaz = agent-Zcdaz
      ziman = agent_ziman
      zimar = agent-Zimar
      zpcpr = agent_zpcpr
      zimpp = agent_zimpp
      zimco = agent_zimco
      zimpu = agent-Zimpu
      zwaer = agent-Zwaer
      kunrg = agent-Kunrg
      budat = agent-Budat
      kurrf = agent-Kurrf
      ztpag = agent-Ztpag
      zdest = agent-Zdest
    ) TO lcl_buffer=>mt_update_agent.

  ENDLOOP.

  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(agent_key).

      SELECT SINGLE zstre
        FROM /eacm/prdo
        WHERE zclpr = @agent_key-Zclpr
          AND bukrs = @agent_key-Bukrs
          AND vkorg = @agent_key-Vkorg
          AND vtweg = @agent_key-Vtweg
          AND vbeln = @agent_key-Vbeln
          AND gjahr = @agent_key-Gjahr
          AND posnr = @agent_key-Posnr
          AND zidag = @agent_key-Zidag
          AND zcdaz = @agent_key-Zcdaz
          AND zstre <> 'D'
          AND zmodi <> 'D'
        INTO @DATA(agent_delete_zstre).

      IF sy-subrc = 0 AND agent_delete_zstre = 'C'.
        APPEND VALUE #( %tky = agent_key-%tky ) TO failed-agent.
        APPEND VALUE #(
          %tky = agent_key-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Stato C: consentito solo inserimento agenti.' )
        ) TO reported-agent.
        CONTINUE.
      ENDIF.

      APPEND VALUE /eacm/prdo(
        zclpr = agent_key-Zclpr
        bukrs = agent_key-Bukrs
        vkorg = agent_key-Vkorg
        vtweg = agent_key-Vtweg
        vbeln = agent_key-Vbeln
        gjahr = agent_key-Gjahr
        posnr = agent_key-Posnr
        zidag = agent_key-Zidag
        zcdaz = agent_key-Zcdaz
      ) TO lcl_buffer=>mt_delete_agent.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM /eacm/prdo AS z
      INNER JOIN @keys AS k
        ON  z~zclpr = k~Zclpr
        AND z~bukrs = k~Bukrs
        AND z~vkorg = k~Vkorg
        AND z~vtweg = k~Vtweg
        AND z~vbeln = k~Vbeln
        AND z~gjahr = k~Gjahr
        AND z~posnr = k~Posnr
        AND z~zidag = k~Zidag
        AND z~zcdaz = k~Zcdaz
      FIELDS z~zclpr,
             z~bukrs,
             z~vkorg,
             z~vtweg,
             z~vbeln,
             z~gjahr,
             z~posnr,
             z~zidag,
             z~zcdaz,
             z~ziman,
             z~zimar,
             z~zpcpr,
             z~zimpp,
             z~zimco,
             z~zimpu,
             z~zwaer,
             z~kunrg,
             z~budat,
             z~kurrf,
             z~ztpag,
             z~zstre,
             z~zmodi,
             z~zcamd,
             z~zdtmd,
             z~zormd,
             z~zdest,
             z~menge,
             z~zutmx,
             z~fkdat,
             z~waerk,
             z~local_last_changed_at
       WHERE z~posnr <> '000000'
         AND z~zstre <> 'D'
         AND z~zmodi <> 'D'
       INTO TABLE @DATA(agents).

    result = VALUE #( FOR agent IN agents
      (
        Zclpr              = agent-zclpr
        Bukrs              = agent-bukrs
        Vkorg              = agent-vkorg
        Vtweg              = agent-vtweg
        Vbeln              = agent-vbeln
        Gjahr              = agent-gjahr
        Posnr              = agent-posnr
        Zidag              = agent-zidag
        Zcdaz              = agent-zcdaz
        Ziman              = agent-ziman
        Zimar              = agent-zimar
        Zpcpr              = agent-zpcpr
        Zimpp              = agent-zimpp
        Zimco              = agent-zimco
        Zimpu              = agent-zimpu
        Zwaer              = agent-zwaer
        Kunrg              = agent-kunrg
        Budat              = agent-budat
        Kurrf              = agent-kurrf
        Ztpag              = agent-ztpag
        Zstre              = agent-zstre
        Zmodi              = agent-zmodi
        Zcamd              = agent-zcamd
        Zdtmd              = agent-zdtmd
        Zormd              = agent-zormd
        Zdest              = agent-zdest
        UnitMeasure        = agent-zutmx
        DocumentDate       = agent-fkdat
        LocalLastChangedAt = agent-local_last_changed_at
      ) ).
  ENDMETHOD.

  METHOD rba_Position.
    LOOP AT keys_rba INTO DATA(agent_key).
      APPEND VALUE #(
        source-%tky = agent_key-%tky
        target-%tky = VALUE #(
          %is_draft = agent_key-%is_draft
          Zclpr     = agent_key-Zclpr
          Bukrs     = agent_key-Bukrs
          Vkorg     = agent_key-Vkorg
          Vtweg     = agent_key-Vtweg
          Vbeln     = agent_key-Vbeln
          Gjahr     = agent_key-Gjahr
          Posnr     = agent_key-Posnr
        )
      ) TO association_links.

      IF result_requested = abap_true.
        APPEND VALUE #(
          %is_draft = agent_key-%is_draft
          Zclpr     = agent_key-Zclpr
          Bukrs     = agent_key-Bukrs
          Vkorg     = agent_key-Vkorg
          Vtweg     = agent_key-Vtweg
          Vbeln     = agent_key-Vbeln
          Gjahr     = agent_key-Gjahr
          Posnr     = agent_key-Posnr
        ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Document.
    LOOP AT keys_rba INTO DATA(agent_key).
      APPEND VALUE #(
        source-%tky = agent_key-%tky
        target-%tky = VALUE #(
          %is_draft = agent_key-%is_draft
          Zclpr     = agent_key-Zclpr
          Bukrs     = agent_key-Bukrs
          Vkorg     = agent_key-Vkorg
          Vtweg     = agent_key-Vtweg
          Vbeln     = agent_key-Vbeln
          Gjahr     = agent_key-Gjahr
        )
      ) TO association_links.

      IF result_requested = abap_true.
        APPEND VALUE #(
          %is_draft = agent_key-%is_draft
          Zclpr     = agent_key-Zclpr
          Bukrs     = agent_key-Bukrs
          Vkorg     = agent_key-Vkorg
          Vtweg     = agent_key-Vtweg
          Vbeln     = agent_key-Vbeln
          Gjahr     = agent_key-Gjahr
        ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD CalculateZimco.

  READ ENTITIES OF /EACM/I_PRDO_DOC IN LOCAL MODE
    ENTITY Agent
    FIELDS ( ZIMPP ZPCPR )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_agents).

  LOOP AT lt_agents ASSIGNING FIELD-SYMBOL(<agent>).

    IF <agent>-ZPCPR IS NOT INITIAL.
      <agent>-ZIMCO = <agent>-ZIMPP * <agent>-ZPCPR / 100.
    ELSE.
      CLEAR <agent>-ZIMCO.
    ENDIF.

  ENDLOOP.

  MODIFY ENTITIES OF /EACM/I_PRDO_DOC IN LOCAL MODE
    ENTITY Agent
    UPDATE FIELDS ( ZIMCO )
    WITH VALUE #(
      FOR ls_agent IN lt_agents
      (
        %tky  = ls_agent-%tky
        ZIMCO = ls_agent-ZIMCO
      )
    )
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

ENDMETHOD.











ENDCLASS.
**********************************************************************
**********************************************************************
CLASS lsc_I_PRDO_DOC DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_I_PRDO_DOC IMPLEMENTATION.

 METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
    DATA documents_to_check TYPE STANDARD TABLE OF lcl_buffer=>ty_create_document_key.

    documents_to_check = lcl_buffer=>mt_create_document_key.

    LOOP AT lcl_buffer=>mt_create_position_key INTO DATA(create_position_key).
      APPEND VALUE #(
        zclpr = create_position_key-zclpr
        bukrs = create_position_key-bukrs
        vkorg = create_position_key-vkorg
        vtweg = create_position_key-vtweg
        vbeln = create_position_key-vbeln
        gjahr = create_position_key-gjahr
      ) TO documents_to_check.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_create_agent_key INTO DATA(create_agent_key).
      APPEND VALUE #(
        zclpr = create_agent_key-zclpr
        bukrs = create_agent_key-bukrs
        vkorg = create_agent_key-vkorg
        vtweg = create_agent_key-vtweg
        vbeln = create_agent_key-vbeln
        gjahr = create_agent_key-gjahr
      ) TO documents_to_check.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_update_position INTO DATA(update_position).
      APPEND VALUE #(
        zclpr = update_position-zclpr
        bukrs = update_position-bukrs
        vkorg = update_position-vkorg
        vtweg = update_position-vtweg
        vbeln = update_position-vbeln
        gjahr = update_position-gjahr
      ) TO documents_to_check.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_update_agent INTO DATA(update_agent).
      APPEND VALUE #(
        zclpr = update_agent-zclpr
        bukrs = update_agent-bukrs
        vkorg = update_agent-vkorg
        vtweg = update_agent-vtweg
        vbeln = update_agent-vbeln
        gjahr = update_agent-gjahr
      ) TO documents_to_check.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_delete_position INTO DATA(delete_position).
      APPEND VALUE #(
        zclpr = delete_position-zclpr
        bukrs = delete_position-bukrs
        vkorg = delete_position-vkorg
        vtweg = delete_position-vtweg
        vbeln = delete_position-vbeln
        gjahr = delete_position-gjahr
      ) TO documents_to_check.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_delete_agent INTO DATA(delete_agent).
      APPEND VALUE #(
        zclpr = delete_agent-zclpr
        bukrs = delete_agent-bukrs
        vkorg = delete_agent-vkorg
        vtweg = delete_agent-vtweg
        vbeln = delete_agent-vbeln
        gjahr = delete_agent-gjahr
      ) TO documents_to_check.
    ENDLOOP.

    SORT documents_to_check BY zclpr bukrs vkorg vtweg vbeln gjahr.
    DELETE ADJACENT DUPLICATES FROM documents_to_check
      COMPARING zclpr bukrs vkorg vtweg vbeln gjahr.

    LOOP AT documents_to_check INTO DATA(document_to_check).
      IF line_exists( lcl_buffer=>mt_delete_document[
           zclpr = document_to_check-zclpr
           bukrs = document_to_check-bukrs
           vkorg = document_to_check-vkorg
           vtweg = document_to_check-vtweg
           vbeln = document_to_check-vbeln
           gjahr = document_to_check-gjahr ] ).
        CONTINUE.
      ENDIF.

      DATA(has_agent) = abap_false.

      LOOP AT lcl_buffer=>mt_create_agent INTO DATA(create_agent)
        WHERE zclpr = document_to_check-zclpr
          AND bukrs = document_to_check-bukrs
          AND vkorg = document_to_check-vkorg
          AND vtweg = document_to_check-vtweg
          AND vbeln = document_to_check-vbeln
          AND gjahr = document_to_check-gjahr
          AND posnr <> '000000'
          AND zidag IS NOT INITIAL
          AND zcdaz IS NOT INITIAL.
        has_agent = abap_true.
        EXIT.
      ENDLOOP.

      IF has_agent = abap_false.
        SELECT SINGLE zidag
          FROM /EACM/PRDO_AGT_D
          WHERE zclpr = @document_to_check-zclpr
            AND bukrs = @document_to_check-bukrs
            AND vkorg = @document_to_check-vkorg
            AND vtweg = @document_to_check-vtweg
            AND vbeln = @document_to_check-vbeln
            AND gjahr = @document_to_check-gjahr
            AND posnr <> '000000'
            AND zidag <> ''
            AND zcdaz <> ''
          INTO @DATA(draft_zidag).

        IF sy-subrc = 0.
          has_agent = abap_true.
        ENDIF.
      ENDIF.

      IF has_agent = abap_false.
        SELECT zclpr,
               bukrs,
               vkorg,
               vtweg,
               vbeln,
               gjahr,
               posnr,
               zidag,
               zcdaz
          FROM /eacm/prdo
            WHERE zclpr = @document_to_check-zclpr
              AND bukrs = @document_to_check-bukrs
              AND vkorg = @document_to_check-vkorg
              AND vtweg = @document_to_check-vtweg
              AND vbeln = @document_to_check-vbeln
              AND gjahr = @document_to_check-gjahr
              AND posnr <> '000000'
              AND zidag <> ''
              AND zcdaz <> ''
              AND zstre <> 'D'
              AND zmodi <> 'D'
          INTO TABLE @DATA(active_agents).

        LOOP AT active_agents INTO DATA(active_agent).          "#EC CI_NOORDER
          IF line_exists( lcl_buffer=>mt_delete_position[
               zclpr = active_agent-zclpr
               bukrs = active_agent-bukrs
               vkorg = active_agent-vkorg
               vtweg = active_agent-vtweg
               vbeln = active_agent-vbeln
               gjahr = active_agent-gjahr
               posnr = active_agent-posnr ] ).
            CONTINUE.
          ENDIF.

          IF line_exists( lcl_buffer=>mt_delete_agent[
               zclpr = active_agent-zclpr
               bukrs = active_agent-bukrs
               vkorg = active_agent-vkorg
               vtweg = active_agent-vtweg
               vbeln = active_agent-vbeln
               gjahr = active_agent-gjahr
               posnr = active_agent-posnr
               zidag = active_agent-zidag
               zcdaz = active_agent-zcdaz ] ).
            CONTINUE.
          ENDIF.

          has_agent = abap_true.
          EXIT.                                           "#EC CI_NOORDER
        ENDLOOP.                                          "#EC CI_NOORDER
      ENDIF.

      IF has_agent = abap_false.
        APPEND VALUE #(
          %pid  = document_to_check-pid
          Zclpr = document_to_check-zclpr
          Bukrs = document_to_check-bukrs
          Vkorg = document_to_check-vkorg
          Vtweg = document_to_check-vtweg
          Vbeln = document_to_check-vbeln
          Gjahr = document_to_check-gjahr
        ) TO failed-document.

        APPEND VALUE #(
          %pid  = document_to_check-pid
          Zclpr = document_to_check-zclpr
          Bukrs = document_to_check-bukrs
          Vkorg = document_to_check-vkorg
          Vtweg = document_to_check-vtweg
          Vbeln = document_to_check-vbeln
          Gjahr = document_to_check-gjahr
          %msg  = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Inserire almeno un agente prima del salvataggio.' )
        ) TO reported-document.
      ENDIF.

      DATA(document_currency) = VALUE /eacm/prdo-zwaer( ).
      DATA(document_date) = VALUE /eacm/prdo-fkdat( ).
      DATA(has_currency_conflict) = abap_false.
      DATA(has_date_conflict) = abap_false.
      DATA(has_document_date_update) = abap_false.

      LOOP AT lcl_buffer=>mt_create_position INTO DATA(create_position_currency)
        WHERE zclpr = document_to_check-zclpr
          AND bukrs = document_to_check-bukrs
          AND vkorg = document_to_check-vkorg
          AND vtweg = document_to_check-vtweg
          AND vbeln = document_to_check-vbeln
          AND gjahr = document_to_check-gjahr.
        IF create_position_currency-waerk IS NOT INITIAL.
          IF document_currency IS INITIAL.
            document_currency = create_position_currency-waerk.
          ELSEIF document_currency <> create_position_currency-waerk.
            has_currency_conflict = abap_true.
          ENDIF.
        ENDIF.

        IF create_position_currency-fkdat IS NOT INITIAL.
          IF document_date IS INITIAL.
            document_date = create_position_currency-fkdat.
          ELSEIF document_date <> create_position_currency-fkdat.
            has_date_conflict = abap_true.
          ENDIF.
        ENDIF.
      ENDLOOP.

      LOOP AT lcl_buffer=>mt_create_agent INTO DATA(create_agent_check)
        WHERE zclpr = document_to_check-zclpr
          AND bukrs = document_to_check-bukrs
          AND vkorg = document_to_check-vkorg
          AND vtweg = document_to_check-vtweg
          AND vbeln = document_to_check-vbeln
          AND gjahr = document_to_check-gjahr.
        IF create_agent_check-zwaer IS NOT INITIAL.
          IF document_currency IS INITIAL.
            document_currency = create_agent_check-zwaer.
          ELSEIF document_currency <> create_agent_check-zwaer.
            has_currency_conflict = abap_true.
          ENDIF.
        ENDIF.

        IF create_agent_check-fkdat IS NOT INITIAL.
          IF document_date IS INITIAL.
            document_date = create_agent_check-fkdat.
          ELSEIF document_date <> create_agent_check-fkdat.
            has_date_conflict = abap_true.
          ENDIF.
        ENDIF.
      ENDLOOP.

      LOOP AT lcl_buffer=>mt_update_position INTO DATA(update_position_currency)
        WHERE zclpr = document_to_check-zclpr
          AND bukrs = document_to_check-bukrs
          AND vkorg = document_to_check-vkorg
          AND vtweg = document_to_check-vtweg
          AND vbeln = document_to_check-vbeln
          AND gjahr = document_to_check-gjahr.
        IF update_position_currency-waerk IS NOT INITIAL.
          IF document_currency IS INITIAL.
            document_currency = update_position_currency-waerk.
          ELSEIF document_currency <> update_position_currency-waerk.
            has_currency_conflict = abap_true.
          ENDIF.
        ENDIF.
      ENDLOOP.

      LOOP AT lcl_buffer=>mt_create_document_key INTO DATA(create_document_date)
        WHERE zclpr = document_to_check-zclpr
          AND bukrs = document_to_check-bukrs
          AND vkorg = document_to_check-vkorg
          AND vtweg = document_to_check-vtweg
          AND vbeln = document_to_check-vbeln
          AND gjahr = document_to_check-gjahr.
        IF create_document_date-fkdat IS NOT INITIAL.
          IF document_date IS INITIAL.
            document_date = create_document_date-fkdat.
          ELSEIF document_date <> create_document_date-fkdat.
            has_date_conflict = abap_true.
          ENDIF.
        ENDIF.
      ENDLOOP.

      LOOP AT lcl_buffer=>mt_update_document INTO DATA(update_document_date)
        WHERE zclpr = document_to_check-zclpr
          AND bukrs = document_to_check-bukrs
          AND vkorg = document_to_check-vkorg
          AND vtweg = document_to_check-vtweg
          AND vbeln = document_to_check-vbeln
          AND gjahr = document_to_check-gjahr.
        has_document_date_update = abap_true.

        IF update_document_date-fkdat IS NOT INITIAL.
          IF document_date IS INITIAL.
            document_date = update_document_date-fkdat.
          ELSEIF document_date <> update_document_date-fkdat.
            has_date_conflict = abap_true.
          ENDIF.
        ENDIF.
      ENDLOOP.

      SELECT posnr,
             zidag,
             zcdaz,
             fkdat,
             zwaer
        FROM /eacm/prdo
        WHERE zclpr = @document_to_check-zclpr
          AND bukrs = @document_to_check-bukrs
          AND vkorg = @document_to_check-vkorg
          AND vtweg = @document_to_check-vtweg
          AND vbeln = @document_to_check-vbeln
          AND gjahr = @document_to_check-gjahr
          AND posnr <> '000000'
          AND zstre <> 'D'
          AND zmodi <> 'D'
        INTO TABLE @DATA(document_active_rows).

      LOOP AT document_active_rows INTO DATA(document_active_row).
        IF line_exists( lcl_buffer=>mt_delete_position[
             zclpr = document_to_check-zclpr
             bukrs = document_to_check-bukrs
             vkorg = document_to_check-vkorg
             vtweg = document_to_check-vtweg
             vbeln = document_to_check-vbeln
             gjahr = document_to_check-gjahr
             posnr = document_active_row-posnr ] )
          OR line_exists( lcl_buffer=>mt_delete_agent[
             zclpr = document_to_check-zclpr
             bukrs = document_to_check-bukrs
             vkorg = document_to_check-vkorg
             vtweg = document_to_check-vtweg
             vbeln = document_to_check-vbeln
             gjahr = document_to_check-gjahr
             posnr = document_active_row-posnr
             zidag = document_active_row-zidag
             zcdaz = document_active_row-zcdaz ] ).
          CONTINUE.
        ENDIF.

        IF NOT line_exists( lcl_buffer=>mt_update_position[
             zclpr = document_to_check-zclpr
             bukrs = document_to_check-bukrs
             vkorg = document_to_check-vkorg
             vtweg = document_to_check-vtweg
             vbeln = document_to_check-vbeln
             gjahr = document_to_check-gjahr
             posnr = document_active_row-posnr ] )
          AND document_active_row-zwaer IS NOT INITIAL.
          IF document_currency IS INITIAL.
            document_currency = document_active_row-zwaer.
          ELSEIF document_currency <> document_active_row-zwaer.
            has_currency_conflict = abap_true.
          ENDIF.
        ENDIF.

        IF has_document_date_update = abap_false
          AND document_active_row-fkdat IS NOT INITIAL.
          IF document_date IS INITIAL.
            document_date = document_active_row-fkdat.
          ELSEIF document_date <> document_active_row-fkdat.
            has_date_conflict = abap_true.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF has_currency_conflict = abap_true
        OR has_date_conflict = abap_true.
        APPEND VALUE #(
          %pid  = document_to_check-pid
          Zclpr = document_to_check-zclpr
          Bukrs = document_to_check-bukrs
          Vkorg = document_to_check-vkorg
          Vtweg = document_to_check-vtweg
          Vbeln = document_to_check-vbeln
          Gjahr = document_to_check-gjahr
        ) TO failed-document.
      ENDIF.

      IF has_currency_conflict = abap_true.
        APPEND VALUE #(
          %pid  = document_to_check-pid
          Zclpr = document_to_check-zclpr
          Bukrs = document_to_check-bukrs
          Vkorg = document_to_check-vkorg
          Vtweg = document_to_check-vtweg
          Vbeln = document_to_check-vbeln
          Gjahr = document_to_check-gjahr
          %msg  = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Il documento non puo contenere piu valute. Allineare WAERK/ZWAER.' )
        ) TO reported-document.
      ENDIF.

      IF has_date_conflict = abap_true.
        APPEND VALUE #(
          %pid           = document_to_check-pid
          Zclpr          = document_to_check-zclpr
          Bukrs          = document_to_check-bukrs
          Vkorg          = document_to_check-vkorg
          Vtweg          = document_to_check-vtweg
          Vbeln          = document_to_check-vbeln
          Gjahr          = document_to_check-gjahr
          %element-Fkdat = if_abap_behv=>mk-on
          %msg           = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Il documento non puo contenere date documento diverse.' )
        ) TO reported-document.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD adjust_numbers.
    DATA mapped_documents LIKE mapped-document.
    DATA mapped_positions LIKE mapped-position.
    DATA mapped_agents    LIKE mapped-agent.
    DATA document_keys TYPE STANDARD TABLE OF lcl_buffer=>ty_create_document_key.
    DATA position_keys TYPE STANDARD TABLE OF lcl_buffer=>ty_create_position_key.
    DATA agent_keys    TYPE STANDARD TABLE OF lcl_buffer=>ty_create_agent_key.
    DATA lv_number TYPE cl_numberrange_runtime=>nr_number.
    DATA lv_vbeln  TYPE vbeln.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_gjahr) = CONV gjahr( lv_today+0(4) ).

    mapped_documents = mapped-document.
    mapped_positions = mapped-position.
    mapped_agents = mapped-agent.
    document_keys = lcl_buffer=>mt_create_document_key.
    position_keys = lcl_buffer=>mt_create_position_key.
    agent_keys = lcl_buffer=>mt_create_agent_key.
    CLEAR mapped-document.
    CLEAR mapped-position.
    CLEAR mapped-agent.
    CLEAR lcl_buffer=>mt_document_key_map.

    IF document_keys IS INITIAL.
      LOOP AT mapped_documents INTO DATA(mapped_document).
        APPEND VALUE #(
          pid   = mapped_document-%pid
          zclpr = mapped_document-%tmp-Zclpr
          bukrs = mapped_document-%tmp-Bukrs
          vkorg = mapped_document-%tmp-Vkorg
          vtweg = mapped_document-%tmp-Vtweg
          vbeln = mapped_document-%tmp-Vbeln
          gjahr = mapped_document-%tmp-Gjahr
        ) TO document_keys.
      ENDLOOP.
    ENDIF.

    IF position_keys IS INITIAL.
      LOOP AT mapped_positions INTO DATA(mapped_position).
        APPEND VALUE #(
          pid   = mapped_position-%pid
          zclpr = mapped_position-%tmp-Zclpr
          bukrs = mapped_position-%tmp-Bukrs
          vkorg = mapped_position-%tmp-Vkorg
          vtweg = mapped_position-%tmp-Vtweg
          vbeln = mapped_position-%tmp-Vbeln
          gjahr = mapped_position-%tmp-Gjahr
          posnr = mapped_position-%tmp-Posnr
        ) TO position_keys.
      ENDLOOP.
    ENDIF.

    IF agent_keys IS INITIAL.
      LOOP AT mapped_agents INTO DATA(mapped_agent).
        APPEND VALUE #(
          pid   = mapped_agent-%pid
          zclpr = mapped_agent-%tmp-Zclpr
          bukrs = mapped_agent-%tmp-Bukrs
          vkorg = mapped_agent-%tmp-Vkorg
          vtweg = mapped_agent-%tmp-Vtweg
          vbeln = mapped_agent-%tmp-Vbeln
          gjahr = mapped_agent-%tmp-Gjahr
          posnr = mapped_agent-%tmp-Posnr
          zidag = mapped_agent-%tmp-Zidag
          zcdaz = mapped_agent-%tmp-Zcdaz
        ) TO agent_keys.
      ENDLOOP.
    ENDIF.

    LOOP AT document_keys INTO DATA(document_key).
      DATA(lv_final_gjahr) = COND gjahr(
        WHEN document_key-gjahr IS INITIAL THEN lv_gjahr
        ELSE document_key-gjahr ).

      IF document_key-vbeln IS NOT INITIAL
        AND document_key-vbeln(1) <> 'D'.
        lv_vbeln = |{ document_key-vbeln ALPHA = IN }|.
      ELSE.
        TRY.
            cl_numberrange_runtime=>number_get(
              EXPORTING
                object      = '/EACM/PRVG'
                nr_range_nr = '01'
              IMPORTING
                number      = lv_number
            ).

            DATA(lv_number_text) = CONV string( lv_number ).
            CONDENSE lv_number_text NO-GAPS.

            DATA(lv_number_length) = strlen( lv_number_text ).
            IF lv_number_length > 10.
              DATA(lv_offset) = lv_number_length - 10.
              lv_number_text = substring( val = lv_number_text off = lv_offset len = 10 ).
            ENDIF.

            lv_vbeln = lv_number_text.
            lv_vbeln = |{ lv_vbeln ALPHA = IN }|.

          CATCH cx_number_ranges INTO DATA(number_error).
            APPEND VALUE #(
              %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = number_error->get_text( ) )
            ) TO reported-document.
            CONTINUE.
        ENDTRY.
      ENDIF.

      APPEND VALUE #(
        %pre-%pid       = document_key-pid
        %pre-%tmp-Zclpr = document_key-zclpr
        %pre-%tmp-Bukrs = document_key-bukrs
        %pre-%tmp-Vkorg = document_key-vkorg
        %pre-%tmp-Vtweg = document_key-vtweg
        %pre-%tmp-Vbeln = document_key-vbeln
        %pre-%tmp-Gjahr = document_key-gjahr
        %key-Zclpr      = document_key-zclpr
        %key-Bukrs      = document_key-bukrs
        %key-Vkorg      = document_key-vkorg
        %key-Vtweg      = document_key-vtweg
        %key-Vbeln      = lv_vbeln
        %key-Gjahr      = lv_final_gjahr
      ) TO mapped-document.

      APPEND VALUE #(
        zclpr     = document_key-zclpr
        bukrs     = document_key-bukrs
        vkorg     = document_key-vkorg
        vtweg     = document_key-vtweg
        old_vbeln = document_key-vbeln
        old_gjahr = document_key-gjahr
        new_vbeln = lv_vbeln
        new_gjahr = lv_final_gjahr
      ) TO lcl_buffer=>mt_document_key_map.
    ENDLOOP.

    LOOP AT position_keys INTO DATA(position_key).
      READ TABLE lcl_buffer=>mt_document_key_map INTO DATA(position_key_map)
        WITH KEY zclpr     = position_key-zclpr
                 bukrs     = position_key-bukrs
                 vkorg     = position_key-vkorg
                 vtweg     = position_key-vtweg
                 old_vbeln = position_key-vbeln
                 old_gjahr = position_key-gjahr.

      DATA(position_vbeln) = COND vbeln(
        WHEN sy-subrc = 0 THEN position_key_map-new_vbeln
        ELSE position_key-vbeln ).
      DATA(position_gjahr) = COND gjahr(
        WHEN sy-subrc = 0 THEN position_key_map-new_gjahr
        ELSE position_key-gjahr ).

      APPEND VALUE #(
        %pre-%pid       = position_key-pid
        %pre-%tmp-Zclpr = position_key-zclpr
        %pre-%tmp-Bukrs = position_key-bukrs
        %pre-%tmp-Vkorg = position_key-vkorg
        %pre-%tmp-Vtweg = position_key-vtweg
        %pre-%tmp-Vbeln = position_key-vbeln
        %pre-%tmp-Gjahr = position_key-gjahr
        %pre-%tmp-Posnr = position_key-posnr
        %key-Zclpr      = position_key-zclpr
        %key-Bukrs      = position_key-bukrs
        %key-Vkorg      = position_key-vkorg
        %key-Vtweg      = position_key-vtweg
        %key-Vbeln      = position_vbeln
        %key-Gjahr      = position_gjahr
        %key-Posnr      = position_key-posnr
      ) TO mapped-position.
    ENDLOOP.

    LOOP AT agent_keys INTO DATA(agent_key).
      READ TABLE lcl_buffer=>mt_document_key_map INTO DATA(agent_key_map)
        WITH KEY zclpr     = agent_key-zclpr
                 bukrs     = agent_key-bukrs
                 vkorg     = agent_key-vkorg
                 vtweg     = agent_key-vtweg
                 old_vbeln = agent_key-vbeln
                 old_gjahr = agent_key-gjahr.

      DATA(agent_vbeln) = COND vbeln(
        WHEN sy-subrc = 0 THEN agent_key_map-new_vbeln
        ELSE agent_key-vbeln ).
      DATA(agent_gjahr) = COND gjahr(
        WHEN sy-subrc = 0 THEN agent_key_map-new_gjahr
        ELSE agent_key-gjahr ).

      APPEND VALUE #(
        %pre-%pid       = agent_key-pid
        %pre-%tmp-Zclpr = agent_key-zclpr
        %pre-%tmp-Bukrs = agent_key-bukrs
        %pre-%tmp-Vkorg = agent_key-vkorg
        %pre-%tmp-Vtweg = agent_key-vtweg
        %pre-%tmp-Vbeln = agent_key-vbeln
        %pre-%tmp-Gjahr = agent_key-gjahr
        %pre-%tmp-Posnr = agent_key-posnr
        %pre-%tmp-Zidag = agent_key-zidag
        %pre-%tmp-Zcdaz = agent_key-zcdaz
        %key-Zclpr      = agent_key-zclpr
        %key-Bukrs      = agent_key-bukrs
        %key-Vkorg      = agent_key-vkorg
        %key-Vtweg      = agent_key-vtweg
        %key-Vbeln      = agent_vbeln
        %key-Gjahr      = agent_gjahr
        %key-Posnr      = agent_key-posnr
        %key-Zidag      = agent_key-zidag
        %key-Zcdaz      = agent_key-zcdaz
      ) TO mapped-agent.
    ENDLOOP.
  ENDMETHOD.

  METHOD save.
    GET TIME STAMP FIELD DATA(now).
    DATA system_time TYPE syuzeit.
*    GET TIME FIELD system_time.
    DATA(system_date) = cl_abap_context_info=>get_system_date( ).
    DATA(user_name) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT lcl_buffer=>mt_document_key_map INTO DATA(key_map).
      LOOP AT lcl_buffer=>mt_create_position ASSIGNING FIELD-SYMBOL(<create_position>)
        WHERE zclpr = key_map-zclpr
          AND bukrs = key_map-bukrs
          AND vkorg = key_map-vkorg
          AND vtweg = key_map-vtweg
          AND vbeln = key_map-old_vbeln
          AND gjahr = key_map-old_gjahr.
        <create_position>-vbeln = key_map-new_vbeln.
        <create_position>-gjahr = key_map-new_gjahr.
      ENDLOOP.

      LOOP AT lcl_buffer=>mt_create_agent ASSIGNING FIELD-SYMBOL(<create_agent>)
        WHERE zclpr = key_map-zclpr
          AND bukrs = key_map-bukrs
          AND vkorg = key_map-vkorg
          AND vtweg = key_map-vtweg
          AND vbeln = key_map-old_vbeln
          AND gjahr = key_map-old_gjahr.
        <create_agent>-vbeln = key_map-new_vbeln.
        <create_agent>-gjahr = key_map-new_gjahr.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_create_document_key INTO DATA(create_document_key)
      WHERE fkdat IS NOT INITIAL.
      DATA(create_document_vbeln) = create_document_key-vbeln.
      DATA(create_document_gjahr) = create_document_key-gjahr.

      READ TABLE lcl_buffer=>mt_document_key_map INTO DATA(create_document_key_map)
        WITH KEY zclpr     = create_document_key-zclpr
                 bukrs     = create_document_key-bukrs
                 vkorg     = create_document_key-vkorg
                 vtweg     = create_document_key-vtweg
                 old_vbeln = create_document_key-vbeln
                 old_gjahr = create_document_key-gjahr.

      IF sy-subrc = 0.
        create_document_vbeln = create_document_key_map-new_vbeln.
        create_document_gjahr = create_document_key_map-new_gjahr.
      ENDIF.

      LOOP AT lcl_buffer=>mt_create_position ASSIGNING FIELD-SYMBOL(<create_position_date>)
        WHERE zclpr = create_document_key-zclpr
          AND bukrs = create_document_key-bukrs
          AND vkorg = create_document_key-vkorg
          AND vtweg = create_document_key-vtweg
          AND vbeln = create_document_vbeln
          AND gjahr = create_document_gjahr.
        <create_position_date>-fkdat = create_document_key-fkdat.
      ENDLOOP.

      LOOP AT lcl_buffer=>mt_create_agent ASSIGNING FIELD-SYMBOL(<create_agent_date>)
        WHERE zclpr = create_document_key-zclpr
          AND bukrs = create_document_key-bukrs
          AND vkorg = create_document_key-vkorg
          AND vtweg = create_document_key-vtweg
          AND vbeln = create_document_vbeln
          AND gjahr = create_document_gjahr.
        <create_agent_date>-fkdat = create_document_key-fkdat.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_create_agent INTO DATA(create_agent).
      IF create_agent-posnr IS INITIAL
        OR create_agent-posnr = '000000'
        OR create_agent-zidag IS INITIAL
        OR create_agent-zcdaz IS INITIAL.
        CONTINUE.
      ENDIF.

      IF create_agent-created_by IS INITIAL.
        create_agent-created_by = user_name.
      ENDIF.

      IF create_agent-created_at IS INITIAL.
        create_agent-created_at = now.
      ENDIF.

      create_agent-changed_by = user_name.
      create_agent-changed_at = now.
      create_agent-local_last_changed_at = now.
      create_agent-zstre = space.
      create_agent-zmodi = space.

      IF create_agent-zaucr IS INITIAL.
        create_agent-zaucr = user_name.
      ENDIF.

      IF create_agent-zdtcr IS INITIAL.
        create_agent-zdtcr = system_date.
      ENDIF.

      IF create_agent-zorcr IS INITIAL.
        create_agent-zorcr = system_time.
      ENDIF.

      MODIFY /eacm/prdo FROM @create_agent.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_update_position INTO DATA(update_position).
      UPDATE /eacm/prdo SET
        matnr = @update_position-matnr,
        maktx = @update_position-maktx,
        waerk = @update_position-waerk,
        zwaer = @update_position-waerk,
        menge = @update_position-menge,
        changed_by = @user_name,
        changed_at = @now,
        local_last_changed_at = @now
      WHERE zclpr = @update_position-zclpr
        AND bukrs = @update_position-bukrs
        AND vkorg = @update_position-vkorg
        AND vtweg = @update_position-vtweg
        AND vbeln = @update_position-vbeln
        AND gjahr = @update_position-gjahr
        AND posnr = @update_position-posnr
        AND zstre <> 'D'
        AND zmodi <> 'D'.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_update_agent INTO DATA(update_agent).
      SELECT SINGLE *
        FROM /eacm/prdo
        WHERE zclpr = @update_agent-zclpr
          AND bukrs = @update_agent-bukrs
          AND vkorg = @update_agent-vkorg
          AND vtweg = @update_agent-vtweg
          AND vbeln = @update_agent-vbeln
          AND gjahr = @update_agent-gjahr
          AND posnr = @update_agent-posnr
          AND zidag = @update_agent-zidag
          AND zcdaz = @update_agent-zcdaz
          AND zstre <> 'D'
          AND zmodi <> 'D'
        INTO @DATA(current_agent).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      UPDATE /eacm/prdo SET
        zmodi = 'D',
        zstre = 'D',
        zcamd = @user_name,
        zdtmd = @system_date,
        zormd = @system_time,
        changed_by = @user_name,
        changed_at = @now,
        local_last_changed_at = @now
      WHERE zclpr = @update_agent-zclpr
        AND bukrs = @update_agent-bukrs
        AND vkorg = @update_agent-vkorg
        AND vtweg = @update_agent-vtweg
        AND vbeln = @update_agent-vbeln
        AND gjahr = @update_agent-gjahr
        AND posnr = @update_agent-posnr
        AND zidag = @update_agent-zidag
        AND zcdaz = @update_agent-zcdaz.

      SELECT MAX( zidag )
        FROM /eacm/prdo
        WHERE zclpr = @update_agent-zclpr
          AND bukrs = @update_agent-bukrs
          AND vkorg = @update_agent-vkorg
          AND vtweg = @update_agent-vtweg
          AND vbeln = @update_agent-vbeln
          AND gjahr = @update_agent-gjahr
          AND posnr = @update_agent-posnr
          AND zcdaz = @update_agent-zcdaz
        INTO @DATA(max_update_zidag).

      DATA(new_update_agent) = current_agent.
      DATA(new_zidag_number) = CONV i( max_update_zidag ) + 1.
      new_update_agent-zidag = CONV /eacm/zidag( |{ new_zidag_number WIDTH = 4 PAD = '0' ALIGN = RIGHT }| ).
      new_update_agent-ziman = update_agent-ziman.
      new_update_agent-zimar = update_agent-zimar.
      new_update_agent-zpcpr = update_agent-zpcpr.
      new_update_agent-zimpp = update_agent-zimpp.
      new_update_agent-zimco = update_agent-zimco.
      IF update_agent-zpcpr IS NOT INITIAL.
        CLEAR new_update_agent-zimpu.
      ELSEIF update_agent-zimpu IS NOT INITIAL.
        new_update_agent-zimpu = update_agent-zimpu.
      ENDIF.
      IF update_agent-zwaer IS NOT INITIAL.
        new_update_agent-zwaer = update_agent-zwaer.
      ENDIF.
      new_update_agent-kunrg = update_agent-kunrg.
      IF update_agent-budat IS NOT INITIAL.
        new_update_agent-budat = update_agent-budat.
      ENDIF.
      IF update_agent-kurrf IS NOT INITIAL.
        new_update_agent-kurrf = update_agent-kurrf.
      ENDIF.
      IF update_agent-ztpag IS NOT INITIAL.
        new_update_agent-ztpag = update_agent-ztpag.
      ENDIF.
      new_update_agent-zdest = update_agent-zdest.
      new_update_agent-zmodi = 'M'.
      new_update_agent-zstre = space.
      new_update_agent-zcamd = user_name.
      new_update_agent-zdtmd = system_date.
      new_update_agent-zormd = system_time.
      new_update_agent-changed_by = user_name.
      new_update_agent-changed_at = now.
      new_update_agent-local_last_changed_at = now.

      INSERT /eacm/prdo FROM @new_update_agent.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_update_document INTO DATA(update_document).
      UPDATE /eacm/prdo SET
        fkdat = @update_document-fkdat,
        waerk = @update_document-waerk,
        changed_by = @user_name,
        changed_at = @now,
        local_last_changed_at = @now
      WHERE zclpr = @update_document-zclpr
        AND bukrs = @update_document-bukrs
        AND vkorg = @update_document-vkorg
        AND vtweg = @update_document-vtweg
        AND vbeln = @update_document-vbeln
        AND gjahr = @update_document-gjahr
        AND posnr <> '000000'
        AND zstre <> 'D'
        AND zmodi <> 'D'.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_delete_agent INTO DATA(delete_agent).
      UPDATE /eacm/prdo SET
        zmodi = 'D',
        zstre = 'D',
        zcamd = @user_name,
        zdtmd = @system_date,
        zormd = @system_time,
        changed_by = @user_name,
        changed_at = @now,
        local_last_changed_at = @now
      WHERE zclpr = @delete_agent-zclpr
        AND bukrs = @delete_agent-bukrs
        AND vkorg = @delete_agent-vkorg
        AND vtweg = @delete_agent-vtweg
        AND vbeln = @delete_agent-vbeln
        AND gjahr = @delete_agent-gjahr
        AND posnr = @delete_agent-posnr
        AND zidag = @delete_agent-zidag
        AND zcdaz = @delete_agent-zcdaz
        AND zstre <> 'D'
        AND zmodi <> 'D'.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_delete_position INTO DATA(delete_position).
      UPDATE /eacm/prdo SET
        zmodi = 'D',
        zstre = 'D',
        zcamd = @user_name,
        zdtmd = @system_date,
        zormd = @system_time,
        changed_by = @user_name,
        changed_at = @now,
        local_last_changed_at = @now
      WHERE zclpr = @delete_position-zclpr
        AND bukrs = @delete_position-bukrs
        AND vkorg = @delete_position-vkorg
        AND vtweg = @delete_position-vtweg
        AND vbeln = @delete_position-vbeln
        AND gjahr = @delete_position-gjahr
        AND posnr = @delete_position-posnr
        AND zstre <> 'D'
        AND zmodi <> 'D'.
    ENDLOOP.

    LOOP AT lcl_buffer=>mt_delete_document INTO DATA(delete_document).
      UPDATE /eacm/prdo SET
        zmodi = 'D',
        zstre = 'D',
        zcamd = @user_name,
        zdtmd = @system_date,
        zormd = @system_time,
        changed_by = @user_name,
        changed_at = @now,
        local_last_changed_at = @now
      WHERE zclpr = @delete_document-zclpr
        AND bukrs = @delete_document-bukrs
        AND vkorg = @delete_document-vkorg
        AND vtweg = @delete_document-vtweg
        AND vbeln = @delete_document-vbeln
        AND gjahr = @delete_document-gjahr
        AND zstre <> 'D'
        AND zmodi <> 'D'.
    ENDLOOP.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR lcl_buffer=>mt_create_document_key.
    CLEAR lcl_buffer=>mt_create_position_key.
    CLEAR lcl_buffer=>mt_create_agent_key.
    CLEAR lcl_buffer=>mt_create_position.
    CLEAR lcl_buffer=>mt_create_agent.
    CLEAR lcl_buffer=>mt_update_document.
    CLEAR lcl_buffer=>mt_update_position.
    CLEAR lcl_buffer=>mt_update_agent.
    CLEAR lcl_buffer=>mt_delete_document.
    CLEAR lcl_buffer=>mt_delete_position.
    CLEAR lcl_buffer=>mt_delete_agent.
    CLEAR lcl_buffer=>mt_document_key_map.
  ENDMETHOD.

  METHOD cleanup_finalize.
    CLEAR lcl_buffer=>mt_create_document_key.
    CLEAR lcl_buffer=>mt_create_position_key.
    CLEAR lcl_buffer=>mt_create_agent_key.
    CLEAR lcl_buffer=>mt_create_position.
    CLEAR lcl_buffer=>mt_create_agent.
    CLEAR lcl_buffer=>mt_update_document.
    CLEAR lcl_buffer=>mt_update_position.
    CLEAR lcl_buffer=>mt_update_agent.
    CLEAR lcl_buffer=>mt_delete_document.
    CLEAR lcl_buffer=>mt_delete_position.
    CLEAR lcl_buffer=>mt_delete_agent.
    CLEAR lcl_buffer=>mt_document_key_map.
  ENDMETHOD.

ENDCLASS.
