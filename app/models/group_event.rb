class GroupEvent < ApplicationRecord
  validate :can_be_published?, if: -> { self.status_changed?(to: GroupEvent.statuses[:published]) }
  validates :is_draft, presence: true
  validates :is_published, presence: true
  enum status: {
    published: "PUBLISHED",
    draft: "DRAFT"
  }
  
  private
    def can_be_published?
      all_fields_present = GroupEvent.column_names.map(&:to_sym)
        .delete_if{|field| [:created_at, :updated_at, :id, :is_draft, :is_published].include?(field) }
        .map{ |field| self.send(field).present?(field) }
        .reduce{ |field, value| value && field }
      if all_fields_present and self.is_published
        self.errors.add(:is_published, "Published event can not be published again")
      elsif !all_fields_present
        self.errors.add(:is_published, "Can not publish event with a missing require field")
      end
    end
end
