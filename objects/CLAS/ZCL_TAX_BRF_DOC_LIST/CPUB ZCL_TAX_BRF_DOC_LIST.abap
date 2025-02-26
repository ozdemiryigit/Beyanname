CLASS zcl_tax_brf_doc_list DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

    DATA mr_monat TYPE RANGE OF monat.
    DATA mv_monat TYPE monat.

    DATA p_monat TYPE monat.
    DATA p_gjahr TYPE gjahr.
    DATA p_bukrs TYPE bukrs.
    DATA p_donemb TYPE ztax_e_donemb.

    TYPES BEGIN OF mty_collect.
    TYPES kiril1  TYPE ztax_t_mg-kiril1.
    TYPES acklm1  TYPE ztax_t_mk1-acklm.
    TYPES kiril2  TYPE ztax_t_mg-kiril2.
    TYPES acklm2  TYPE ztax_t_mk1-acklm.
    TYPES kiril3(120).
    TYPES gyst    TYPE p LENGTH 13 DECIMALS 2 .
    TYPES kst     TYPE p LENGTH 13 DECIMALS 2.
    TYPES END OF mty_collect.

    TYPES BEGIN OF mty_mg.
    TYPES bukrs  TYPE ztax_t_mg-bukrs.
    TYPES kiril1 TYPE ztax_t_mg-kiril1.
    TYPES acklm1 TYPE ztax_t_mk1-acklm.
    TYPES kiril2 TYPE ztax_t_mg-kiril2.
    TYPES acklm2 TYPE ztax_t_mk2-acklm.
    TYPES hkont  TYPE ztax_t_mg-hkont.
    TYPES txt50  TYPE i_glaccounttext-GLAccountLongName."skat-txt50.
    TYPES mindk  TYPE ztax_t_mg-mindk.
    TYPES mtext  TYPE c LENGTH 30."t059t-mtext.
    TYPES END OF mty_mg.

    TYPES mtty_mg      TYPE TABLE OF mty_mg.

    TYPES BEGIN OF mty_data.
    TYPES bukrs       TYPE i_glaccountlineitemrawdata-CompanyCode.
    TYPES gjahr       TYPE i_glaccountlineitemrawdata-FiscalYear.
    TYPES belnr       TYPE i_glaccountlineitemrawdata-AccountingDocument.
    TYPES docln       TYPE i_glaccountlineitemrawdata-LedgerGLLineItem.
    TYPES ryear       TYPE i_glaccountlineitemrawdata-LedgerFiscalYear.
    TYPES fiscyearper TYPE i_glaccountlineitemrawdata-FiscalYearPeriod.
    TYPES hsl         TYPE i_glaccountlineitemrawdata-AmountInCompanyCodeCurrency.
    TYPES wsl         TYPE i_glaccountlineitemrawdata-AmountInTransactionCurrency.
    TYPES drcrk       TYPE i_glaccountlineitemrawdata-DebitCreditCode.
    TYPES awref_rev   TYPE i_glaccountlineitemrawdata-ReversalReferenceDocument.
    TYPES aworg_rev   TYPE i_glaccountlineitemrawdata-ReversalReferenceDocumentCntxt.
    TYPES awtyp       TYPE i_glaccountlineitemrawdata-ReferenceDocumentType.
    TYPES awref       TYPE i_glaccountlineitemrawdata-ReferenceDocument.
    TYPES aworg       TYPE i_glaccountlineitemrawdata-ReferenceDocumentContext.
    TYPES xreversing  TYPE i_glaccountlineitemrawdata-IsReversal.
    TYPES xreversed   TYPE i_glaccountlineitemrawdata-IsReversed.
    TYPES lifnr       TYPE i_glaccountlineitemrawdata-Supplier.
    TYPES racct       TYPE i_glaccountlineitemrawdata-GLAccount.
    TYPES txt50       TYPE i_glaccounttext-GLAccountLongName.
    TYPES sgtxt       TYPE i_glaccountlineitemrawdata-DocumentItemText.
    TYPES name1       TYPE i_supplier-OrganizationBPName1.
    TYPES name2       TYPE i_supplier-OrganizationBPName2.
    TYPES name_org1   TYPE i_businesspartner-OrganizationBPName1.
    TYPES name_org2   TYPE i_businesspartner-OrganizationBPName2.
    TYPES rwcur       TYPE i_glaccountlineitemrawdata-TransactionCurrency.
    TYPES zuonr       TYPE i_glaccountlineitemrawdata-AssignmentReference.
    TYPES butxt       TYPE i_companycode-CompanyCodeName.
    TYPES xblnr       TYPE i_journalentry-DocumentReferenceID.
    TYPES budat       TYPE i_glaccountlineitemrawdata-PostingDate.
    TYPES stras       TYPE i_supplier-StreetName.
