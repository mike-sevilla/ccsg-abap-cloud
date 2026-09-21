@EndUserText.label : 'Affected Batch'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zdt_cc_exc_batch {

  key client   : abap.clnt not null;
  key exc_id   : abap.char(10) not null;
  key item_id  : abap.char(10) not null;
  material     : abap.char(40);
  batch        : abap.char(10);
  quantity_uom : abap.unit(3);
  @Semantics.quantity.unitOfMeasure : 'zdt_cc_exc_batch.quantity_uom'
  quantity     : abap.quan(15,3);
  orig_sled    : abap.datn;
  new_sled     : abap.datn;

}
