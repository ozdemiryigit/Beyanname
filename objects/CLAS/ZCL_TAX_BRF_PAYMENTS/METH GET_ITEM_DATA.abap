  METHOD get_item_data.

    DATA lr_fiscyearper TYPE RANGE OF fis_jahrper_conv.
    DATA lt_reversed    TYPE mtty_data.
    DATA lt_reversing   TYPE mtty_data.
    DATA lt_lifnr       TYPE mtty_data.
    DATA lt_data        TYPE mtty_data.

*
    me->fill_period( EXPORTING ir_monat       = mr_monat
                     IMPORTING er_fiscyearper = lr_fiscyearper ).
*
*


    CLEAR et_mg.
    CLEAR et_data.
    CLEAR et_lfb1.
*
    SELECT ztax_t_mg~bukrs, "skat yetine  I_GLACCOUNTTEXT kullanıldı , t001 yerine I_COMPANYCODE,t059t yerine I_TaxTypeText
       ztax_t_mg~kiril1,
       ztax_t_mk1~acklm AS acklm1,
       ztax_t_mg~kiril2,
       ztax_t_mk2~acklm AS acklm2,
       ztax_t_mg~hkont,
        i_glaccounttext~glaccountlongname AS txt50,
       ztax_t_mg~mindk,
       i_taxtypetext~taxtypename
*
       FROM i_companycode
       INNER JOIN ztax_t_mg
       ON ztax_t_mg~bukrs EQ i_companycode~companycode
       INNER JOIN ztax_t_mk1
       ON ztax_t_mk1~kiril1 EQ ztax_t_mg~kiril1
       INNER JOIN ztax_t_mk2
       ON ztax_t_mk2~kiril2 EQ ztax_t_mg~kiril2
       LEFT OUTER JOIN  i_glaccounttext
       ON  i_glaccounttext~language EQ @sy-langu
    AND  i_glaccounttext~chartofaccounts EQ i_companycode~chartofaccounts
    AND  i_glaccounttext~glaccount EQ ztax_t_mg~hkont
       LEFT OUTER JOIN i_taxtypetext
       ON i_taxtypetext~language EQ @sy-langu
       AND i_taxtypetext~taxtype EQ ztax_t_mg~mindk
    WHERE ztax_t_mg~bukrs EQ @p_bukrs
     INTO TABLE @et_mg.
