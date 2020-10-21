class Book < ActiveRecord::Base
  belongs_to :author
  
  has_many :chapters, dependent: :destroy
  has_one :foreword, dependent: :destroy
end
