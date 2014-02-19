# -*- coding: UTF-8 -*-
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
      ctrl_klas=Kernel.const_get(controller)
      mtds=ctrl_klas.instance_methods(false).grep /_report$/
      mtds.each do |m|
        begin
          ctrl=ctrl_klas.new
          class << ctrl
            attr_accessor :data,:options,:save_to
          end
          ctrl.data,ctrl.options=fetch_data,{}
          ctrl.send m
          dir="#{@root}/views/#{@_report}"
          html=render_html(dir,m.to_s,:data=>ctrl.data)
          puts "Below is content body\n#{'-'*20}"
          puts html
          `echo "#{html}" > "#{ctrl.save_to}"` if ctrl.save_to
          ops=ctrl.options.merge!('body'=>html,'content-type'=>"text/html;charset=UTF-8")
          puts "Sending email for #{m}..."
	  if ctrl.respond_to? :send_mail
	    ctrl.send :send_mail,ops
	  else
	    puts "Send with default mailer"
            send_mail ops
	  end
        rescue=>e
          puts e
          puts e.backtrace
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
      begin
        m=Mail.new do
          from    options['from']
          to      options['to']
          subject options['subject']
          html_part do
            body options['body']
            content_type options['content-type']
          end
 	  if options['files']
	    options.split(';').each{|f| add_file f }
	  end	  
        end
        m.deliver!
	puts 'Sent!'
      rescue=>e
        puts "Send mail faild!"
        puts e.backtrace
      end
    end
    
  end
end
