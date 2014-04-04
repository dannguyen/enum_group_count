# collection, some kind of Enumerable
# opts, a Hash
#   :sort =>
#           :key [default]    # => by key
#           :count/:frequency            # => by occurrence count
#           [proc(k,v)]       # => a block that is evaluated on a key, value pair
#   :order =>
#           :asc [default]    # => ascending order
#           :desc/:reverse    # => reversed order
#
#   :hash =>
#           false [default]   # => returns an Array
#           true              # => returns a Hash, after the sort
#
#
# group_by_blk, a block that is evaluated on each member of the Array
#
#

# returns:
#  default: An Array sorted by key (e.g. a[0]) in ascending order
def enum_group_count(collection, opts={}, &group_by_blk)
  raise ArgumentError, "Collection must be an Enumerable" unless collection.class.include?Enumerable



  # grouping opt
  group_proc = block_given? ? group_by_blk : ->(v){ v }

  coll = case opts[:count]
  when false
  # rare option: basically, act like Enumerable#group_by
    collection.group_by(&group_proc)
  else
  # default behavior, the enum's value will be the count of members

    collection.inject(Hash.new{|h,k| h[k] = 0}) do |h, val|
      key = group_proc.call(val)
      h[key] += 1

      h
    end
  end

  # Sorting opt
  sort_opt =  opts[:sort]

  # TODO
  # if sort_opt.is_a?(Hash)
  #   # no change
  # else
  #   sort_opt = Array(sort_opt)
  # end

  coll = case sort_opt
    when nil, true, :key
      coll.sort{|a, b| a[0] <=> b[0] }
    when :count, :size, :frequency
      coll.sort_by{|a| a.reverse }
    when Proc
      raise ArgumentError, ":sort proc requires 2 arguments" unless sort_opt.arity == 2
      coll.sort_by{|a| [sort_opt.call(*a), a[0]] }
    when false
      coll
    else
      raise ArgumentError, ":sort must be a valid Symbol or Proc, not #{sort_opt}"
    end

  # Ordering opt (i.e. reverse or not to reverse)
  # actions are done in place
  # TK: take out
  # order_opt = opts[:order]
  # case order_opt
  # when nil, :asc # no change
  #   coll
  # when :desc, :reverse # reverse, in place
  #   coll.reverse!
  # else
  #   raise ArgumentError, ":order must be :asc, :desc/:reverse, not #{order_opt}"
  # end


  # return type
  as_opt = opts[:as].to_s
    coll = case as_opt
    when '', 'hash', 'Hash'
      coll.is_a?(Hash) ? coll : Hash[coll]
    when 'array', 'Array'
      coll.is_a?(Array) ? coll : Array[coll]
    else
      raise ArgumentError, ":as must be Hash or Array, not #{as_opt}"
    end

  return coll
end
