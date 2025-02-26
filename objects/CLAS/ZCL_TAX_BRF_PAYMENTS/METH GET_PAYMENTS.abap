  METHOD get_payments.


    DATA lt_mg          TYPE mtty_mg.
    DATA lt_lfb1        TYPE mtty_lfb1.
    DATA ls_lfb1        TYPE mty_lfb1.
    DATA ls_data        TYPE mty_data.
    DATA ls_data_k      TYPE mty_data.
    DATA lt_data        TYPE mtty_data.
    DATA ls_ode         TYPE mty_ode_smpl.
    DATA lt_lifnr       TYPE mtty_data.
    DATA ls_lifnr       TYPE mty_data.
    DATA lt_data_k      TYPE mtty_data.
    DATA lt_data_191    TYPE mtty_data_191.
    DATA lt_ode         TYPE TABLE OF mty_ode_smpl.
    DATA lt_mg_range    TYPE mtty_mg.

    DATA lv_amount_k    TYPE p LENGTH 16 DECIMALS 2..
    DATA lv_amount_191  TYPE p LENGTH 16 DECIMALS 2.

    DATA lt_mmt TYPE TABLE OF ztax_t_mmt.
    DATA ls_mmt TYPE ztax_t_mmt.
    DATA lt_mmt_lifnr TYPE TABLE OF ztax_t_mmt.

    TYPES: BEGIN OF lty_lfa1,
             lifnr TYPE string,            " Business Partner Number
             name1 TYPE string,            " Name 1
             name2 TYPE string,            " Name 2
             stras TYPE string,            " Street
             regio TYPE string,            " Region
             mcod3 TYPE string,            " Additional Code
             land1 TYPE string,            " Country
             stcd2 TYPE string,            " Tax Number
           END OF lty_lfa1.


    DATA lt_lfa1 TYPE TABLE OF lty_lfa1.
    DATA ls_lfa1 TYPE lty_lfa1.
    DATA lr_hkont TYPE RANGE OF hkont.
    FIELD-SYMBOLS <fs_ode>       TYPE ztax_ddl_i_brf_payments.
    FIELD-SYMBOLS <fs_data>      TYPE mty_data.
    FIELD-SYMBOLS <fs_data_191>  TYPE mty_data_191.

*    CLEAR et_ode.
*    CLEAR ms_button_pushed.
*    CLEAR mv_mod.
*    ms_button_pushed-ode = abap_true.

    get_item_data( IMPORTING et_mg       = lt_mg
                             et_data     = lt_data
                             et_data_191 = lt_data_191
                             et_lfb1     = lt_lfb1 ).

*    SELECT land1,
*           bland,
*           bezei
*           FROM I_T005U
*           WHERE spras EQ @sy-langu
*           INTO TABLE @DATA(lt_t005u).
**
    SELECT country AS land1,
           countryname AS landx
           FROM i_countrytext "t005t
           WHERE language EQ @sy-langu
           INTO TABLE @DATA(lt_t005t).
*
*    SELECT mindk,
*           mtext
*           FROM t059t
*           WHERE spras EQ @sy-langu
*            INTO TABLE @DATA(lt_gricd_txt)
*             .
*
    SELECT mindk,
           beltr,
           acklm
           FROM ztax_t_modt
            INTO TABLE @DATA(lt_modt).
*
*    SORT lt_t005u     BY land1 bland.
    SORT lt_t005t     BY land1.
*    SORT lt_gricd_txt BY mindk.
    SORT lt_modt      BY mindk.

    lt_lifnr = lt_data.
    DELETE lt_lifnr WHERE lifnr EQ space.

    SORT lt_lifnr BY bukrs gjahr belnr.

    "
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





  ENDMETHOD.