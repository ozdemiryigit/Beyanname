  PROTECTED SECTION.

    METHODS:
      get_documents,
      get_item_data EXPORTING et_mg       TYPE mtty_mg
                              et_data     TYPE mtty_data
                              et_data_191 TYPE mtty_data_191
                              et_lfb1     TYPE mtty_lfb1,
      fill_period IMPORTING ir_monat       TYPE ANY TABLE
                  EXPORTING er_fiscyearper TYPE ANY TABLE,
      fill_range IMPORTING iv_sign   TYPE c DEFAULT 'I'
                           iv_option TYPE ztax_e_option DEFAULT 'EQ'
                           iv_low    TYPE clike DEFAULT space
                           iv_high   TYPE clike DEFAULT space
                 EXPORTING et_range  TYPE STANDARD TABLE
                 .