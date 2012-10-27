module GData
  class QueryParams < Hash
    @@params_descriptions = {}
    
    #every attribute is nil by default, except
    #:strict => true(default)
    #:q => "keyword"
    #:catetegories => ["Category1", "Category2"]
    #:entry_id => ...
    def validate!
      each do |param, value|
        raise StandardError, "Query parameter '#{param}' is not supported." unless @@params_descriptions.key? param
        description = @@params_descriptions[param]
        case description
        when Array:
            raise StandardError, "Param '#{param}' has to be one of '#{description}'"  unless description.include?(value)
        when Class:
            raise StandardError, "Param '#{param}' has to be instance of class '#{description}'"  unless value.is_a? description
        when :boolean:
            raise StandardError, "Param '#{param}' should be true or false." unless [true, false].include?(value)
        when :date_or_time:
            raise StandardError, "Param '#{param}' should be Date, Time or DateTime."  unless [Date,Time,DateTime].include?(value.class)
        end
      end
    end
    
    def self.describe_params(*params)
      raise ArgumentError, "Invalid query params #{params}" if params.size > 1 && !params[0].is_a?(Hash)
      @@params_descriptions.merge!(params[0])
    end
    
    def to_s
      result = ""
      each do |param, value|
        param_name = param.to_s.gsub('_', '-')
        param_value = value
        description = @@params_descriptions[param]
        case description
        when :date_or_time:
            case value
            when Date:
                param_value = Time.local(value.year, value.month, value.day)
            when DateTime:
                param_value = Time.parse(value.to_s)
            end
          param_value = param_value.iso8601
          param_value = CGI::escape(param_value)
        end
        result += result.empty? ? "?" : "&"
        result += "#{param_name}=#{param_value}"
      end
      result
    end

    describe_params :max_results=>:Integer
  end #QueryParams
end
