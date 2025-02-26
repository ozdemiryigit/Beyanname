  METHOD get_documents.

    TYPES BEGIN OF lty_lfa1.
    TYPES lifnr TYPE i_supplier-Supplier.
    TYPES name1 TYPE i_supplier-OrganizationBPName1.
    TYPES name2 TYPE i_supplier-OrganizationBPName2.
    TYPES END OF lty_lfa1.

    DATA ls_collect     TYPE mty_collect.
    DATA lt_mg          TYPE mtty_mg.
    DATA lt_mg_range    TYPE mtty_mg.
    DATA lt_data        TYPE mtty_data.
    DATA lt_data_k      TYPE mtty_data.
    DATA lt_data_191    TYPE mtty_data_191.
    DATA lt_lfb1        TYPE mtty_lfb1.
    DATA ls_lfb1        TYPE mty_lfb1.
    DATA ls_data        TYPE mty_data.
    DATA ls_mg          TYPE mty_mg.
    DATA ls_detail      TYPE ztax_ddl_i_brf_detail.
    DATA lv_amount_k    TYPE i_glaccountlineitemrawdata-AmountInCompanyCodeCurrency.
    DATA lv_amount_191  TYPE i_glaccountlineitemrawdata-AmountInCompanyCodeCurrency.
    DATA lv_butxt       TYPE i_companycode-CompanyCodeName."t001-butxt.
    DATA lt_mmt         TYPE TABLE OF ztax_t_mmt.
    DATA ls_mmt         TYPE ztax_t_mmt.
    DATA ls_lfa1        TYPE lty_lfa1.
    DATA lt_lfa1        TYPE TABLE OF lty_lfa1.
    DATA lr_hkont       TYPE RANGE OF i_operationalacctgdocitem-GLAccount."bseg-hkont.
    FIELD-SYMBOLS <fs_collect>   TYPE mty_collect.
    FIELD-SYMBOLS <fs_data>      TYPE mty_data.
    FIELD-SYMBOLS <fs_data_191>  TYPE mty_data_191.
    FIELD-SYMBOLS <fs_detail>    TYPE ztax_ddl_i_brf_detail.

    CLEAR mt_collect.
    CLEAR mt_detail.
    CLEAR me->ms_button_pushed.

    me->ms_button_pushed-bel = abap_true.

    me->get_item_data( IMPORTING et_mg       = lt_mg
                                 et_data     = lt_data
                                 et_data_191 = lt_data_191
                                 et_lfb1     = lt_lfb1 ).

    lt_data_k = lt_data.

    CLEAR lt_mg_range[].
    MOVE-CORRESPONDING lt_mg[] TO lt_mg_range[].
    SORT lt_mg_range ASCENDING BY hkont.
    DELETE ADJACENT DUPLICATES FROM lt_mg_range COMPARING hkont.
    CLEAR lr_hkont[].

    lr_hkont = VALUE #( FOR ls_mg_range IN lt_mg_range
                      ( sign   = 'I'
                        option = 'EQ'
                        low    = ls_mg_range-hkont ) ).

    DELETE lt_data   WHERE racct NOT IN lr_hkont .
    DELETE lt_data_k WHERE lifnr EQ space AND racct IN lr_hkont.

    SORT lt_data_191 BY rbukrs
                        gjahr
                        belnr.

    SORT lt_data_k BY bukrs
                      gjahr
                      belnr.

    SORT lt_data BY bukrs
                    gjahr
                    belnr.

    LOOP AT lt_data INTO ls_data.
      CLEAR ls_collect.
      CLEAR ls_detail.
      CLEAR lv_amount_191.
      CLEAR lv_amount_k.

      CASE ls_data-lifnr.
        WHEN space.
          READ TABLE lt_mg INTO ls_mg WITH KEY bukrs = ls_data-bukrs
                                               hkont = ls_data-racct
                                               BINARY SEARCH.
        WHEN OTHERS.
          READ TABLE lt_lfb1 INTO ls_lfb1 WITH KEY bukrs = ls_data-bukrs
                                                   lifnr = ls_data-lifnr
                                                   BINARY SEARCH.

          READ TABLE lt_mg INTO ls_mg WITH KEY bukrs = ls_data-bukrs
                                               mindk = ls_lfb1-mindk
                                               BINARY SEARCH.
      ENDCASE.

      CHECK sy-subrc IS INITIAL.

      READ TABLE lt_data_191 TRANSPORTING NO FIELDS WITH KEY rbukrs = ls_data-bukrs
                                                             gjahr  = ls_data-gjahr
                                                             belnr  = ls_data-belnr
                                                             BINARY SEARCH.
      CASE sy-subrc.
        WHEN 0.
          LOOP AT lt_data_191 ASSIGNING <fs_data_191> FROM sy-tabix.
            IF <fs_data_191>-rbukrs NE ls_data-bukrs OR
               <fs_data_191>-gjahr  NE ls_data-gjahr OR
               <fs_data_191>-belnr  NE ls_data-belnr.
              EXIT.
            ENDIF.
            ADD <fs_data_191>-hsl TO lv_amount_191.
            CLEAR <fs_data_191>-hsl.
          ENDLOOP.
      ENDCASE.

      READ TABLE lt_data_k TRANSPORTING NO FIELDS WITH KEY bukrs = ls_data-bukrs
                                                           gjahr = ls_data-gjahr
                                                           belnr = ls_data-belnr
                                                          BINARY SEARCH.
      CASE sy-subrc.
        WHEN 0.
          LOOP AT lt_data_k ASSIGNING <fs_data> FROM sy-tabix.
            IF <fs_data>-bukrs NE ls_data-bukrs OR
               <fs_data>-gjahr NE ls_data-gjahr OR
               <fs_data>-belnr NE ls_data-belnr.
              EXIT.
            ENDIF.
            ADD <fs_data>-hsl TO lv_amount_k.
            CLEAR <fs_data>-hsl.
          ENDLOOP.
      ENDCASE.
      "ilk tutarlar
      ls_collect-kst    = ls_data-hsl.
