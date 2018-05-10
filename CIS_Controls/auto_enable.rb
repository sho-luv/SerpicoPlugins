require 'optparse'

def check_path
  if(File.directory?("#{Dir.pwd()}/public/img/"))
    return true
  else
    puts "\033[31m|!| #{$0} must be ran from Serpico root directory to work! Please cd to correct dir!\033[0m"
    return false
  end
end

def replace_code(search, replace, location)
  location.each do |file_name|
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

# Method to enable CIS Controls plugin
def enable
    file_names = ["#{Dir.pwd()}/views/findings_edit.haml"]
    # Code that is searched for as marker
    views_code = '%option #{effort}.*Finding Type'
    # Code that is inserted to add plugin
    new_views = <<-'CODE'
%option #{effort}
    .control-group
      %label.control-label{ :for => "cis_control" } CIS Control
      .controls
        %select{ :name => "cis_control" }
          - settings.cis_control.each do |cis_control|
            - if cis_control == @finding.cis_control
              %option{ :selected => "selected" } #{cis_control}
            - else
              %option #{cis_control}
    .control-group
      %label.control-label{ :for => "type" } Finding Type
    CODE
    new_views.chomp! # chomp of newline

  # Check if imaged used in chart is already there
  # Replace code to add button
  if(replace_code(views_code, new_views, file_names))
    puts "\033[32m|+| Loaded plugin successfully!\033[0m"
  else
    exit -1
  end
end
=begin
# Method to disable NIST800 chart plugin
def disable
  if File.file?("#{Dir.pwd()}/public/img/nist800.png")
    File.rename("#{Dir.pwd()}/public/img/nist800.png", "#{Dir.pwd()}/plugins/NIST800_Chart/nist800.png")
    code_replace = '- elsif @nist800.*nist800.png"}'
    new_code = '- elsif @nist800'
    if(replace_code(code_replace, new_code))
      puts "\033[32m|+| Disabled plugin successfully!\033[0m"
    else
      puts "\033[31m|!| Failed to disable plugin!\033[0m"
    end
  else
    puts "\033[31m|!| Plugin Already Disabled!\033[0m"
    exit
  end
end
=end
if(check_path)
  if(options.empty? || options.length > 1)
    enable
  elsif options[:enable]
    enable
  elsif options[:disable]
    disable
  end
else
  exit -1
end
