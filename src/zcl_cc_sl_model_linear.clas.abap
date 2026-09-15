"! <p class="shorttext synchronized">
"! Linear shelf-life model
"! </p>
"!
"! This implementation applies a simple linear rule
"! 100 degree-minutes = 1 day of shelf-life reduction.
CLASS zcl_cc_sl_model_linear DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_cc_shelflife_model.

    "! Degree-minute equivalent to one day of shelf-life loss
    CONSTANTS gc_degree_minutes_per_day TYPE decfloat34 VALUE 100.
ENDCLASS.


CLASS zcl_cc_sl_model_linear IMPLEMENTATION.
  METHOD zif_cc_shelflife_model~calculate_expiry.
    FINAL(days_lost) = floor( iv_degree_minutes / gc_degree_minutes_per_day ).

    rv_new_shelf_life_days = nmax( val1 = iv_original_shelf_life_days - days_lost
                                   val2 = 0 ).
  ENDMETHOD.
ENDCLASS.

CLASS ltc_sl_model_linear DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA model TYPE REF TO zif_cc_shelflife_model.

    METHODS setup.
    METHODS no_loss        FOR TESTING.
    METHODS one_day_loss   FOR TESTING.
    METHODS two_day_loss   FOR TESTING.
    METHODS never_negative FOR TESTING.

ENDCLASS.


CLASS ltc_sl_model_linear IMPLEMENTATION.
  METHOD setup.
    model = NEW zcl_cc_sl_model_linear( ).
  ENDMETHOD.

  METHOD no_loss.
    FINAL(result) = model->calculate_expiry( iv_original_shelf_life_days = 14
                                             iv_degree_minutes           = 0 ).

    cl_abap_unit_assert=>assert_equals( exp = 14
                                        act = result ).
  ENDMETHOD.

  METHOD one_day_loss.
    FINAL(result) = model->calculate_expiry( iv_original_shelf_life_days = 14
                                             iv_degree_minutes           = 100 ).

    cl_abap_unit_assert=>assert_equals( exp = 13
                                        act = result ).
  ENDMETHOD.

  METHOD two_day_loss.
    FINAL(result) = model->calculate_expiry( iv_original_shelf_life_days = 14
                                             iv_degree_minutes           = 200 ).

    cl_abap_unit_assert=>assert_equals( exp = 12
                                        act = result ).
  ENDMETHOD.

  METHOD never_negative.
    FINAL(result) = model->calculate_expiry( iv_original_shelf_life_days = 14
                                             iv_degree_minutes           = 9999999 ).

    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = result ).
  ENDMETHOD.
ENDCLASS.
