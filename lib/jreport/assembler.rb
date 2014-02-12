module Jreport
  class Assembler
    def initialize(report_name)
      @root=`pwd`.chomp
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
          ctrl.instance_eval do 
            @data=fetch_data
            def data
              @data
            end
            @options={}
            def options
              @options
            end
          end
          ctrl.send m
        # then use strl.data to merge data to template
        # then send out email
        rescue=>e
          puts e
        end
      end
      
    end
  end
end