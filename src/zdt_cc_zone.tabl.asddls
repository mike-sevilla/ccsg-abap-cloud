@EndUserText.label : 'Zones'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zdt_cc_zone {
  key client        : abap.clnt not null;
  key zone_id       : abap.char(8) not null;
  description       : abap.char(40);
  plant             : abap.char(4);
  threshold_temp_c  : abap.dec(5,2);
  product_category  : abap.char(4);
  max_excursion_min : abap.int4;
}