*      ls_collect-gyst   = ls_data-hsl +
*                          lv_amount_k -
*                          lv_amount_191.
      ls_collect-gyst   = lv_amount_k.

      "kiril1
      ls_collect-kiril1 = ls_mg-kiril1.
      ls_collect-acklm1 = ls_mg-acklm1.
      COLLECT ls_collect INTO mt_collect.

      "kiril2
      ls_collect-kiril2 = ls_mg-kiril2.
      ls_collect-acklm2 = ls_mg-acklm2.
      COLLECT ls_collect INTO mt_collect.

      "kiril3
      CONCATENATE ls_mg-mindk
                  '-'
                  ls_data-racct
                  '/('
                  ls_mg-mtext
                  '-'
                  ls_data-txt50
                  ')'
                  INTO ls_collect-kiril3.

      COLLECT ls_collect INTO mt_collect.

      ls_detail-kiril1 = ls_mg-kiril1.
      ls_detail-acklm1 = ls_mg-acklm1.
      ls_detail-kiril2 = ls_mg-kiril2.
      ls_detail-acklm2 = ls_mg-acklm2.
      ls_detail-belnr  = ls_data-belnr.
      ls_detail-bukrs  = ls_data-bukrs.
      ls_detail-butxt  = ls_data-butxt.
      ls_detail-gjahr  = ls_data-gjahr.
      ls_detail-racct  = ls_data-racct.
      ls_detail-txt50  = ls_data-txt50.
      ls_detail-lifnr  = ls_data-lifnr.
      ls_detail-name1  = ls_data-name1.
      ls_detail-name2  = ls_data-name2.
      ls_detail-mindk  = ls_mg-mindk.
      ls_detail-mtext   = ls_mg-mtext.
      ls_detail-hsl    = ls_data-hsl.
      ls_detail-wsl    = ls_data-wsl.
      ls_detail-rwcur  = ls_data-rwcur.
      ls_detail-sgtxt  = ls_data-sgtxt.
      ls_detail-zuonr  = ls_data-zuonr.
      ls_detail-gyst   = ls_collect-gyst.
      ls_detail-kst    = ls_collect-kst.
      COLLECT ls_detail INTO mt_detail.

      CLEAR ls_mg.
      CLEAR ls_lfb1.
      CLEAR ls_detail.
      CLEAR ls_collect.

    ENDLOOP.

    "abs
    LOOP AT mt_collect ASSIGNING <fs_collect>.
      <fs_collect>-gyst = abs( <fs_collect>-gyst ).
      <fs_collect>-kst  = abs( <fs_collect>-kst  ).
    ENDLOOP.

    "manuel
    IF lines( lt_mg ) GT 0.

      SELECT *
          FROM ztax_t_mmt
          FOR ALL ENTRIES IN @lt_mg
          WHERE bukrs EQ @p_bukrs
            AND gjahr EQ @p_gjahr
            AND monat EQ @mv_monat
            AND mindk EQ @lt_mg-mindk
           INTO TABLE @lt_mmt.

    ENDIF.

    SELECT SINGLE CompanyCodeName AS butxt
       FROM i_companycode
       WHERE CompanyCode EQ @p_bukrs
        INTO @lv_butxt.

    IF lines( lt_mmt ) GT 0.

      SELECT Supplier as lifnr,
             OrganizationBPName1 as name1,
             OrganizationBPName2 as name2
             FROM I_SUPPLIER
             FOR ALL ENTRIES IN @lt_mmt
             WHERE I_SUPPLIER~Supplier EQ @lt_mmt-lifnr
              INTO TABLE @lt_lfa1.

    ENDIF.

    SORT lt_mg BY mindk.
    SORT lt_lfa1 BY lifnr.

    LOOP AT lt_mmt INTO ls_mmt.
      CLEAR ls_mg.
      READ TABLE lt_mg INTO ls_mg WITH KEY mindk = ls_mmt-mindk BINARY SEARCH.
      CHECK sy-subrc IS INITIAL.

      CLEAR ls_lfa1.
      CLEAR ls_detail.
      CLEAR ls_collect.
      "ilk tutarlar
      ls_collect-kst    = ls_mmt-kst.
      ls_collect-gyst   = ls_mmt-gyst.

      "kiril1
      ls_collect-kiril1 = ls_mg-kiril1.
      ls_collect-acklm1 = ls_mg-acklm1.
      COLLECT ls_collect INTO mt_collect.

      "kiril2
      ls_collect-kiril2 = ls_mg-kiril2.
      ls_collect-acklm2 = ls_mg-acklm2.
      COLLECT ls_collect INTO mt_collect.

      CONCATENATE ls_mg-mindk
                  '-'
                  TEXT-t12
                  '/('
                  ls_mg-mtext
                  ')'
                  INTO ls_collect-kiril3.

      COLLECT ls_collect INTO mt_collect.


      ls_detail-kiril1 = ls_mg-kiril1.
      ls_detail-acklm1 = ls_mg-acklm1.
      ls_detail-kiril2 = ls_mg-kiril2.
      ls_detail-acklm2 = ls_mg-acklm2.
      ls_detail-bukrs  = p_bukrs.
