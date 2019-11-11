def solve(problem)
  exc_cands = Array.new(LENGTH, [])
  cands =  Array.new(LENGTH, [])
  assigned = false
  until assigned do
    LENGTH.times do |i|
      if problem[i] == 0
        cands[i] =  NUMBERS - problem.values_at(*SAME_INDEXES[i])
      else
        cands[i] = []
      end
    end
    LENGTH.times do |i|
      if problem[i] == 0 && cands[i].size != 1
        [SAME_ROW_INDEXES[i]-[i], SAME_COL_INDEXES[i]-[i], SAME_BLOCK_INDEXES[i]-[i]].each do |indexes|
          cand = cands[i] - cands.values_at(*indexes).flatten
          if cand.size == 1
            cands[i] = cand
            next
          end
        end
      end
    end
    LENGTH.times do |i|
      problem[i] = cands[i][0] if cands[i].size == 1
    end
    assigned = !cands.any? { |cand| cand.size == 1 }
  end
  while cands.any? { |cand| !cand.empty? } do
    est_cand = cands.map.with_index{ |cand, i| [i, cand[0], cand.size] }.sort_by{ |arr| [(arr[2] == 0 ?  ONESIDE_LENGTH + 1 : arr[2]), arr[0]] }[0]
    next_problem = problem.dup
    next_problem[est_cand[0]] = est_cand[1]
    next_problem = solve(next_problem)
    if next_problem
      problem = next_problem
    else
      exc_cands[est_cand[0]] << est_cand[1]
    end
    LENGTH.times do |i|
      cands[i] = problem[i] == 0 ? NUMBERS - problem.values_at(*SAME_INDEXES[i]) - exc_cands[i] : []
    end
    LENGTH.times do |i|
      if problem[i] == 0 && cands[i].size != 1
        [SAME_ROW_INDEXES[i]-[i], SAME_COL_INDEXES[i]-[i], SAME_BLOCK_INDEXES[i]-[i]].each do |indexes|
          cand = cands[i] - cands.values_at(*indexes).flatten
          if cand.size == 1
            cands[i] = cand
            next
          end
        end
      end
    end
  end
  ROW_NUMBERS.each do |i|
    return nil unless (NUMBERS - problem.values_at(*SAME_ROW_INDEXES[i])).empty?
  end
  COL_NUMBERS.each do |i|
    return nil unless (NUMBERS - problem.values_at(*SAME_COL_INDEXES[i])).empty?
  end
  BLOCK_NUMBERS.each do |i|
    return nil unless (NUMBERS - problem.values_at(*SAME_BLOCK_INDEXES[i])).empty?
  end
  problem
end

start_at = Time.now
argv = ARGV.shift
data = File.open(argv).each_char.map(&:chomp).reject(&:empty?).join
problem = data.each_char.each_slice((data.length > 81 ? 2 : 1)).map { |a| a.join.to_i }

LENGTH = problem.length
ONESIDE_LENGTH = Math.sqrt(LENGTH).to_i
BLOCK_LENGTH = Math.sqrt(ONESIDE_LENGTH).to_i
NUMBERS = [*1..ONESIDE_LENGTH]
ROW_NUMBERS = Array.new(ONESIDE_LENGTH) {|i| i * ONESIDE_LENGTH }
COL_NUMBERS = [*0..(ONESIDE_LENGTH - 1)]
BLOCK_NUMBERS = Array.new(ONESIDE_LENGTH) {|i| i * BLOCK_LENGTH + i / BLOCK_LENGTH * (ONESIDE_LENGTH * (BLOCK_LENGTH - 1))}
ROW_START_INDEXES = Array.new(LENGTH) {|i| i / ONESIDE_LENGTH * ONESIDE_LENGTH }
COL_START_INDEXES = Array.new(LENGTH) {|i| i % ONESIDE_LENGTH }
BLOCK_START_INDEXES = Array.new(LENGTH) do |i|
  ((i / (ONESIDE_LENGTH * BLOCK_LENGTH)) * (ONESIDE_LENGTH * BLOCK_LENGTH)) + ((i % ONESIDE_LENGTH) / BLOCK_LENGTH) * BLOCK_LENGTH
end
SAME_ROW_INDEXES = Array.new(LENGTH) do |i|
  [*ROW_START_INDEXES[i]..(ROW_START_INDEXES[i]+ONESIDE_LENGTH-1)]
end
SAME_COL_INDEXES = Array.new(LENGTH) do |i|
  Array.new(ONESIDE_LENGTH) do |j|
    j * ONESIDE_LENGTH + COL_START_INDEXES[i]
  end
end
SAME_BLOCK_INDEXES = Array.new(LENGTH) do |i|
  Array.new(ONESIDE_LENGTH) do |j|
    j / BLOCK_LENGTH * ONESIDE_LENGTH + BLOCK_START_INDEXES[i] + j % BLOCK_LENGTH
  end
end
SAME_INDEXES = Array.new(LENGTH) {|i| SAME_ROW_INDEXES[i] + SAME_COL_INDEXES[i] + SAME_BLOCK_INDEXES[i] }

solution = solve(problem.dup)
end_at = Time.now
print Array.new(BLOCK_LENGTH) {
  Array.new(BLOCK_LENGTH * (ONESIDE_LENGTH.to_s.length + 1) + 1) { "-" }.join
}.join("-")[1..-2] + "\n"
LENGTH.times do |i|
  print "\e[30;47;1m" if problem[i] != 0
  print (solution[i] != 0 ? "%0*d" % [ONESIDE_LENGTH.to_s.length, solution[i]] : "\e[37;41;1m ") + "\e[m"
  if i % ONESIDE_LENGTH == (ONESIDE_LENGTH-1)
    print "\n"
  elsif i % (BLOCK_LENGTH) == (BLOCK_LENGTH-1)
    print " | "
  else
    print " "
  end
  if i % (BLOCK_LENGTH * ONESIDE_LENGTH) == (BLOCK_LENGTH * ONESIDE_LENGTH - 1) && i != (LENGTH - 1)
    print Array.new(BLOCK_LENGTH) {
      Array.new(BLOCK_LENGTH * (ONESIDE_LENGTH.to_s.length + 1) + 1) { "-" }.join
    }.join("+")[1..-2] + "\n"
  end
end
print Array.new(BLOCK_LENGTH) {
  Array.new(BLOCK_LENGTH * (ONESIDE_LENGTH.to_s.length + 1) + 1) { "-" }.join
}.join("-")[1..-2] + "\n"
print "#{(end_at - start_at).floor(6)} SECOND\n"
