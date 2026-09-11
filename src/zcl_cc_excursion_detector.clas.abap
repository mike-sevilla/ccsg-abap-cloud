CLASS zcl_cc_excursion_detector DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_reading,
             zone_id    TYPE c LENGTH 8,
             reading_ts TYPE utclong,
             temp_c     TYPE decfloat34,
           END OF ty_reading,

           tt_readings TYPE STANDARD TABLE OF ty_reading WITH EMPTY KEY.

    TYPES: BEGIN OF ty_excursion,
             zone_id        TYPE c LENGTH 8,
             start_ts       TYPE utclong,
             end_ts         TYPE utclong,
             max_temp_c     TYPE decfloat34,
             degree_minutes TYPE decfloat34,
           END OF ty_excursion,

           tt_excursions TYPE STANDARD TABLE OF ty_excursion WITH EMPTY KEY.

    METHODS detect
      IMPORTING it_readings          TYPE tt_readings
                iv_threshold_c       TYPE decfloat34
      RETURNING VALUE(rt_excursions) TYPE tt_excursions
      RAISING   zcx_cc_error.

ENDCLASS.


CLASS zcl_cc_excursion_detector IMPLEMENTATION.
  METHOD detect.
    IF it_readings IS INITIAL.
      RETURN.
    ENDIF.

    DATA(readings) = it_readings.
    SORT readings BY reading_ts.

    DATA(first_zone_id) = readings[ 1 ]-zone_id.

    LOOP AT readings TRANSPORTING NO FIELDS
         WHERE zone_id <> first_zone_id.

      RAISE EXCEPTION NEW zcx_cc_error( text = 'Readings for different zonez cannot be processed together.' ).
    ENDLOOP.

    DATA excursion_open    TYPE abap_bool.
    DATA previous_reading  TYPE ty_reading.
    DATA current_excursion TYPE ty_excursion.

    LOOP AT readings INTO DATA(current_reading).

      IF sy-tabix = 1.

        IF current_reading-temp_c > iv_threshold_c.
          excursion_open = abap_true.

          current_excursion = VALUE ty_excursion( zone_id        = current_reading-zone_id
                                                  start_ts       = current_reading-reading_ts
                                                  end_ts         = current_reading-reading_ts
                                                  max_temp_c     = current_reading-temp_c
                                                  degree_minutes = 0 ).
        ENDIF.

        previous_reading = current_reading.
        CONTINUE.
      ENDIF.

      DATA(interval_seconds) = utclong_diff( high = current_reading-reading_ts
                                             low  = previous_reading-reading_ts ).

      IF interval_seconds < 0.
        RAISE EXCEPTION NEW zcx_cc_error( text = 'The reading timestamps are not in chronological order.' ).
      ENDIF.

      DATA(interval_minutes) = interval_seconds / 60.

      IF excursion_open = abap_true.

        DATA(temperature_excess) = previous_reading-temp_c - iv_threshold_c.

        IF temperature_excess > 0.
          current_excursion-degree_minutes += temperature_excess * interval_minutes.
        ENDIF.

        IF current_reading-temp_c > iv_threshold_c.
          current_excursion-max_temp_c = nmax( val1 = current_excursion-max_temp_c
                                               val2 = current_reading-temp_c ).
        ELSE.

          current_excursion-end_ts = current_reading-reading_ts.
          APPEND current_excursion TO rt_excursions.

          CLEAR current_excursion.
          excursion_open = abap_false.

        ENDIF.
      ELSEIF current_reading-temp_c > iv_threshold_c.

        excursion_open = abap_true.

        current_excursion = VALUE #( zone_id        = current_reading-zone_id
                                     start_ts       = current_reading-reading_ts
                                     max_temp_c     = current_reading-temp_c
                                     degree_minutes = 0 ).

      ENDIF.

      previous_reading = current_reading.

    ENDLOOP.

    IF excursion_open = abap_true.
      current_excursion-end_ts = previous_reading-reading_ts.
      APPEND current_excursion TO rt_excursions.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
