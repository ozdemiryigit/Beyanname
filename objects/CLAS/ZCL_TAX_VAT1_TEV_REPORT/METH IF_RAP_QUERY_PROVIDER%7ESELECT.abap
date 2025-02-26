  METHOD if_rap_query_provider~select.

    FIELD-SYMBOLS <fs_out_tev>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <fs_line>      TYPE any.
    FIELD-SYMBOLS <fs_value>     TYPE any.
    FIELD-SYMBOLS <fs_value_dyn> TYPE any.

    TRY.

        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
        DATA: lt_bukrs_range  TYPE RANGE OF bukrs,
              lt_gjahr_range  TYPE RANGE OF gjahr,
              lt_monat_range  TYPE RANGE OF monat,
              lt_donemb_range TYPE RANGE OF ztax_e_donemb,
              lt_output       TYPE TABLE OF ztax_ddl_i_vat1_tev_report,
              ls_output       TYPE ztax_ddl_i_vat1_tev_report.
        DATA(lt_paging) = io_request->get_paging( ).

        LOOP AT lt_filter INTO DATA(ls_filter).
          CASE ls_filter-name.
            WHEN 'BUKRS'.
              lt_bukrs_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'GJAHR'.
              lt_gjahr_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'MONAT'.
              lt_monat_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'DONEMB'.
              lt_monat_range = CORRESPONDING #( ls_filter-range ).
          ENDCASE.
        ENDLOOP.

        p_bukrs  = VALUE #( lt_bukrs_range[ 1 ]-low OPTIONAL ).
        p_gjahr  = VALUE #( lt_gjahr_range[ 1 ]-low OPTIONAL ).
        p_monat  = VALUE #( lt_monat_range[ 1 ]-low OPTIONAL ).
        p_donemb = VALUE #( lt_donemb_range[ 1 ]-low OPTIONAL ).

        me->fill_monat_range( ).
        me->get_map_tab( IMPORTING et_map = lt_map ).
        me->fill_mwskz( EXPORTING it_map   = lt_map
                        IMPORTING er_mwskz = lr_mwskz ).

        me->get_fieldname( IMPORTING et_tevita = mt_tevita ).

        ASSIGN lo_data->* TO <fs_out_tev>.
        CREATE DATA lo_data_line LIKE LINE OF <fs_out_tev>.
        ASSIGN lo_data_line->* TO <fs_line>.

        CLEAR ls_read_tab.
        ls_read_tab-bset = abap_true.
        ls_read_tab-bseg = abap_true.

        me->find_document(  EXPORTING is_read_tab = ls_read_tab
                                      ir_mwskz    = lr_mwskz
                            IMPORTING et_bkpf     = lt_bkpf
                                      et_bset     = lt_bset
                                      et_bseg     = lt_bseg ).

        CLEAR lt_belnr.
        lt_belnr = lt_bset.

        DELETE ADJACENT DUPLICATES FROM lt_belnr COMPARING belnr bukrs gjahr.

        INSERT LINES OF lt_bseg INTO TABLE lt_bseg_koart.
        DELETE lt_bseg_koart WHERE FinancialAccountType EQ space.

        INSERT LINES OF lt_bseg INTO TABLE lt_bseg_buzid.
        DELETE lt_bseg_buzid WHERE AccountingDocumentItemType NE 'T' OR DebitCreditCode NE 'H'.

        CLEAR lt_kunnr.
        lt_kunnr = lt_bseg.
        DELETE lt_kunnr WHERE Customer EQ space.
        SORT lt_kunnr BY Customer.
        DELETE ADJACENT DUPLICATES FROM lt_kunnr COMPARING Customer.

        IF lines( lt_kunnr ) GT 0.

          SELECT Customer ,
                 OrganizationBPName1 ,
                 OrganizationBPName2 ,
                 TaxNumber2
                 FROM i_customer
                 FOR ALL ENTRIES IN @lt_kunnr
                 WHERE Customer EQ @lt_kunnr-Customer
                 INTO TABLE @lt_kna1.

        ENDIF.

        CLEAR lt_lifnr.
        lt_lifnr = lt_bseg.
        DELETE lt_lifnr WHERE Supplier EQ space.
        SORT lt_lifnr BY Supplier.
        DELETE ADJACENT DUPLICATES FROM lt_lifnr COMPARING Supplier.

        IF lines( lt_lifnr ) GT 0.

          SELECT Supplier ,
                 OrganizationBPName1 ,
                 OrganizationBPName2 ,
                 TaxNumber2
                 FROM i_supplier
                 FOR ALL ENTRIES IN @lt_lifnr
                 WHERE Supplier EQ @lt_lifnr-Supplier
                 INTO TABLE @lt_lfa1.

        ENDIF.
        DATA ls_tax_voran TYPE  ztax_t_voran.
        DATA lv_hwste TYPE p LENGTH 16 DECIMALS 2.

        LOOP AT lt_belnr INTO ls_belnr.
          CLEAR ls_tax_voran.
          CLEAR lv_hwste.
          SELECT SINGLE * FROM ztax_t_voran
            WHERE bukrs EQ @p_bukrs
              AND mwskz EQ @ls_belnr-mwskz
              INTO @ls_tax_voran.

          CLEAR ls_tevkifat.
          CLEAR <fs_line>.
          CLEAR ls_bkpf.
          CLEAR lt_split.
          CLEAR ls_split.
          CLEAR ls_tevita.
          CLEAR lv_percent_s.
          CLEAR lv_percent_h.

          ASSIGN COMPONENT 'BELNR' OF STRUCTURE <fs_line> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            <fs_value> = ls_belnr-belnr.
            UNASSIGN <fs_value>.
          ENDIF.

          ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_line> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            <fs_value> = ls_belnr-bukrs.
            UNASSIGN <fs_value>.
          ENDIF.

          ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <fs_line> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            <fs_value> = ls_belnr-gjahr.
            UNASSIGN <fs_value>.
          ENDIF.

          READ TABLE lt_bkpf INTO ls_bkpf WITH TABLE KEY bukrs = ls_belnr-bukrs
                                                         belnr = ls_belnr-belnr
                                                         gjahr = ls_belnr-gjahr.
          ASSIGN COMPONENT 'BLDAT' OF STRUCTURE <fs_line> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            <fs_value> = ls_bkpf-bldat.
            UNASSIGN <fs_value>.
          ENDIF.

          IF ls_bkpf-xblnr CA mc_hyphen.
            SPLIT ls_bkpf-xblnr AT mc_hyphen INTO TABLE lt_split.

            CLEAR ls_split.
            READ TABLE lt_split INTO ls_split INDEX 1.
            IF sy-subrc IS INITIAL.
              ASSIGN COMPONENT 'SERINO' OF STRUCTURE <fs_line> TO <fs_value>.
              IF <fs_value> IS ASSIGNED.
                <fs_value> = ls_split-value.
                UNASSIGN <fs_value>.
              ENDIF.
            ENDIF.
            CLEAR ls_split.
            READ TABLE lt_split INTO ls_split INDEX 2.
            IF sy-subrc IS INITIAL.
              ASSIGN COMPONENT 'SIRANO' OF STRUCTURE <fs_line> TO <fs_value>.
              IF <fs_value> IS ASSIGNED.
                <fs_value> = ls_split-value.
                UNASSIGN <fs_value>.
              ENDIF.
            ENDIF.
          ELSE.
            ASSIGN COMPONENT 'SIRANO' OF STRUCTURE <fs_line> TO <fs_value>.
            IF <fs_value> IS ASSIGNED.
              <fs_value> = ls_bkpf-xblnr.
              UNASSIGN <fs_value>.
            ENDIF.
          ENDIF.

          CLEAR ls_bseg.
          READ TABLE lt_bseg_koart INTO ls_bseg WITH TABLE KEY CompanyCode        = ls_belnr-bukrs
                                                               AccountingDocument = ls_belnr-belnr
                                                               FiscalYear         = ls_belnr-gjahr.
          IF ls_bseg-FinancialAccountType EQ 'D'.
            CLEAR ls_kna1.
            READ TABLE lt_kna1 INTO ls_kna1 WITH TABLE KEY kunnr = ls_bseg-Customer.
            ASSIGN COMPONENT 'STCD2' OF STRUCTURE <fs_line> TO <fs_value>.
            IF <fs_value> IS ASSIGNED.
              <fs_value> = ls_kna1-stcd2.
              UNASSIGN <fs_value>.
            ENDIF.
            ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_line> TO <fs_value>.
            IF <fs_value> IS ASSIGNED.
              <fs_value> = ls_kna1-name1.
              UNASSIGN <fs_value>.
            ENDIF.
            ASSIGN COMPONENT 'NAME2' OF STRUCTURE <fs_line> TO <fs_value>.
            IF <fs_value> IS ASSIGNED.
              <fs_value> = ls_kna1-name2.
              UNASSIGN <fs_value>.
            ENDIF.
          ELSEIF ls_bseg-FinancialAccountType EQ 'K'.
            CLEAR ls_lfa1.
            READ TABLE lt_lfa1 INTO ls_lfa1 WITH TABLE KEY lifnr = ls_bseg-Supplier.
            ASSIGN COMPONENT 'STCD2' OF STRUCTURE <fs_line> TO <fs_value>.
            IF <fs_value> IS ASSIGNED.
              <fs_value> = ls_lfa1-stcd2.
              UNASSIGN <fs_value>.
            ENDIF.
            ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_line> TO <fs_value>.
            IF <fs_value> IS ASSIGNED.
              <fs_value> = ls_lfa1-name1.
              UNASSIGN <fs_value>.
            ENDIF.
            ASSIGN COMPONENT 'NAME2' OF STRUCTURE <fs_line> TO <fs_value>.
            IF <fs_value> IS ASSIGNED.
              <fs_value> = ls_lfa1-name2.
              UNASSIGN <fs_value>.
            ENDIF.
          ENDIF.

          CLEAR ls_bseg.
          READ TABLE lt_bseg_buzid INTO ls_bseg WITH TABLE KEY AccountingDocument = ls_belnr-belnr
                                                               CompanyCode        = ls_belnr-bukrs
                                                               FiscalYear         = ls_belnr-gjahr.
          IF sy-subrc IS INITIAL.
            LOOP AT mt_tevita INTO ls_tevita.
              ASSIGN COMPONENT ls_tevita-fieldname OF STRUCTURE <fs_line> TO <fs_value>.
              IF <fs_value> IS ASSIGNED.
                ASSIGN COMPONENT ls_tevita-fieldname OF STRUCTURE ls_bseg TO <fs_value_dyn>.
                IF <fs_value_dyn> IS ASSIGNED.
                  <fs_value> = <fs_value_dyn>.
                  UNASSIGN <fs_value_dyn>.
                ENDIF.
                UNASSIGN <fs_value>.
              ENDIF.
            ENDLOOP.
          ENDIF.

          CLEAR ls_bset.
          LOOP AT lt_bset INTO ls_bset WHERE belnr EQ ls_belnr-belnr
                                         AND bukrs EQ ls_belnr-bukrs
                                         AND gjahr EQ ls_belnr-gjahr.
            CASE ls_bset-shkzg.
              WHEN 'H'.
                lv_percent_h = abs( ls_bset-kbetr ).
                IF ls_tax_voran-oran IS NOT INITIAL .
                  lv_percent_h = ( ls_tax_voran-oran * 10 ).
                  lv_percent_s = ( ls_tax_voran-oran * 10 - ls_bset-kbetr ).
                ENDIF.
                ASSIGN COMPONENT 'MATRAH' OF STRUCTURE <fs_line> TO <fs_value>.
                IF <fs_value> IS ASSIGNED.
                  ADD ls_bset-hwbas TO <fs_value>.
                  UNASSIGN <fs_value>.
                ENDIF.
                ASSIGN COMPONENT 'HESKDV' OF STRUCTURE <fs_line> TO <fs_value>.
                IF <fs_value> IS ASSIGNED.
                  IF ls_tax_voran-oran IS INITIAL .
                    ADD ls_bset-hwste TO <fs_value>.
                  ELSE.
                    lv_hwste = ( ls_bset-hwbas * ls_tax_voran-oran ) / 100.
                    lv_hwste = lv_hwste + ( -1 * ( ( ls_bset-hwbas * ls_tax_voran-oran ) / 100 - lv_hwste ) ).
                    ADD lv_hwste TO <fs_value>.
                  ENDIF.
                  UNASSIGN <fs_value>.
                ENDIF.
                IF ls_tax_voran-oran IS NOT INITIAL .
                  ASSIGN COMPONENT 'VERGI' OF STRUCTURE <fs_line> TO <fs_value>.
                  IF <fs_value> IS ASSIGNED.
                    lv_hwste = ( ( ls_bset-hwbas * ls_tax_voran-oran ) / 100 - ls_bset-hwste ).
                    ADD lv_hwste TO <fs_value>.
                    UNASSIGN <fs_value>.
                  ENDIF.
                ENDIF.
              WHEN 'S'.
                lv_percent_s = abs( ls_bset-kbetr ).
                ASSIGN COMPONENT 'VERGI' OF STRUCTURE <fs_line> TO <fs_value>.
                IF <fs_value> IS ASSIGNED.
                  ADD ls_bset-hwste TO <fs_value>.
                  UNASSIGN <fs_value>.
                ENDIF.
            ENDCASE.
          ENDLOOP.

          ASSIGN COMPONENT 'KBETR' OF STRUCTURE <fs_line> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            <fs_value> = lv_percent_h / 10.
            UNASSIGN <fs_value>.
          ENDIF.

          ASSIGN COMPONENT 'MWSKZ' OF STRUCTURE <fs_line> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            <fs_value> = ls_belnr-mwskz.
            UNASSIGN <fs_value>.
          ENDIF.

          CLEAR lv_percent_dec.
          ASSIGN COMPONENT 'TEVKIFATO' OF STRUCTURE <fs_line> TO <fs_value>.
          IF <fs_value> IS ASSIGNED.
            TRY.
                lv_percent_dec = ( lv_percent_s / lv_percent_h ) * 10.
              CATCH cx_sy_zerodivide.
            ENDTRY.
            lv_percent_h = lv_percent_dec.
            <fs_value> = lv_percent_h.
            SHIFT <fs_value> LEFT DELETING LEADING space.
            SHIFT <fs_value> LEFT DELETING LEADING '0'.
            <fs_value> = <fs_value> && '/10'.
            UNASSIGN <fs_value>.
          ENDIF.

          APPEND <fs_line> TO <fs_out_tev>.
        ENDLOOP.


      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
  ENDMETHOD.