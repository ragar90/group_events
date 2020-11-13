class GroupEvent < ApplicationRecord
  validates :status, presence: true
  validate :can_be_published?, if: -> { self.status_changed?(to: GroupEvent.statuses[:published]) }
  validate :can_calculate_missing_date_fields?
  validate :date_fields_match
  enum status: {
    published: "published",
    draft: "draft"
  }
  scope :deleted, -> { where(is_deleted: true)}
  scope :not_deleted, -> { where(is_deleted: false)}
  # Ex:- scope :active, -> {where(:active => true)}

  def calculate_date_fields
    if self.has_all_date_fields?
      return
    elsif self.start_date.present? and self.end_date.present?
      self.calculate_duration
    elsif self.start_date.present? and self.duration.present?
      self.calculate_end_date
    else
      self.calculate_start_date
    end
  end

  def has_all_date_fields?
    self.start_date.present? and self.end_date.present? and self.duration.present?
  end

  def delete
    update_columns(is_deleted: true, deleted_at: Time.now)
  end

  def destroy
    callbacks_result = transaction do
      run_callbacks(:destroy) do
        delete
      end
    end
    callbacks_result ? self : false
  end

  def formatted_start_date
    self.start_date.strftime("%Y-%m-%dT%H:%M:%S%z")
  end

  def formatted_end_date
    self.start_date.strftime("%Y-%m-%dT%H:%M:%S%z")
  end

  def formatted_created_at
    self.start_date.strftime("%Y-%m-%dT%H:%M:%S%z")
  end

  def formatted_updated_at
    self.start_date.strftime("%Y-%m-%dT%H:%M:%S%z")
  end

  def formatted_deleted_at
    self.start_date.strftime("%Y-%m-%dT%H:%M:%S%z")
  end


  private

    def calculate_duration
      seconds_in_a_day = 1.day.to_i
      self.duration = (self.end_date - self.start_date).to_i / seconds_in_a_day
    end

    def calculate_end_date
      self.end_date = self.start_date + duration.days
    end

    def calculate_start_date
      self.start_date = self.end_date -  duration.days
    end

    def date_fields_match
      if self.has_all_date_fields? 
        seconds_in_a_day = 1.day.to_i
        expected_duration =  (self.end_date - self.start_date).to_i / seconds_in_a_day
        unless self.duration == expected_duration
          self.errors.add(:date_fields, "Date fields do not match, specify the correct duration or the right start/end dates")
        end
      end
    end

    def can_calculate_missing_date_fields?
      date_fields_present = [self.start_date.present?, self.end_date.present?, self.duration.present?].keep_if{|field_present| field_present }
      if(date_fields_present.size < 2)
        self.errors.add(:date_fields, "At least two date fields are required to save event")
      end
    end

    def can_be_published?
      all_fields_present = GroupEvent.column_names.map(&:to_sym)
        .delete_if{|f| [:id, :created_at, :updated_at, :deleted_at].include?(f) }
        .map{ |field| !self.send(field).nil? }
        .reduce{ |field, value| value && field }
      if all_fields_present and self.published?
        self.errors.add(:status, "Published event can not be published again")
      elsif !all_fields_present
        GroupEvent.column_names.map(&:to_sym)
        .delete_if{|field| [:id, :created_at, :updated_at].include?(field) }
        .delete_if{ |field| !self.send(field).nil? }
        .each{ |field| self.errors.add(field, "Must be present before publishing an event") }
        self.errors.add(:status, "Can not publish event with a missing require field")
      end
    end
end
