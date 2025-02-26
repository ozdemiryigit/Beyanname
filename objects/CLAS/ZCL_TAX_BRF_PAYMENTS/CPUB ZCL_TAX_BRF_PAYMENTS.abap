CLASS zcl_tax_brf_payments DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

    DATA p_monat TYPE monat.
    DATA p_gjahr TYPE gjahr.
    DATA p_bukrs TYPE bukrs.
    DATA p_donemb TYPE ztax_e_donemb.


    TYPES mtty_ode     TYPE TABLE OF ztax_ddl_i_brf_payments.

    TYPES BEGIN OF mty_mg.
    TYPES bukrs  TYPE ztax_t_mg-bukrs.
    TYPES kiril1 TYPE ztax_t_mg-kiril1.
    TYPES acklm1 TYPE ztax_t_mk1-acklm.
    TYPES kiril2 TYPE ztax_t_mg-kiril2.
    TYPES acklm2 TYPE ztax_t_mk2-acklm.
    TYPES hkont  TYPE ztax_t_mg-hkont.
    TYPES txt50  TYPE c LENGTH 50.
    TYPES mindk  TYPE ztax_t_mg-mindk.
    TYPES mtext   TYPE c LENGTH 30."t059t-mtext.
    TYPES END OF mty_mg.

    TYPES BEGIN OF mty_lfb1.
    TYPES lifnr TYPE lifnr.
    TYPES bukrs TYPE bukrs.
    TYPES mindk TYPE ztax_e_mindk.
    TYPES END OF mty_lfb1.


    TYPES BEGIN OF mty_data.
    TYPES:
      bukrs       TYPE bukrs,          "Company Code
      gjahr       TYPE gjahr,          "Fiscal Year
      belnr       TYPE belnr_d,        "Accounting Document Number
      docln       TYPE n LENGTH 10,         "Document Line Number (10 characters)
      ryear       TYPE gjahr,          "Reference Year
      fiscyearper TYPE n LENGTH 6,          "Fiscal Year Period (6 characters)
      hsl         TYPE decfloat34,          "Local Currency Amount
      wsl         TYPE decfloat34,          "Transaction Currency Amount
      drcrk       TYPE c LENGTH 1,          "Debit/Credit Indicator
      awref_rev   TYPE c LENGTH 12,         "Reversal Reference
      aworg_rev   TYPE c LENGTH 4,          "Reversal Organization Key
      awtyp       TYPE c LENGTH 4,          "Document Type
      awref       TYPE c LENGTH 12,         "Document Reference
      aworg       TYPE c LENGTH 4,          "Organization Key
      xreversing  TYPE abap_bool,      "Reversing Indicator
      xreversed   TYPE abap_bool,      "Reversed Indicator
      lifnr       TYPE lifnr,          "Vendor Account Number
      racct       TYPE c LENGTH 10,           "General Ledger Account
      txt50       TYPE c LENGTH 50,         "Description (50 characters)
      sgtxt       TYPE sgtxt,          "Document Item Text
      name1       TYPE name1_gp,          "Name 1
      name2       TYPE name2_gp,          "Name 2
      name_org1   TYPE c LENGTH 40,         "Organization Name 1 (40 characters)
      name_org2   TYPE c LENGTH 40,         "Organization Name 2 (40 characters)
      rwcur       TYPE waers,          "Currency Key
      zuonr       TYPE c LENGTH 18,          "Assignment Number
      butxt       TYPE c LENGTH 25,         "Company Name (25 characters)
      xblnr       TYPE xblnr,          "Reference Document Number
      budat       TYPE datum,           "Posting Date
      stras       TYPE c LENGTH 60,         "Street Address
      mcod3       TYPE c LENGTH 25,         "Search Term
      regio       TYPE regio,          "Region (State, Province, County)
      land1       TYPE land1,          "Country Key
      stcd2       TYPE c LENGTH 20,         "Tax Number 2
      koart       TYPE koart.          "Account Type
    TYPES END OF mty_data.

    TYPES BEGIN OF mty_ode_smpl.
    TYPES belnr  TYPE ztax_ddl_i_brf_payments-belnr.
    TYPES gjahr  TYPE ztax_ddl_i_brf_payments-gjahr.
    TYPES lifnr  TYPE ztax_ddl_i_brf_payments-lifnr.
    TYPES name2  TYPE ztax_ddl_i_brf_payments-name2.
    TYPES name1  TYPE ztax_ddl_i_brf_payments-name1.
    TYPES adres  TYPE ztax_ddl_i_brf_payments-adres.
    TYPES tckn   TYPE ztax_ddl_i_brf_payments-tckn.
    TYPES vkn    TYPE ztax_ddl_i_brf_payments-vkn.
    TYPES mindk  TYPE ztax_ddl_i_brf_payments-mindk.
    TYPES mtext  TYPE ztax_ddl_i_brf_payments-mtext.
    TYPES budat  TYPE ztax_ddl_i_brf_payments-budat.
    TYPES xblnr  TYPE ztax_ddl_i_brf_payments-xblnr.
    TYPES beltr  TYPE ztax_ddl_i_brf_payments-beltr.
    TYPES beltrx TYPE ztax_ddl_i_brf_payments-beltrx.
    TYPES gyst   TYPE ztax_ddl_i_brf_payments-gyst.
    TYPES kst    TYPE ztax_ddl_i_brf_payments-kst.
    TYPES sosg   TYPE ztax_ddl_i_brf_payments-sosg.
