require File.dirname(__FILE__) + '/../test_helper'

class EmailerTest < ActionMailer::TestCase
  tests Emailer
  def test_info
    @expected.subject = 'Emailer#info'
    @expected.body    = read_fixture('info')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Emailer.create_info(@expected.date).encoded
  end

  def test_sent
    @expected.subject = 'Emailer#sent'
    @expected.body    = read_fixture('sent')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Emailer.create_sent(@expected.date).encoded
  end

end
