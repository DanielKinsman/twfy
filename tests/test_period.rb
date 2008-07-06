$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'test/unit'
require 'date'

require 'period'
require 'name'
require 'person'
require 'date_with_future'

class TestPeriod < Test::Unit::TestCase
  def test_equality
    person = Person.new(Name.new(:first => "John", :last => "Smith"))
    period1 = Period.new(:house => "representatives", :division => "division1", :party => "party1",
      :from_date => Date.new(2000, 1, 1), :to_date => Date.new(2001, 1, 1),
      :from_why => "general_election", :to_why => "defeated", :person => person)
    # Make period2 and period1 the same by giving them the same id
    period2 = Period.new(:count => period1.count, :house => "representatives", :division => "division1", :party => "party1",
        :from_date => Date.new(2000, 1, 1), :to_date => Date.new(2001, 1, 1),
        :from_why => "general_election", :to_why => "defeated", :person => person)
    
    period3 = Period.new(:house => "representatives", :division => "division1", :party => "party1",
            :from_date => Date.new(2002, 1, 1), :to_date => DateWithFuture.future,
            :from_why => "general_election", :to_why => "current_member", :person => person)
    assert_equal(period1, period2)
    assert_not_equal(period2, period3)
  end
end