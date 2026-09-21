@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cold-Chain Zone Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CC_ZONE
  as select from zdt_cc_zone
{
  key zone_id           as ZoneId,
      description       as Description,
      plant             as Plant,
      threshold_temp_c  as ThresholdTempC,
      product_category  as ProductCategory,
      max_excursion_min as MaxExcursionMin
}
