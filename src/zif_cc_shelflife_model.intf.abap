INTERFACE zif_cc_shelflife_model
  PUBLIC.

  METHODS calculate_expiry
    IMPORTING iv_original_shelf_life_days   TYPE i
              iv_degree_minutes             TYPE decfloat34
    RETURNING VALUE(rv_new_shelf_life_days) TYPE i.

ENDINTERFACE.
