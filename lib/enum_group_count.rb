# collection, some kind of Enumerable
# opts, a Hash
#   :sort =>
#           :keys [default]    # => by key
#            :keys => :desc     # => by key, descending order
#           :count            # => by occurrence count
#            :count => :asc / :desc  # => by count, and order
#           [proc(k,v)]       # => a block that is evaluated on a key, value pair
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

  # Sorting opt, can be a single Symbol, or a Hash
  sort_option = case opts[:sort]
    when true, nil, :keys
      {:keys => :asc}
    when Symbol # eg :count, or :keys
      { opts[:sort] => :asc }
    else
      opts[:sort]
  end

  # check if sorting by :count
  coll = case sort_option
  when Hash
    count_ord = sort_option.delete(:count)
    keys_ord = sort_option.delete(:keys) == :desc ? :desc : :asc

    raise ArgumentError, "#{sort_option} should contain only :keys and/or :count" unless sort_option.empty?
    coll.sort do |a, b|
      if count_ord && a[1] != b[1] # count_ord is optional
        count_ord == :desc ? b[1] <=> a[1] : a[1] <=> b[1]
      else
        keys_ord == :desc ?  b[0] <=> a[0] : a[0] <=> b[0]
      end
    end
  when false
    # do nothing
    coll
  when Proc
    raise ArgumentError, ":sort proc requires 2 arguments" unless sort_option.arity == 2
    coll.sort_by{|a| [sort_option.call(*a), a[0]] }
  else
    raise ArgumentError, ":sort must be a valid Symbol or Proc, not #{sort_option}"
  end

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
