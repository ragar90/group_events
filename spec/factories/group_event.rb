FactoryBot.define do
  factory :group_event do
    sequence(:name) { |n| "Cool Event #{n} " }
    sequence(:description) { |n| "Event for #{n} cool people" }
    sequence(:location) { |n| "Cool location #{n}" }
    status { GroupEvent.statuses[:draft] }
    factory :valid_group_event do
      start_date { Time.now }
      end_date { Time.now + 1.day}
      duration {1}
    end
  end
end