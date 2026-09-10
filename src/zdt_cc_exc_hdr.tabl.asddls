@EndUserText.label : 'Excursion case header'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zdt_cc_exc_hdr {
  key client     : abap.clnt not null;
  key exc_id     : abap.char(10) not null;
  zone_id        : abap.char(8);
  plant          : abap.char(4);
  start_ts       : abap.utclong;
  end_ts         : abap.utclong;
  max_temp_c     : abap.dec(5,2);
  degree_minutes : abap.dec(11,2);
  exc_status     : abap.char(12);
  disposition    : abap.char(14);
  created_by     : abp_creation_user;
  created_at     : abp_creation_utcl;
  changed_by     : abp_lastchange_user;
  changed_at     : abp_lastchange_utcl;
}
