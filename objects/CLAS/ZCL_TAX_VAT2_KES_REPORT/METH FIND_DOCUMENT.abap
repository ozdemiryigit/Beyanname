  METHOD find_document.

    FIELD-SYMBOLS <fs_bkpf> TYPE mty_bkpf.

    DATA lt_bkpf_rmrp TYPE SORTED TABLE OF mty_bkpf WITH NON-UNIQUE KEY awref_rev gjahr_rev.
    DATA lt_bkpf_vbrk TYPE SORTED TABLE OF mty_bkpf WITH NON-UNIQUE KEY awref_rev.
    DATA lt_bkpf_rev  TYPE SORTED TABLE OF mty_bkpf WITH NON-UNIQUE KEY bukrs stblg stjah.
    DATA ls_bkpf_rev_cont TYPE mty_bkpf_rev_cont.
    DATA lt_bkpf_rev_cont TYPE SORTED TABLE OF mty_bkpf_rev_cont WITH UNIQUE KEY bukrs belnr gjahr.
    DATA ls_rbkp TYPE mty_rbkp.
    DATA lt_rbkp TYPE SORTED TABLE OF mty_rbkp WITH UNIQUE KEY belnr gjahr.
    DATA ls_vbrk TYPE mty_vbrk.
    DATA lt_vbrk TYPE SORTED TABLE OF mty_vbrk WITH UNIQUE KEY vbeln.


    TYPES bukrs     TYPE i_journalentry-companycode.
    TYPES belnr     TYPE i_journalentry-accountingdocument.
    TYPES gjahr     TYPE i_journalentry-fiscalyear.
    TYPES budat     TYPE i_journalentry-postingdate.
    TYPES monat     TYPE i_journalentry-fiscalperiod.
    TYPES awtyp     TYPE i_journalentry-referencedocumenttype.
    TYPES awref_rev TYPE i_journalentry-reversalreferencedocument.
    TYPES aworg_rev TYPE i_journalentry-reversalreferencedocumentcntxt.
    TYPES stblg     TYPE i_journalentry-reversedocument.
    TYPES stjah     TYPE i_journalentry-reversedocumentfiscalyear.
    TYPES xblnr     TYPE i_journalentry-documentreferenceid.
    TYPES bldat     TYPE i_journalentry-documentdate.
    TYPES gjahr_rev TYPE i_journalentry-fiscalyear.

    SELECT i_journalentry~companycode AS bukrs,
           i_journalentry~accountingdocument AS belnr,
           i_journalentry~fiscalyear AS gjahr,
           i_journalentry~postingdate AS budat,
           i_journalentry~fiscalperiod AS monat,
           i_journalentry~referencedocumenttype AS awtyp,
           i_journalentry~reversalreferencedocument AS awref_rev,
           i_journalentry~reversalreferencedocumentcntxt AS aworg_rev,
           i_journalentry~reversedocument AS stblg,
           i_journalentry~reversedocumentfiscalyear AS stjah,
           i_journalentry~documentreferenceid AS xblnr,
           i_journalentry~documentdate AS bldat
           FROM i_journalentry
           WHERE i_journalentry~companycode EQ @p_bukrs
             AND i_journalentry~fiscalyear EQ @p_gjahr
             AND i_journalentry~fiscalperiod IN @mr_monat
              INTO TABLE @et_bkpf.
    IF sy-subrc IS NOT INITIAL.
      RETURN.
    ENDIF.

    LOOP AT et_bkpf ASSIGNING <fs_bkpf> WHERE awtyp EQ 'RMRP'.
      CASE strlen( <fs_bkpf>-aworg_rev ).
        WHEN 4.
          <fs_bkpf>-gjahr_rev = <fs_bkpf>-aworg_rev.
      ENDCASE.
    ENDLOOP.

    "elemination logic. - 1
    INSERT LINES OF et_bkpf INTO TABLE lt_bkpf_rmrp.
    DELETE lt_bkpf_rmrp WHERE awtyp     NE 'RMRP' OR
                              awref_rev EQ space.

    IF lines( lt_bkpf_rmrp ) GT 0.
      SELECT i_supplierinvoiceapi01~supplierinvoice AS  belnr,
             i_supplierinvoiceapi01~fiscalyear AS gjahr,
             i_supplierinvoiceapi01~postingdate AS budat

             FROM i_supplierinvoiceapi01
             FOR ALL ENTRIES IN @lt_bkpf_rmrp
             WHERE i_supplierinvoiceapi01~supplierinvoice EQ @lt_bkpf_rmrp-awref_rev
               AND i_supplierinvoiceapi01~fiscalyear EQ @lt_bkpf_rmrp-gjahr_rev
                INTO TABLE @lt_rbkp.

      LOOP AT lt_rbkp INTO ls_rbkp.
        DELETE et_bkpf WHERE awref_rev  EQ ls_rbkp-belnr
                         AND gjahr_rev  EQ ls_rbkp-gjahr
                         AND budat+4(2) EQ ls_rbkp-budat+4(2).
      ENDLOOP.
    ENDIF.

    CLEAR lt_bkpf_rmrp.
    CLEAR lt_rbkp.

    "elemination logic - 2
    INSERT LINES OF et_bkpf INTO TABLE lt_bkpf_vbrk.
    DELETE lt_bkpf_vbrk WHERE awtyp     NE 'VBRK' OR
                              awref_rev EQ space.

    IF lines( lt_bkpf_vbrk ) GT 0.
      SELECT i_salesdocument~salesdocument AS vbeln,
             i_salesdocument~salesdocumentdate AS fkdat
             FROM i_salesdocument
             FOR ALL ENTRIES IN @lt_bkpf_vbrk
             WHERE salesdocument EQ @lt_bkpf_vbrk-awref_rev
              INTO TABLE @lt_vbrk.

      LOOP AT lt_vbrk INTO ls_vbrk.
        DELETE et_bkpf WHERE awref_rev  EQ ls_vbrk-vbeln
                         AND budat+4(2) EQ ls_vbrk-fkdat+4(2).
      ENDLOOP.
    ENDIF.

    CLEAR lt_vbrk.
    CLEAR lt_bkpf_vbrk.

    "elemination logic - 3
    INSERT LINES OF et_bkpf INTO TABLE lt_bkpf_rev.
    DELETE lt_bkpf_rev WHERE ( awtyp     EQ 'VBRK' OR
                               awtyp     EQ 'RMRP' ) AND ( stblg EQ space ).

    IF lines( lt_bkpf_rev ) GT 0.
      SELECT  companycode AS bukrs,
             accountingdocument AS belnr,
             fiscalyear AS gjahr,
            postingdate AS budat

             FROM i_journalentry
             FOR ALL ENTRIES IN @lt_bkpf_rev
             WHERE companycode EQ @lt_bkpf_rev-bukrs
               AND accountingdocument EQ @lt_bkpf_rev-stblg
               AND fiscalyear EQ @lt_bkpf_rev-stjah
               INTO TABLE @lt_bkpf_rev_cont.

      LOOP AT lt_bkpf_rev_cont INTO ls_bkpf_rev_cont.
        DELETE et_bkpf WHERE bukrs      EQ ls_bkpf_rev_cont-bukrs
                         AND stblg      EQ ls_bkpf_rev_cont-belnr
                         AND stjah      EQ ls_bkpf_rev_cont-gjahr
                         AND budat+4(2) EQ ls_bkpf_rev_cont-budat+4(2).
      ENDLOOP.
    ENDIF.

    IF is_read_tab-bset EQ abap_true.
      IF lines( et_bkpf ) GT 0.
        SELECT i_operationalacctgdoctaxitem~companycode AS bukrs,
               i_operationalacctgdoctaxitem~accountingdocument AS belnr,
               i_operationalacctgdoctaxitem~fiscalyear AS gjahr,
               i_operationalacctgdoctaxitem~taxitem AS buzei,
               i_operationalacctgdoctaxitem~taxcode AS mwskz,
               i_operationalacctgdoctaxitem~debitcreditcode AS shkzg,
               i_operationalacctgdoctaxitem~taxbaseamountincocodecrcy AS hwbas,
               i_operationalacctgdoctaxitem~taxamountincocodecrcy AS hwste
