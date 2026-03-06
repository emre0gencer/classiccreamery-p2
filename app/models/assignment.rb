class Assignment < ApplicationRecord
  ### Relationships
  belongs_to :store
  belongs_to :employee
  ### Validations
  validates :start_date, presence: true
  validates :store_id, presence: true
  validates :employee_id, presence: true

  validate :start_date_valid_time
  validate :end_date_valid_time
  validate :store_active
  validate :employee_active
  

  ### Scopes
  scope :current, -> {where(end_date: nil)}
  scope :past, -> { where.not(end_date: nil) }
  scope :by_store, -> { joins(:store).order('stores.name') }
  scope :by_employee, -> { joins(:employee).order('employees.last_name', 'employees.first_name') }
  scope :chronological, -> { order(start_date: :desc) }
  scope :for_store, ->(store_id) { where(store_id: store_id) }
  scope :for_employee, ->(employee_id) { where(employee_id: employee_id) }
  scope :for_role, -> (role) { joins(:employee).where(employees: { role: role }) }
  scope :for_date, -> (date) { where("start_date <= ? AND (end_date >= ? OR end_date IS NULL)", date, date) }

  ### Callback
  before_create :end_previous_assignment

  private

  def start_date_valid_time
    return if start_date.blank?

    if start_date > Date.current
      errors.add(:start_date, "must be on or before the present date")
    end
  end

  def end_date_valid_time
    return if end_date.blank? || start_date.blank?

    # must be AFTER start_date
    if end_date <= start_date
      errors.add(:end_date, "must be after the start date")
      return
    end

    # must be on or before today
    if end_date > Date.current
      errors.add(:end_date, "must be on or before the present date")
    end
  end


  def store_active
    return if store_id.blank?
    s = Store.find_by(id: store_id)
    errors.add(:store_id, "must be active") if s.nil? || !s.active?
  end

  def employee_active
    return if employee_id.blank?
    e = Employee.find_by(id: employee_id)
    errors.add(:employee_id, "must be active") if e.nil? || !e.active?
  end


  #GPT-suggested code (revised)
  def end_previous_assignment
    return if employee_id.blank? || start_date.blank?

    current = Assignment
                .where(employee_id: employee_id)
                .where(end_date: nil)
                .where("start_date <= ?", start_date)
                .order(start_date: :desc)
                .first

    current.update_column(:end_date, start_date) unless current.nil?
  end

end