*    TYPES mcod3       TYPE c LENGTH 25."I_SUPPLIER-mcod3.
    TYPES regio       TYPE i_supplier-Region.
    TYPES land1       TYPE i_supplier-Country.
    TYPES stcd2       TYPE i_supplier-TaxNumber2.
    TYPES koart       TYPE i_glaccountlineitemrawdata-FinancialAccountType.
    TYPES END OF mty_data.

    TYPES mtty_data    TYPE TABLE OF mty_data.

    TYPES BEGIN OF mty_data_191.
    TYPES rbukrs      TYPE i_glaccountlineitemrawdata-CompanyCode. "rbukrs.
    TYPES gjahr       TYPE i_glaccountlineitemrawdata-FiscalYear. "gjahr.
    TYPES belnr       TYPE i_glaccountlineitemrawdata-AccountingDocument. "belnr.
    TYPES docln       TYPE i_glaccountlineitemrawdata-LedgerGLLineItem. "docln.
    TYPES ryear       TYPE i_glaccountlineitemrawdata-LedgerFiscalYear. "ryear.
    TYPES fiscyearper TYPE i_glaccountlineitemrawdata-FiscalYearPeriod. "fiscyearper.
    TYPES hsl         TYPE i_glaccountlineitemrawdata-AmountInCompanyCodeCurrency. "hsl.
    TYPES wsl         TYPE i_glaccountlineitemrawdata-AmountInTransactionCurrency. "wsl.
    TYPES drcrk       TYPE i_glaccountlineitemrawdata-DebitCreditCode. "drcrk.
    TYPES awref_rev   TYPE i_glaccountlineitemrawdata-ReversalReferenceDocument. "awref_rev.
    TYPES aworg_rev   TYPE i_glaccountlineitemrawdata-ReversalReferenceDocumentCntxt. "aworg_rev.
    TYPES awtyp       TYPE i_glaccountlineitemrawdata-ReferenceDocumentType. "awtyp.
    TYPES awref       TYPE i_glaccountlineitemrawdata-ReferenceDocument. "awref.
    TYPES aworg       TYPE i_glaccountlineitemrawdata-ReferenceDocumentContext. "aworg.
    TYPES xreversing  TYPE i_glaccountlineitemrawdata-IsReversal. "xreversing.
    TYPES xreversed   TYPE i_glaccountlineitemrawdata-IsReversed. "xreversed.
    TYPES lifnr       TYPE i_glaccountlineitemrawdata-Supplier. "lifnr.
    TYPES racct       TYPE i_glaccountlineitemrawdata-GLAccount. "racct.
    TYPES sgtxt       TYPE i_glaccountlineitemrawdata-DocumentItemText. "sgtxt.
    TYPES rwcur       TYPE i_glaccountlineitemrawdata-TransactionCurrency. "rwcur.
    TYPES zuonr       TYPE i_glaccountlineitemrawdata-AssignmentReference. "zuonr.
    TYPES budat       TYPE i_glaccountlineitemrawdata-PostingDate. "budat.
    TYPES koart       TYPE i_glaccountlineitemrawdata-FinancialAccountType. "koart.
    TYPES END OF mty_data_191.

    TYPES mtty_data_191 TYPE TABLE OF mty_data_191.

    TYPES BEGIN OF mty_lfb1.
    TYPES lifnr TYPE i_suppliercompany-Supplier. "lifnr.
    TYPES bukrs TYPE i_suppliercompany-CompanyCode. "bukrs.
    TYPES mindk TYPE i_suppliercompany-MinorityGroup. "mindk.
    TYPES END OF mty_lfb1.

    TYPES mtty_lfb1    TYPE TABLE OF mty_lfb1.

    TYPES BEGIN OF mty_button_pushed.
    TYPES bel TYPE selkz_08.
    TYPES ode TYPE selkz_08.
    TYPES isy TYPE selkz_08.
    TYPES END OF mty_button_pushed.

    TYPES mtty_details TYPE TABLE OF ztax_ddl_i_brf_detail.
    DATA mt_collect    TYPE TABLE OF mty_collect.

    DATA mt_detail     TYPE mtty_details.

    DATA ms_button_pushed TYPE mty_button_pushed.

    CONSTANTS BEGIN OF mc_range_att.
    CONSTANTS sign   TYPE c LENGTH 4 VALUE 'SIGN'.
    CONSTANTS option TYPE c LENGTH 6 VALUE 'OPTION'.
    CONSTANTS low    TYPE c LENGTH 4 VALUE 'LOW'.
    CONSTANTS high   TYPE c LENGTH 4 VALUE 'HIGH'.
    CONSTANTS END OF mc_range_att.