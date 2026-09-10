@EndUserText.label : 'Sensor reading'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zdt_cc_templog {
  key client     : abap.clnt not null;
  key zone_id    : abap.char(8) not null;
  key reading_ts : abap.utclong not null;
  temp_c         : abap.dec(5,2);
  sensor_id      : abap.char(12);
}
