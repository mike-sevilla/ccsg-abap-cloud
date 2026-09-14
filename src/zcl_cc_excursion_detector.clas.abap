"! <p class="shorttext synchronized">Detect cold-chain temperature excursions</p>
CLASS zcl_cc_excursion_detector DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_reading,
             zone_id    TYPE c LENGTH 8,
             reading_ts TYPE utclong,
             temp_c     TYPE decfloat34,
           END OF ty_reading,
           "! Collection of temperature readings for {@link .METH:detect}
           tt_readings TYPE STANDARD TABLE OF ty_reading WITH EMPTY KEY.

    TYPES: BEGIN OF ty_excursion,
             zone_id        TYPE c LENGTH 8,
             start_ts       TYPE utclong,
             end_ts         TYPE utclong,
             max_temp_c     TYPE decfloat34,
             degree_minutes TYPE decfloat34,
           END OF ty_excursion,
           "! Collection of detected temperature excursions for {@link .METH:detect}
           tt_excursions TYPE STANDARD TABLE OF ty_excursion WITH EMPTY KEY.

    "! Detects temperature excursions for one cold-storage zone
    "!
    "! The method sorts the readings chronologically and calculates
    "! cumulative degree-minutes for every period above the threshold
    "!
    "! @parameter it_readings    | Temperature readings for one zone
    "! @parameter iv_threshold_c | Maximum permitted temperature in degree Celsius
    "! @parameter rt_excursions  | Detected excursion periods
    "! @raising   zcx_cc_error   | Raised when the input readings are inconsistent
    METHODS detect
      IMPORTING it_readings          TYPE tt_readings
                iv_threshold_c       TYPE decfloat34
      RETURNING VALUE(rt_excursions) TYPE tt_excursions
      RAISING   zcx_cc_error.

ENDCLASS.


CLASS zcl_cc_excursion_detector IMPLEMENTATION.
  METHOD detect.
    DATA previous_timestamp TYPE utclong.
    DATA excursion_open     TYPE abap_bool.
    DATA current_excursion  TYPE ty_excursion.
    DATA previous_reading   TYPE ty_reading.

    IF it_readings IS INITIAL.
      RETURN.
    ENDIF.

    DATA(readings) = it_readings.

    FINAL(first_zone_id) = readings[ 1 ]-zone_id.

    LOOP AT readings TRANSPORTING NO FIELDS
         WHERE zone_id <> first_zone_id.

      RAISE EXCEPTION NEW zcx_cc_error( text = 'Readings for different zones cannot be processed together.' ).
    ENDLOOP.

    SORT readings BY reading_ts.

    LOOP AT readings INTO FINAL(reading_for_validation).

      IF sy-tabix > 1 AND reading_for_validation-reading_ts = previous_timestamp.

        RAISE EXCEPTION NEW zcx_cc_error( text = 'Multiple readings have the same timestamp' ).

      ENDIF.

      previous_timestamp = reading_for_validation-reading_ts.
    ENDLOOP.

    LOOP AT readings INTO FINAL(current_reading).

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

      FINAL(interval_seconds) = utclong_diff( high = current_reading-reading_ts
                                              low  = previous_reading-reading_ts ).

      IF interval_seconds < 0.
        RAISE EXCEPTION NEW zcx_cc_error( text = 'The reading timestamps are not in chronological order.' ).
      ENDIF.

      FINAL(interval_minutes) = interval_seconds / 60.

      IF excursion_open = abap_true.

        FINAL(temperature_excess) = previous_reading-temp_c - iv_threshold_c.

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


CLASS ltc_excursion_detector DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_detector TYPE REF TO zcl_cc_excursion_detector.

    METHODS setup.

    METHODS detects_one_excursion        FOR TESTING RAISING zcx_cc_error.

    METHODS detects_no_excursion         FOR TESTING RAISING zcx_cc_error.

    METHODS detects_multiple_excursions  FOR TESTING RAISING zcx_cc_error.

    METHODS rejects_mixed_zones          FOR TESTING.

    METHODS closes_open_excursion_at_end FOR TESTING RAISING zcx_cc_error.

