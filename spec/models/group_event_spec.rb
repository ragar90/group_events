require 'rails_helper'

RSpec.describe GroupEvent, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:status) }
    context "WHEN status have changed to published" do
      context "AND not all of the required fields are present" do
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

      context "AND all the required field are present" do
        it "should be valid" do
          event = build(:valid_group_event)
          # Forcing conditional validation
          allow(event).to receive(:status_changed?).and_return(true)
          expect(event.valid?).to be_truthy
          expect(event.errors.messages[:status].empty?).to be_truthy
          expect(event.errors.messages[:start_date].empty?).to be_truthy
          expect(event.errors.messages[:end_date].empty?).to be_truthy
          expect(event.errors.messages[:duration].empty?).to be_truthy
          expect(event.errors.messages[:name].empty?).to be_truthy
          expect(event.errors.messages[:description].empty?).to be_truthy
          expect(event.errors.messages[:location].empty?).to be_truthy
          expect(event.errors.messages[:is_deleted].empty?).to be_truthy
        end
      end
    end

    context "WHEN have only one date field assign" do
      it "should be invalid" do
        event = build(:group_event, start_date: Time.now)
        # Forcing conditional validation
        allow(event).to receive(:status_changed?).and_return(false)
        expect(event.valid?).to be_falsey
        expect(event.errors.messages[:date_fields]).to include("At least two date fields are required to save event")
      end
    end

    context 'WHEN all date fields have been setup manually' do
      context "AND the calculations do not match" do
        it "should be invalid" do
          start_date = Time.now
          duration = 5
          end_date = start_date + 10.days
          event = build(:group_event, start_date: start_date, end_date: end_date, duration: duration)
          # Forcing conditional validation
          allow(event).to receive(:status_changed?).and_return(false)
          expect(event.valid?).to be_falsey
          expect(event.errors.messages[:date_fields]).to include("Date fields do not match, specify the correct duration or the right start/end dates")
        end
      end
      context "AND the calculations do match" do
        it "should be invalid" do
          start_date = Time.now
          duration = 5
          end_date = start_date + duration.days
          event = build(:group_event, start_date: start_date, end_date: end_date, duration: duration)
          # Forcing conditional validation
          allow(event).to receive(:status_changed?).and_return(false)
          expect(event.valid?).to be_truthy
          expect(event.errors.messages[:date_fields].empty?).to be_truthy
        end
      end
      
    end
  end

  describe '#calculate_date_fields' do
    context "WHEN it has assign #start_date and #end_date" do
      it "should have matching duration" do
        start_date = Time.now
        duration = 3
        end_date = start_date + 3.days
        event = build(:group_event, start_date: start_date, end_date: end_date)
        event.calculate_date_fields
        expect(event.duration).to be == duration
      end
    end

    context "WHEN it has assign #start_date and #duration" do
      it "should have matching duration" do
        start_date = Time.now
        duration = 3
        end_date = start_date + 3.days
        event = build(:group_event, start_date: start_date, duration: duration)
        event.calculate_date_fields
        expect(event.end_date).to be == end_date
      end
    end
    
    context "WHEN it has assign #end_date and #duration" do
      it "should have matching duration" do
        start_date = Time.now
        duration = 3
        end_date = start_date + 3.days
        event = build(:group_event, end_date: end_date, duration: duration)
        event.calculate_date_fields
        expect(event.start_date).to be == start_date
      end
    end
  end

  describe '#delete' do
    it "should mark the record as deleted instead of deleting it from the database" do
      event = create(:valid_group_event)
      expect(event.is_deleted).to be_falsey
      event.delete
      event = GroupEvent.find event.id
      expect(event.is_deleted).to be_truthy
    end
  end

  describe '#destroy' do
    it "should mark the record as deleted instead of deleting it from the database" do
      event = create(:valid_group_event)
      expect(event.is_deleted).to be_falsey
      event.destroy
      event = GroupEvent.find event.id
      expect(event.is_deleted).to be_truthy
    end
  end
end
