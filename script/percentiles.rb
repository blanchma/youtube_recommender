def percentiles(field)
  percentages = (1..100).collect {|i| i.to_f/100}
  # all_scores = Video.connection.select_values "select #{field} from videos where (#{field} > 0 and #{field} < 1) order by #{field}"
  all_scores = Video.connection.select_values "select #{field} from videos order by #{field}"
  steps = {}
  puts '{'
  percentages.each do |p|
    v = perc(all_scores, p)
    puts "#{v} => #{p},"
    steps[v] = p
  end
  puts '}'
  puts "done"
  steps
end

def perc(ary, p)
  ary[(p * ary.length).ceil - 1]
end