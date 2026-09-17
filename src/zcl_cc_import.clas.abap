"! <p class="shorttext synchronized">
"! Imports cold-chain sensor readings from CSV lines
"! </p>
"!
"! Expected CSV column order:
"! zone ID, UTC timestamp, temperature in Celsius, sensor ID
CLASS zcl_cc_import DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES tt_csv_lines TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    METHODS parse_readings
      IMPORTING it_lines           TYPE tt_csv_lines
      RETURNING VALUE(rt_readings) TYPE zcl_cc_excursion_detector=>tt_readings
      RAISING   zcx_cc_error.

  PRIVATE SECTION.
    CONSTANTS gc_expected_columns TYPE i VALUE 4.
ENDCLASS.


CLASS zcl_cc_import IMPLEMENTATION.
  METHOD parse_readings.
    LOOP AT it_lines INTO FINAL(raw_line).
      FINAL(line) = condense( val = raw_line ).

      IF line IS INITIAL.
        CONTINUE.
      ENDIF.

      SPLIT line AT ',' INTO TABLE FINAL(fields).

      IF lines( fields ) <> gc_expected_columns.
        RAISE EXCEPTION NEW zcx_cc_error( text = |Invalid CSV row { sy-tabix }: expected four columns.| ).
      ENDIF.

      FINAL(zone_id_text) = condense( val = fields[ 1 ] ).
      FINAL(timestamp_text) = condense( val = fields[ 2 ] ).
      FINAL(temperature_text) = condense( val = fields[ 3 ] ).
      FINAL(sensor_id_text) = condense( val = fields[ 4 ] ).

      IF zone_id_text IS INITIAL.
        RAISE EXCEPTION NEW zcx_cc_error( text = |Invalid CSV row { sy-tabix }: zone ID is missing.| ).
      ENDIF.

      IF strlen( zone_id_text ) > 8.

        RAISE EXCEPTION NEW zcx_cc_error( text = |Invalid CSV row { sy-tabix }: zone ID exceeds eight characters.| ).
      ENDIF.

      IF timestamp_text IS INITIAL.
        RAISE EXCEPTION NEW zcx_cc_error( text = |Invalid CSV row { sy-tabix }: timestamp is missing.| ).
      ENDIF.

      IF temperature_text IS INITIAL.
        RAISE EXCEPTION NEW zcx_cc_error( text = |Invalid CSV row { sy-tabix }: temperature is missing.| ).
      ENDIF.

      TRY.
          FINAL(timestamp) = CONV utclong( timestamp_text ).
          FINAL(temperature_c) = CONV decfloat34( temperature_text ).

          APPEND VALUE #( zone_id    = zone_id_text
                          reading_ts = timestamp
                          temp_c     = temperature_c
                          sensor_id  = sensor_id_text )
                 TO rt_readings.

        CATCH cx_sy_conversion_no_date_time.
          RAISE EXCEPTION NEW zcx_cc_error( text = |Invalid CSV row { sy-tabix }: timestamp format is invalid.| ).
        CATCH cx_sy_conversion_no_number.
          RAISE EXCEPTION NEW zcx_cc_error( text = |Invalid CSV row { sy-tabix }: temperature is not numeric.| ).
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS ltc_cc_import DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA importer TYPE REF TO zcl_cc_import.

    METHODS setup.

    METHODS parses_valid_rows           FOR TESTING RAISING zcx_cc_error.

    METHODS ignores_blank_lines         FOR TESTING RAISING zcx_cc_error.

    METHODS rejects_missing_column      FOR TESTING.

    METHODS rejects_invalid_temperature FOR TESTING.

    METHODS rejects_invalid_timestamp   FOR TESTING.

ENDCLASS.


CLASS ltc_cc_import IMPLEMENTATION.
  METHOD setup.
    importer = NEW zcl_cc_import( ).
  ENDMETHOD.

  METHOD parses_valid_rows.
    FINAL(lines) =
      VALUE zcl_cc_import=>tt_csv_lines( ( `ZONE0001,2026-09-11 00:00:00.0000000,2.0,SENSOR000001` )
                                         ( `ZONE0001,2026-09-11 00:10:00.0000000,6.0,SENSOR000001` ) ).

    FINAL(readings) =
      importer->parse_readings( it_lines = lines ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( readings )
                                        msg = 'The importer should return two readings' ).

    cl_abap_unit_assert=>assert_equals( exp = 'ZONE0001'
                                        act = readings[ 1 ]-zone_id
                                        msg = 'The first zone ID is incorrect' ).

    cl_abap_unit_assert=>assert_equals( exp = CONV decfloat34( '6.0' )
                                        act = readings[ 2 ]-temp_c
                                        msg = 'The second temperature is incorrect' ).
  ENDMETHOD.

  METHOD ignores_blank_lines.
    FINAL(lines) =
      VALUE zcl_cc_import=>tt_csv_lines( ( `` )
                                         ( `ZONE0001,2026-09-11 00:00:00.0000000,2.0,SENSOR000001` )
                                         ( `   ` ) ).

    FINAL(readings) =
      importer->parse_readings( it_lines = lines ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( readings )
                                        msg = 'Blank CSV lines should be ignored' ).
  ENDMETHOD.

  METHOD rejects_missing_column.
    FINAL(lines) =
      VALUE zcl_cc_import=>tt_csv_lines( ( `ZONE0001,2026-09-11 00:00:00.0000000,2.0` ) ).

    TRY.

        importer->parse_readings( it_lines = lines ).

        cl_abap_unit_assert=>fail( msg = 'A row with a missing column should be rejected' ).

      CATCH zcx_cc_error.
        " Expected exception
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_invalid_temperature.
    FINAL(lines) =
      VALUE zcl_cc_import=>tt_csv_lines( ( `ZONE0001,2026-09-11 00:00:00.0000000,INVALID,SENSOR000001` ) ).

    TRY.

        importer->parse_readings( it_lines = lines ).

        cl_abap_unit_assert=>fail( msg = 'A nonnumeric temperature should be rejected' ).

      CATCH zcx_cc_error.
        " Expected exception
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_invalid_timestamp.
    FINAL(lines) =
      VALUE zcl_cc_import=>tt_csv_lines( ( `ZONE0001,NOT-A-TIMESTAMP,2.0,SENSOR000001` ) ).

    TRY.

        importer->parse_readings( it_lines = lines ).

        cl_abap_unit_assert=>fail( msg = 'An invalid timestamp should be rejected' ).

      CATCH zcx_cc_error.
        " Expected exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.


