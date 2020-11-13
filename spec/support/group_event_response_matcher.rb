RSpec::Matchers.define :describe_group_event do |expected|
  match_unless_raises do |actual|
    event = actual['group_event']
    expect(event['id']).to eq expected.id
    expect(event["start_date"]).to eq(expected.formatted_start_date)
    expect(event["end_date"]).to eq(expected.formatted_end_date)
    expect(event["duration"]).to eq(expected.duration)
    expect(event["name"]).to eq(expected.name)
    expect(event["location"]).to eq(expected.location)
    expect(event["status"]).to eq(expected.status)
    expect(event["is_deleted"]).to eq(expected.is_deleted)
    expect(event["created_at"]).to eq(expected.formatted_created_at)
    expect(event["updated_at"]).to eq(expected.formatted_updated_at)
    expect(event["deleted_at"]).to eq(expected.formatted_deleted_at)
  end
end

RSpec::Matchers.define :list_group_events do |expected|
  match_unless_raises do |response|
    group_events_data = JSON.parse(response.body)["group_events"]
    expect(group_events_data.size).to eq(expected.size)
    group_events_data.zip(expected).each do |data, group_event|
      expect(data).to describe_group_event(group_event)
    end
  end
end