*
*
*
*    SELECT i_journalentryitem~companycode AS bukrs,"skar = GLACCOUNTTEXT i_journalentry= bkpf but000 =  I_BUSINESSPARTNER t001=i_companycode lfa1 = I_Supplier
*           i_journalentryitem~fiscalyear AS gjahr,
*           i_journalentryitem~accountingdocument AS belnr,
**           i_journalentryitem~DocumentLine AS docln,
**           I_JournalEntryItem~ as ryear,
**           I_JournalEntryItem~FiscalYearPeriod,
**           i_journalentryitem~debitcreditcode AS hsl,
**           i_journalentryitem~debitcreditcode AS wsl, "?
**           i_journalentryitem~debitcreditcode AS drcrk, "?
**           I_JournalEntryItem~awref_rev,
**           I_JournalEntryItem~aworg_rev,
**           I_JournalEntryItem~awtyp,
**           I_JournalEntryItem~awref,
**           I_JournalEntryItem~aworg,
**           I_JournalEntryItem~xreversing,
**           I_JournalEntryItem~xreversed,
*           i_journalentryitem~supplier AS lifnr,
**           I_JournalEntryItem~racct,
*            i_glaccounttext~glaccountlongname AS txt50,
*           i_journalentryitem~documentitemtext AS sgtxt,
*           i_businesspartner~firstname AS name1,
*           i_businesspartner~lastname  AS name2,
*           i_businesspartner~organizationbpname1 AS name_org1,
*           i_businesspartner~organizationbpname2 AS name_org2,
**           acdoca~rwcur,
**           acdoca~zuonr,
*           i_companycode~companycodename AS butxt,
*           i_journalentry~documentreferenceid AS xblnr,
*           i_journalentryitem~postingdate AS budat,
*           i_supplier~streetname AS stras,
*           i_supplier~cityname AS mcod3,
*           i_supplier~region AS regio,
*           i_supplier~country AS land1,
*           i_supplier~taxnumber2 AS stcd2,
*           i_journalentryitem~financialaccounttype AS koart
*           "
*
*           FROM i_journalentryitem
*           "
*           INNER JOIN i_companycode
*           ON i_companycode~companycode EQ i_journalentryitem~companycode
*           "
*           INNER JOIN i_journalentry
*           ON i_journalentry~companycode  EQ i_journalentryitem~companycode
*           AND i_journalentry~accountingdocument EQ i_journalentryitem~accountingdocument
*           AND i_journalentry~fiscalyear EQ i_journalentryitem~fiscalyear
*           "
*           LEFT OUTER JOIN i_glaccounttext
*           ON i_glaccounttext~language            EQ @sy-langu
**           AND skat~ktopl           EQ i_journalentryitem~ktopl
**           AND skat~saknr           EQ i_journalentryitem~racct
*           "
*           LEFT OUTER JOIN  i_businesspartner
*           ON i_businesspartner~businesspartner        EQ i_journalentryitem~customer
*           "
*           LEFT OUTER JOIN  i_supplier
*           ON  i_supplier~supplier           EQ i_journalentryitem~customer
*           "
*           WHERE i_journalentryitem~fiscalyear       EQ @p_gjahr
*             AND i_journalentryitem~companycode      EQ @p_bukrs
**             AND I_JournalEntryItem~fiscyearper IN @lr_fiscyearper
**             AND ( ( acdoca~xreversing EQ @space AND acdoca~drcrk EQ 'H' ) OR ( acdoca~xreversing EQ @abap_true AND acdoca~drcrk  EQ 'S' ) )
*             AND i_journalentryitem~referencedocumenttype       NE 'RMRP'
**             AND acdoca~rldnr       EQ '0L'
*             AND EXISTS ( "
*                          SELECT *
*                           FROM i_journalentryitem AS account
*                           "
*                           INNER JOIN ztax_t_mg AS mg1
*                           ON  mg1~bukrs  EQ account~companycode
**                           AND mg1~hkont  EQ account~racct
*                           "
*                           WHERE "account~rldnr       EQ acdoca~rldnr
*                              account~companycode      EQ i_journalentryitem~companycode
*                             AND account~accountingdocument       EQ i_journalentryitem~accountingdocument
*
*                             AND account~fiscalyear       EQ i_journalentryitem~fiscalyear
**                             AND account~fiscyearper EQ I_JournalEntryItem~fiscyearper
**                             AND ( ( account~xreversing EQ @space AND account~drcrk EQ 'H' ) OR ( account~xreversing EQ @abap_true AND account~drcrk  EQ 'S' ) )
*                             AND EXISTS ( "
*                                          SELECT *
*                                            FROM i_journalentryitem AS gricd
*                                            "
*                                            INNER JOIN i_suppliercompany
*                                            ON i_suppliercompany~companycode EQ gricd~companycode
*                                            AND i_suppliercompany~supplier EQ gricd~customer
*                                            "
*                                            INNER JOIN ztax_t_mindk AS mindk
*                                             ON  mindk~bukrs  EQ gricd~companycode
*                                             AND mindk~lifnr  EQ i_suppliercompany~Supplier
*
*                                            INNER JOIN ztax_t_mg AS mg12
*                                             ON  mg12~bukrs  EQ gricd~companycode
*                                             AND mg12~mindk  EQ mindk~mindk
*
*                                             "
*                                             WHERE" gricd~rldnr       EQ account~rldnr
*                                                gricd~companycode      EQ account~companycode
*                                               AND gricd~accountingdocument       EQ account~accountingdocument
*                                               AND gricd~fiscalyear       EQ account~fiscalyear
**                                               AND gricd~fiscyearper EQ account~fiscyearper
**                                               AND mg12~hkont        EQ account~racct
**                                               AND ( ( gricd~xreversing EQ @space AND gricd~drcrk EQ 'H' ) OR ( gricd~xreversing EQ @abap_true AND gricd~drcrk  EQ 'S' ) )
*                                         )
*                            )
*                             INTO CORRESPONDING FIELDS OF TABLE @et_data.
*
*
*
*    SELECT i_journalentryitem~companycode AS bukrs,"skar = GLACCOUNTTEXT i_journalentry= bkpf but000 =  I_BUSINESSPARTNER rbkp = SupplierInvoiceAPI01 lfb1 = i_suppliercompany
*               i_journalentryitem~fiscalyear AS gjahr,
*               i_journalentryitem~accountingdocument AS belnr,
**           i_journalentryitem~DocumentLine AS docln,
**           I_JournalEntryItem~ as ryear,
**           I_JournalEntryItem~FiscalYearPeriod,
**           i_journalentryitem~debitcreditcode AS hsl,
**           i_journalentryitem~debitcreditcode AS wsl, "?
**           i_journalentryitem~debitcreditcode AS drcrk, "?
**           I_JournalEntryItem~awref_rev,
**           I_JournalEntryItem~aworg_rev,
**           I_JournalEntryItem~awtyp,
**           I_JournalEntryItem~awref,
**           I_JournalEntryItem~aworg,
**           I_JournalEntryItem~xreversing,
**           I_JournalEntryItem~xreversed,
**           rbkp~supplier AS lifnr,
**           I_JournalEntryItem~racct,
*                i_glaccounttext~glaccountlongname AS txt50,
*               i_journalentryitem~documentitemtext AS sgtxt,
*               i_businesspartner~firstname AS name1,
*               i_businesspartner~lastname  AS name2,
*               i_businesspartner~organizationbpname1 AS name_org1,
*               i_businesspartner~organizationbpname2 AS name_org2,
**           acdoca~rwcur,
**           acdoca~zuonr,
*               i_companycode~companycodename AS butxt,
*               i_journalentry~documentreferenceid AS xblnr,
*               i_journalentryitem~postingdate AS budat,
*               i_supplier~streetname AS stras,
*               i_supplier~cityname AS mcod3,
*               i_supplier~region AS regio,
*               i_supplier~country AS land1,
*               i_supplier~taxnumber2 AS stcd2,
*               i_journalentryitem~financialaccounttype AS koart
*               "
*
*            "
*            FROM i_journalentryitem
*            INNER JOIN i_companycode
*            ON i_companycode~companycode EQ i_journalentryitem~companycode
*            "
*            INNER JOIN i_supplierinvoiceapi01
*            ON i_supplierinvoiceapi01~supplierinvoice EQ i_journalentryitem~accountassignment "AWREF bunu bul
*            AND i_supplierinvoiceapi01~fiscalyear EQ i_journalentryitem~accountassignment     "aworg
*            "
*            INNER JOIN i_journalentry
*            ON i_journalentry~companycode  EQ i_journalentryitem~companycode
*            AND i_journalentry~accountingdocument EQ i_journalentryitem~accountingdocument
*            AND i_journalentry~fiscalyear EQ i_journalentryitem~fiscalyear
*            "
*            LEFT OUTER JOIN i_glaccounttext
*            ON i_glaccounttext~language            EQ @sy-langu
**        AND skat~ktopl           EQ i_journalentryitem~ktopl
**        AND skat~saknr           EQ i_journalentryitem~racct
*            "
*            LEFT OUTER JOIN i_businesspartner
*            ON i_businesspartner~businesspartner        EQ i_journalentryitem~customer
*            "
*        LEFT OUTER JOIN I_Supplier
*        ON I_Supplier~supplier   EQ I_SupplierInvoiceAPI01~CreatedByUser
*            "
*            WHERE i_journalentryitem~fiscalyear       EQ @p_gjahr
*            AND i_journalentryitem~companycode      EQ @p_bukrs
**        AND i_journalentryitem~fiscyearper IN @lr_fiscyearper
**        AND ( ( acdoca~xreversing EQ @space AND acdoca~drcrk EQ 'H' ) OR ( acdoca~xreversing EQ abap_true AND acdoca~drcrk  EQ 'S' ) )
*            AND i_journalentryitem~ReferenceDocumentType       EQ 'RMRP'
**            AND acdoca~rldnr       EQ '0L'
*            AND EXISTS ( "
*            SELECT *
*            FROM i_journalentryitem AS account
*            "
*            INNER JOIN ztax_t_mg AS mg1
*            ON  mg1~bukrs  EQ account~companycode
*            AND mg1~hkont  EQ account~GLAccount
*            "
*            WHERE "account~rldnr       EQ acdoca~rldnr
*             account~companycode      EQ i_journalentryitem~companycode
*            AND account~accountingdocument       EQ i_journalentryitem~accountingdocument
*            AND account~fiscalyear       EQ i_journalentryitem~fiscalyear
**        AND account~fiscyearper EQ i_journalentryitem~fiscyearper
**        AND ( ( account~xreversing EQ space AND account~drcrk EQ 'H' ) OR ( account~xreversing EQ abap_true AND account~drcrk  EQ 'S' ) )
*            AND EXISTS ( "
*                         SELECT *
*                           FROM i_journalentryitem AS gricd
*                           "
**                           INNER JOIN i_SupplierInvoiceAPI01
*                           "on i_SupplierInvoiceAPI01~supplierinvoice EQ gricd~awref
**                            and i_SupplierInvoiceAPI01~fiscalyear EQ gricd~aworg
*                           "
*                           INNER JOIN i_suppliercompany
*                           ON i_suppliercompany~bukrs EQ i_SupplierInvoiceAPI01~bukrs
*                           AND i_suppliercompany~lifnr EQ i_SupplierInvoiceAPI01~lifnr
*                           "
*                          INNER JOIN ztax_t_mindk AS mindk
*                            ON  mindk~bukrs  EQ i_SupplierInvoiceAPI01~bukrs
*                            AND mindk~lifnr  EQ i_SupplierInvoiceAPI01~lifnr
*
*                           INNER JOIN ztax_t_mg AS mg12
*                            ON  mg12~bukrs  EQ gricd~rbukrs
*                            AND mg12~mindk  EQ mindk~mindk
*                            "
*                            WHERE "gricd~rldnr       EQ account~rldnr
*                               gricd~companycode      EQ account~companycode
*                              AND gricd~accountingdocument       EQ account~accountingdocument
*                              AND gricd~fiscalyear       EQ account~fiscalyear
**                          AND gricd~fiscyearper EQ account~fiscyearper
**                          AND mg12~hkont        EQ account~racct
**                          AND ( ( gricd~xreversing EQ space AND gricd~drcrk EQ 'H' ) OR ( gricd~xreversing EQ abap_true AND gricd~drcrk  EQ 'S' ) )
*                           )
*            )
*
*
*            APPENDING CORRESPONDING FIELDS OF TABLE @et_data
*    .
*

    lt_reversed  = et_data.
    lt_reversing = et_data.


    DELETE lt_reversed  WHERE awref_rev EQ space AND xreversed  EQ space.
    DELETE lt_reversing WHERE awref_rev EQ space AND xreversing EQ space.

    SORT lt_reversed  BY awref_rev aworg_rev.
    SORT lt_reversing BY awref aworg.
    DELETE ADJACENT DUPLICATES FROM lt_reversed COMPARING awref_rev aworg_rev.
    DELETE ADJACENT DUPLICATES FROM lt_reversing COMPARING awref aworg.

    LOOP AT lt_reversed INTO DATA(ls_reversed).

      READ TABLE lt_reversing TRANSPORTING NO FIELDS WITH KEY awref = ls_reversed-awref_rev
                                                              aworg = ls_reversed-aworg_rev
                                                              BINARY SEARCH.
      CHECK sy-subrc IS INITIAL.

      DELETE et_data WHERE awref_rev EQ ls_reversed-awref_rev
                       AND aworg_rev EQ ls_reversed-aworg_rev.

      DELETE et_data WHERE awref EQ ls_reversed-awref_rev
                       AND aworg EQ ls_reversed-aworg_rev.

    ENDLOOP.

    lt_lifnr = et_data.
    SORT lt_lifnr BY bukrs lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_lifnr COMPARING bukrs lifnr.

    IF lines( lt_lifnr ) GT 0.

      SELECT a~supplier AS lifnr,
             a~companycode AS bukrs,
             b~mindk

             FROM i_suppliercompany AS a
             LEFT OUTER JOIN ztax_t_mindk AS b ON  b~bukrs = a~companycode
                                              AND b~lifnr = a~supplier
             FOR ALL ENTRIES IN @lt_lifnr
             WHERE a~supplier EQ @lt_lifnr-lifnr
               AND a~companycode EQ @lt_lifnr-bukrs
                INTO TABLE  @et_lfb1.

    ENDIF.

    SORT et_lfb1 BY bukrs lifnr.
    SORT et_mg BY bukrs hkont mindk.

    IF lines( et_data ) GT 0.

      lt_data = et_data.

      SORT lt_data BY bukrs
                      gjahr
                      belnr.

      DELETE ADJACENT DUPLICATES FROM lt_data COMPARING bukrs
                                                        gjahr
                                                        belnr.
*
*      SELECT rbukrs
*             gjahr
*             belnr
*             docln
*             ryear
*             fiscyearper
*             hsl
*             wsl
*             drcrk
*             awref_rev
*             aworg_rev
*             awtyp
*             awref
*             aworg
*             xreversing
*             xreversed
*             lifnr
*             racct
*             sgtxt
*             rwcur
*             zuonr
*             budat
*             koart
*             INTO TABLE et_data_191
*             FROM acdoca
*             FOR ALL ENTRIES IN lt_data
*             WHERE rldnr  EQ '0L'
*               AND rbukrs EQ lt_data-bukrs
*               AND gjahr  EQ lt_data-gjahr
*               AND belnr  EQ lt_data-belnr
*               AND racct  LIKE '191%'.

    ENDIF.




  ENDMETHOD.