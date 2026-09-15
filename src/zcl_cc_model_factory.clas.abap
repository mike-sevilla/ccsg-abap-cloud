"! <p class="shorttext synchronized">
"! Factory for shelf-life model creation
"! </p>
CLASS zcl_cc_model_factory DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Identifier used to select a shelf-life model
    TYPES ty_model_key TYPE c LENGTH 4.

    "! Linear shelf-life model key
    CONSTANTS gc_model_linear TYPE ty_model_key VALUE 'LIN'.
    "! Q10 shelf-life model key
    CONSTANTS gc_model_q10    TYPE ty_model_key VALUE 'Q10'.

    "! <p class="shorttext synchronized">
    "! Creates & returns a shelf-life model implementation
    "! </p>
    "!
    "! @parameter iv_model_key | <p class="shorttext synchronized">Requested model identifier</p>
    "! @parameter ro_model     | <p class="shorttext synchronized">Shelf-life model instance</p>
    "! @raising   zcx_cc_error | <p class="shorttext synchronized">Raised when the model key is unknown</p>
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


CLASS ltc_model_factory DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS returns_linear_model  FOR TESTING RAISING zcx_cc_error.

    METHODS returns_q10_model     FOR TESTING RAISING zcx_cc_error.

    METHODS rejects_unknown_model FOR TESTING.

ENDCLASS.


CLASS ltc_model_factory IMPLEMENTATION.
  METHOD returns_linear_model.
    FINAL(model) =
      zcl_cc_model_factory=>get_model( zcl_cc_model_factory=>gc_model_linear ).

    cl_abap_unit_assert=>assert_bound( act = model ).
  ENDMETHOD.

  METHOD returns_q10_model.
    FINAL(model) =
      zcl_cc_model_factory=>get_model( zcl_cc_model_factory=>gc_model_q10 ).

    cl_abap_unit_assert=>assert_bound( act = model ).
  ENDMETHOD.

  METHOD rejects_unknown_model.
    TRY.

        zcl_cc_model_factory=>get_model( 'ABC' ).

        cl_abap_unit_assert=>fail( msg = 'Expected ZCX_CC_ERROR' ).

      CATCH zcx_cc_error.
        " Expected
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
