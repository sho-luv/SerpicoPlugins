if File.file?("#{Dir.pwd()}/plugins/NIST800_Chart/installed")
    if File.file?("#{Dir.pwd()}/plugins/NIST800_Chart/nist800.png")
      File.rename("#{Dir.pwd()}/plugins/NIST800_Chart/nist800.png", "#{Dir.pwd()}/public/img/nist800.png")
    else
      puts "|!| Failed to locate NIST800 image to use."
      exit
    end

    text_to_replace = '    - elsif @nist800
      .control-group.nist800'

    new_text = '    - elsif @nist800
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
              %img{:src => "/img/nist800.png"}'

    file_names = ["#{Dir.pwd()}/views/create_finding.haml", "#{Dir.pwd()}/views/findings_edit.haml"]
    file_names.each do |file_name|
      text = File.read(file_name)
      File.write(file_name, text.gsub(/text_to_replace/, new_text))
    end
else
	puts "|!| Failed to load NIST800_Chart, see the README for installation instructions."
end
