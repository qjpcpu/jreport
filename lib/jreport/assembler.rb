# -*- coding: UTF-8 -*-
require 'erubis'
require 'premailer'
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
            attr_accessor :data,:save_to
          end
          ctrl.data=fetch_data
          # initialize a mail object
          mail=Mail.new
          ctrl.send m,mail
          dir="#{@root}/views/#{@_report}"
          html=render_html(dir,m.to_s,:data=>ctrl.data,:attachments=>mail.attachments)
		      File.open(ctrl.save_to,'w'){|fi| fi.write(html) } if ctrl.save_to
          # send out report
          if mail.html_part
              mail.html_part.body=html
          else
              mail.body=html
          end
	  send_mail(mail)
        rescue=>e
          puts e
          puts e.backtrace
        end
      end
      
    end
    
    def render_html(dir,report_name,bindings)
      base="#{dir}/#{report_name}"
      html=Erubis::Eruby.new(File.read("#{base}.eruby")).result(bindings)
      if File.exist?("#{base}.css")
  		css=File.read "#{base}.css"
		p=Premailer.new(html,:with_html_string=>true,:css_string=>css)
  		html=p.to_inline_css
      end
      html
    end
    def send_mail(mail)
	lost=mail.from.nil? ? 'from' : mail.to.nil? ? 'to' : mail.subject.nil? ? 'subject' : nil
	if  lost
		puts "Mail '#{lost}' empty, mail wouldn't be sent!"
		return
	end
	mail.deliver!
	puts "Mail sent!"
    end    
  end
end
