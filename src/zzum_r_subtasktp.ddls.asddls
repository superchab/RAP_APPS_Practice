@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Restricted View for Task Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity zzum_r_subtasktp
  as select from zzum_i_task_item
  association to parent zzum_r_taskTP as _Header on $projection.ParentUUID = _Header.TaskUUID
{
  key SubtaskUUID,
      ParentUUID,
      
      SubtaskID,
      Description,
      Status,
      DueDate,
      
      -- Admin Data
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      
      -- Associations
      _Header
}
