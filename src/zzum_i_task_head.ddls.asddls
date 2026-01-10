@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Basic view for Task header'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{  
    dataClass: #TRANSACTIONAL,
    serviceQuality: #A,
    sizeCategory: #S   
}
@VDM.viewType: #BASIC

define view entity zzum_i_task_head
  as select from zzum_task_head

{
  key task_uuid          as TaskUuid,

      task_id            as TaskId,
      title              as Title,
      description        as Description,
      overall_status     as OverallStatus,
      createdby          as Createdby,
      createdat          as Createdat,
      lastchangedby      as Lastchangedby,
      lastchangedat      as Lastchangedat,
      locallastchangedat as Locallastchangedat
}
