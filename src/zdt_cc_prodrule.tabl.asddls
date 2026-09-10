@EndUserText.label : 'Product Rule'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zdt_cc_prodrule {
  key client           : abap.clnt not null;
  key product_category : abap.char(4) not null;
  model_key            : abap.char(4);
  q10_factor           : abap.dec(5,2);
  ref_temp_c           : abap.dec(5,2);
  base_shelf_life      : abap.int4;
}
