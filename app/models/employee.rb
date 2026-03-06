class Employee < ApplicationRecord
  ### Relationships
  has_many :assignments
  has_many :stores, through: :assignments

  ### Callback
  before_save :normalize_phone
  before_save :normalize_ssn

  ### Roles
  enum :role, { employee: 1, manager: 2, admin: 3 }, scopes: false, default: :employee

  #Co-pilot-suggested code for ROLES constant
  ROLES = [
    ["Employee", Employee.roles[:employee]],
    ["Manager", Employee.roles[:manager]],
    ["Admin", Employee.roles[:admin]]
  ]

  ### Referenced PATs_v1 Regex for phone and ssn normalization
  PHONE_REGEX_old = /\A(\d{10}|\(?\d{3}\)?[-. ]?\d{3}[-. ]?\d{4})\z/
  PHONE_REGEX = /\A(\d{10}|\(?\d{3}\)?[-. ]\d{3}[-.]\d{4})\z/
  SSN_REGEX_old = /\A(\d{9}|\d{3}[- ]?\d{2}[- ]?\d{4})\z/
  SSN_REGEX = /\A(\d{9}|\d{3}[- ]\d{2}[- ]\d{4})\z/

  ### Validations
  validates_presence_of :first_name, :last_name, :phone, :ssn, :date_of_birth
  validates_format_of :phone, with: PHONE_REGEX, message: "should be a 10-digit number, with or without dashes, parentheses, spaces, dots, etc."
  validates_format_of :ssn, with: SSN_REGEX, message: "should be a 9-digit number, with or without dashes, parantheses, spaces, dots, etc."
  validates_uniqueness_of :ssn
  validate :at_least_14_years_old
  #Copilot-suggested code for role validation
  validates :role, presence: true, inclusion: { in: %w[employee manager admin] }

  ### Scopes

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where.not(active: true) }
  scope :alphabetical, -> { order(:last_name, :first_name) }
  scope :is_18_or_older, -> { where("date_of_birth <= ?", 18.years.ago.to_date) }
  scope :younger_than_18, -> { where("date_of_birth > ?", 18.years.ago.to_date) }
  
  scope :regulars, -> { where(role: 1) }
  scope :managers, -> { where(role: 2) }
  scope :admins, -> { where(role: 3) }

  #returns all employees who have either a first or last name starts with or matches a given search term
  scope :search, ->(term) {
    return none if term.blank?
    where("LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?", "#{term.downcase}%", "#{term.downcase}%")
  }

  ### Instance Methods

  def employee_role?
    employee?
  end

  def manager_role?
    manager?
  end

  def admin_role?
    admin?
  end

  def make_active
    update(active: true)
  end

  def make_inactive
    update(active: false)
  end

  def name
    "#{last_name}, #{first_name}"
  end

  def proper_name
    "#{first_name} #{last_name}"
  end

  #Copilot-suggested code
  def current_assignment
    assignments.current.order(start_date: :desc).first
  end

  def over_18?
    date_of_birth <= 18.years.ago.to_date
  end

  private

  # Copilot-suggested code
  def at_least_14_years_old
    return if date_of_birth.blank?

    if date_of_birth > 14.years.ago.to_date
      errors.add(:date_of_birth, "must be at least 14 years old")
    end
  end

  ### Phone and SSN helpers (PATS)

  def normalize_phone
    return if phone.blank?
    self.phone = phone.gsub(/\D/, "")
  end

  def normalize_ssn
    return if ssn.blank?
    self.ssn = ssn.gsub(/\D/, "")
  end

end
