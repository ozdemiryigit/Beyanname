  METHOD if_rap_query_provider~select.

  data : lv_lineitem type int1.


    TRY.


        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
        DATA: lt_bukrs_range  TYPE RANGE OF bukrs,
              lt_gjahr_range  TYPE RANGE OF gjahr,
              lt_monat_range  TYPE RANGE OF monat,
              lt_donemb_range TYPE RANGE OF ztax_e_donemb,
              lt_output       TYPE TABLE OF ztax_ddl_i_vat2_beyan_report,
              ls_output       TYPE ztax_ddl_i_vat2_beyan_report.
        DATA(lt_paging) = io_request->get_paging( ).
*
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
*
        p_bukrs  = VALUE #( lt_bukrs_range[ 1 ]-low OPTIONAL ).
        p_gjahr  = VALUE #( lt_gjahr_range[ 1 ]-low OPTIONAL ).
        p_monat  = VALUE #( lt_monat_range[ 1 ]-low OPTIONAL ).
*        p_donemb = VALUE #( lt_donemb_range[ 1 ]-low OPTIONAL ).
        p_donemb = 01."Sadece aylık kullanıldığı için
        p_beyant = 02.

        fill_monat_range( ).
        fill_shared_structure( ).
        kdv2( ).

        LOOP AT mt_collect INTO DATA(ls_collect).
          APPEND INITIAL LINE TO lt_output ASSIGNING FIELD-SYMBOL(<fs_output>).
          MOVE-CORRESPONDING ls_collect TO <fs_output>.
          <fs_output>-bukrs = p_bukrs.
          <fs_output>-gjahr = p_gjahr.
          <fs_output>-monat = p_monat.

          lv_lineitem = lv_lineitem + 1.
          <fs_output>-lineitem = lv_lineitem.

        ENDLOOP.

        SORT lt_output BY kiril1 kiril2 kiril3.

*        LOOP AT mt_kesinti INTO DATA(ls_lesinti) .
*          MOVE-CORRESPONDING ls_lesinti TO ls_output.
*          APPEND ls_output TO lt_output.
*        ENDLOOP.




        IF io_request->is_total_numb_of_rec_requested(  ).
          io_response->set_total_number_of_records( iv_total_number_of_records = lines( lt_output ) ).
        ENDIF.
        io_response->set_data( it_data = lt_output ).


      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
  ENDMETHOD.