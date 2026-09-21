@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Affected Batch'
@Metadata.ignorePropagatedAnnotations: true
define view entity zc_cc_exc_batch
  as select from zi_cc_exc_batch
{
  key ExcursionId,
  key ItemId,
      Material,
      Batch,
      Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      Qty,
      OrigSled,
      NewSled
}
