CLASS LHC_ZTAX_DDL_I_PERIOD_INFORMAT DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.

    METHODS GET_INSTANCE_AUTHORIZATIONS FOR INSTANCE AUTHORIZATION
      IMPORTING KEYS REQUEST REQUESTED_AUTHORIZATIONS FOR ZTAX_DDL_I_PERIOD_INFORMATION RESULT RESULT.

ENDCLASS.

CLASS LHC_ZTAX_DDL_I_PERIOD_INFORMAT IMPLEMENTATION.

  METHOD GET_INSTANCE_AUTHORIZATIONS.
  ENDMETHOD.

ENDCLASS.