module Gerrit
  module Cli
  end
end

module Gerrit::Cli::Util
  class << self
    def render_table(rows, opts={})
      return "" if rows.empty?

      max_col_lengths = []
      rows.first.length.times { max_col_lengths << 0 }

      # Compute maximum length of each column
      rows.each do |row|
        if row.length != max_col_lengths.length
          raise ArgumentError, "Column mismatch"
        end

        row.each_with_index do |c, ii|
          len = c.to_s.length
          if len> max_col_lengths[ii]
            max_col_lengths[ii] = len
          end
        end
      end

      delim = opts[:delimiter] || ' '
      row_format = max_col_lengths.map {|len| "%-#{len}s" }.join(delim)

      rows.map {|row| row_format % row }.join("\n")
    end
  end
end
