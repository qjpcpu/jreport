require 'erubis'
require 'inline-style'
require 'mail'

module Jreport
  class Assembler
    def initialize(report_name)
      @root=`pwd`.chomp
      @_report=report_name
      @report=report_name.split('_').map{|x| x.capitalize}.join
    end
    def fetch_data
      collector="#{@report}Collector"
      raise "Can't find #{collector}" unless Kernel.const_get(collector)
      Kernel.const_get(collector).new.fetch_data
    end
    def make_report
      controller="#{@report}Controller"
      raise "Can't find #{controller}" unless Kernel.const_defined?(controller)
      ctrl_klas=Kernel.const_get(controller)
      mtds=ctrl_klas.instance_methods(false).grep /_report$/
      mtds.each do |m|
        begin
          ctrl=ctrl_klas.new
          fd=fetch_data
          ctrl.instance_eval do 
            @data=fd
            def data
              @data
            end
            @options={}
            def options
              @options
            end
          end
          ctrl.send m
          dir="#{@root}/views/#{@_report}"
          html=render_html(dir,m.to_s,:data=>ctrl.data)
          puts "Below is content body\n#{'-'*20}"
          puts html
          ops=ctrl.options.merge('body'=>html,'content-type'=>"text/html;charset=UTF-8")
          send_mail ops
        rescue=>e
          puts e
        end
      end
      
    end
    
    def render_html(dir,report_name,bindings)
      base="#{dir}/#{report_name}"
      html=Erubis::Eruby.new(File.read("#{base}.eruby")).result(bindings)
  		if File.exist? "#{base}.css"
  			css=File.read "#{base}.css"
  			html<<%Q{<style type="text/css" media="screen">#{css}</style>}
  			html=InlineStyle.process(html)
  		end
  		html
    end
    
    def send_mail(options)
      m=Mail.new do
        from    options['from']
        to      options['to']
        subject options['subject']
        html_part do
          body options['body']
          content_type options['content-type']
        end
        add_file options['file']
      end
      m.deliver
    end
    
  end
end