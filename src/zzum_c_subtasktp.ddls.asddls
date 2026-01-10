@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for Subtask'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zzum_c_subtaskTP
  as projection on zzum_r_subtasktp
{
    key SubtaskUUID,
    ParentUUID,
    
    SubtaskID,
    Description,
    Status,
    DueDate,

    LocalLastChangedAt,
    /* Associations */
    _Header : redirected to parent zzum_c_tasktp
}
