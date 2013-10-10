module WelcomesHelper
  def print_val(val)
      ret = ''
      if val.is_a? Hash
          ret += '<ul>'
          val.each_pair do |k, v|
              ret += '<li>' + k.to_s + ': '
              if k == "id"
                  @id = v unless @id
                  ret += print_val(v)
              elsif @connections
                  ret += k
              elsif k == "link"
                  ret += link_to(v, v)
              else
                  @connections = true    if k == "connections"
                  ret += print_val(v) + '</li>'
                  @connections = false if k == "connections"
              end

          end
          ret += '</ul>'
      elsif val.is_a? Array
          ret += '['
          val.each do |v|
              ret += ",<br/>" + print_val(v)
          end
          ret += ']'
      else
          ret += val.to_s
      end
      ret.html_safe
  end
  
end
