@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Basic View for Task Item'

@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #TRANSACTIONAL }

@VDM.viewType: #BASIC

define view entity zzum_i_task_item
  as select from zzum_task_item

{
  key subtask_uuid       as SubtaskUUID,

      parent_uuid        as ParentUUID,

      subtask_id         as SubtaskID,
      description        as Description,
      status             as Status,
      due_date           as DueDate,

      -- Admin Data
      createdby          as CreatedBy,
      createdat          as CreatedAt,
      lastchangedby      as LastChangedBy,
      lastchangedat      as LastChangedAt,
      locallastchangedat as LocalLastChangedAt
}
