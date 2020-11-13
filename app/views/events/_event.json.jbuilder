json.group_event do
  json.(event, :id, :duration, :name, :description, :location, :status, :is_deleted)
  json.start_date event.formatted_start_date
  json.end_date event.formatted_end_date
  json.created_at event.formatted_created_at
  json.updated_at event.formatted_updated_at
  json.deleted_at event.formatted_deleted_at
end
