require 'rails_helper'

RSpec.describe GroupEvent, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:status) }
    context "WHEN status have changed to published" do
      context "WHEN not all of the required fields are present" do
        it "should be invalid" do
          now = Time.now
          duration = 3
          end_date = now + duration.days
          event = build(:group_event, start_date: now, end_date: end_date, duration: duration, location: nil)
          # Forcing conditional validation
          allow(event).to receive(:status_changed?).and_return(true)
          expect(event.valid?).to be_falsey
          expect(event.errors.messages[:status]).to include("Can not publish event with a missing require field")
          expect(event.errors.messages[:location]).to include("Must be present before publishing an event")
        end
      end

      context "WHEN all the required field are present" do
        it "should be valid" do
          event = build(:valid_group_event)
          # Forcing conditional validation
          allow(event).to receive(:status_changed?).and_return(true)
          expect(event.valid?).to be_truthy
        end
      end
    end
  end
end