*               I_operationalAcctgDocTaxItem~kbetr,
*               I_operationalAcctgDocTaxItem~kschl,
*               I_operationalAcctgDocTaxItem~hkont
               FROM i_operationalacctgdoctaxitem
               FOR ALL ENTRIES IN @et_bkpf
               WHERE i_operationalacctgdoctaxitem~companycode EQ @et_bkpf-bukrs
                 AND i_operationalacctgdoctaxitem~accountingdocument EQ @et_bkpf-belnr
                 AND i_operationalacctgdoctaxitem~fiscalyear EQ @et_bkpf-gjahr
                 AND i_operationalacctgdoctaxitem~taxcode IN @ir_mwskz
*                 AND I_operationalAcctgDocTaxItem~kschl IN @ir_kschl
                  INTO TABLE @et_bset.
      ENDIF.
    ENDIF.

    IF is_read_tab-bseg EQ abap_true.
      IF lines( et_bset ) GT 0.
        SELECT i_journalentryitem~companycode AS bukrs,
               i_journalentryitem~accountingdocument AS belnr,
               i_journalentryitem~fiscalyear AS gjahr,
               i_journalentryitem~financialaccounttype AS koart,
               i_journalentryitem~supplier AS lifnr,
*               i_journalentryitem~AccountingDocumentItemType as buzid,
               i_journalentryitem~taxcode AS mwskz

               FROM i_journalentryitem
               FOR ALL ENTRIES IN @et_bset
               WHERE i_journalentryitem~companycode EQ @et_bset-bukrs
                 AND i_journalentryitem~accountingdocument EQ @et_bset-belnr
                 AND i_journalentryitem~fiscalyear EQ @et_bset-gjahr
                 INTO TABLE @et_bseg.
      ELSEIF lines( et_bkpf ) GT 0.
        SELECT i_journalentryitem~companycode AS bukrs,
               i_journalentryitem~accountingdocument AS belnr,
               i_journalentryitem~fiscalyear AS gjahr,
               i_journalentryitem~financialaccounttype AS koart,
               i_journalentryitem~supplier AS lifnr,
*               i_journalentryitem~AccountingDocumentItemType as buzid,
               i_journalentryitem~taxcode AS mwskz

               FROM i_journalentryitem
               FOR ALL ENTRIES IN @et_bkpf
               WHERE i_journalentryitem~companycode EQ @et_bkpf-bukrs
                 AND i_journalentryitem~accountingdocument EQ @et_bkpf-belnr
                 AND i_journalentryitem~fiscalyear EQ @et_bkpf-gjahr
                      INTO TABLE @et_bseg.
      ENDIF.
    ENDIF.


  ENDMETHOD.