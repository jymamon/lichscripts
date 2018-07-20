=begin
    Local character DRb server

    ;local_lnet --help

    author: Jymamon (gs4-jymamon@hotmail.com)
       game: Gemstone
    version: 2015.06.12.01

    history:
=end

require 'drb'

#SERVER_URI="druby://#{ENV["COMPUTERNAME"]}:20002"
SERVER_URI="druby://localhost:20002"

class Characters
    include DRbUndumped
    attr_reader :character_hash

    def initialize
        @character_hash = Hash.new
    end

    # Causes group members to be accessed and the failures handled so
    # we don't need to do the same in all methods. May be a perf issue
    # and need to be individually inlined later.
    def check
        @character_hash.each_pair { |name,object|
            begin
                if ( "#{name.downcase}"!="#{object.name.downcase}" )
                    @character_hash.delete(name)
                end
            rescue
                @character_hash.delete(name)
            end
        }
        return(true)
    end

    def add_character(character)
        check()

        begin
            @character_hash[character.name().downcase] = character
        rescue
            sleep 0.1
            retry
        end

        return(@party)
    end

    def characters()
        check()
        return(@character_hash.keys)
    end

    def del_character(character_name)
        check()
        @character_hash.delete(character_name.downcase)
        return(@party)
    end

    def members()
        check()
        return(@character_hash)
    end

    def size()
        check()
        return(@character_hash.size)
    end
end

characters = Characters.new
DRb.start_service SERVER_URI, characters

Thread.new {
    pause 10
    characters.check
    characters.members().each{|m| puts "#{m.name} connected"};
}

DRb.thread.join
