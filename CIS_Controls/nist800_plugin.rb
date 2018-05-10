require 'optparse'

# The only difference between auto_enable.rb and nist800_plugin.rb is that
# auto_enable.rb automaticlly tries to add the plugin and nist800_plugin.rb 
# shows you options. However they both and enable and disable NIST800 Chart Plugin


def check_path
  if(File.directory?("#{Dir.pwd()}/public/img/"))
    return true
  else
    puts "\033[31m|!| #{$0} must be ran from Serpico root directory to work! Please cd to correct dir!\033[0m"
    return false
  end
end

def replace_code(search, replace)
  file_names = ["#{Dir.pwd()}/views/findings_edit.haml"]
  file_names.each do |file_name|
    text = File.read(file_name)
    if(text.gsub!(/#{search}/m,replace))
      File.open(file_name, "w") {|file| file.write(text) }
      return true
    else
      puts "\033[31m|!| Failed to load plugin successfully: Did not find code to replace in #{file_name}\033[0m"
      return false
    end
  end
end

options = {}
optionparser = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options] \n\n"\
                "\tExample 1.) ruby #{$0} -e\n"\
                "\tExample 2.) ruby #{$0} -d\n\n"
    opts.on("-e", "--enable", "Enable Plugin") do |e|
        options[:enable] = e
    end
    opts.on("-d", "--disable", "Disable Plugin") do |d|
        options[:disable] = d
    end
    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end

begin
    optionparser.parse!
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
    puts "\n\033[33mERROR: #{$!.to_s}\033[0m\n\n"
    puts optionparser.help
    exit
end

# Method to enable NIST800 chart plugin
def enable
    # Code to replace to get button to show up
    code_to_replace = '- elsif @nist800'
    new_code = <<-CODE2
- elsif @nist800
      .control-group.nist800
        %label.control-label
        .controls
          %a.btn.btn-info{ :href=> "#nist800modal", "data-toggle" => "modal" }
            NIST800-30 Chart
        .modal.modal.hide.fade#nist800modal{ :tabindex => "-1", :role => "dialog", "aria-labelledby" => "modal-label", "aria-hidden" => "true"}
          .modal-header
            %button.close{ :type => "button", "data-dismiss" => "modal", "aria-hidden" => "true" }
              X
            %h3#modal-label
              NIST800-30 Chart
          .modal-body
            %p
              %img{:src => "/img/nist800.png"}
    CODE2
    new_code.chomp! # chomp of newline

  # Check if imaged used in chart is already there
  if File.file?("#{Dir.pwd()}/public/img/nist800.png")
    puts "\033[31m|!| Plugin Already Installed!\033[0m"
    exit
  else
    # Copy image to correct DIR to be used in views
    if File.file?("#{Dir.pwd()}/plugins/NIST800_Chart/nist800.png")
      File.rename("#{Dir.pwd()}/plugins/NIST800_Chart/nist800.png", "#{Dir.pwd()}/public/img/nist800.png")
      # Replace code to add button
      if(replace_code(code_to_replace, new_code))
        puts "\033[32m|+| Loaded plugin successfully!\033[0m"
      else
        exit -1
      end
    else
      puts "\033[31m|!| Failed to load plugin, No NIST800 image found.\033[0m."
      exit -1
    end
  end
end

# Method to disable NIST800 chart plugin
def disable
  if File.file?("#{Dir.pwd()}/public/img/nist800.png")
    File.rename("#{Dir.pwd()}/public/img/nist800.png", "#{Dir.pwd()}/plugins/NIST800_Chart/nist800.png")
    code_to_replace = '- elsif @nist800.*nist800.png"}'
    new_code = '- elsif @nist800'
    if(replace_code(code_to_replace, new_code))
      puts "\033[32m|+| Disabled plugin successfully!\033[0m"
    else
      puts "\033[31m|!| Failed to disable plugin!\033[0m"
    end
  else
    puts "\033[31m|!| Plugin Already Disabled!\033[0m"
    exit
  end
end

if(check_path)
  if(options.empty? || options.length > 1)
    puts optionparser.help
    exit 1
  elsif options[:enable]
    enable
  elsif options[:disable]
    disable
  end
else
  exit -1
end
