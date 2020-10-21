class Author < ActiveRecord::Base
  include Rules::HasRules

  has_many :books
  has_one :pen_name

  has_rule_attributes({
    last_name: {
      name: 'author last name'
    },
    titles: {
      name: 'titles of books associated with this author',
      association: :books
    },
    pen_name: {
      name: 'pen name',
      association: :pen_name,
      attribute: :name
    },
    chapter_titles: {
      name: 'book chapter titles',
      association: :chapters,
      through: :books,
      attribute: :title
    },
    book_dedications: {
      name: 'book dedications',
      association: :foreword,
      through: :books,
      attribute: :dedication
    }
  })
end
