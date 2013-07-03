require 'cora'
require 'siri_objects'
require 'pp'

require 'httparty'
require 'json'
require 'rubygems'
gem 'net-ssh'
require 'net/ssh'

#######
# This is a "hello world" style plugin. It simply intercepts the phrase "test siri proxy" and responds
# with a message about the proxy being up and running (along with a couple other core features). This
# is good base code for other plugins.
#
# Remember to add other plugins to the "config.yml" file if you create them!
######

class SiriProxy::Plugin::Example < SiriProxy::Plugin
  def initialize(config)
      
      #if you have custom configuration options, process them here!
      @imac_ip_adress = config["imac_ip_adress"]
      @imac_ssh_user_name = config["imac_ssh_user_name"]
      @imac_ssh_password = config["imac_ssh_password"]
      
      @macbookpro_ip_adress = config["macbookpro_ip_adress"]
      @macbookpro_ssh_user_name = config["macbookpro_ssh_user_name"]
      @macbookpro_ssh_password = config["macbookpro_ssh_password"]
  end
    
listen_for /mac open iTunes/i do
    Net::SSH.start( @macbookpro_ip_adress, @macbookpro_ssh_user_name, :password => @macbookpro_ssh_password ) do|ssh|
        #out =
        ssh.exec!("osascript -e 'tell application \"iTunes\" to play'")
        #        puts out
    end
      say "right zooz i open Itunes, you are my boss"
end

listen_for /mac ouvre iTunes/i do
    Net::SSH.start( @macbookpro_ip_adress, @macbookpro_ssh_user_name, :password => @macbookpro_ssh_password ) do|ssh|
        #out =
        ssh.exec!("osascript -e 'tell application \"iTunes\" to play'")
        #        puts out
    end
    say "ok zooz, je démmarre iTunes"
end


listen_for /mac ferme iTunes/i do
Net::SSH.start( @macbookpro_ip_adress, @macbookpro_ssh_user_name, :password => @macbookpro_ssh_password ) do|ssh|    
    ssh.exec!("osascript -e 'tell application \"iTunes\" to quit'")
        end
    say "iTunes close"
end


listen_for /mac down itunes /i do
    say "itunes down"
    Net::SSH.start( @macbookpro_ip_adress, @macbookpro_ssh_user_name, :password => @macbookpro_ssh_password ) do|ssh|    ssh.exec!("osascript -e 'tell application \"iTunes\" to next track'")
    end
end

listen_for /mac up itunes /i do
    say "itunes up"
Net::SSH.start( @macbookpro_ip_adress, @macbookpro_ssh_user_name, :password => @macbookpro_ssh_password ) do|ssh|    ssh.exec!("osascript -e 'tell application \"iTunes\" to previous track'")
        end
end
listen_for /mac stop itunes /i do
    say "itunes pause"
Net::SSH.start( @macbookpro_ip_adress, @macbookpro_ssh_user_name, :password => @macbookpro_ssh_password ) do|ssh|        ssh.exec!("osascript -e 'tell application \"iTunes\" to pause'")
end
    end


  listen_for /test siri proxy/i do
    say "Siri Proxy is up and running!" #say something to the user!

    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  #Demonstrate that you can have Siri say one thing and write another"!
  listen_for /you don't say/i do
    say "Sometimes I don't write what I say", spoken: "Sometimes I don't say what I write"
  end

  #demonstrate state change
  listen_for /siri proxy test state/i do
    set_state :some_state #set a state... this is useful when you want to change how you respond after certain conditions are met!
    say "I set the state, try saying 'confirm state change'"

    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  listen_for /confirm state change/i, within_state: :some_state do #this only gets processed if you're within the :some_state state!
    say "State change works fine!"
    set_state nil #clear out the state!

    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  #demonstrate asking a question
  listen_for /siri proxy test question/i do
    response = ask "Is this thing working?" #ask the user for something

    if(response =~ /yes/i) #process their response
      say "Great!"
    else
      say "You could have just said 'yes'!"
    end

    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  #demonstrate capturing data from the user (e.x. "Siri proxy number 15")
  listen_for /siri proxy number ([0-9,]*[0-9])/i do |number|
    say "Detected number: #{number}"

    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  #demonstrate injection of more complex objects without shortcut methods.
  listen_for /test map/i do
    add_views = SiriAddViews.new
    add_views.make_root(last_ref_id)
    map_snippet = SiriMapItemSnippet.new
    map_snippet.items << SiriMapItem.new
    utterance = SiriAssistantUtteranceView.new("Testing map injection!")
    add_views.views << utterance
    add_views.views << map_snippet

    #you can also do "send_object object, target: :guzzoni" in order to send an object to guzzoni
    send_object add_views #send_object takes a hash or a SiriObject object

    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end
end
