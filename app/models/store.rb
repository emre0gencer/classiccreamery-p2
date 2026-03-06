class Store < ApplicationRecord
  ### Relationships
  has_many :assignments
  has_many :employees, through: :assignments

  ### Callback
  before_save :normalize_phone

  PHONE_REGEX = /\A(\d{10}|\(?\d{3}\)?[-. ]\d{3}[-.]\d{4})\z/

  ### Validations - PATS style
  
  validates_presence_of :name, :street, :city, :state, :zip, :phone
  validates_uniqueness_of :name, case_sensitive: false
  validates_inclusion_of :state, in: %w[PA OH WV], message: "should be PA, OH, or WV"
  validates_format_of :zip, with: /\A\d{5}\z/, message: "should be 5 digits"
  validates_format_of :phone, with: PHONE_REGEX, message: "should be a 10-digit number, with or without dashes, parentheses, spaces, dots, etc."

  ### Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :alphabetical, -> { order(:name) }

  def make_active
    update(active: true)
  end
  def make_inactive
    update(active: false)
  end
  
  private

  ### Phone reformatter helper
    
  def normalize_phone
    return if phone.blank?
    self.phone = phone.gsub(/\D/, '')
  end
end
