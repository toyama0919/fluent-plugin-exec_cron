require 'helper'

class ExecCronInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf)
    Fluent::Test::InputTestDriver.new(Fluent::ExecCronInput).configure(conf)
  end

  def test_configure_full
    d = create_driver %q{
      type exec_cron
      tag exec_cron.example
      command echo '{"a":"a"}'
      format json
      cron * * * * *
      graceful_shutdown false
    }

    assert_equal 'exec_cron.example', d.instance.tag
  end

  def test_configure_error_when_config_is_empty
    assert_raise(Fluent::ConfigError) do
      create_driver ''
    end
  end

  def test_configure_error_cron_syntax
    assert_raise(Fluent::ConfigError) do
      create_driver %q{
        tag exec_cron.example
        command echo '{"a":"a"}'
        format json
        cron hogehoge
        graceful_shutdown false
      }
    end
  end

  def test_emit
    d = create_driver %q{
      tag exec_cron.example
      command echo '{"a":"a", "time":"2011-01-02 13:14:15"}'
      format json
      time_key time
      time_format %Y-%m-%d %H:%M:%S
      cron * * * * *
      graceful_shutdown false
    }

    d.run do
      sleep 60
    end

    emits = d.emits
    assert_equal true, emits.length > 0
    assert_equal ["exec_cron.example", Time.parse("2011-01-02 13:14:15").to_i, {"a"=>"a"}], emits[0]
  end
end
