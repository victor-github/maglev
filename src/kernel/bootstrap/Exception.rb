# Exception is identically Smalltalk class Exception
#
class Exception
    class_primitive 'allocate', 'rubyBasicNew'
    class_primitive '__signal', 'signal:'
    class_primitive_nobridge '__signal', 'signal'

    class_primitive 'install_debug_block&', 'installDebugBlock:'

    # support for errno to Name translation
    class_primitive_nobridge  '__errno_tables', 'errnoTables'
    class_primitive_nobridge  '__errno_to_name', 'errnoToName:'
    class_primitive_nobridge  '__cpu_os_kind', 'cpuOsKind'

    primitive_nobridge '__handler_active' , '_handlerActive'

    primitive_nobridge '__reraise', '_rubyReraise'
    primitive          '__signal', 'signal:'
    primitive_nobridge '__signal', 'signal'
    primitive          '__description', 'description'
    primitive_nobridge '__message=', 'messageText:'
    primitive_nobridge '__st_initialize', 'initialize'

    primitive_nobridge '__basic_dup', '_basicCopy'

    def __message
      m = @_st_gsDetails
      if m._equal?(nil)
        m = __description  # generate Smalltalk message
      end
      if m.frozen?
        # messages encoded by Smalltalk may be frozen,
        # but ruby allows modifications
        unless m._isSymbol
          m = m.dup
        end
      end
      m
    end

    def message
      self.to_s
    end

    def self.__default_ruby_message
      nil
    end

    def __message_append(str)
      m = @_st_messageText
      if m._equal?(nil)
        m = self.message
        if m._equal?(nil)
          @_st_messageText = str.to_s
          return
        end
      end
      m << str.to_s
    end

    # Define this in ruby code so we get the full env1 creation hooks
    def self.exception(msg)
      self.new(msg)
    end

    def self.exception
      self.new
    end

    def self._validate(obj)
      # used in implementation of $! on LHS of assignment
      if (obj._kind_of?(Exception))
        return obj
      else
        raise ArgumentError, 'not an Exception'
      end
    end

    IncludeSmalltalkFrames = false

    def initialize(msg)
      # bridge methods for this variant
      self.__st_initialize  # initialize smalltak instvars
      if msg._equal?(nil)
        msg = self.class.name
      end
      @_st_messageText = msg
    end

    def initialize
      self.__st_initialize  # initialize smalltak instvars
      @_st_messageText = self.class.name
    end

    def initialize(*args)
      self.__st_initialize
      if args.length >= 1
        msg = args[0]
      end
      if msg._equal?(nil)
        msg = self.class.name
      end
      @_st_messageText = msg
    end

    def backtrace(limit = 1000)
      # excludes smalltalk frames from the result
      #  limit defines smalltalk stack depth at which to stop
      @_st_gsStack || Thread.__backtrace(IncludeSmalltalkFrames, limit)
    end

    def backtrace_st(limit = 1000)
      # include smalltalk frames in the result
      #  limit defines smalltalk stack depth at which to stop
      Thread.__backtrace(true, limit)
    end

    def exception(msg = MaglevUndefined)
      if msg._equal?(self) || msg._equal?(MaglevUndefined)
        return self
      end
      e = dup
      e.__message=(msg)
      e
    end

    def inspect
      str = '#<'
      str << self.class.name
      str << ': '
      str << self.message
      str << '>'
      str
    end

    def set_backtrace(array)
      @_st_gsStack = array
    end

    def to_s
      (m = self.__message)._equal?(nil) ? self.class.name : m
    end

    def to_str
      (m = self.__message)._equal?(nil) ? self.class.name : m
    end
end

# open each of the subclasses of Exception that map to
#   a Smalltalk class to initialize the ruby name space
#  order here matches order in  AbstractException(C)>>commentRubyMapping

class SystemExit
  # Smalltalk reimplements initialize
  primitive_nobridge '__st_initialize', 'initialize'

  def status
    @_st_status
  end

  # If a_bool is false, marks this exception as coming from Kernel#exit!
  def run_at_exit_handlers=(a_bool)
    @_st_runAtExitHandlers = a_bool
  end

  def initialize(*args)
    status = if args.first._isFixnum
               args.shift
             else
               0
             end
    super(*args)
    @_st_status = status
  end
