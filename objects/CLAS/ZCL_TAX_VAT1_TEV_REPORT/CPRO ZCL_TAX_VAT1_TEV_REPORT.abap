  PROTECTED SECTION.

    METHODS:
      fill_monat_range,
      get_map_tab EXPORTING et_map TYPE mtty_map,
      fill_mwskz IMPORTING it_map   TYPE mtty_map
                 EXPORTING er_mwskz TYPE mtty_mwskz_range,
      get_fieldname EXPORTING et_tevita TYPE mtty_tevita,
      create_dynamic_tab IMPORTING iv_str_name TYPE clike
                                   it_field    TYPE mtty_tevita
                         EXPORTING eo_data     TYPE REF TO data,
*                                   et_fcat     TYPE lvc_t_fcat.
      find_document IMPORTING is_read_tab TYPE mty_read_tab
                              ir_saknr    TYPE mtty_saknr_range OPTIONAL
                              ir_mwskz    TYPE mtty_mwskz_range OPTIONAL
                    EXPORTING et_bkpf     TYPE mtty_bkpf
                              et_bset     TYPE mtty_bset
                              et_bseg     TYPE mtty_bseg.
