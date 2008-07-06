class PeriodBase
  attr_accessor :from_date, :to_date, :person
  
  def initialize(params)
    @from_date =  params[:from_date]
    @to_date =    params[:to_date]
    @person =     params.delete(:person)
    invalid_keys = params.keys - [:from_date, :to_date, :person]
    throw "Invalid keys: #{invalid_keys}" unless invalid_keys.empty?
  end  

  def current_on_date?(date)
    date >= @from_date && date <= @to_date
  end
  
  def current?
    current_on_date?(Date.today)
  end
  
  def name
    person.name
  end
end

class MinisterPosition < PeriodBase
  attr_accessor :position, :minister_count
  
  def MinisterPosition.reset_id_counter
    @@next_minister_count = 1
  end
  
  reset_id_counter
  
  def id
    "uk.org.publicwhip/moffice/#{@minister_count}"
  end
  
  def initialize(params)
    @position = params.delete(:position)
    @minister_count = @@next_minister_count
    @@next_minister_count = @@next_minister_count + 1
    super
  end  
end

# Represents a period in the house of representatives
class Period < PeriodBase
  attr_accessor :from_why, :to_why, :division, :party, :house
  attr_reader :count

  def Period.reset_id_counter
    @@next_rep_count = 1
    @@next_senator_count = 1
  end
  
  reset_id_counter
  
  def id
    if senator?
      "uk.org.publicwhip/lord/#{@count}"
    else
      "uk.org.publicwhip/member/#{@count}"
    end
  end
  
  def representative?
    @house == "representatives"
  end
  
  def senator?
    @house == "senate"
  end
  
  def initialize(params)
    # TODO: Make some parameters compulsary and others optional
    throw ":person parameter required in HousePeriod.new" unless params[:person]
    @from_why =   params.delete(:from_why)
    @to_why =     params.delete(:to_why)
    @division =   params.delete(:division)
    @party =      params.delete(:party)
    @house =      params.delete(:house)
    throw ":house parameter must have value 'representatives' or 'senate'" unless representative? || senator?
    if params[:count]
      @count = params.delete(:count)
    else
      if senator?
        @count = @@next_senator_count
        @@next_senator_count = @@next_senator_count + 1
      else
        @count = @@next_rep_count
        @@next_rep_count = @@next_rep_count + 1
      end
    end
    super
  end
  
  def house_speaker?
    representative? && @party == "SPK"
  end
  
  def deputy_house_speaker?
    representative? && @party == "CWM"
  end
  
  def ==(p)
    id == p.id && from_date == p.from_date && to_date == p.to_date &&
      from_why == p.from_why && to_why == p.to_why && division == p.division && party == p.party && house == p.house
  end
end
