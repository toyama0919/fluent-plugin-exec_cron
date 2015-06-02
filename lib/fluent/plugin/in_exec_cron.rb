module Fluent
  class ExecCronInput < Input
    Plugin.register_input('exec_cron', self)

    def initialize
      super
      require 'fluent/plugin/exec_util'
      require 'fluent/timezone'
      require 'parse-cron'
      require 'erb'
    end

    SUPPORTED_FORMAT = {
      'tsv' => :tsv,
      'json' => :json,
      'msgpack' => :msgpack,
    }

    unless method_defined?(:router)
      define_method("router") { Fluent::Engine }
    end

    config_param :command, :string
    config_param :format, :default => :tsv do |val|
      f = SUPPORTED_FORMAT[val]
      raise ConfigError, "Unsupported format '#{val}'" unless f
      f
    end
    config_param :keys, :default => [] do |val|
      val.split(',')
    end
    config_param :tag, :string, :default => nil
    config_param :tag_key, :string, :default => nil
    config_param :time_key, :string, :default => nil
    config_param :time_format, :string, :default => nil
    config_param :run_interval, :time, :default => nil
    config_param :graceful_shutdown, :bool, :default => true
    config_param :cron, :string

    def configure(conf)
      super

      if localtime = conf['localtime']
        @localtime = true
      elsif utc = conf['utc']
        @localtime = false
      end

      if conf['timezone']
        @timezone = conf['timezone']
        Fluent::Timezone.validate!(@timezone)
      end

      if !@tag && !@tag_key
        raise ConfigError, "'tag' or 'tag_key' option is required on exec input"
      end

      if @time_key
        if @time_format
          f = @time_format
          @time_parse_proc = Proc.new {|str| Time.strptime(str, f).to_i }
        else
          @time_parse_proc = Proc.new {|str| str.to_i }
        end
      end

      case @format
      when :tsv
        if @keys.empty?
          raise ConfigError, "keys option is required on exec input for tsv format"
        end
        @parser = ExecUtil::TSVParser.new(@keys, method(:on_message))
      when :json
        @parser = ExecUtil::JSONParser.new(method(:on_message))
      when :msgpack
        @parser = ExecUtil::MessagePackParser.new(method(:on_message))
      end

      begin
        @cron_parser = CronParser.new(@cron)
      rescue => e
        raise ConfigError, "invalid cron expression. [#{@cron}]"
      end
      @command = ERB.new(@command.gsub(/\$\{([^}]+)\}/, '<%= \1 %>'))
    end

    def start
      @finished = false
      @thread = Thread.new(&method(:run_periodic))
    end

    def shutdown
      @finished = true
      if @graceful_shutdown
        @thread.join
      else
        Thread.kill(@thread)
      end
    end

    def run_periodic
      until @finished
        begin
          secs = @cron_parser.next(Time.now) - Time.now
          sleep secs
          io = IO.popen(@command.result(binding), "r")
          @parser.call(io)
          Process.waitpid(io.pid)
        rescue
          log.error "exec failed to run or shutdown child process", :error => $!.to_s, :error_class => $!.class.to_s
          log.warn_backtrace $!.backtrace
        end
      end
    end

    private

    def on_message(record)
      if val = record.delete(@tag_key)
        tag = val
      else
        tag = @tag
      end

      if val = record.delete(@time_key)
        time = @time_parse_proc.call(val)
      else
        time = Engine.now
      end

      router.emit(tag, time, record)
    rescue => e
      log.error "exec failed to emit", :error => e.to_s, :error_class => e.class.to_s, :tag => tag, :record => Yajl.dump(record)
    end
  end
end
