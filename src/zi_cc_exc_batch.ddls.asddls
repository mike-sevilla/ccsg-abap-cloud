@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Affected Batch Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_cc_exc_batch
  as select from zdt_cc_exc_batch
{
  key exc_id       as ExcId,
      item_id      as ItemId,
      material     as Material,
      batch        as Batch,
      quantity_uom as Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      quantity     as Qty,
      orig_sled    as OrigSled,
      new_sled     as NewSled
}
