json.group_events @events do |event|
  json.partial! "events/event", event: event
end