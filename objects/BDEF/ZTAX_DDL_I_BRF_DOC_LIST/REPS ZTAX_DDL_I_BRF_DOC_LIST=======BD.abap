unmanaged implementation in class zbp_tax_ddl_i_brf_doc_list unique;
strict ( 2 ); //Uncomment this line in order to enable strict mode 2. The strict mode has two variants (strict(1), strict(2)) and is prerequisite to be future proof regarding syntax and to be able to release your BO.

define behavior for ZTAX_DDL_I_BRF_DOC_LIST //alias <alias_name>
//late numbering
lock master
authorization master ( instance )
//etag master <field_name>
{
//  create;
//  update;
//  delete;
  field ( readonly ) bukrs, gjahr, monat, lineitem;
}