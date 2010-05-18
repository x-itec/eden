module Eden
  class Tokenizer
    def initialize( source_file )
      @sf = source_file
    end
      
    def tokenize!
      @i = 0 # Current position in the source buffer
      @ln = 1 # Line Number
      @cp = 0 # Current Character in the line
      @thunk_st = 0
      @thunk_end = -1 # Start/end of the current token
      @current_line = Line.new( @ln )
      
      default_state_transitions!

      until( @i == @sf.source.length )
        case( @state )
        when :newline
          @current_line.tokens << Token.new( :newline, thunk )
          @sf.lines << @current_line
          @ln += 1
          @current_line = Line.new( @ln )
        when :whitespace
          @current_line.tokens << tokenize_whitespace
        when :identifier # keyword / name / etc
          @current_line.tokens << tokenize_identifier
        when :instancevar
        when :classvar
        when :classvar
        when :lparen, :rparen, :lsquare, :rsquare,
          :lcurly, :rcurly
        when :comma
        when :plus, :minus, :equals, :modulo, :multiply, :ampersand, :pipe,
          :caret, :gt, :lt, :colon, :bang, :period
        when :whitespace
        when :comment
        when :single_q_string, :double_q_string, :heredoc_string, :bquote_string
        when :symbol
        when :number
        when :regex
        end
      end
      @sf.lines << @current_line
    end

    private
    
    def thunk
      @sf.source[@thunk_st..@thunk_end]
    end

    def default_state_transitions!
      case( cchar )
      when ' '  then @state = :whitespace
      when '\t' then @state = :whitespace
      when '"'  then @state = :double_q_string
      when '\'' then @state = :single_q_string
      when '`'  then @state = :bquote_string
      when '@'
        if peek_ahead_for( /@/ )
          @state = :classvar
        else
          @state = :instancevar
        end
      when '/'  then @state = :regex
      when '#'  then @state = :comment
      when ','  then @state = :comma
      when '.'  then @state = :period
      when '&'  then @state = :ampersand
      when '|'  then @state = :pipe
      when '>'  then @state = :gt
      when '<'  then @state = :lt
      when '%'  then @state = :modulo
      when '*'  then @state = :multiply
      when '('  then @state = :lparen
      when ')'  then @state = :rparen
      when '{'  then @state = :lcurly
      when '}'  then @state = :rcurly
      when '['  then @state = :lsquare
      when ']'  then @state = :rsquare
      when 'a'..'z', 'A'..'Z', '_'
        @state = :identifier
      when '0'..'9'
        @state = :number
      when '+', '-'
        if peek_ahead_for( /[0-9]/ )
          @state = :number
        else
          @state = @source[@i] == '+' ? :plus : :minus
        end
      end
    end

    # Returns the current character
    def cchar
      @sf.source[@i..@i]
    end

    # Resets the thunk to start at the current character
    def reset_thunk!
      @thunk_st = @i
      @thunk_end = @i - 1
    end

    def peek_ahead_for( regex )
      !!regex.match( @sf.source[@i+1] )
    end
    
    def tokenize_identifier
      until( /[A-Za-z_]/.match( cchar ).nil? )
        @thunk_end += 1; @i += 1
      end
      token = Token.new(:identifier, thunk)
      reset_thunk!
      default_state_transitions!
      return token
    end

    def tokenize_whitespace
      until( cchar != ' ' && cchar != '\t' )
        @thunk_end += 1; @i += 1
      end
      token = Token.new(:whitespace, thunk)
      reset_thunk!
      default_state_transitions!
      return token
    end
  end
end