ENDCLASS.


CLASS ltc_excursion_detector IMPLEMENTATION.
  METHOD setup.
    mo_detector = NEW zcl_cc_excursion_detector( ).
  ENDMETHOD.

  METHOD detects_one_excursion.
    FINAL(readings) =
      VALUE zcl_cc_excursion_detector=>tt_readings( zone_id = 'ZONE0001'

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:00:00.0000000' )
                                                      temp_c     = '2.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:10:00.0000000' )
                                                      temp_c     = '6.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:20:00.0000000' )
                                                      temp_c     = '6.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:30:00.0000000' )
                                                      temp_c     = '3.0' ) ).

    FINAL(excursions) =
      mo_detector->detect( it_readings    = readings
                           iv_threshold_c = '4.0' ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( excursions ) ).

    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '40.0' )
                                        act = excursions[ 1 ]-degree_minutes ).

    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '6.0' )
                                        act = excursions[ 1 ]-max_temp_c ).
  ENDMETHOD.

  METHOD detects_no_excursion.
    FINAL(readings) =
      VALUE zcl_cc_excursion_detector=>tt_readings( zone_id = 'ZONE0001'

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:00:00.0000000' )
                                                      temp_c     = '2.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:10:00.0000000' )
                                                      temp_c     = '3.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:20:00.0000000' )
                                                      temp_c     = '4.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:30:00.0000000' )
                                                      temp_c     = '3.5' ) ).

    FINAL(excursions) =
      mo_detector->detect( it_readings    = readings
                           iv_threshold_c = '4.0' ).

    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lines( excursions ) ).
  ENDMETHOD.

  METHOD detects_multiple_excursions.
    FINAL(readings) =
      VALUE zcl_cc_excursion_detector=>tt_readings( zone_id = 'ZONE0001'

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:00:00.0000000' )
                                                      temp_c     = '2.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:10:00.0000000' )
                                                      temp_c     = '6.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:20:00.0000000' )
                                                      temp_c     = '3.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:30:00.0000000' )
                                                      temp_c     = '7.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:40:00.0000000' )
                                                      temp_c     = '3.0' ) ).

    FINAL(excursions) =
      mo_detector->detect( it_readings    = readings
                           iv_threshold_c = '4.0' ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( excursions ) ).
  ENDMETHOD.

  METHOD rejects_mixed_zones.
    FINAL(readings) =
      VALUE zcl_cc_excursion_detector=>tt_readings( ( zone_id    = 'ZONE0001'
                                                      reading_ts = CONV utclong( '2026-09-11 00:00:00.0000000' )
                                                      temp_c     = '2.0' )

                                                    ( zone_id    = 'ZONE0002'
                                                      reading_ts = CONV utclong( '2026-09-11 00:10:00.0000000' )
                                                      temp_c     = '6.0' ) ).

    TRY.

        mo_detector->detect( it_readings    = readings
                             iv_threshold_c = '4.0' ).

        cl_abap_unit_assert=>fail( msg = 'Expected ZCX_CC_ERROR' ).

      CATCH zcx_cc_error.
        " Expected
    ENDTRY.
  ENDMETHOD.

  METHOD closes_open_excursion_at_end.
    FINAL(readings) =
      VALUE zcl_cc_excursion_detector=>tt_readings( zone_id = 'ZONE0001'

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:00:00.0000000' )
                                                      temp_c     = '2.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:10:00.0000000' )
                                                      temp_c     = '6.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:20:00.0000000' )
                                                      temp_c     = '7.0' )

                                                    ( reading_ts = CONV utclong( '2026-09-11 00:30:00.0000000' )
                                                      temp_c     = '8.0' ) ).

    FINAL(excursions) =
      mo_detector->detect( it_readings    = readings
                           iv_threshold_c = '4.0' ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( excursions ) ).

    cl_abap_unit_assert=>assert_equals( exp = CONV utclong(
                                          '2026-09-11 00:30:00.0000000' )
                                        act = excursions[ 1 ]-end_ts ).
  ENDMETHOD.
ENDCLASS.