*    TYPES row_color TYPE /itetr/tax_s_muh_ode-row_color.
    TYPES END OF mty_ode_smpl.


    TYPES BEGIN OF mty_data_191.
    TYPES rbukrs      TYPE bukrs.
    TYPES gjahr       TYPE gjahr.
    TYPES belnr       TYPE belnr_d.
    TYPES docln       TYPE c LENGTH 6.
    TYPES ryear       TYPE n LENGTH 4.
    TYPES fiscyearper TYPE n LENGTH 7.
    TYPES hsl         TYPE p LENGTH 16 DECIMALS 2.
    TYPES wsl         TYPE p LENGTH 16 DECIMALS 2.
    TYPES drcrk       TYPE c LENGTH 1.         "Debit/Credit Indicator
    TYPES awref_rev   TYPE c LENGTH 12.        "Reversal Reference
    TYPES aworg_rev   TYPE c LENGTH 4.         "Reversal Organization Key
    TYPES awtyp       TYPE c LENGTH 4.         "Document Type
    TYPES awref       TYPE c LENGTH 12.        "Document Reference
    TYPES aworg       TYPE c LENGTH 4.         "Organization Key
    TYPES xreversing  TYPE abap_bool.          "Reversing Indicator
    TYPES xreversed   TYPE abap_bool.          "Reversed Indicator
    TYPES lifnr       TYPE lifnr.              "Vendor Account Number
    TYPES racct       TYPE c LENGTH 10. .            "General Ledger Account
    TYPES sgtxt       TYPE sgtxt.              "Document Item Text
    TYPES rwcur       TYPE waers.              "Currency Key
    TYPES zuonr       TYPE c LENGTH 18.              "Assignment Number
    TYPES budat       TYPE datum.               "Posting Date
    TYPES koart       TYPE c LENGTH 1.         "Account Type
    TYPES END OF mty_data_191.
    "

    TYPES mtty_mg      TYPE TABLE OF mty_mg.
    TYPES mtty_lfb1    TYPE TABLE OF mty_lfb1.
    TYPES mtty_data    TYPE TABLE OF mty_data.
    TYPES mtty_data_191 TYPE TABLE OF mty_data_191.



    DATA mr_monat TYPE RANGE OF monat.

    CONSTANTS BEGIN OF mc_range_att.
    CONSTANTS sign   TYPE c LENGTH 4 VALUE 'SIGN'.
    CONSTANTS option TYPE c LENGTH 6 VALUE 'OPTION'.
    CONSTANTS low    TYPE c LENGTH 3 VALUE 'LOW'.
    CONSTANTS high   TYPE c LENGTH 4 VALUE 'HIGH'.
    CONSTANTS END OF mc_range_att.
