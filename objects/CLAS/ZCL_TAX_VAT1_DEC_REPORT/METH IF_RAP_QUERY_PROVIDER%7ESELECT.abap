  METHOD if_rap_query_provider~select.

    DATA : lv_lineitem TYPE int1.

    TRY.
        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
        DATA: lt_bukrs_range  TYPE RANGE OF bukrs,
              lt_gjahr_range  TYPE RANGE OF gjahr,
              lt_monat_range  TYPE RANGE OF monat,
              lt_donemb_range TYPE RANGE OF ztax_e_donemb,
              lt_output       TYPE TABLE OF ztax_ddl_i_vat1_dec_report,
              ls_output       TYPE ztax_ddl_i_vat1_dec_report.
        DATA(lt_paging) = io_request->get_paging( ).

        LOOP AT lt_filter INTO DATA(ls_filter).
          CASE ls_filter-name.
            WHEN 'BUKRS'.
              lt_bukrs_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'GJAHR'.
              lt_gjahr_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'MONAT'.
              lt_monat_range = CORRESPONDING #( ls_filter-range ).
*            WHEN 'DONEMB'.
*              lt_monat_range = CORRESPONDING #( ls_filter-range ).
          ENDCASE.
        ENDLOOP.

        p_bukrs  = VALUE #( lt_bukrs_range[ 1 ]-low OPTIONAL ).
        p_gjahr  = VALUE #( lt_gjahr_range[ 1 ]-low OPTIONAL ).
        p_monat  = VALUE #( lt_monat_range[ 1 ]-low OPTIONAL ).
*        p_donemb = VALUE #( lt_donemb_range[ 1 ]-low OPTIONAL ).
        p_donemb = 01."Sadece aylık kullanıldığı için
        p_beyant = 02.

        fill_monat_range( ).
        fill_det_kural_range( ).
        kdv1( ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
  ENDMETHOD.