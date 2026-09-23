@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Temperature Trend'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CC_TEMP_TREND
  with parameters
    p_zone : abap.char( 8 )
  as select from zdt_cc_templog

{
  key reading_ts as ReadingTimestamp,
      zone_id    as ZoneId,
      sensor_id  as SensorId,
      temp_c     as TemperatureC
}

where
  zone_id = $parameters.p_zone
