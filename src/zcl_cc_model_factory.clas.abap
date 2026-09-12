CLASS zcl_cc_model_factory DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_model_key TYPE c LENGTH 4.

    CONSTANTS gc_model_linear TYPE ty_model_key VALUE 'LIN'.
    CONSTANTS gc_model_q10    TYPE ty_model_key VALUE 'Q10'.

    CLASS-METHODS get_model
      IMPORTING iv_model_key    TYPE ty_model_key
      RETURNING VALUE(ro_model) TYPE REF TO zif_cc_shelflife_model
      RAISING   zcx_cc_error.
ENDCLASS.


CLASS zcl_cc_model_factory IMPLEMENTATION.
  METHOD get_model.
    CASE iv_model_key.
      WHEN gc_model_linear.
        ro_model = NEW zcl_cc_sl_model_linear( ).

      WHEN gc_model_q10.

        ro_model = NEW zcl_cc_sl_model_q10( ).

      WHEN OTHERS.
        RAISE EXCEPTION NEW zcx_cc_error( text = 'Unknown shelf-life model' ).

    ENDCASE.
  ENDMETHOD.
ENDCLASS.
