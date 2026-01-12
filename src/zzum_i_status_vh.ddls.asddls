@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZZUM_I_STATUS_VH 
  as select from dd07t
{
      @ObjectModel.text.element: ['Description']
  key domvalue_l as Status,
      
      ddtext     as Description
}
where domname    = 'ZZUM_STATUS_D'  -- <--- Your Domain Name
  and as4local   = 'A'              -- Active entries only
  and as4vers    = '0000'           -- Version 0 (Standard)
  and ddlanguage = $session.system_language