*      ls_detail-belnr  = mc_new_line.
      ls_detail-butxt  = lv_butxt.
      ls_detail-gjahr  = p_gjahr.
      ls_detail-lifnr  = ls_mmt-lifnr.
      READ TABLE lt_lfa1 INTO ls_lfa1 WITH KEY lifnr = ls_mmt-lifnr BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        ls_detail-name1  = ls_lfa1-name1.
        ls_detail-name2  = ls_lfa1-name2.
      ELSE.
        ls_detail-name1  = ls_mmt-name1.
        ls_detail-name2  = ls_mmt-name2.
      ENDIF.
      ls_detail-mindk     = ls_mg-mindk.
      ls_detail-mtext      = ls_mg-mtext.
      ls_detail-hsl       = 0.
      ls_detail-wsl       = 0.
      ls_detail-rwcur     = 'TRY'.
      ls_detail-sgtxt     = TEXT-t12.
      ls_detail-gyst      = ls_mmt-gyst.
      ls_detail-kst       = ls_mmt-kst.
*      ls_detail-row_color = mc_new_line_color.
      COLLECT ls_detail INTO mt_detail.

    ENDLOOP.

    LOOP AT mt_detail ASSIGNING <fs_detail>.
      <fs_detail>-gyst = abs( <fs_detail>-gyst ).
      <fs_detail>-kst  = abs( <fs_detail>-kst  ).
    ENDLOOP.


  ENDMETHOD.