class Employee < ApplicationRecord

  validates :employee_id, presence: true, uniqueness: true

  validates :first_name, :last_name, :email, :doj, :salary, presence: true
  
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  validates :employee_id, format: { with: /\A[A-Za-z]+\d+\z/, message: "must start with letters followed by numbers" }

  serialize :phone_numbers, JSON

  validate :validate_phone_numbers

  private

  def validate_phone_numbers
    if phone_numbers.blank? || phone_numbers.any? { |number| !number.match?(/\A\d{10}\z/) }
      errors.add(:phone_numbers, 'must have at least one valid phone number')
    end
  end
end