end

class SystemStackError
  # stack overflow error
end
class NoMemoryError
   # Smalltalk reimplements initialize
   primitive_nobridge '__st_initialize', 'initialize'
end
class ScriptError
   # Smalltalk reimplements initialize
   primitive_nobridge '__st_initialize', 'initialize'
end
class LoadError  # a subclass of ScriptError
end
class NotImplementedError  # a subclass of ScriptError
end
class SyntaxError  # a subclass of ScriptError
end
class StandardError
end
class ArgumentError
end
class IOError
end
class EOFError  # a subclass of IOError
end
class SocketError  # a subclass of IOError
end
class IndexError
end
class StopIteration # a subclass of IndexError, added in 1.8.7
end
class LocalJumpError
end
class RuntimeError
end
class RangeError
end
class FloatDomainError # a subclass of RangeError
end
class RegexpError
end
class SecurityError
end
class SystemCallError

  def self.exception(msg)
    exc = self.allocate
    exc.__st_initialize
    n = Errno.__errno_for_class(self)
    if n._equal?(nil)
      n = 0
    end
    exc.errno=(n)
    exc.__message=(msg)
    exc
  end

  def self.exception
    exc = self.allocate
    exc.__st_initialize
    n = Errno.__errno_for_class(self)
    if n._equal?(nil)
      n = 0
    end
    exc.errno=(n)
    exc
  end

  def self.new(*args)
    if args.length < 1
      raise ArgumentError, 'too few args'
    end
    argone = args[0]
    argtwo = nil
    errnum = nil
    if argone._isFixnum
      errnum = argone
      msg = nil
    elsif argone._isString
      msg = argone
      if args.length >= 2
        argtwo = args[1]
        if argtwo._isFixnum
          errnum = argtwo
        end
      end
    end
    if errnum._not_equal?(nil)
      exc = Errno.__new_for_errno(errnum)
    end
    if exc._equal?(nil)
      exc = self.allocate
      exc.__st_initialize
      exc.errno=(errnum)
    end
    if msg._equal?(nil)
      exc.__message=('Unknown error')
    else
      exc.__message=(msg)
    end
    exc
  end

  def errno=(errnum)
    @_st_errno = errnum
  end

  def errno
    @_st_errno
  end
end
class ThreadError
end
class TypeError
end
class ZeroDivisionError
end

class NameError
   # Smalltalk reimplements initialize
   primitive_nobridge '__st_initialize', 'initialize'

   def self.new(msg=nil, name=nil)
     exc = super(msg)
     if name._not_equal?(nil)
       exc.name=(name)
     end
     exc
   end
   primitive_nobridge 'name=' , 'name:'
   primitive_nobridge 'name', 'name'

   def inspect
     str = super
     n = self.name
     if n._not_equal?(nil)
       str << ', '
       str << n.to_s
     end
     str
   end
end

class NoMethodError  # a subclass of NameError
   # Smalltalk reimplements initialize
   primitive_nobridge '__st_initialize', 'initialize'

   def __init(selector, args_arr, envid)
     if selector._isSymbol
       @_st_selector = selector
     end
     if args_arr._isArray
       @_st_gsArgs = args_arr
     end
     if envid._isFixnum
       @_st_envId = envid
     end
     self
   end

   def selector
     @_st_selector
   end
   def envid
     @_st_envId
   end
   def args
     a = @_st_gsArgs
     if a._equal?(nil)
       a = []
     end
     a
   end

   def inspect
     str = super
     str << "`" ; str << self.selector.to_s ; str << "' called"
     str
   end

end
class SignalException
end
class Interrupt  # a subclass of SignalException
end

# This was in lib/ruby/1.8/timeout.rb, but class_primitive_nobridge is not
# allowed after boot, so the exception definition was moved here.
#
# class RubyTimeoutError  is defined in the maglev*.mcz
#   RubyTimeoutError deprecated , just use  lib/ruby/1.8/timeout.rb
# RUBY.global("TimeoutError", "RubyTimeoutError")
# class TimeoutError
#  class_primitive_nobridge 'timeout', 'timeout:do:'
# end
Object.__freeze_constants
