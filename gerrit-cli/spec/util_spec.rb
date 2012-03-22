require 'spec_helper'

require 'gerrit/cli/util'

describe Gerrit::Cli::Util do
  describe '.render_table' do
    it 'should return an empty string if supplied with now rows' do
      Gerrit::Cli::Util.render_table([]).should == ''
    end

    it 'should raise an error if column counts do not match' do
      rows = [[1], [1, 2]]
      expect do
        Gerrit::Cli::Util.render_table(rows)
      end.to raise_error(/column mismatch/i)
    end

    it 'should pad each column to the max. length element' do
      rows = [["a", "bb", "ccc"],
              ["aa", "bbb", "cccc"]]
      table = Gerrit::Cli::Util.render_table(rows)
      expected = "a  bb  ccc \n" \
               + "aa bbb cccc"
      table.should == expected
    end
  end
end
