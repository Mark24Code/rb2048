class Logger
  def initialize(switch)
    @switch = switch
    if @switch == :on
     @output = File.absolute_path("#{__dir__}/../../log")
     @f = File.open("#{@output}/#{Time.now.to_s}.log","w+")
    end
  end

  def log(component, info)
    @f << "[#{component}]: #{Time.now.to_s}: #{info}\n" if @switch == :on
  end

  def close
    @f.close if @switch == :on
  end
end

LoggerMan = Logger.new(:on)

at_exit { LoggerMan.close }
